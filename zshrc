# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

export XDG_CONFIG_HOME=$HOME/.config
export RLWRAP_COMMAND=`which rlwrap`

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Aliases
alias cls='clear;ls'

alias vim='nvim'

alias zshrc="nvim $HOME/.zshrc"
alias nvimrc="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias plugins="nvim $XDG_CONFIG_HOME/nvim/dein.toml"
alias plugins_lazy="nvim $XDG_CONFIG_HOME/nvim/dein_lazy.toml"

alias reload="source $HOME/.zshrc"

alias ocaml="$RLWRAP_COMMAND ocaml"
alias ocamltter="$RLWRAP_COMMAND ocamltter"

alias scheme="$RLWRAP_COMMAND scheme"
alias gosh="$RLWRAP_COMMAND gosh"
