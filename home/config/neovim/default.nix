{ inputs, pkgs, lib, ... }:

let 
  buildGrammar = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/tools/parsing/tree-sitter/grammar.nix" {};

  genAttrs' = values: f: with lib; listToAttrs (map (v: nameValuePair (f v) v) values);
  grammars = with lib;
    genAttrs' pkgs.vimPlugins.nvim-treesitter.withAllGrammars.passthru.dependencies
    (v: replaceStrings ["vimplugin-treesitter-grammar-"] ["tree-sitter-"] v.name);

  parserDir = with lib;
    pkgs.linkFarm
    "treesitter-parsers"
    (mapAttrsToList
      (n: v:
      let name = "${replaceStrings ["-"] ["_"] (removePrefix "tree-sitter-" n)}.so"; in {
        inherit name;
        path =
          # nvim-treesitter's grammars are inside a "parser" directory, which sucks
          if hasPrefix "vimplugin-treesitter" v.name
          then "${v}/parser/${name}"
          else "${v}/parser";
      })
     grammars);
in
{
  programs.neovim = {
    enable   = true;
    viAlias  = true;
    vimAlias = true;
    plugins  = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
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
    "nvim/parser" = {
      source = "${parserDir}"; recursive = true;
    };
  };
}
