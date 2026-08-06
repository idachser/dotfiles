#!/usr/bin/env bash
#
# Symlink dotfiles into place.
#
# Usage:
#   ./install.sh            # link everything
#   ./install.sh --dry-run  # show what would happen, change nothing
#
# An existing target that is not already the right symlink is moved aside to
# <target>.backup.<timestamp> rather than deleted.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0

usage() {
    cat <<'EOF'
Symlink dotfiles into place.

Usage:
  ./install.sh            link everything
  ./install.sh --dry-run  show what would happen, change nothing

An existing target that is not already the right symlink is moved aside to
<target>.backup.<timestamp> rather than deleted.
EOF
}

log() { printf '%s\n' "$*"; }
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log "  would run: $*"
    else
        "$@"
    fi
}

# link <source-in-repo> <target-path>
link() {
    local src="$DOTFILES/$1" dst="$2"

    if [ ! -e "$src" ]; then
        log "!! $1: missing in repo, skipped"
        return 1
    fi

    # -L before -e: a symlink pointing nowhere is still something we must move.
    if [ -L "$dst" ]; then
        if [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
            log "== $dst -> $1 (already linked)"
            return 0
        fi
        log ":: $dst is a symlink to $(readlink "$dst")"
        run mv -- "$dst" "$dst.backup.$STAMP"
        log "   backed up to $dst.backup.$STAMP"
    elif [ -e "$dst" ]; then
        log ":: $dst exists"
        run mv -- "$dst" "$dst.backup.$STAMP"
        log "   backed up to $dst.backup.$STAMP"
    fi

    run mkdir -p -- "$(dirname "$dst")"
    run ln -s -- "$src" "$dst"
    log "-> $dst -> $1"
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n | --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            log "unknown option: $1"
            usage
            exit 2
            ;;
    esac
done

[ "$DRY_RUN" -eq 1 ] && log "(dry run — nothing will be changed)"

link nvim "$CONFIG_HOME/nvim"
# Only kitty.conf: the rest of ~/.config/kitty (current-theme.conf and the
# *.auto.conf files kitty generates) is not tracked here, so linking the whole
# directory would break the `include current-theme.conf` at the bottom.
link kitty.conf "$CONFIG_HOME/kitty/kitty.conf"
link .tmux.conf "$HOME/.tmux.conf"

log "done."
