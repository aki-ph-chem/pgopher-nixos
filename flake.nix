{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      src = pkgs.fetchurl {
        url = "https://github.com/aki-ph-chem/pgopher-nixos/releases/download/v0/pgopher-x86_64-linux-gtk2.tgz";
        sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
      };

    };
}
