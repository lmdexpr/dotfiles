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

    defaultEditor = true;
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua"     = { source = ./nvim/lua; recursive = true; };
    "nvim/after"   = { source = ./nvim/after; recursive = true; };
  };
}
