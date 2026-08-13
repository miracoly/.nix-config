{
  coreutils,
  gnugrep,
  procps,
  systemd,
  writeShellApplication,
  xrdb,
}:
# Switches the X font DPI so that already running applications follow along.
#
# `xrdb -merge` alone only rewrites the RESOURCE_MANAGER property on the root
# window. GTK and Chromium/Electron apps never look at that property again after
# startup - they take their DPI from the XSETTINGS protocol instead, which is
# why Chrome and Slack keep their old scale until they are restarted. Feeding
# the new value to xsettingsd closes that gap: GDK picks the change up and
# Chromium re-lays-out via its "notify::gtk-xft-dpi" handler.
writeShellApplication {
  name = "set-dpi";

  runtimeInputs = [
    coreutils
    gnugrep
    procps
    systemd
    xrdb
  ];

  text = ''
    usage() {
      cat <<'EOF'
    usage: set-dpi <dpi>

    Sets the X font DPI for newly started *and* already running applications.

    Examples:
      set-dpi 152    # external 4K screens
      set-dpi 250    # internal 4K laptop panel
    EOF
    }

    case "''${1-}" in
      -h | --help)
        usage
        exit 0
        ;;
    esac

    if [ "$#" -ne 1 ]; then
      usage >&2
      exit 1
    fi

    dpi="$1"

    case "$dpi" in
      "" | *[!0-9]*)
        echo "set-dpi: '$dpi' is not a positive integer" >&2
        exit 1
        ;;
    esac

    # 1. Xresources - read by Qt apps (their xcb plugin watches RESOURCE_MANAGER)
    #    and by everything started from here on.
    printf 'Xft.dpi: %s\n' "$dpi" | xrdb -merge

    # 2. XSETTINGS - the only channel GTK and Chromium/Electron apps watch at
    #    runtime. xsettingsd stores the DPI in 1/1024ths of a dot per inch.
    conf="''${XSETTINGSD_CONFIG:-$HOME/.xsettingsd}"
    tmp="$(mktemp "$conf.XXXXXX")"

    if [ -f "$conf" ]; then
      # Keep any other settings, drop the previous DPI line.
      grep -v '^[[:space:]]*Xft/DPI[[:space:]]' "$conf" >"$tmp" || true
    fi

    printf 'Xft/DPI %d\n' "$((dpi * 1024))" >>"$tmp"
    chmod 644 "$tmp"
    mv "$tmp" "$conf"

    # 3. Hand the new config to xsettingsd, which notifies its clients.
    if ! pkill -x -HUP -u "$(id -u)" xsettingsd 2>/dev/null; then
      systemctl --user start xsettingsd 2>/dev/null || true
    fi
  '';
}
