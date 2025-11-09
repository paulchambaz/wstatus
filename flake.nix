{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "wstatus";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = with pkgs; [ scdoc ];
          makeFlags = [ "PREFIX=$(out)" ];
          installPhase = ''
            mkdir -p $out/bin $out/share/man/man1
            cp wstatus $out/bin/
            scdoc < wstatus.1.scd | sed "s/1980-01-01/$(date '+%B %Y')/" > $out/share/man/man1/wstatus.1
          '';
        };
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ scdoc ];
        };
      }
    );
}
