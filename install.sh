#!/bin/bash

export XDG_CONFIG_HOME=$HOME/.config
mkdir -p $XDG_CONFIG_HOME

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git neovim
brew install wezterm htop broot bat rg

ln -s $(pwd)/zshrc $HOME/.zshrc
ln -s $(pwd)/zpreztorc $HOME/.zpreztorc
ln -s $(pwd)/gitconfig $HOME/.gitconfig
ln -s $(pwd)/sbclrc $HOME/.sbclrc

ln -s $(pwd)/config/nvim $XDG_CONFIG_HOME/nvim
ln -s $(pwd)/config/wezterm $XDG_CONFIG_HOME/wezterm
