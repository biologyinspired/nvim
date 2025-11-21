local function enable_transparency()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end
return {
    {
	"rose-pine/neovim",
	name = "rose-pine",
	lazy = false, -- load during startup
	priority = 1000, -- load before all other start plugins
	config = function()
	    -- load colorscheme
	    require("rose-pine").setup({
		variant = "auto",
		dark_variant = "moon",
		styles = {
		    italic = false,
		    transparency = true,
		}
	    })
	    vim.cmd.colorscheme "rose-pine"
	    enable_transparency()
	end
    },
    {
	"nvim-lualine/lualine.nvim",
	name = "lualine",
	dependencies = {
	    "nvim-tree/nvim-web-devicons",
	},
	opts = {
	    theme = "rose-pine",
	}
    },
}
