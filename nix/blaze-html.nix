{ stdenv, mkDerivation, base, blaze-builder, blaze-markup, bytestring
, containers, HUnit, QuickCheck, test-framework
, test-framework-hunit, test-framework-quickcheck2, text
, fetchFromGitHub
}:
mkDerivation {
  pname = "blaze-html";
  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "blaze-html";
    rev = "c1c14a7f2d1de6b5eb4e5686534ff7ef0ca10dc7";
    sha256 = "082dii2scwp0ff6rsxqsfajsq3hrm7453a9h3ppblzcm20mgsj0s";
  };
  isLibrary = true;
  isExecutable = false;
  version = "0.9.0.1";
  libraryHaskellDepends = [
    base blaze-builder blaze-markup bytestring text
  ];
  testHaskellDepends = [
    base blaze-builder blaze-markup bytestring containers HUnit
    QuickCheck test-framework test-framework-hunit
    test-framework-quickcheck2 text
  ];
  preConfigure = ''
    make combinators
  '';
  homepage = "http://jaspervdj.be/blaze";
  description = "A blazingly fast HTML combinator library for Haskell";
  license = stdenv.lib.licenses.bsd3;
}
