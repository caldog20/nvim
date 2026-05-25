return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 2048,
    opts = {
      options = {
        -- Manage overflow by wrapping to multiple lines
        overflow = {
          mode = "wrap",
        },
      },
    },
  },
}
