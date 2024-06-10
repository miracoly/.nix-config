{ stdenv, lib, fetchzip }:
stdenv.mkDerivation rec {
  name = "depencency-check-${version}";
  version = "8.4.2";

  # https://github.com/pjreddie/darknet
  src = fetchzip {
    url =
      "https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.2/dependency-check-8.4.2-release.zip";
    hash = "sha256-PFESR8yInkhyU8kQUJtICbSiGv49gsiavK2EhxNoXOY=";
  };

  installPhase = ''
    cp -r . $out
  '';
}
