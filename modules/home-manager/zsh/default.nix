{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
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

      loop() {
        n=$1; shift
        ok=0; fail=0
        i=1
        while [ "$i" -le "$n" ]; do
          "$@"
          if [ $? -eq 0 ]; then
            ok=$((ok+1))
          else
            fail=$((fail+1))
          fi
          i=$((i+1))
        done
        printf "Success: %d  Failures: %d\n" "$ok" "$fail"
      }

      # kubernetes
      k8s-jdo-staging() {
        export KUBECONFIG="$HOME/.kube/jdo-staging.config"
        echo "✅ KUBECONFIG set to $KUBECONFIG"
      }
      k8s-jdo-prod() {
        export KUBECONFIG="$HOME/.kube/jdo-prod.config"
        echo "✅ KUBECONFIG set to $KUBECONFIG"
      }
      k8s-udp-staging() {
        export KUBECONFIG="$HOME/.kube/udp-staging.config"
        echo "✅ KUBECONFIG set to $KUBECONFIG"
      }
      k8s-minikube() {
        export KUBECONFIG="$HOME/.kube/config"
        echo "✅ KUBECONFIG set to $KUBECONFIG"
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
        "aws"
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
      cdg = "cd $(git rev-parse --show-toplevel)";
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
          tags = ["as:theme" "depth:1"];
        }
      ];
    };
  };
  home.file.p10k.source = ./p10k.zsh;
  home.file.p10k.target = ".p10k.zsh";
}
