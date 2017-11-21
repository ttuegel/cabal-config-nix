{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
with pkgs;

{ inputs ? (pkgs: []) }:

stdenv.mkDerivation {
  name = "cabal.config";
  phases = "buildPhase";
  buildInputs = [ gcc zlib ] ++ (inputs pkgs);
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
      ar-location: $(command -v ar)
      gcc-location: $(command -v gcc)
      ld-location: $(command -v ld)
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
