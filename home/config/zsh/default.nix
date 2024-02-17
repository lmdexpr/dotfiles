{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    shellAliases = {
      cls = "clear;ls";
      reload="source $HOME/.zshrc";
    };

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
        "prompt"
        "completion"
      ];
      editor.keymap = "vi";
      git.submoduleIgnore = "all";
      prompt.theme = "paradox";
    };

    envExtra = ''
      export XDG_CONFIG_HOME=$HOME/.config
      export GOPATH=$HOME/go
      export PATH=$PATH:$GOPATH/bin
      export DOTNET_TOOLS_PATH=$HOME/.dotnet/tools
      export PATH=$PATH:$DOTNET_TOOLS_PATH
      export CARGO_PATH=$HOME/.cargo/bin
      export PATH=$PATH:$CARGO_PATH
      export NPM_PATH=`npm prefix --location=global`/bin
      export PATH=$PATH:$NPM_PATH
    '';
  };
}
