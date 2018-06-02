{ nixpkgs ? import ./nixpkgs.nix, compiler ? "ghc802" }:
(import ./default.nix { inherit nixpkgs compiler; }).env
