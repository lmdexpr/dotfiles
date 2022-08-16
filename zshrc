#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# OPAM configuration
. /home/yuki/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

export XDG_CONFIG_HOME=$HOME/.config
export RLWRAP_COMMAND=`which rlwrap`

# Aliases
alias cls='clear;ls'

alias vim='nvim'

alias zshrc="nvim $HOME/.zshrc"
alias nvimrc="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias plugins="nvim $HOME/.dein.toml"
alias plugins_lazy="nvim $HOME/.dein_lazy.toml"

alias reload="source $HOME/.zshrc"

alias ocaml="$RLWRAP_COMMAND ocaml"
alias ocamltter="$RLWRAP_COMMAND ocamltter"

alias scheme="$RLWRAP_COMMAND scheme"
alias gosh="$RLWRAP_COMMAND gosh"

