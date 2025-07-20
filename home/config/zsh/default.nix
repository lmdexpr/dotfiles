{ lib, ... }:

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

    setOptions = [
      "AUTO_CD"
    ];
  };

  programs.starship = {
    enable = true;

    settings = {
      format = lib.strings.concatStrings [
        "$status" "$time" "$cmd_duration" "$line_break"
        "$all" "$line_break"
        "$character"
      ];

      status = {
        disabled = false;
        success_symbol = "🟢";
        format = "[$symbol]($style) ";
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
        style = "bold blue";
      };

      time = {
        disabled = false;
        format = "at [$time]($style) ";
      };

      kubernates.disabled = false;
      direnv.disabled = false;

      git_branch.symbol = " ";
      git_status.style = "bold purple";
    };
  };
}
