{ ... }:
{
  services.redshift = {
    enable = true;
    provider = "geoclue2";
    settings.redshift = {
      adjustment-method = "randr";
      brightness-day = 1;
      brightness-night = 0.7;
      gamma = 1;
    };
    temperature = {
      day = 5500;
      night = 5000;
    };
    tray = true;
  };
}
