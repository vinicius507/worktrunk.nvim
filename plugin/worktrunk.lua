-- worktrunk.nvim - User commands and keymaps

vim.api.nvim_create_user_command("Worktree", function(opts)
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute(opts.args)
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    require("worktrunk")._ensure_initialized()
    return require("worktrunk.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "Worktrunk worktree management",
})

-- Define <Plug> mappings for user keymaps
vim.keymap.set("n", "<Plug>(WorktreeList)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("list")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeSwitch)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("switch")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeRemove)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("remove")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeHooks)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("hooks")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeCurrent)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("current")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeMerge)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("merge")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeStep)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("step")
end, { silent = true })
