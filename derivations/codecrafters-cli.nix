{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  name = "codecrafters-cli-${version}";
  version = "30";

  # https://github.com/codecrafters-io/cli/releases
  src = fetchurl {
    url = "https://github.com/codecrafters-io/cli/releases/download/v${version}/v${version}_linux_amd64.tar.gz";
    sha256 = "sha256-mjP0BL1aXCDqQm70UFHGckF1cMeDnKTcbbk1eVNz/38=";
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
