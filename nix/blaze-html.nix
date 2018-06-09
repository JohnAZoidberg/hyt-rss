{ stdenv, mkDerivation, base, blaze-builder, blaze-markup, bytestring
, containers, HUnit, QuickCheck, test-framework
, test-framework-hunit, test-framework-quickcheck2, text
, fetchFromGitHub
}:
mkDerivation {
  pname = "blaze-html";
  src = fetchFromGitHub {
    owner ="jaspervdj";
    repo = "blaze-html";
    rev = "0f720359d7fa6baa2b8a19327dff2f20d3d652d3";
    sha256 = "164s9sl3i13np2qwg5yr4vmh23819jgg0xyr6drsa4c84jvb76lj";
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
