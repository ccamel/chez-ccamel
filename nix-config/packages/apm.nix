{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  libffi,
  libuuid,
  openssl,
  sqlite,
  bzip2,
  readline,
  xz,
}:
let
  # managed by update-resource
  version = "0.30.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/microsoft/apm/releases/download/v${version}/apm-linux-x86_64.tar.gz";
        # managed by update-resource
        hash = "sha256-i4S+vxnDUPrzbSGuuzUNxlbQTAt6HCv46jXAyqDkS7k=";
      };
      aarch64-darwin = {
        url = "https://github.com/microsoft/apm/releases/download/v${version}/apm-darwin-arm64.tar.gz";
        # managed by update-resource
        hash = "sha256-HL2P77tfdP0OBfGWu4HP887Ch2+PjhouRdS3j6Eno3w=";
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "apm is only supported on x86_64-linux and aarch64-darwin");
in
stdenv.mkDerivation {
  pname = "apm";
  inherit version;

  src = fetchurl source;

  # PyInstaller onedir bundle: the Linux binary links dynamically against
  # glibc and needs its interpreter/rpath patched; the bundled libpython
  # satisfies most transitive NEEDED entries, the rest come from buildInputs.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    libffi
    libuuid
    openssl
    sqlite
    bzip2
    readline
    xz
  ];

  unpackPhase = "tar -xzf $src";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/apm" "$out/bin"
    cp -R apm-*/. "$out/libexec/apm/"
    ln -s "$out/libexec/apm/apm" "$out/bin/apm"
    runHook postInstall
  '';

  meta = {
    description = "Agent Package Manager: dependency manager for AI agent configuration";
    homepage = "https://github.com/microsoft/apm";
    license = lib.licenses.mit;
    mainProgram = "apm";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
