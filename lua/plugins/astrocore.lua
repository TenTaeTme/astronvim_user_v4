-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        matchup_matchparen_nomode = "i", -- set mode to not match parenthesis in matchup
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        ["<C-.>"] = {
          "<Cmd>ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open vertical Terminal",
        },
        ["<C-,>"] = {
          "<Cmd>2ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open second vertical Terminal",
        },
        ["<C-/>"] = {
          "<Cmd>ToggleTerm size=150 direction=vertical<CR>",
          desc = "Increase size of vertical Terminal",
        },
        ["gi"] = {
          "gI",
          desc = "go to implementation",
        },
        -- packagejson config manager
        ["<Leader>ns"] = {
          function() require("package-info").show() end,
          desc = "show info package",
        },
        ["<Leader>np"] = {
          function() require("package-info").change_version() end,
          desc = "change version package json",
        },
        ["<Leader>nd"] = {
          function() require("package-info").delete() end,
          desc = "delete version package json",
        },
        ["<Leader>ni"] = {
          function() require("package-info").install() end,
          desc = "install version package json",
        },
        ["<Leader>fd"] = {
          function() require("telescope.builtin").lsp_definitions { jump_type = "never" } end,
          desc = "lsp definitions",
        },
        ["<Leader>aa"] = { "ggyG", desc = "Copy whole buffer" },
        ["<Leader>ac"] = { "ggdG", desc = "Cut whole buffer" },
        ["<Leader>pp"] = { '"0p', desc = "Put from 0 register" },
        ["<C-u>"] = { "<C-u>zz", desc = "Up and center" },
        ["<C-d>"] = { "<C-d>zz", desc = "Down and center" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command

        ["<Leader>w"] = { ":w!<cr>", desc = "Save File" }, -- change description but the same command
        ["<Leader>q"] = { "::wall|qa!<cr>", desc = "Save all and quit" }, -- change description but the same command
        -- navigate buffer tabs with `H` and `L`
        L = {
          function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
          desc = "Next buffer",
        },
        H = {
          function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
          desc = "Previous buffer",
        },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
      },
      i = {

        ["<C-.>"] = {
          "<Cmd>ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open vertical Terminal",
        },
        ["<C-,>"] = {
          "<Cmd>2ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open second vertical Terminal",
        },
        ["<C-/>"] = {
          "<Cmd>ToggleTerm size=150 direction=vertical<CR>",
          desc = "Increase size of vertical Terminal",
        },
      },
      t = {
        ["<C-.>"] = {
          "<Cmd>ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open vertical Terminal",
        },
        ["<C-,>"] = {
          "<Cmd>2ToggleTerm size=60 direction=vertical<CR>",
          desc = "Open second vertical Terminal",
        },
        ["<C-/>"] = {
          "<Cmd>ToggleTerm size=150 direction=vertical<CR>",
          desc = "Increase size of vertical Terminal",
        },
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
    },
  },
}
