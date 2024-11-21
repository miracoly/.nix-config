{
  description = "My Home configuration";

  inputs = {
    dnd-latex-template = {
      url = "github:rpgtex/DND-5e-LaTeX-Template/stable";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper = {
      url = "github:miracoly/wallpaper/main";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      miras-home-manager =
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mira = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit (inputs) dnd-latex-template nixvim wallpaper;
              pkgs-unstable = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            };
          };
        };
    in
    {
      nixosConfigurations = {
        miras-xps-9730 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hosts/xps9730.nix
            home-manager.nixosModules.home-manager
            miras-home-manager
          ];
        };

        miras-xps-93xx = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hosts/xps93xx.nix
            home-manager.nixosModules.home-manager
            miras-home-manager
          ];
        };
      };
    };
}
