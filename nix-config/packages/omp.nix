{
  lib,
  fetchurl,
  makeWrapper,
  glibc,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "19.0.1";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
        # managed by update-resource
        hash = "sha256-bO7wRDCFG7EFDG/aOvRnQS60ShHfCm/4Eh/mAQE8VBU=";
      };
      aarch64-darwin = {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
        # managed by update-resource
        hash = "sha256-L+Qgu9APgYmYFuUcvuuVk6+lnZNo1iydPnhTXVQOMvY=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "omp is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation {
  pname = "omp";
  inherit version;

  src = fetchurl source;

  dontUnpack = true;

  # Upstream ships a self-contained bun-compiled executable: fetching it beats
  # building the bun2nix + rust-overlay toolchain from source on every flake
  # update. `autoPatchelfHook` rewrites the ELF and corrupts bun's embedded
  # bundle trailer, so only the dynamic-linker path is fixed via a wrapper
  # that execs the untouched binary through the correct `ld.so`; glibc's own
  # loader already finds libc/libm/libpthread/libdl next to itself. Preserve
  # argv[0] so Lig's process mirror exposes omp, not ld.so, to HerdR.
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ makeWrapper ];

  installPhase =
    if stdenvNoCC.hostPlatform.isLinux then
      ''
        runHook preInstall
        install -Dm755 "$src" "$out/libexec/omp"
        makeWrapper "${glibc}/lib/ld-linux-x86-64.so.2" "$out/bin/omp" --argv0 omp --add-flags "$out/libexec/omp"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        install -Dm755 "$src" "$out/bin/omp"
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
}
