{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [
        (self: super: rec {
          nodejs = super.nodejs_20;
          pnpm = super.nodePackages.pnpm;
          yarn = super.yarn.override {inherit nodejs;};
        })
      ];
      pkgs = import nixpkgs {inherit overlays system;};
      pkgs_chromium = import nixpkgs {inherit system;};
      packages = with pkgs; [node2nix nodejs pnpm yarn git];
    in {
      devShells.default = pkgs.mkShell {
        inherit packages;

        shellHook = ''
          echo "node `${pkgs.nodejs}/bin/node --version`"
        '';
      };

      devShells.export-pdf = pkgs.mkShell {
        inherit packages;

        shellHook = ''
          echo "node `${pkgs.nodejs}/bin/node --version`"

          # Set Puppeteer to not download Chrome, cause it doesn't work on NixOS
          export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
          # Set Puppeteer to use Chromium from Nixpkgs
          export PUPPETEER_EXECUTABLE_PATH=${pkgs_chromium.chromium.outPath}/bin/chromium
        '';
      };
    });
}
