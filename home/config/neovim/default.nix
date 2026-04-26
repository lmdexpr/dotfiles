{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    plugins = [ ];
    extraPackages = with pkgs; [
      gcc
      cargo
      gnumake
    ];

    defaultEditor = true;
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua" = {
      source = ./nvim/lua;
      recursive = true;
    };
    "nvim/after" = {
      source = ./nvim/after;
      recursive = true;
    };
  };
}
