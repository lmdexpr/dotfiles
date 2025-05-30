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
  };

  outputs = { nixpkgs, nixos-wsl, home-manager, ... }:
    let
      mkNixosSystem = { system, hostname, username, homename, additionalModules ? [] }: 
        nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit hostname username; };
          modules = additionalModules ++ [
            ./machine/${hostname}

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = ./home/${homename};
              home-manager.extraSpecialArgs = specialArgs;
            }

            { nixpkgs.config = { allowUnfree = true; }; }
          ];
        };
    in {
      nixosConfigurations.svartalfaheimr = mkNixosSystem {
        system   = "x86_64-linux";
        hostname = "svartalfaheimr";
        username = "lmdexpr";
        homename = "cui";
      };

      nixosConfigurations.fenrir = mkNixosSystem {
        system   = "x86_64-linux";
        hostname = "fenrir";
        username = "lmdexpr";
        homename = "plasma6";
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
