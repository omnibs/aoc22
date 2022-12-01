let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };
  roc = import sources.roc {
    cargoSha256 = "sha256-AH/cWRbshJI2pweoz24AXcDcz/+fM6cGHJU7V9GH/w4=";
    pkgs = pkgs;
  };
in pkgs.mkShell {
  buildInputs = [
    roc
  ];
}