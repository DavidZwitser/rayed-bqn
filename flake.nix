{
  description = "Rayed BQN";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = nixpkgs.legacyPackages.${system};
      raylib = pkgs.raylib;

    in rec {
      packages.default = pkgs.stdenv.mkDerivation {
        name = "RayedBQN";
        src = ./.;

        nativeBuildInputs = [ pkgs.git ];

        buildPhase = /*bash*/ ''
          # Overwriting the default raylib loading
          echo "raylibheaderpath ⇐ •file.At \"${raylib}/include/raylib.h\"" > $src/config.bqn
          echo "rayliblibpath ⇐ •file.At \"${raylib}/lib/libraylib.dylib\"" >> $src/config.bqn
          echo "⟨raylibheaderpath ⋄ rayliblibpath⟩ ⇐ •Import \"../config.bqn\"" > $src/src/loadConfig.bqn
        '';

        installPhase = /*bash*/ ''
          mkdir -p $out
          cp -r $src/src $out
          cp -r $src/ffi $out
        '';
      };
  });
}
