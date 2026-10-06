return {
  "ajatdarojat45/commitmate.nvim",
  cmd = { "CommitMate", "CommitMateConfig" },
  keys = {
    { "<leader>gc", "<cmd>CommitMate<cr>", desc = "Generate Commit Message (CommitMate)" },
  },
  opts = {
    provider = "copilot",
    auto_stage = true,
  },
}
