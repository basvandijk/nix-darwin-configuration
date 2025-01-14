{
  description = "A flake for my nix-darwin-based system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    configuration = { pkgs, ... }: {
      imports = [ home-manager.darwinModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users."bas" = {
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          programs.git = {
            enable = true;
            userEmail = "bas@van.dijk.ch";
            userName = "Bas van Dijk";
          };

          programs.kitty = {
            enable = true;
          };

          programs.oh-my-posh = {
            enable = true;
            useTheme = "M365Princess";
          };

          programs.zsh = {
            enable = true;
            syntaxHighlighting.enable = true;
            shellAliases = {
              ls = "ls --color";
              l = "ls --color -la";
              t = "terraform";
              k = "kubectl";
              h = "hledger";
            };
          };

          programs.emacs = {
            enable = true;
            extraPackages = epkgs: with epkgs; [
              bazel
              magit
              forge
              flycheck
              company
              github-review
              haskell-mode
              zenburn-theme
              solarized-theme
              yaml-mode
              markdown-mode
              nix-mode
              nix-sandbox
              ormolu
              graphviz-dot-mode
              direnv
              projectile
              terraform-mode
              go-mode
              rust-mode
              lsp-mode
              lsp-ui
              adoc-mode
              plantuml-mode
              use-package
              rg
              tt-mode
              elixir-mode
              yasnippet
              hledger-mode
            ];
          };
        };
      };

      users.users."bas" = {
        home = "/Users/bas";
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        coreutils
        git-filter-repo
        gh
        htop
        tree
        gnupg
        openssl
        plantuml
        ripgrep
        jq
        graphviz
        cabal2nix
        cabal-install
        colordiff
        yq
        krew
        bazelisk
        ormolu
        tldr
        nodejs_22
        pkgs.haskellPackages.ghc
      ];

      fonts.packages = [
        # See: https://www.nerdfonts.com/font-downloads
        pkgs.nerd-fonts._0xproto
      ];

      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Bas-Dijk-LXQ66Y3561" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
