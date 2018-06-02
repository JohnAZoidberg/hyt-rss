let
  fetchNixpkgsChannels = { rev, sha256 } : builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
    inherit sha256;
  };
in
  import (fetchNixpkgsChannels {
    #rev = "nixos-18.03"; # c40fdcd26c26ffc0832d8d6d7ce671aea075c356
    #sha256 = "1ln9x7zg0rqpkd56fxx4i6i3sad91js8ma9bz78iy5lw5cp888mv";
    # TODO update to a more recent commit
    rev = "5141f28405e5d31f21c10869dfc86ff340053787";
    sha256 = "0q91kfxg950g1nr71ifxhb4gfn3vfs4szh2yn7z8s2xri4l36p5m";
  }) { config = {}; }
