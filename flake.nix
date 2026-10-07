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
          pkgs.perl
        ];

        unpackPhase = ''
          tar -xzf "$src"
        '';

        installPhase = ''
          # prepare directory
          mkdir -p "$out/bin"
          mkdir -p "$out/share/applications"
          mkdir -p "$out/share/icons/hicolor/64x64/apps"

          # executable binary
          cp pgopher "$out/bin/"
          cp pgo "$out/bin/"
          cp tabslave "$out/bin/"

          # desktop entry & icon file
          cp ${./pgopher.desktop} "$out/share/applications/pgopher.desktop"
          cp ${./pgopher.png} "$out/share/icons/hicolor/64x64/apps/pgopher.png"
        '';

        postFixup = ''
          # Workaround for NixOS: the prebuilt FPC (2018) binaries read
          # /etc/timezone at startup; NixOS does not provide it as a regular
          # file, and the failed read causes a nil dereference -> SIGSEGV
          # (runtime error 216) before any argument is processed.
          # Same-length path patch redirects the read to /tmp/timezone, which
          # the wrapper below ensures exists. The actual timezone is resolved
          # via /etc/localtime, so the file content only needs to be a
          # well-formed zone name.
          for b in pgo pgopher tabslave; do
            perl -pi -e 's{/etc/timezone}{/tmp/timezone}g' "$out/bin/$b"
            # self-check: fail the build if the PGOPHER binary changed and
            # the string is no longer present (silent no-op patch would ship
            # a crashing binary on the next version bump)
            grep -aq '/tmp/timezone' "$out/bin/$b" || {
              echo "error: '/etc/timezone' string not found in $b - PGOPHER binary changed; update this patch"
              exit 1
            }
            wrapProgram "$out/bin/$b" \
              --run '[ -f /tmp/timezone ] || printf "Asia/Tokyo\n" > /tmp/timezone 2>/dev/null || true'
          done
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
