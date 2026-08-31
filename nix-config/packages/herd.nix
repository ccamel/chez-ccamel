{
  bash,
  fetchurl,
  writeShellApplication,
  git,
  jq,
  herdr,
  omp,
}:
let
  src = fetchurl {
    url = "https://gist.githubusercontent.com/ccamel/46a021372c326f31fdb3b5a55b238214/raw/herd";
    # managed by update-resource
    hash = "sha256-Y19Mr02bF9qSeEM3Nv1hTz3n4HwAxKQkmD/UN5AbFGo=";
  };
in
writeShellApplication {
  name = "herd";

  runtimeInputs = [
    git
    jq
    herdr
    omp
  ];

  text = ''
    exec ${bash}/bin/bash ${src} "$@"
  '';
}
