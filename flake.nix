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
    dnd-latex-template = {
      url = "github:rpgtex/DND-5e-LaTeX-Template/stable";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    nvim-dap-vscode-js = {
      url = "github:mxsdev/nvim-dap-vscode-js";
      flake = false;
    };

    wallpaper = {
      url = "github:miracoly/wallpaper/main";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    supportedSystems = [system];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    miras-home-manager = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.mira = import ./home.nix;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit
            (inputs)
            dnd-latex-template
            nixvim
            wallpaper
            ;
          nvim-extraPlugins = {
            inherit (inputs) nvim-dap-vscode-js;
          };
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
    };
  in {
    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });

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
