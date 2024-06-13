{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "codecrafters-cli-${version}";
  version = "29";

  # https://github.com/codecrafters-io/cli/releases
  src = fetchurl {
    url =
      "https://github.com/codecrafters-io/cli/releases/download/v${version}/v${version}_linux_amd64.tar.gz";
    sha256 = "sha256-WJE2o4tvq9WzfWIYXXJ2gIFf07F5R7CWiBqBfnNkuAo=";
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
