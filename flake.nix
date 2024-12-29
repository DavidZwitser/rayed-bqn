{
  description = "Rayed BQN flake!";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      packageVersion = "0.1.0";
      # revision = "1454488e5384f8e436844ac62ad4014ad3a1749c";

      # Fetching this repo itself to load its submodules
      rayedBqn = builtins.fetchGit {
        url = "https://github.com/DavidZwitser/rayed-bqn.git";
        # rev = revision;
        ref = "master";
        submodules = true;
      };
      pkgs = nixpkgs.legacyPackages.${system};

      default = pkgs.stdenv.mkDerivation {
        pname = "RayedBQN";
        version = packageVersion;
        src = rayedBqn;
        buildPhase = ''
          mkdir -p $out
          cp rayed.bqn $out
          cp -r ./src $out
          cp -r ./imports $out

          mkdir -p $out/lib
          ln -sf ${pkgs.raylib}/lib/libraylib.so $out/lib || true
          ln -sf ${pkgs.raylib}/lib/libraylib.dylib $out/lib || true
        '';
      };

      examplesToUse = {
        ColorFrenzy = "1_shapes/colorFrenzy.bqn";
        SnakeGame = "4_snakeGame/snake.bqn";
        REPL = "9_repl/repl.bqn";
      };

      examplePackages = builtins.mapAttrs (name: path: pkgs.stdenv.mkDerivation {
        pname = name;
        version = packageVersion;
        src = rayedBqn;
        buildPhase = ''
          mkdir -p $out
          cp rayed.bqn $out
          cp -r ./src $out
          cp -r ./imports $out

          mkdir -p $out/lib
          ln -sf ${pkgs.raylib}/lib/libraylib.so $out/lib || true
          ln -sf ${pkgs.raylib}/lib/libraylib.dylib $out/lib || true

          cp -r ./examples $out

          mkdir -p $out/bin
          echo "#!/bin/bash" > $out/bin/${name}
          echo "${pkgs.cbqn-replxx}/bin/cbqn $out/examples/${path}" >> $out/bin/${name}
          chmod +x $out/bin/${name}
        '';
      }) examplesToUse;

      exampleApps = builtins.mapAttrs (name: path: {
        type = "app";
        program = "${self.packages.${system}.${name}}/bin/${name}";
      }) examplesToUse;

    in {

    packages = examplePackages // {default = default;};
    apps = exampleApps;

  });
}
