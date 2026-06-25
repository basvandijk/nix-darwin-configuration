{
  description = "A flake for my nix-darwin-based system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NOTE: mac-app-util intentionally does NOT follow our nixpkgs.
    # SBCL 2.6.x in nixpkgs 26.05 breaks named-readtables/cl-interpol, which
    # mac-app-util depends on. Using its own pinned nixpkgs (with a working
    # SBCL) is the maintainer-recommended workaround.
    # See: https://github.com/hraban/mac-app-util/issues/42
    mac-app-util.url = "github:hraban/mac-app-util";

    devbox-src = {
      url = "https://github.com/namespacelabs/devbox/releases/download/v0.0.170/devbox_0.0.170_darwin_arm64.tar.gz";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, mac-app-util, devbox-src }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      configuration = { pkgs, ... }:
        let
          devbox = pkgs.runCommand "devbox" { } ''
            install -D ${devbox-src}/devbox $out/bin/devbox
          '';
        in
        {
          imports = [
            home-manager.darwinModules.home-manager
            mac-app-util.darwinModules.default
          ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
            users."bas" = {
              home.stateVersion = "25.05";
              programs.home-manager.enable = true;

              programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
              };

              programs.git = {
                enable = true;
                settings = {
                  user.email = "bas@van.dijk.ch";
                  user.name = "Bas van Dijk";
                };
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
                envExtra = ''
                  . "$HOME/.cargo/env"
                  . "$HOME/Library/Application Support/org.dfinity.dfx/env"
                  export PATH="$HOME/.npm-global/bin:$PATH"
                '';
                initContent = ''
                  # The commands below set some key bindings. To figure out the code for a particular
                  # key binding, use 'cat':
                  # % cat
                  # ^A^C

                  # Ensure "del" key deletes the next char
                  # (needed if terminal doesn't handle it directly)
                  bindkey "^[[3~" delete-char
                '';
              };

              programs.emacs = {
                enable = true;
                extraPackages = epkgs: with epkgs; [
                  adoc-mode
                  bazel
                  company
                  direnv
                  elixir-mode
                  exec-path-from-shell
                  flycheck
                  forge
                  github-review
                  go-mode
                  graphviz-dot-mode
                  haskell-mode
                  hledger-mode
                  lsp-mode
                  lsp-ui
                  magit
                  markdown-mode
                  nix-mode
                  nix-sandbox
                  ormolu
                  plantuml-mode
                  projectile
                  rg
                  rust-mode
                  solarized-theme
                  terraform-mode
                  tt-mode
                  tuareg
                  use-package
                  yaml-mode
                  yasnippet
                  zenburn-theme
                ];
              };
              home.packages = with pkgs; [
                bazelisk
                bazel_8
                cabal-install
                cabal2nix
                cachix
                colordiff
                gh
                git-filter-repo
                gnupg
                graphviz
                haskellPackages.ghc
                jq
                krew
                nodejs_22
                openssl
                ormolu
                ripgrep
                tldr
                yq
                saml2aws
                okta-aws-cli
                awscli
                devbox
              ];
            };
          };

          users.users."bas" = {
            home = "/Users/bas";
          };

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            coreutils
            htop
            rectangle
            tree
            wireguard-tools
          ];

          fonts.packages = [
            # See: https://www.nerdfonts.com/font-downloads
            pkgs.nerd-fonts._0xproto
          ];

          nix.settings = {
            experimental-features = "nix-command flakes";
            trusted-users = [ "bas" ];
          };

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
      formatter.${system} = pkgs.writeShellScriptBin "formatter" ''
        if [[ $# = 0 ]]; then set -- .; fi
        exec "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" "$@"
      '';
    };
}
