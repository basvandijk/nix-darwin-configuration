{
  description = "A flake for my nix-darwin-based system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }:
      let
        emacs = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs:
          with epkgs.melpaPackages; [
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
          ]);
      in {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        coreutils
        git
        git-filter-repo
        gh
        #git-lfs
        htop
        zsh
        oh-my-zsh
        # powerline-fonts # Make sure to run ~/Library/Fonts/update.sh
        tree
        gnupg
        openssl
        plantuml
        # jre
        ripgrep
        jq
        direnv
        nix-direnv
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

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      programs.direnv.enable = true;

      programs.zsh.enableSyntaxHighlighting = true;
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
