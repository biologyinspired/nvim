return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- LSP Package Manager
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'saadparwaiz1/cmp_luasnip',
        -- Snippets
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
    },
    config = function()
	-- Advertise cmp Capabilities to LSP
        local lspconfig_defaults = require('lspconfig').util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lspconfig_defaults.capabilities,
            require('cmp_nvim_lsp').default_capabilities()
        )
	-- Install & Attach Servers
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                "lua_ls",
                "pyright",
                -- "r_language_server", seems broken for now... not sure why
                -- "groovyls",
                -- "html",
                -- "cssls",
                -- "gdscript",
                -- "rust_analyzer"
            },
            handlers = {
                function(server_name)
                    if server_name == "lua_ls" then return end -- avoid starting with {}
                    require('lspconfig')[server_name].setup({})
                end,
                lua_ls = function()
                    require('lspconfig').lua_ls.setup({
                        settings = {
                            Lua = {
                                runtime = { version = 'LuaJIT' },
                                diagnostics = { globals = { 'vim' } },
                                workspace = { library = { vim.env.VIMRUNTIME } },
                            },
                        },
                    })
                end,
            },
        })
        -- LSP-Active Only Keymaps
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = { buffer = event.buf }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
        })
        -- Floating Window Borders
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
            vim.lsp.handlers.hover,
            { border = 'rounded' }
        )
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            { border = 'rounded' }
        )
        -- Configure Error/Warnings Interface
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = {
                style = 'minimal',
                border = 'rounded',
                header = '',
                prefix = '',
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN] = '▲',
                    [vim.diagnostic.severity.HINT] = '⚑',
                    [vim.diagnostic.severity.INFO] = '»',
                },
            },
        })
	-- Snippets + Completion Plumbing
        local cmp = require('cmp')
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
        cmp.setup({
            -- Snippet Engine Hook
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            -- Completion Behavior and UI
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            formatting = {
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local n = entry.source.name
                    if n == 'nvim_lsp' then
                        item.menu = '[LSP]'
                    else
                        item.menu = string.format('[%s]', n)
                    end
                    return item
                end,
            },
            -- Sources
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'luasnip' },
            },
            -- Key Mapping
            mapping = cmp.mapping.preset.insert({
                -- Accept Selected Suggestion (Tab)
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = false })
                    else
                        fallback() -- do normal Tab action
                    end
                end, { 'i', 's' }),
                
                -- Cycle Through Auto-Complete Suggestions
                ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = 'select' })
                    else
                        fallback() -- normal newline
                    end
                end),

                -- Scroll Documentation Window Up/Down (Ctrl + u/f)
                ['<C-f>'] = cmp.mapping.scroll_docs(5),
                ['<C-u>'] = cmp.mapping.scroll_docs(-5),

                -- Toggle Completion Menu (Ctrl + e)
                ['<C-e>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end),

                -- Navigate to Next Snippet Placeholder (Ctrl + d)
--                ['<C-d>'] = cmp.mapping(function(fallback)
--                    local luasnip = require('luasnip')
--
--                    if luasnip.jumpable(1) then
--                        luasnip.jump(1)
--                    else
--                        fallback()
--                    end
--                end, { 'i', 's' }),

                -- Navigate to Previous Snippet Placeholder (Ctrl + b)
--                ['<C-b>'] = cmp.mapping(function(fallback)
--                    local luasnip = require('luasnip')
--
--                    if luasnip.jumpable(-1) then
--                        luasnip.jump(-1)
--                    else
--                        fallback()
--                    end
--                end, { 'i', 's' }),
            }),
        })
    end
}
