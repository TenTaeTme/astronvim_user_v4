-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.api.nvim_create_augroup("neotree", {})
vim.api.nvim_create_autocmd("UiEnter", {
  desc = "Open Neotree automatically",
  group = "neotree",
  callback = function()
    if vim.fn.argc() == 0 then vim.cmd "Neotree toggle" end
  end,
})

-- Set filetype to php.html for .php files on buffer read and new file creation
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.php",
  callback = function() vim.bo.filetype = "php.html" end,
})
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-t>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
-- Assuming the Lua module is named 'curl_command_runner.lua' and stored in '~/.config/nvim/lua/'
vim.api.nvim_set_keymap(
  "n",
  "<C-c>",
  '<cmd>lua require("curl_command_runner").run_curl_command()<CR>',
  { noremap = true, silent = true }
)
-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}
