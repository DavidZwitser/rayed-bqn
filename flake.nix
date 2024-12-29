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
      revision = "e6acb24a2831f583e5ed6562790c61163756c642";

      # Fetching this repo itself to load its submodules
      rayedBqn = builtins.fetchGit {
        url = "https://github.com/DavidZwitser/rayed-bqn.git";
        rev = revision;
        submodules = true;
      };
      pkgs = nixpkgs.legacyPackages.${system};

      basicBuild = ''
        mkdir -p $out
        cp rayed.bqn $out
        cp -r ./src $out
        cp -r ./imports $out

        mkdir -p $out/lib
        ln -sf ${pkgs.raylib}/lib/libraylib.${if pkgs.stdenv.isLinux then "so" else "dylib"} $out/lib
      '' ;

      # genExamples = f: builtins.mapAttrs (name: value: f [name value]) {
      #   colorFrenzy = "1_shapes/colorFrenzy.bqn"
      # }
    in {

    packages.default = pkgs.stdenv.mkDerivation {
      pname = "RayedBQN";
      version = packageVersion;
      src = rayedBqn;

      buildPhase = basicBuild;
    };

    packages.example = pkgs.stdenv.mkDerivation {
      pname = "RayedBQN";
      version = "0.1.0";
      src = rayedBqn;

      buildInputs = [ pkgs.cbqn-replxx pkgs.git ];

      buildPhase = basicBuild ++ ''
        cp -r ./examples $out

        mkdir -p $out/bin
        echo "#!/bin/bash" > $out/bin/rayed-bqn
        echo "${pkgs.cbqn-replxx}/bin/cbqn $out/examples/1_shapes/colorFrenzy.bqn" >> $out/bin/rayed-bqn
        chmod +x $out/bin/rayed-bqn
      '';
    };

    apps.example =  {
      type = "app";
      program = "${self.packages.${system}.example}/bin/rayed-bqn";
    };

  });
}
