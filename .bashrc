# .bashrc

export PATH="$PATH:$HOME/.local/bin"

PS1='\u: \[\033[01;32m\]\W\[\033[00m\] => '

# Custom aliases
alias v="nvim"
alias py="python3.13"
alias ll="ls -alFhg"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc


eval "$(uv generate-shell-completion bash)"
eval "$(uvx --generate-shell-completion bash)"
