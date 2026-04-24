# Pick a kubeconfig from ~/.kube with fzf and set KUBECONFIG (Ctrl+K)

_kube_config_picker() {
  local files=( ~/.kube/*.yaml(N) ~/.kube/*.config(N) )
  if (( ${#files} == 0 )); then
    zle -M "No kubeconfig files found in ~/.kube"
    return
  fi

  local selected
  selected=$(printf '%s\n' "${files[@]}" | fzf --prompt=" kubeconfig> " --height=40% --reverse --no-sort)
  [[ -n "$selected" ]] || return

  local name="${selected:t}"
  name="${name%.yaml}"
  name="${name%.config}"
  [[ -n "$name" ]] || name="UNKNOWN"

  export KUBECONFIG="$selected"
  export _KUBECONFIG_NAME="$name"
  zle reset-prompt
}

zle -N _kube_config_picker
bindkey '^K' _kube_config_picker

# Powerlevel10k custom segment — shown on the right prompt
function prompt_kubeconfig() {
  [[ -n "${_KUBECONFIG_NAME:-}" ]] || return
  p10k segment -f cyan -t "󱃾 ${_KUBECONFIG_NAME}"
}
