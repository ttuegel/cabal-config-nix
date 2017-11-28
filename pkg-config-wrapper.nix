{
  stdenv, makeWrapper,
  pkgconfig,
}:

{
  buildInputs
}:

let
  inherit (builtins.parseDrvName pkgconfig.name) version;
in

stdenv.mkDerivation {
  name = "pkg-config-wrapper-${version}";
  nativeBuildInputs = [ pkgconfig makeWrapper ];
  inherit buildInputs;
  phases = "buildPhase";
  buildPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    makeWrapper $(command -v pkg-config) "$out/bin/pkg-config" \
        --prefix PKG_CONFIG_PATH : "$PKG_CONFIG_PATH"

    runHook postInstall
  '';
}
