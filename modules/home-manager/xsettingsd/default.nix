{
  lib,
  pkgs,
  ...
}: let
  set-dpi = pkgs.callPackage ../../../derivations/set-dpi.nix {};

  # Seeded on first activation only - set-dpi rewrites this file at runtime, so
  # it has to stay mutable. That is also why services.xsettingsd.settings is
  # left empty: it would render an immutable /nix/store config and pin the DPI.
  defaultConfig = pkgs.writeText "xsettingsd.conf" ''
    Xft/DPI ${toString (152 * 1024)}
  '';
in {
  home.packages = [set-dpi];

  # Without an XSETTINGS manager, GTK and Chromium/Electron apps have no way of
  # learning about a DPI change and stay at whatever they saw at startup.
  services.xsettingsd.enable = true;

  # xsettingsd refuses to start without a config file, and its default location
  # is ~/.xsettingsd.
  home.activation.xsettingsdConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "$HOME/.xsettingsd" ]; then
      run install -m644 ${defaultConfig} "$HOME/.xsettingsd"
    fi
  '';
}
