{
  fetchurl,
  lib,
  patchelf,
  stdenv,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "17.2.9";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
        # managed by update-resource
        hash = "sha256-T3rrM7LzR8EaWsjHNjDjHQLAo+7zaTRoiAufXo8CoCs=";
      };
      aarch64-darwin = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
        # managed by update-resource
        hash = "sha256-P5xExGXahCi1qBoMnNrCLO2YIxn+k9U0kUy2GDimMRg=";
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "omp is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omp";
  inherit version;

  src = fetchurl source;

  dontUnpack = true;
  dontPatchELF = true;

  nativeBuildInputs = lib.optional (stdenv.hostPlatform.system == "x86_64-linux") patchelf;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
  ''
  + lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") ''
    patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" --set-rpath "${
      lib.makeLibraryPath [ stdenv.cc.cc ]
    }" "$out/bin/omp"
  ''
  + ''
    runHook postInstall
  '';

  meta = {
    description = "Terminal-first AI coding agent";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
