{ mkDerivation, stdenv
, base, text, time, iso8601-time, bytestring
, Spock, http-types, aeson
, dhall
}:
mkDerivation {
  pname = "hyt-rss";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base text time iso8601-time bytestring
    Spock http-types aeson
    dhall
  ];
  homepage = "https://github.com/JohnAZoidberg";
  license = stdenv.lib.licenses.gpl3; # TODO TBT
}
