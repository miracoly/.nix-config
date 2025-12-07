{
  description = "My Home configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    backlog-md = {
      url = "github:MrLesk/Backlog.md/9b2b4aa4ce7c9dc454215419413109f3efb04708";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    dnd-latex-template = {
      url = "github:rpgtex/DND-5e-LaTeX-Template/stable";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-telepresence.url = "github:NixOS/nixpkgs/15d54e7a7dd5b8f43a1e49ae7795285da1283224";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper = {
      url = "github:miracoly/wallpaper/main";
      flake = false;
    };

    private = {
      url = "git+https://miracoly@github.com/miracoly/.nix-config-private";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  } @ inputs: let
    miras-home-manager = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.mira = import ./home.nix;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit
            (inputs)
            backlog-md
            dnd-latex-template
            nixvim
            purescript-overlay
            wallpaper
            ;
          pkgs-unstable = import inputs.nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          pkgs-telepresence = import inputs.nixpkgs-telepresence {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
    };
  in
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};

      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };
    in {
      checks = {
        pre-commit-check = pre-commit-check;
      };

      devShells = {
        default = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          buildInputs = pre-commit-check.enabledPackages;
        };
      };
    })
    // {
      nixosConfigurations = {
        miras-xps-9730 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./hosts/xps9730.nix
            home-manager.nixosModules.home-manager
            miras-home-manager
          ];
        };

        miras-xps-93xx = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
