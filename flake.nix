{
  description = "Rafael Brandão Systems Configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Nix Community
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # url = "github:nix-community/nixvim?rev=24d2ac2373598c032f37d70c46803feefd169084";
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 3rd Party Inputs
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs = {
        dgop.follows = "dgop";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root = {
      url = "github:srid/flake-root";
    };
    just-flake = {
      url = "github:juspay/just-flake";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fish Plugins
    fish-plugin-spark = {
      url = "github:jorgebucaran/spark.fish";
      flake = false;
    };

    # Vim Plugins
    snacks-nvim = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    todo-comments-nvim = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    trouble-nvim = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };

    # Personal Repositories Inputs
    nix-contrib = {
      url = "github:rafael-brandao/nix-contrib/master";
    };
  };

  outputs = inputs @ {
    # self,
    flake-parts,
    ...
  }:
  # let
  #   inherit (self) outputs;
  # in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./flake
      ];
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];
      # flake = {
      #   inherit
      #     (self.flake.lib.local.project)
      #     nixosConfigurations
      #     homeConfigurations
      #     ;
      # };
      # flake = rec {
      #   lib = (import ./lib) inputs outputs;
      #
      #   inherit
      #     (lib.local)
      #     nixosConfigurations
      #     homeConfigurations
      #     ;
      #
      #   # Custom modules to enable special functionality for nixos or
      #   # home-manager oriented configs.
      #   nixosModules = import lib.local.paths.modules.nixos;
      #   homeManagerModules = import lib.local.paths.modules.home;
      # };
    };
}
