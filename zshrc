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

export DOTNET_TOOLS_PATH=$HOME/.dotnet/tools
export PATH=$PATH:$DOTNET_TOOLS_PATH

export CARGO_PATH=$HOME/.cargo/bin
export PATH=$PATH:$CARGO_PATH

export NPM_PATH=`npm prefix --location=global`/bin
export PATH=$PATH:$NPM_PATH

# Aliases
alias cls='clear;ls'

alias vim='nvim'

alias zshrc="nvim $HOME/.zshrc"
alias nvimrc="nvim $XDG_CONFIG_HOME/nvim/init.lua"
alias plugins="nvim $XDG_CONFIG_HOME/nvim/lua/plugins.lua"

alias reload="source $HOME/.zshrc"

alias ocaml="$RLWRAP_COMMAND ocaml"

alias scheme="$RLWRAP_COMMAND scheme"
alias gosh="$RLWRAP_COMMAND gosh"
