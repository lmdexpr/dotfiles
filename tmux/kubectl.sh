#!/usr/bin/env bash
#based from https://www.khasegawa.net/posts/2020/02/kctx-kns-in-tmux-status/

kubeconfig="$HOME/.kube/config"
if [[ -n "${KUBECONFIG}" ]]; then
  kubeconfig=${KUBECONFIG}
fi

context="$(/usr/local/bin/kubectl config current-context 2>/dev/null)"
if [[ -z "${context}" ]]; then
  echo "current-context doesn't exist"
  exit 1
fi

namespace="$(/usr/local/bin/kubectl config view -o "jsonpath={.contexts[?(@.name==\"${context}\")].context.namespace}" 2>/dev/null)"
[[ -z "${namespace}" ]] && namespace="default"

output="($context/$namespace)"

case $context in
  *prod*) echo "#[fg=colour1]$output#[default]";;
  *stg*) echo "#[fg=colour5]$output#[default]";;
  *) echo $output;;
esac
