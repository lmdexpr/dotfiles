{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];

    prezto = {
      enable = true;
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "git"
        "utility"
        "syntax-highlighting"
        "autosuggestions"
        "nix"
        "nix-shell"
        "prompt"
        "completion"
      ];
      editor.keymap = "vi";
      git.submoduleIgnore = "all";
      prompt.theme = "paradox";
    };
  };

  home.file.".zshrc".source = ./zshrc;
}
