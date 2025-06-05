# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS dotfiles repository using Nix flakes for declarative system and home configuration management. The repository supports multiple machine configurations with different desktop environments and user profiles.

## Architecture

### Core Structure
- `flake.nix`: Entry point defining system configurations for different machines
- `machine/`: Machine-specific configurations (svartalfaheimr, fenrir, skelton)
- `home/`: Home-manager configurations with two profiles:
  - `cui/`: CLI-focused environment 
  - `plasma6/`: KDE Plasma desktop environment
- `os/`: Base operating system configurations
  - `nixos-cli/`: Minimal CLI-only NixOS setup
  - `nixos-plasma/`: Full desktop environment with KDE Plasma 6
- `modules/`: Custom NixOS modules and services

### Configuration Mapping
- `svartalfaheimr`: CLI machine using `cui` home profile
- `fenrir`: Desktop machine using `plasma6` home profile  
- `skelton`: WSL machine using `cui` home profile with NixOS-WSL integration

### Home Configuration Components
Both home profiles import modular configurations from `home/config/`:
- `zsh/`: Shell configuration with prezto
- `git/`: Git configuration  
- `neovim/`: Neovim editor setup with custom plugins
- `wezterm/`: Terminal emulator (plasma6 profile only)

## Common Commands

### System Management
```sh
# Apply NixOS configuration changes
sudo nixos-rebuild switch --flake '.#' --show-trace

# Apply home-manager configuration changes  
home-manager switch --flake '.#'

# Update flake inputs
nix flake update

# Build specific machine configuration (without applying)
nixos-rebuild build --flake '.#hostname'
```

### Development Workflow
```sh
# Check flake syntax and evaluation
nix flake check

# Show flake outputs
nix flake show

# Enter development shell with build tools
nix develop

# Garbage collect old generations
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

## Configuration Notes

- All machines use flakes with experimental features enabled
- Home-manager is integrated as a NixOS module, not standalone
- The `skelton` machine includes NixOS-WSL for Windows Subsystem for Linux
- Docker is configured with rootless mode on all systems
- Input method support (fcitx5) is configured for Japanese input