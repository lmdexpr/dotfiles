{ ... }:

{
  programs.zsh = {
    enable = true;

    shellAliases = {
      cls = "clear;ls";
      reload="source $HOME/.zshrc";
      k = "kubectl";
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

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1300;
      scan_timeout = 50;
      format = "$all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };
}
