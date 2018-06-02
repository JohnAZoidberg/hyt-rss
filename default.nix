{ nixpkgs ? import ./nixpkgs.nix, compiler ? "ghc802" }:
nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./hyt-rss.nix { }
