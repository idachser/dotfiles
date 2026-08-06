# dotfiles
--- 

Configuration files for:
- [kitty.term](https://sw.kovidgoyal.net/kitty/);
- [tmux](https://tmux.info/);
- [nvim](https://neovim.io/).

## Install

```bash
./install.sh --dry-run   # preview
./install.sh             # create the symlinks
```

Currently links `nvim` only; kitty and tmux are still copied by hand.
Anything already at a target path is moved to `<target>.backup.<timestamp>`.
