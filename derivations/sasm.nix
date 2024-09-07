{ stdenv
, lib
, libsForQt5
, nasm
, qt5
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
}:
stdenv.mkDerivation {
  pname = "sasm";
  version = "3.14.4";

  src = fetchFromGitHub {
    owner = "Dman95";
    repo = "SASM";
    rev = "6bb9ba90b3cd8019c8b8ef7593fb8cf8f5da3a1d";
    sha256 = "sha256-b95dqgOh+mwsC/m8Tmb6XFX0GabZ601yf/Nq7dj+svE=";
  };

  buildInputs = [
    qt5.qtbase.dev
  ];

  nativeBuildInputs = [
    copyDesktopItems
    libsForQt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    nasm
  ];

  buildPhase = ''
    qmake
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p build
    make install INSTALL_ROOT=build
    cp -r build/usr/bin/* $out/bin

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem
      {
        name = "sasm";
        exec = "sasm";
        desktopName = "SASM";
        categories = [ "Development" "IDE" ];
      })
  ];

  meta = with lib; {
    description = "Simple cross-platform IDE for NASM, MASM, GAS, and FASM assembly languages.";
    homepage = "https://github.com/Dman95/SASM";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "sasm";
  };
}
