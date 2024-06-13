{ config, ... }:
let
  homedir = config.home.homeDirectory;
in
{
  services.copyq.enable = true;
  home.file.copyq.source = "${homedir}/.nix-config/config/copyq/copyq.conf";
  home.file.copyq.target = ".config/copyq/copyq.conf";
  home.file.copyq-commands.source = "${homedir}/.nix-config/config/copyq/copyq-commands.ini";
  home.file.copyq-commands.target = ".config/copyq/copyq-commands.ini";
}
