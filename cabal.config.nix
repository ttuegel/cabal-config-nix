{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
with pkgs;

{ inputs ? [] }:

stdenv.mkDerivation {
  name = "cabal.config";
  phases = "buildPhase";
  buildInputs = inputs;
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
    extra-lib-dirs: ''${cabalExtraLibDirs[@]}
    extra-include-dirs: ''${cabalExtraIncludeDirs[@]}

    program-locations
      ar-location: $(type -P ar)
      gcc-location: $(type -P gcc)
      ld-location: $(type -P ld)
      strip-location: $(type -P strip)
      tar-location: $(type -P tar)
    EOF
  '';
};
