local M = {}

local template_dir = vim.fn.stdpath("config") .. "/templates"
local scratch_data_root = vim.fn.stdpath("data") .. "/scratch"

local function load_templates()
  local templates = {}
  if vim.fn.isdirectory(template_dir) == 0 then
    return templates
  end
  for _, name in ipairs(vim.fn.readdir(template_dir)) do
    local ft = vim.fn.fnamemodify(name, ":r") -- stem as ft key: "typescript.ts" -> "typescript"
    local path = template_dir .. "/" .. name
    templates[ft] = table.concat(vim.fn.readfile(path), "\n")
  end
  return templates
end

M.templates = load_templates()

local markers = {
  { file = "go.mod",       ft = "go" },
  { file = "Cargo.toml",   ft = "rust" },
  { file = "package.json", ft = "typescript" },
  { file = "build.zig",    ft = "zig" },
}

local ft_ext = {
  go = "go", python = "py", typescript = "ts", javascript = "js",
  rust = "rs", zig = "zig", c = "c", cpp = "cpp", lua = "lua",
}

-- Creates a go.mod + go.work in scratch_dir so gopls loads the project module
-- alongside the scratch module. Overwrites go.work on every open so it stays
-- in sync if the user switches projects.
local function setup_go_workspace(scratch_dir, project_root)
  local go_version = "1.21"
  local modfile = io.open(project_root .. "/go.mod", "r")
  if modfile then
    for line in modfile:lines() do
      local v = line:match("^go%s+(%S+)")
      if v then go_version = v; break end
    end
    modfile:close()
  end

  if vim.fn.filereadable(scratch_dir .. "/go.mod") == 0 then
    local f = io.open(scratch_dir .. "/go.mod", "w")
    if f then
      f:write("module scratch\n\ngo " .. go_version .. "\n")
      f:close()
    end
  end

  local wf = io.open(scratch_dir .. "/go.work", "w")
  if wf then
    wf:write("go " .. go_version .. "\n\nuse .\nuse " .. project_root .. "\n")
    wf:close()
  end
end

function M.open_for_cwd()
  local cwd = vim.fn.getcwd()

  -- step 1: detect ft — prefer current buffer, fall back to cwd marker
  local ft = nil
  if vim.bo.buftype == "" and vim.bo.filetype ~= "" then
    ft = vim.bo.filetype
  end
  if not ft then
    for _, m in ipairs(markers) do
      if vim.fs.find(m.file, { upward = true, path = cwd })[1] then
        ft = m.ft
        break
      end
    end
  end
  ft = ft or "markdown"

  -- step 2: find project root for this ft
  local project_root = nil
  for _, m in ipairs(markers) do
    if m.ft == ft then
      local found = vim.fs.find(m.file, { upward = true, path = cwd })[1]
      if found then
        project_root = vim.fn.fnamemodify(found, ":h")
      end
      break
    end
  end

  -- step 3: place scratch file in a stable per-project hash dir under stdpath("data")
  local scratch_opts = { ft = ft, template = M.templates[ft] }
  if project_root and ft_ext[ft] then
    local hash = vim.fn.sha256(project_root .. "|" .. ft):sub(1, 8)
    local scratch_dir = scratch_data_root .. "/" .. hash
    vim.fn.mkdir(scratch_dir, "p")
    if ft == "go" then
      setup_go_workspace(scratch_dir, project_root)
    end
    scratch_opts.file = scratch_dir .. "/main." .. ft_ext[ft]
  end

  Snacks.scratch.open(scratch_opts)
end

function M.pick_template()
  local fts = vim.tbl_keys(M.templates)
  table.sort(fts)
  vim.ui.select(fts, { prompt = "Scratch template" }, function(choice)
    if not choice then
      return
    end
    Snacks.scratch.open({ ft = choice, template = M.templates[choice] })
  end)
end

-- Error parsers

local function file_line_errors(stderr, tmpfile)
  local diagnostics = {}
  for lnum, msg in stderr:gmatch(vim.pesc(tmpfile) .. ":(%d+):%d+: ([^\n]+)") do
    table.insert(diagnostics, {
      col = 0,
      lnum = tonumber(lnum) - 1,
      message = msg,
      severity = vim.diagnostic.severity.ERROR,
    })
  end
  return diagnostics
end

local function python_errors(stderr, tmpfile)
  local diagnostics = {}
  for lnum in stderr:gmatch('File "' .. vim.pesc(tmpfile) .. '", line (%d+)') do
    local msg = stderr:match("[%w]+Error: ([^\n]+)") or "error"
    table.insert(diagnostics, {
      col = 0,
      lnum = tonumber(lnum) - 1,
      message = msg,
      severity = vim.diagnostic.severity.ERROR,
    })
  end
  return diagnostics
end

-- Runner factory
--
-- get_tmpfile(ext, buf) returns (path, cleanup_fn, run_cwd|nil).
-- run_cwd is passed as cwd to vim.system — nil means inherit.

local function default_tmpfile(ext, _buf)
  local path = vim.fn.tempname() .. "." .. ext
  return path, function()
    os.remove(path)
  end, nil
end

-- For Go scratch buffers backed by a go.work workspace: the buffer file IS the
-- source file, so no copy is needed. Return it directly with a no-op cleanup
-- and the scratch dir as cwd so `go run .` resolves the workspace.
local function go_tmpfile(_ext, buf)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local scratch_dir = vim.fn.fnamemodify(buf_name, ":h")
  return buf_name, function() end, scratch_dir
end

local function make_runner(ext, get_cmd, parse_errors, get_tmpfile)
  parse_errors = parse_errors or file_line_errors
  get_tmpfile = get_tmpfile or default_tmpfile
  return function(self)
    local buf = self.buf
    local ns = vim.api.nvim_create_namespace("snacks_scratch_run")

    local function reset()
      vim.diagnostic.reset(ns, buf)
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
    reset()

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      group = vim.api.nvim_create_augroup("snacks_scratch_run_" .. buf, { clear = true }),
      buffer = buf,
      callback = reset,
    })

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local tmpfile, cleanup, run_cwd = get_tmpfile(ext, buf)
    if tmpfile == vim.api.nvim_buf_get_name(buf) then
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
    else
      local fd = io.open(tmpfile, "w")
      if not fd then
        return
      end
      fd:write(table.concat(lines, "\n"))
      fd:close()
    end

    vim.system(get_cmd(tmpfile), { cwd = run_cwd }, function(result)
      vim.schedule(function()
        cleanup()
        if result.code ~= 0 then
          local stderr = result.stderr or ""
          local diags = parse_errors(stderr, tmpfile)
          if #diags > 0 then
            vim.diagnostic.set(ns, buf, diags)
          end
          Snacks.notify.error(stderr ~= "" and stderr or (result.stdout or ""), { title = "Run" })
        else
          local stdout = result.stdout or ""
          if stdout == "" then
            return
          end
          local virt_lines = {}
          for _, line in ipairs(vim.split(vim.trim(stdout), "\n", { plain = true })) do
            table.insert(virt_lines, { { "  │ ", "SnacksDebugIndent" }, { line, "SnacksDebugPrint" } })
          end
          local last_line = vim.api.nvim_buf_line_count(buf) - 1
          vim.api.nvim_buf_set_extmark(buf, ns, last_line, 0, { virt_lines = virt_lines })
        end
      end)
    end)
  end
end

-- Compile + run via shell for languages that produce a binary.
local function compile_run(src_ext, compiler)
  return make_runner(src_ext, function(f)
    local out = vim.fn.tempname()
    return {
      "sh",
      "-c",
      ("%s %s -o %s && %s; rm -f %s"):format(
        compiler,
        vim.fn.shellescape(f),
        vim.fn.shellescape(out),
        vim.fn.shellescape(out),
        vim.fn.shellescape(out)
      ),
    }
  end)
end

M.runners = {
  go = make_runner("go", function(f)
    local dir = vim.fn.fnamemodify(f, ":h")
    if vim.fn.filereadable(dir .. "/go.work") == 1 then
      return { "go", "run", "." }
    end
    return { "go", "run", f }
  end, nil, go_tmpfile),
  python = make_runner("py", function(f)
    return { "python3", f }
  end, python_errors),
  javascript = make_runner("js", function(f)
    return { "node", f }
  end),
  typescript = make_runner("ts", function(f)
    return { "npx", "tsx", f }
  end),
  zig = make_runner("zig", function(f)
    return { "zig", "run", f }
  end),
  rust = compile_run("rs", "rustc"),
  c = compile_run("c", "cc"),
  cpp = compile_run("cpp", "c++"),
}

function M.win_by_ft()
  local by_ft = {}
  for ft, runner in pairs(M.runners) do
    by_ft[ft] = {
      keys = { ["run"] = { "<cr>", runner, desc = "Run buffer", mode = { "n", "x" } } },
    }
  end
  return by_ft
end

return M
