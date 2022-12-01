let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };

  # For overriding roc stuff
  nixGlibcPath = if pkgs.stdenv.isLinux then "${pkgs.glibc.out}/lib" else "";

  roc = (import sources.roc {
    cargoSha256 = "sha256-AH/cWRbshJI2pweoz24AXcDcz/+fM6cGHJU7V9GH/w4=";
    pkgs = pkgs;
  }).overrideAttrs (final: previous: {
      # debug build failures
      nativeBuildInputs = previous.nativeBuildInputs ++ [pkgs.breakpointHook];
      # remove cp from linux, i don't have the lib directory it tried to copy
      postInstall = if pkgs.stdenv.isLinux then ''
          wrapProgram $out/bin/roc --set NIX_GLIBC_PATH ${nixGlibcPath} --prefix PATH : ${
          pkgs.lib.makeBinPath [ pkgs.stdenv.cc ]
          }
      '' else ''
          cp -r target/aarch64-apple-darwin/release/lib/. $out/lib
          wrapProgram $out/bin/roc --prefix PATH : ${
          pkgs.lib.makeBinPath [ pkgs.stdenv.cc ]
          }
      '';
  });
in pkgs.mkShell {
  buildInputs = [
    roc
  ];
}