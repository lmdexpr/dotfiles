#!/bin/bash

export XDG_CONFIG_HOME=$HOME/.config
mkdir -p $XDG_CONFIG_HOME

if [ "$(uname)" == 'Darwin' ]; then
  # Mac OS X
  install-cmd = "brew install"
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  if [[ `uname -r` =~ ARCH$ ]]; then
    # ArchLinux
    install-cmd = "sudo pacman -S"
  else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
  fi
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

eval $install-cmd git neovim wezterm

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

ln -s $(pwd)/zshrc $HOME/.zshrc
ln -s $(pwd)/zpreztorc $HOME/.zpreztorc
ln -s $(pwd)/gitconfig $HOME/.gitconfig
ln -s $(pwd)/sbclrc $HOME/.sbclrc
ln -s $(pwd)/config/nvim $XDG_CONFIG_HOME/nvim
ln -s $(pwd)/config/wezterm $XDG_CONFIG_HOME/wezterm
