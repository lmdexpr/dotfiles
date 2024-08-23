{
  description = "";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    inherit (self) outputs;
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
  };
}
