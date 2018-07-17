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
    rev = "5714c5b8c77c548c96782d9caa8c0a9b33a0b48d";
    sha256 = "05zjmycgk2rb33fcddi0r4rq8bz496nxxddbpc75nmf94r29y51i";
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
