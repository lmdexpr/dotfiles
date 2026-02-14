{
  description = "lmdexpr's dotfiles";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  };

  inputs = {
    nixpkgs.url   = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers.url = "github:natsukium/mcp-servers-nix";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { nixpkgs, nixos-wsl, home-manager, mcp-servers, zen-browser, ... } @ inputs:
    let
      mkNixosSystem = { system, hostname, username, homename, additionalModules ? [] }:
        nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit inputs hostname username mcp-servers zen-browser; };
          modules = additionalModules ++ [
            ./machine/${hostname}

            home-manager.nixosModules.home-manager
            {
              documentation.enable = false;
              documentation.nixos.enable = false;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = ./home/${homename};
              home-manager.extraSpecialArgs = specialArgs;
            }

            { nixpkgs.config = { allowUnfree = true; }; }
          ];
        };
    in {
      nixosConfigurations.svartalfheimr = mkNixosSystem {
        system   = "x86_64-linux";
        hostname = "svartalfheimr";
        username = "lmdexpr";
        homename = "cui";
      };

      nixosConfigurations.fenrir = mkNixosSystem {
        system   = "x86_64-linux";
        hostname = "fenrir";
        username = "lmdexpr";
        homename = "niri";
      };

      nixosConfigurations.skelton = mkNixosSystem {
        system   = "x86_64-linux";
        hostname = "skelton";
        username = "nixos";
        homename = "cui";
        additionalModules = [ nixos-wsl.nixosModules.default ];
      };
    };
}
