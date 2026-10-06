return {
  "barrett-ruth/live-server.nvim",
  build = "pnpm add -g live-server",
  config = true,
  cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
  keys = {
    { "<leader>ls", "<cmd>LiveServerToggle<cr>", desc = "Toggle Live Server" },
  },
}
