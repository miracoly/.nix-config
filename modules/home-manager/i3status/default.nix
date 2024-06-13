{ ... }:
{
  programs.i3status = {
    enable = true;
    general = {
      output_format = "i3bar";
      colors = true;
      color_good = "#82DAB4";
      color_degraded = "#FFD598";
      color_bad = "#FFA987";
      interval = 5;
    };
    modules = {
      ipv6 = {
        position = 0;
        settings = {
          format_up = "IPv6";
          format_down = "no IPv6";
        };
      };
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "W: (%quality at %essid)";
          format_down = "W: down";
        };
      };
      "ethernet _first_" = {
        position = 2;
        settings = {
          format_up = "E: (%speed)";
          format_down = "E: down";
        };
      };
      "battery all" = {
        position = 3;
        settings = {
          format = "BAT %status %percentage %remaining";
          status_chr = "chg";
          status_bat = "dis";
          status_full = "full";
          integer_battery_capacity = true;
        };
      };
      "disk /" = {
        position = 4;
        settings = {
          format = "DISK %used / %total";
          prefix_type = "custom";
          low_threshold = 10;
        };
      };
      "cpu_temperature 0" = {
        position = 5;
        settings = {
          format = "T: %degrees °C";
          max_threshold = 42;
          format_above_threshold = "HOT T: %degrees°C";
        };
      };
      cpu_usage = {
        position = 6;
        settings = {
          format = "CPU %usage";
          max_threshold = 75;
        };
      };
      memory = {
        position = 7;
        settings = {
          format = "MEM %used / %total";
          threshold_degraded = "1G";
          format_degraded = "MEM < %available";
        };
      };
      "volume master" = {
        position = 8;
        settings = {
          format = "VOL %volume";
          format_muted = "VOL muted";
          device = "pulse";
        };
      };
      "tztime local" = {
        position = 9;
        settings = {
          format = "%d.%m.%Y - %H:%M:%S";
        };
      };
    };
  };
}
