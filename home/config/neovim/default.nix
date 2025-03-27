{  pkgs, ... }:

{
  programs.neovim = {
    enable   = true;
    viAlias  = true;
    vimAlias = true;
    plugins  = with pkgs.vimPlugins; [
      # avante-nvim
      # nvim-treesitter.withAllGrammars
    ];
    extraPackages = with pkgs; [ 
      gcc 
      cargo
      gnumake
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua" = {
      source = ./nvim/lua; recursive = true;
    };
    "nvim/snippet" = {
      source = ./nvim/snippet; recursive = true;
    };
  };
}
