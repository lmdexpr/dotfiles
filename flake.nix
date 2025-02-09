{
  description = "";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url   = "github:NixOS/nixpkgs/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-wsl, home-manager, ... }:
  let
    allow_unfree = { ... }: { nixpkgs.config = { allowUnfree = true; }; };
  in
  {
    nixosConfigurations.svartalfaheimr = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./machine/svartalfaheimr

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lmdexpr = ./home/lmdexpr;
        }

        allow_unfree
      ];
    };

    nixosConfigurations.fenrir = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./machine/fenrir

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = ./home/wsl;
        }

        allow_unfree
      ];
    };

    nixosConfigurations.skelton = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        nixos-wsl.nixosModules.default

        ./machine/skelton

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = ./home/wsl;
        }

        allow_unfree
      ];
    };
  };
}
