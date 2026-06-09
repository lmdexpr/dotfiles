{ lib, ... }:

{
  programs.zsh = {
    enable = true;
    
    shellAliases = {
      cls = "clear;ls";
      reload="source $HOME/.zshrc";
      k = "kubectl";
    };

    initContent = ''
      bindkey -v
    '';

    envExtra = ''
      export XDG_CONFIG_HOME=$HOME/.config
      export TMUX_TMPDIR="''${XDG_RUNTIME_DIR:-/tmp}"
      export GOPATH=$HOME/go
      export PATH=$PATH:$GOPATH/bin
      export DOTNET_TOOLS_PATH=$HOME/.dotnet/tools
      export PATH=$PATH:$DOTNET_TOOLS_PATH
      export CARGO_PATH=$HOME/.cargo/bin
      export PATH=$PATH:$CARGO_PATH
      export NPM_PATH=`npm prefix --location=global`/bin
      export PATH=$PATH:$NPM_PATH

      export EDITOR=nvim
    '';

    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
      "AUTO_CD"
    ];
  };

  programs.starship = {
    enable = true;

    settings = {
      format = lib.strings.concatStrings [
        "$cmd_duration" "$all" "$line_break"
        "$character"
      ];

      cmd_duration = {
        format = "took [$duration]($style)\n";
        style = "bold blue";
      };

      direnv.disabled = false;

      aws.symbol = " ";
      aws.region_aliases.ap-northeast-1 = "jp";

      buf.symbol = " ";

      bun.symbol = " ";

      c.symbol = " ";

      cpp.symbol = " ";

      cmake.symbol = " ";

      conda.symbol = " ";

      crystal.symbol = " ";

      dart.symbol = " ";

      deno.symbol = " ";

      directory.read_only = " 󰌾";

      docker_context.symbol = " ";

      elixir.symbol = " ";

      elm.symbol = " ";

      fennel.symbol = " ";

      fossil_branch.symbol = " ";

      gcloud.format = "on $symbol$account(\($region\))]($style) ";
      gcloud.symbol = " ";

      git_branch.symbol = " ";

      git_commit.tag_symbol = "  ";

      golang.symbol = " ";

      guix_shell.symbol = " ";

      haskell.symbol = " ";

      haxe.symbol = " ";

      hg_branch.symbol = " ";

      hostname.ssh_symbol = " ";

      java.symbol = " ";

      julia.symbol = " ";

      kotlin.symbol = " ";

      lua.symbol = " ";

      memory_usage.symbol = "󰍛 ";

      meson.symbol = "󰔷 ";

      nim.symbol = "󰆥 ";

      nix_shell.symbol = " ";

      nodejs.symbol = " ";

      ocaml.symbol = " ";

      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CachyOS = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        Nobara = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        RockyLinux = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
      };

      package.symbol = "󰏗 ";

      perl.symbol = " ";

      php.symbol = " ";

      pijul_channel.symbol = " ";

      pixi.symbol = "󰏗 ";

      python.symbol = " ";

      rlang.symbol = "󰟔 ";

      ruby.symbol = " ";

      rust.symbol = "󱘗 ";

      scala.symbol = " ";

      swift.symbol = " ";

      zig.symbol = " ";

      gradle.symbol = " ";
    };
  };
}
