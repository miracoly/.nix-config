{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "codecrafters-cli-${version}";
  version = "25";

  # https://github.com/codecrafters-io/cli/releases
  src = fetchurl {
    url =
    "https://github.com/codecrafters-io/cli/releases/download/v25/v25_linux_amd64.tar.gz";
    sha256 = "9df1ad971cf337325397443ab45be6c0514661d1adb0d8c713f172b83224c261";
  };

  unpackPhase = ''
    mkdir -p $out
    tar -xzvf ${src}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out/bin/
  '';
}
