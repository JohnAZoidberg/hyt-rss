# hyt-rss

Youtube playlist to podcast rss-feed converter.
Will replace [YoutubeRSS](https://github.com/JohnAZoidberg/YoutubeRSS) with
a safer faster version.

## Building

### Using [Nix](https://nixos.org/nix/)
`nix-build --attr dhall`

### Using cabal
Install prerequisites or drop yourself into a nix-shell with everything
installed via `nix-shell`.

`cabal new-build`

## Running
Build and then either

- `result/bin/hyt-rss`
- `cabal new-run`

## TODO
- switch to a newer nixpkgs and ghc version
