# PGOPHER for NixOS

<img src="./figs/pgopher.png"/>

## About

PGOPHER with Nix!

PGOPHER is a program which is used as simulation & analysis of spectrum. 

This package is based on original [PGOPHER](https://pgopher.chm.bris.ac.uk/) 
and wrap executable binary with flake.

## Usage Instructions

### requirements

Needs `nix-ld` config like below:

```nix
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    # X11
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXfixes
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm

    # GTK2
    glib
    gtk2
    gdk-pixbuf

    # others
    zlib
    pango
    atk
    cairo
    stdenv.cc.cc
  ];
};
```

### Running Ad-hoc 

```bash
nix run github:aki-ph-chem/pgopher-nixos/main#pgopher
nix run github:aki-ph-chem/pgopher-nixos/main#pgo
nix run github:aki-ph-chem/pgopher-nixos/main#tabslave
```

### Intall on NixOS/Home Manager

<details>
<summary>Install on NixOS</summary>

```nix
{
  inputs = {
    # ...
    pgopher = {
      url = "github:aki-ph-chem/pgopher-nixos?ref=fix/desktop-entroy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs @ {
    pgopher
    ...
  }: {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        # ...
        {
          environment.systemPackages = [pgopher.packages.x86_64-linux.default];
        }
      ];
    };
  }
}
```

</details>

<details>
<summary>Install with Home Manager</summary>

```nix
{
  inputs = {
    pgopher = {
      url = "github:aki-ph-chem/pgopher-nixos?ref=fix/desktop-entroy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
  };

  outputs = inputs @ {
    pgopher
    ...
  }: {
    homeConfigurations.my-user = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {inherit inputs;};
      modules = [
        # ...
        {
          home.packages = [pgopher.packages.x86_64-linux.default];
        }
      ];
    };
  }
}
```

</details>
