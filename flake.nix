{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkg = pkgs.stdenv.mkDerivation {
        pname = "pgopher";
        version = "1.0";

        src = pkgs.fetchurl {
          url = "https://github.com/aki-ph-chem/pgopher-nixos/releases/download/v0/pgopher-x86_64-linux-gtk2.tgz";
          sha256 = "sha256-pIgHTazLmWN+gPPTMs6yIwSSO9SgLSqguR3VFm6m/5E=";
        };

        # needed by build this package
        nativeBuildInputs = [
          pkgs.gnutar
          pkgs.makeWrapper
        ];

        unpackPhase = ''
          tar -xzf "$src"
        '';

        installPhase = ''
          # prepare directory
          mkdir -p "$out/bin"
          mkdir -p "$out/share/applications"
          mkdir -p "$out/share/icons/hicolor/scalable/apps"

          # executable binary
          cp pgopher "$out/bin/"
          cp pgo "$out/bin/"
          cp tabslave "$out/bin/"

          # desktop entry & icon file
          cp ${./pgopher.desktop} "$out/share/applications/"
          cp ${./pgopher.gif} "$out/share/icons/hicolor/64x64/apps/"
        '';

      };
    in
    {
      packages.${system}.default = pkg;

      apps.${system} = {
        pgopher = {
          type = "app";
          program = "${pkg}/bin/pgopher";
        };
        pgo = {
          type = "app";
          program = "${pkg}/bin/pgo";
        };
        tabslave = {
          type = "app";
          program = "${pkg}/bin/tabslave";
        };

        default = {
          type = "app";
          program = "${pkg}/bin/pgopher";
        };
      };
    };
}
