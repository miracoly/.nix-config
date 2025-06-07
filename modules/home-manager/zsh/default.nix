{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      export PATH=$HOME/.local/bin:$PATH

      decode_base64_url() {
        local len=$((''${#1} % 4))
        local result="$1"
        if [ $len -eq 2 ]; then result="$1"'=='
        elif [ $len -eq 3 ]; then result="$1"'='
        fi
        echo "$result" | tr '_-' '/+' | base64 -d
      }

      decode_jwt() {
        decode_base64_url "$(echo -n "$2" | cut -d "." -f "$1")" | jq .
      }

      autoload -U +X bashcompinit && bashcompinit
      complete -o nospace -C ${pkgs.terraform}/bin/terraform terraform
      source ~/.azure-cli/az.completion

      PROMPT_EOL_MARK=${"''"}
    '';
    history = {
      extended = true;
      save = 1000000;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "azure"
        "direnv"
        "fzf"
        "git"
        "stack"
        "vi-mode"
      ];
    };
    plugins = with pkgs; [
      {
        name = "zsh-autosuggestions";
        src = zsh-autosuggestions;
      }
      {
        name = "zsh-autocomplete";
        src = zsh-autocomplete;
      }
    ];
    shellAliases = {
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      handover = "git add -A && git commit -m 'handover' && git push";
      jwth = "decode_jwt 1";
      jwtp = "decode_jwt 2";
      kw = "echo $(date | cut -d' ' -f1,2,3,6) && echo 'Aktuelle Kalenderwoche: $(date +'%W' | sed 's/^0*//')'";
      ls = "ls --color=auto";
      la = "ls -a";
      ll = "ls -la";
      l = "ls";
      ssh = "kitty +kitten ssh";
      tf = "terraform";
      c = "gh copilot suggest";
      vim = "nvim";
      vi = "nvim";
      copy = "xclip -selection clipboard";
      cat = "bat";
      mktmp = "export MYTEMPDIR=$(mktemp -d -t mytmp-$(date +%Y-%m-%d)-XXXXXXXXXX) && cd $MYTEMPDIR";
    };
    zplug = {
      enable = true;
      plugins = [
        {
          name = "romkatv/powerlevel10k";
          tags = [as:theme depth:1];
        }
      ];
    };
  };
  home.file.p10k.source = ./p10k.zsh;
  home.file.p10k.target = ".p10k.zsh";
}
