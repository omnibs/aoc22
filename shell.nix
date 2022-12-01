let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };
  roc = import sources.roc {
    cargoSha256 = "0000000000000000000000000000000000000000000000000000";
  };
in pkgs.mkShell {
  buildInputs = [
    roc
  ];
}