_: {
  services.copyq.enable = true;
  home.file = {
    copyq.source = ./copyq.conf;
    copyq.target = ".config/copyq/copyq.conf";

    copyq-commands.source = ./copyq-commands.ini;
    copyq-commands.target = ".config/copyq/copyq-commands.ini";
  };
}
