{
  fetchurl,
  lib,
  patchelf,
  stdenv,
  stdenvNoCC,
}:
let
  source =
    {
      x86_64-linux = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v17.0.9/omp-linux-x64";
        hash = "sha256-SFzDAdb9/ya6tdOrRasTdjSnO3Gy7XqRxshUWEL/TAk=";
      };
      aarch64-darwin = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v17.0.9/omp-darwin-arm64";
        hash = "sha256-3RQwukgJpV9Nby9kYhHO5RU1+WGetmcPG/z3SEwjuTE=";
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "omp is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omp";
  version = "17.0.9";

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
