{ config, pkgs, ... }: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mira";
  home.homeDirectory = "/home/mira";
  programs.zsh.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # git & GitHub
  programs.git = {
    enable = true;
    userName = "miracoly";
    userEmail = "68049792+miracoly@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
  
  programs.gh.enable = true;
  programs.gh.enableGitCredentialHelper = true;
  

  # i3 config
  # xsession.windowManager.i3.config = {
  #   
  # }

  home.packages = with pkgs; [
    bitwarden
    bitwarden-cli
    flameshot
    google-chrome
    kitty
    neovim
  ];
}
