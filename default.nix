let
  fetchNixpkgs = import ./nix/fetchNixpkgs.nix;

  nixpkgs = import ./nix/nixpkgs.nix;
  #nixpkgs = fetchNixpkgs {
  #  rev = "804060ff9a79ceb0925fe9ef79ddbf564a225d47";

  #  sha256 = "01pb6p07xawi60kshsxxq1bzn8a0y4s5jjqvhkwps4f5xjmmwav3";

  #  outputSha256 = "0ga345hgw6v2kzyhvf5kw96hf60mx5pbd9c4qj5q4nan4lr7nkxn";
  #};

  config = {
    packageOverrides = pkgs: {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: {
          hyt-rss =
           #pkgs.haskell.lib.failOnAllWarnings
           #  (pkgs.haskell.lib.justStaticExecutables
                (haskellPackagesNew.callPackage ./nix/hyt-rss.nix {
                 # TODO why doesn't this work?
                 #blaze-html = haskellPackagesNew.callPackage ./nix/blaze-html.nix { };
                });
           #  );

           # I don't really need the dependencies of blaze-html to rebuild
           # based off of my fork TODO why do I have to?
           blaze-html = haskellPackagesNew.callPackage ./nix/blaze-html.nix { };
        };
      };
    };
  };

  pkgs = import nixpkgs { inherit config; };

in
  {
    inherit (pkgs.haskellPackages) hyt-rss;
    #inherit (pkgs.haskellPackages) blaze-html;

    shell = (pkgs.haskellPackages.hyt-rss).env;
}
