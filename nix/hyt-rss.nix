{ mkDerivation, stdenv
, base, text, time, iso8601-time, bytestring
, Spock, http-types, aeson , wreq, lens, lens-aeson, vector
, blaze-html
, dhall
}:
mkDerivation {
  pname = "hyt-rss";
  version = "0.1.0.0";
  src = ./..;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base text time iso8601-time bytestring
    Spock http-types aeson wreq lens lens-aeson vector
    blaze-html
    dhall
  ];
  homepage = "https://github.com/JohnAZoidberg/hyt-rss";
  description = "";
  license = stdenv.lib.licenses.gpl3; # TODO TBT
}
