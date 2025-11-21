return {
    'nvim-treesitter/nvim-treesitter',
    name = 'treesitter',
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
	local configs = require("nvim-treesitter.configs")
	configs.setup({
	    highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	    },
	    indent = { enable = true },
	    autotage = { enable = true },
	    ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"markdown",
		"markdown_inline",
		"r",
		"python",
		"bash",
		"css"
	    },
	    sync_install = false,
	    auto_install = true,
	})
    end
}
