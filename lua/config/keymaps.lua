-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" }) -- vim: ts=2 sts=2 sw=2 et
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u", "<C-u>zz")
vim.keymap.set("n", "Q", "<nop>", { remap = true })
vim.keymap.set("n", "q", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dd", [["_dd]], { desc = "Delete noreg" })
vim.keymap.set("v", "<leader>dd", [["_d]], { desc = "Delete visual noreg" })

-- substitute
vim.keymap.set("n", "s", require("substitute").operator, { desc = "substitute", noremap = true })
vim.keymap.set("n", "ss", require("substitute").line, { desc = "substitute line", noremap = true })
vim.keymap.set("n", "S", require("substitute").eol, { desc = "substitute eol", noremap = true })
vim.keymap.set("x", "s", require("substitute").visual, { desc = "substitute visual", noremap = true })
vim.keymap.set("n", "sx", require("substitute.exchange").operator, { desc = "substitute exchange", noremap = true })
vim.keymap.set("n", "sxx", require("substitute.exchange").line, { desc = "substitute exchange line", noremap = true })
vim.keymap.set("x", "X", require("substitute.exchange").visual, { desc = "substitute exchange visual", noremap = true })
vim.keymap.set(
  "n",
  "sxc",
  require("substitute.exchange").cancel,
  { desc = "substitute exchange cancel", noremap = true }
)

-- Runs 'go mod tidy' and shows live progress via Snacks notifier
vim.keymap.set("n", "<leader>ct", function()
  local Job = require("plenary.job")

  Snacks.notify("running go mod tidy...", {
    id = "go-mod-tidy",
    title = "Go",
    level = vim.log.levels.INFO,
    timeout = false,
  })

  Job:new({
    command = "go",
    args = { "mod", "tidy" },
    cwd = vim.fn.expand("%:p:h"),
    on_exit = function(_, return_val)
      vim.schedule(function()
        if return_val == 0 then
          Snacks.notify("go mod tidy completed", {
            id = "go-mod-tidy",
            title = "Go",
            level = vim.log.levels.INFO,
          })
        else
          Snacks.notify("go mod tidy failed", {
            id = "go-mod-tidy",
            title = "Go",
            level = vim.log.levels.ERROR,
          })
        end
      end)
    end,
  }):start()
end, { desc = "Run go mod tidy", silent = true })

-- Go: fill struct fields and activate snippet tab-stops over the values
local function fill_struct_snippet()
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  if #clients == 0 then
    vim.notify("fill_struct: gopls not attached", vim.log.levels.WARN)
    return
  end
  local client = clients[1]

  -- Stage 1: find the composite_literal at the cursor before any edits.
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local parser = vim.treesitter.get_parser(bufnr, "go")
  local node = parser:parse()[1]:root():named_descendant_for_range(row, col, row, col)
  while node and node:type() ~= "composite_literal" do
    node = node:parent()
  end
  if not node then
    vim.notify("fill_struct: no composite literal at cursor", vim.log.levels.WARN)
    return
  end

  -- Record the byte position of the opening { so we can re-locate the struct
  -- after gopls rewrites it across multiple lines.
  local anchor_row, anchor_col
  for child in node:iter_children() do
    if child:type() == "literal_value" then
      anchor_row, anchor_col = child:range()
      break
    end
  end
  if not anchor_row then
    return
  end

  -- Stage 2: ask gopls for the fillStruct code action.
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "refactor.rewrite.fillStruct" }, diagnostics = {} }

  client:request("textDocument/codeAction", params, function(err, result)
    if err or not result or #result == 0 then
      vim.notify("fill_struct: no action available (struct may be fully filled)", vim.log.levels.INFO)
      return
    end

    local action
    for _, a in ipairs(result) do
      if a.kind == "refactor.rewrite.fillStruct" then
        action = a
        break
      end
    end
    if not action then
      return
    end

    -- Stage 3: apply the workspace edit, then rebuild as a snippet.
    local function snippetize(edit)
      vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)

      -- vim.schedule defers until after the buffer change is settled so
      -- treesitter can reparse the new content cleanly.
      vim.schedule(function()
        local p = vim.treesitter.get_parser(bufnr, "go")
        local n = p:parse()[1]:root():named_descendant_for_range(anchor_row, anchor_col, anchor_row, anchor_col + 1)
        while n and n:type() ~= "composite_literal" do
          n = n:parent()
        end
        if not n then
          vim.notify("fill_struct: could not re-locate struct after fill", vim.log.levels.WARN)
          return
        end

        local lv
        for child in n:iter_children() do
          if child:type() == "literal_value" then
            lv = child
            break
          end
        end
        if not lv then
          return
        end

        -- Stage 4: collect keyed_element field/value pairs.
        local fields = {}
        for i = 0, lv:named_child_count() - 1 do
          local ke = lv:named_child(i)
          if ke and ke:type() == "keyed_element" then
            local key_n, val_n = ke:named_child(0), ke:named_child(1)
            if key_n and val_n then
              table.insert(fields, {
                key = vim.treesitter.get_node_text(key_n, bufnr),
                val = vim.treesitter.get_node_text(val_n, bufnr),
              })
            end
          end
        end
        if #fields == 0 then
          return
        end

        -- Infer indentation from the closing-brace line so the rebuilt
        -- snippet matches the surrounding code style exactly.
        local sr, sc, er, ec = lv:range()
        local close_line = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, false)[1] or ""
        local struct_indent = close_line:match("^(%s*)") or ""
        local field_indent = struct_indent .. "\t"

        -- Build snippet content to fill INSIDE the existing braces. The '{' and '}'
        -- from the literal_value stay in the buffer; only the interior is replaced.
        -- This lets cursor_pos() land on '}' in normal mode so vim.snippet.expand
        -- inserts before it — no startinsert! or InsertEnter needed.
        local parts = {}
        for i, f in ipairs(fields) do
          local escaped = f.val:gsub("\\", "\\\\"):gsub("%$", "\\$"):gsub("}", "\\}")
          parts[#parts + 1] = ("%s%s: ${%d:%s},"):format(field_indent, f.key, i, escaped)
        end
        local snippet = "\n" .. table.concat(parts, "\n") .. "\n" .. struct_indent

        -- Keep the outer '{' and '}'; delete only the interior (sc+1 to ec-1).
        vim.api.nvim_buf_set_text(bufnr, sr, sc + 1, er, ec - 1, {})
        -- After deletion, '}' is at column sc+1 — a valid normal-mode cursor position.
        vim.api.nvim_win_set_cursor(0, { sr + 1, sc + 1 })
        vim.snippet.expand(snippet)
      end)
    end

    if action.edit then
      snippetize(action.edit)
    elseif action.data then
      -- Some gopls actions are lazy and need a resolve round-trip first.
      client:request("codeAction/resolve", action, function(_, resolved)
        if resolved and resolved.edit then
          snippetize(resolved.edit)
        end
      end)
    end
  end, bufnr)
end

local function register_fill_struct(buf)
  vim.keymap.set("n", "<leader>cv", fill_struct_snippet, {
    buffer = buf,
    desc = "Fill struct with snippet tab-stops",
  })
end

-- LspAttach fires after gopls connects, well after VeryLazy loads this file.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("go_fill_struct", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "gopls" then
      register_fill_struct(ev.buf)
    end
  end,
})

-- Cover any Go buffers that already had gopls attached before this file loaded.
for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
  for buf in pairs(client.attached_buffers) do
    register_fill_struct(buf)
  end
end
