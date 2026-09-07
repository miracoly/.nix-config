# sonarlint-ls (the server behind "SonarQube for IDE") bundled with the CFamily
# analyzer, so that C/C++/Objective-C can actually be analysed.
#
# Why this derivation exists at all:
#
# nixpkgs' `sonarlint-ls` builds from source with Maven and therefore only ends
# up with the analyzers that are published to Maven Central -- csharp, go, html,
# iac, java, javasymbolicexecution, js, omnisharp, php, python, text and xml.
# The CFamily analyzer (`com.sonarsource.cpp:sonar-cfamily-plugin`) is
# SonarSource proprietary and lives in a commercial repository, so the build
# silently drops it and `nixpkgs#sonarlint-ls` cannot report a single C or C++
# issue. The VS Code extension does not help either: since version 5.2 its VSIX
# ships only `sonarcfamily.jar.asc` and downloads the jar on demand at runtime.
#
# SonarSource does publish the jar for free IDE use, so we fetch it directly and
# rebuild the launcher wrapper with it added to `-analyzers`.
{
  lib,
  fetchurl,
  makeWrapper,
  runCommand,
  jre_headless,
  sonarlint-ls,
}: let
  # Pinned to the exact version that sonarlint-ls itself asks for. Read it back
  # out of the server jar after a nixpkgs bump:
  #
  #   unzip -p "$(nix build --no-link --print-out-paths nixpkgs#sonarlint-ls)/share/sonarlint-ls.jar" \
  #     META-INF/maven/org.sonarsource.sonarlint.ls/sonarlint-language-server/pom.xml \
  #     | grep -A3 sonar-cfamily-plugin
  cfamilyVersion = "6.76.0.93913";

  sonarcfamily = fetchurl {
    url = "https://binaries.sonarsource.com/CommercialDistribution/sonar-cfamily-plugin/sonar-cfamily-plugin-${cfamilyVersion}.jar";
    hash = "sha256-ndTV7YyjOUsLpdmM7SBub6UV1AlWC5AcqaFbYZCj784=";
  };
in
  runCommand "sonarlint-ls-cfamily-${sonarlint-ls.version}" {
    nativeBuildInputs = [makeWrapper];

    passthru = {
      inherit sonarcfamily cfamilyVersion;
      inherit (sonarlint-ls) version;
    };

    meta = {
      description = "Sonarlint language server including the CFamily analyzer for C/C++";
      homepage = "https://github.com/SonarSource/sonarlint-language-server";
      # The server itself is LGPL-3.0, but the CFamily analyzer added here is
      # SonarSource proprietary (free to use from an IDE, not redistributable).
      license = lib.licenses.unfree;
      mainProgram = "sonarlint-ls";
      platforms = lib.platforms.unix;
    };
  }
  ''
    mkdir -p $out/bin $out/share/plugins

    ln -s ${sonarlint-ls}/share/sonarlint-ls.jar $out/share/sonarlint-ls.jar
    ln -s ${sonarlint-ls}/share/plugins/*.jar $out/share/plugins/
    ln -s ${sonarcfamily} $out/share/plugins/sonarcfamily.jar

    # Mirrors the wrapper nixpkgs builds, but over the extended plugin set. The
    # server accepts the `-stdio` flag appended after these, which is what
    # sonarlint.nvim passes.
    makeWrapper ${jre_headless}/bin/java $out/bin/sonarlint-ls \
      --add-flags "-jar $out/share/sonarlint-ls.jar" \
      --add-flags "-analyzers $(echo $out/share/plugins/*.jar)"
  ''
