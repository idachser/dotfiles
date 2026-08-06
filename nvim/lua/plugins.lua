return {
	--- Theme -------------------------------------------------------------------
	{
		"marciomazza/vim-brogrammer-theme",
		name = "brogrammer",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme brogrammer")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		options = { theme = "auto" },
	},
	{
		"xiyaowong/transparent.nvim",
	},

	--- Code --------------------------------------------------------------------
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		{ "brenoprata10/nvim-highlight-colors", opts = {} },
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "LazyVim", words = { "LazyVim" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
				{ path = "lazy.nvim", words = { "LazyVim" } },
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})

			vim.schedule(function()
				require("nvim-treesitter").install({
					"c",
					"go",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"html",
					"python",
					"json",
					"typescript",
					"markdown",
					"markdown_inline",
					"xml",
					"yaml",
				})
			end)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "*" },
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
	{ "echasnovski/mini.indentscope", version = "*", opts = { symbol = "│" } },

	--- LSP -------------------------------------------------------------------
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						vim.keymap.set("n", "<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, { buffer = event.buf, desc = "[T]oggle Inlay [H]ints" })
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts

			vim.o.updatetime = 2000 -- 2 sec holding coursor to open diagnostic popup window
			vim.diagnostic.config({
				severity_sort = true,
				update_in_insert = false,
				float = {
					float = {
						style = "minimal",
					},
					border = "solid",
					source = true,
					header = "",
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				},
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 1,
					prefix = "● ",
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = "󰅚 " .. diagnostic.message,
							[vim.diagnostic.severity.WARN] = "󰀪 " .. diagnostic.message,
							[vim.diagnostic.severity.INFO] = "󰋽 " .. diagnostic.message,
							[vim.diagnostic.severity.HINT] = "󰌶 " .. diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})
			local diag_float_group = vim.api.nvim_create_augroup("DiagnosticFloatHover", {})

			vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
				group = diag_float_group,
				callback = function()
					vim.diagnostic.open_float(nil, {
						scope = "cursor",
						float = {
							style = "minimal",
						},
						source = true,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						focus_id = "cursor-diagnostics",
					})
				end,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
				group = diag_float_group,
				callback = function()
					vim.cmd("pclose")
				end,
			})

			-- blink.cmp only adds its own capabilities here; Neovim merges them
			-- with the client defaults when the server starts.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities({}, false),
			})

			--  additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			local servers = {
				clangd = {},
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
							gofumpt = true,
						},
					},
				},
				pyright = {
					settings = {
						pyright = {
							-- Using Ruff's import organizer
							disableOrganizeImports = true,
						},
						python = {
							analysis = {
								-- Ignore all files for analysis to exclusively use Ruff for linting
								ignore = { "*" },
							},
						},
					},
				},
				ruff = {},
				sqruff = {},
				ts_ls = {},
				cssls = {},
				html = {},
				marksman = {},
				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- ignore Lua_LS's noisy `missing-fields` warnings
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},
				yamlls = {},
			}

			-- to check the current status of installed tools run :Mason
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"gofumpt",
				"golines",
				"goimports",
				"stylua",
				"ruff",
				"prettier",
				"eslint",
				"yamlfix",
				"markdownlint-cli2",
				"markdown-toc",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- Merge our overrides on top of the defaults nvim-lspconfig ships in
			-- its `lsp/` directory. Only values set above are overridden.
			for server_name, server_opts in pairs(servers) do
				if not vim.tbl_isempty(server_opts) then
					vim.lsp.config(server_name, server_opts)
				end
			end

			-- Installed servers are enabled automatically via `vim.lsp.enable()`;
			-- mason-tool-installer above handles installing them.
			require("mason-lspconfig").setup({
				ensure_installed = {},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				c = { "clang-format" },
				go = {
					"gofumpt",
					"golines",
					"goimports",
				},
				cpp = { "clang-format" },
				lua = { "stylua" },
				python = {
					-- To fix auto-fixable lint errors.
					"ruff_fix",
					-- To run the Ruff formatter.
					"ruff_format",
					-- To organize the imports.
					"ruff_organize_imports",
				},
				javascript = { "prettier" },
				yaml = { "yamlfix" },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				-- `:help ins-completion`
				--
				-- All presets have the following mappings:
				-- <tab>/<s-tab>: move to right/left of your snippet expansion
				-- <c-space>: Open menu or open docs if already open
				-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
				-- <c-e>: Hide menu
				-- <c-k>: Toggle signature help
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				preset = "enter",
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true },
		},
	},
	{ -- Markdown Render
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			completions = {
				blink = { enabled = true },
				lsp = { enabled = true },
			},
		},
	},
}
