{
  fetchurl,
  lib,
  patchelf,
  stdenv,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omp";
  version = "17.0.9";

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${finalAttrs.version}/omp-linux-x64";
    hash = "sha256-SFzDAdb9/ya6tdOrRasTdjSnO3Gy7XqRxshUWEL/TAk=";
  };

  dontUnpack = true;
  dontPatchELF = true;

  nativeBuildInputs = [ patchelf ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
    patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" --set-rpath "${
      lib.makeLibraryPath [ stdenv.cc.cc ]
    }" "$out/bin/omp"
    runHook postInstall
  '';

  meta = {
    description = "Terminal-first AI coding agent";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
