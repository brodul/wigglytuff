{ buildType ? "dev" }:
let
  nixpkgs = (import ./nix/sources.nix).nixpkgs;
  pkgs = import nixpkgs {
    config = { allowUnfree = true; };
    overlays = [];
  };

  dependencies = with pkgs; [
    python310
    poetry

    ffmpeg
    syncthing
  ] ++ builtins.getAttr buildType {
    dev = [
      niv
    ];
    prod = [];
  };
in

pkgs.mkShell {
  name = "dev-shell";
  buildInputs = dependencies;
  shellHook = ''
  '';
}
