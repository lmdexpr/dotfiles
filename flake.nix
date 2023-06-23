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

  outputs = { nixpkgs, home-manager, ... }: {

    nixosConfigurations.nkri = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./machine/nkri

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lmdexpr = ./home/lmdexpr;
        }
        
        ({ ... }: {
          nixpkgs.config = { allowUnfree = true; };
        })
      ];
    };

  };
}
