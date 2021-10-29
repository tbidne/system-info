{
  description = "system-info flake";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        compilerVersion = "ghc8107";
        compiler = pkgs.haskell.packages."${compilerVersion}";
        mkPkg = returnShellEnv:
          compiler.developPackage {
            inherit returnShellEnv;
            name = "system-info";
            root = ./.;
            modifier = drv:
              pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages; [
                cabal-fmt
                cabal-install
                cabal-plan
                haskell-language-server
                hlint
                ghcid
                implicit-hie
                ormolu
                pkgs.nixpkgs-fmt
                pkgs.zlib
              ]);
            overrides = hself: hsuper: with pkgs.haskellPackages; {
              optics-core = callHackage "optics-core" "0.4" { };
              optics-th = callHackage "optics-th" "0.4" {
                optics-core = hself.optics-core;
              };
            };
          };
      in
      {
        defaultPackage = mkPkg false;

        devShell = mkPkg true;
      });
}
