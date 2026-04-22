# Neovim Config

Minimal Neovim setup focused on LSP, completion, and formatting.
Uses **stable treesitter** (`master` branch).

---

### Requirements

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

* nvim-treesitter (`master` branch)
* parsers installed via `:TSUpdate`

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

* uses stable treesitter (`master`)
* mason requires system tools (e.g. `unzip`)
* some tools are installed via pip/npm/cargo

---

