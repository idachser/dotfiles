# Neovim Config

Minimal Neovim setup focused on LSP, completion, and formatting.
Uses nvim-treesitter's **`main`** branch.

---

### Requirements

Neovim **0.12.0 or later** — required by the `main` branch of nvim-treesitter.

Install system dependencies:

```bash
git
curl
unzip
python3
pip
node (npm)
cargo
```

---

### Installation

```bash
git clone <repo> ~/.config/nvim
nvim
```

After startup:

```vim
:Mason
```

Ensure all tools are installed.

---

### Components

#### UI

* brogrammer (colorscheme)
* lualine
* transparent.nvim

#### Editing

* autopairs
* highlight-colors
* indent-blankline (ibl)
* mini.indentscope

#### Syntax Highlighting

* nvim-treesitter (`main` branch)
* parsers installed on startup via `require("nvim-treesitter").install(...)`
* update them with `:TSUpdate`

Languages:
c, go, lua, vim, javascript, html, python, json, typescript, markdown, xml, yaml

---

### LSP

Managed with:

* mason.nvim
* nvim-lspconfig
* mason-tool-installer

Servers:

* clangd
* gopls
* pyright
* ts_ls
* cssls
* html
* lua_ls
* yamlls

Additional tools:

* ruff
* sqruff

---

### Formatting

Handled by conform.nvim.

Auto-format on save (except C/C++).

Examples:

* lua → stylua
* python → ruff (fix, format, imports)
* go → gofumpt, golines, goimports
* javascript → prettier
* yaml → yamlfix

Manual format:

```vim
<leader>f
```

---

### Completion

* blink.cmp
* LuaSnip
* friendly-snippets

Sources:

* LSP
* snippets
* path

---

### Notes

* uses the `main` branch of nvim-treesitter, which needs Neovim 0.12+
* mason requires system tools (e.g. `unzip`)
* some tools are installed via pip/npm/cargo

---

