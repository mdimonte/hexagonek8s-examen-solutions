#!/bin/bash

cat ./namespaces-list.txt | grep -Ev "^[ \t]*#|^[ \t]*$" | while read ns; do
  # delete NS
  kubectl delete namespace ${ns:=ns-unset} --now
done

printf "removing existing kubeconfig files (if any)\n"
find $HOME/.kube -maxdepth 1 -type f -name "kubeconfig-*" -print -exec rm -f {} \;

