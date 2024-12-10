{  pkgs, ... }:

{
  programs.neovim = {
    enable   = true;
    viAlias  = true;
    vimAlias = true;
    # plugins  = with pkgs.vimPlugins; [
    #   nvim-treesitter.withAllGrammars
    # ];
    extraPackages = with pkgs; [ gcc ];
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
