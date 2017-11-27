{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
with pkgs;

{
  inputs ? (pkgs: []),
  alex ? (pkgs: pkgs.haskellPackages.alex),
  c2hs ? (pkgs: pkgs.haskellPackages.c2hs),
  ghc ? (pkgs: pkgs.haskell.compiler.ghc822),
  happy ? (pkgs: pkgs.haskellPackages.happy),
  hscolour ? (pkgs: pkgs.haskellPackages.hscolour),
}:

stdenv.mkDerivation {
  name = "cabal.config";
  phases = "buildPhase";
  buildInputs =
    [
      gcc pkgconfig zlib
      (alex pkgs) (c2hs pkgs) (ghc pkgs) (happy pkgs) (hscolour pkgs)
    ]
    ++ (inputs pkgs);
  preHook = ''
    declare -a cabalExtraLibDirs cabalExtraIncludeDirs
    cabalConfigLocalEnvHook() {
        if [ -d "$1/include" ]; then
            cabalExtraIncludeDirs+=("$1/include")
        fi
        if [ -d "$1/lib" ]; then
            cabalExtraLibDirs+=("$1/lib")
        fi
    }
    envHooks+=(cabalConfigLocalEnvHook)
  '';
  buildPhase = ''
    eval $shellHook
    cat >"$out" <<EOF
    program-locations
      alex-location: $(command -v alex)
      ar-location: $(command -v ar)
      c2hs-location: $(command -v c2hs)
      gcc-location: $(command -v gcc)
      ghc-location: $(command -v ghc)
      ghc-pkg-location: $(command -v ghc-pkg)
      haddock-location: $(command -v haddock)
      happy-location: $(command -v happy)
      hsc2hs-location: $(command -v hsc2hs)
      hscolour-location: $(command -v hscolour)
      ld-location: $(command -v ld)
      pkg-config-location: $(command -v pkg-config)
      strip-location: $(command -v strip)
      tar-location: $(command -v tar)

    EOF

    for dir in ''${cabalExtraLibDirs[@]}
    do
        echo "extra-lib-dirs: $dir" >>"$out"
    done

    for dir in ''${cabalExtraIncludeDirs[@]}
    do
        echo "extra-include-dirs: $dir" >>"$out"
    done
  '';
}
