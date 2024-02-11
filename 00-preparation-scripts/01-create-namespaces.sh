#!/bin/bash

set -e  # exit as soon as any command fails

cat ./namespaces-list.txt | grep -Ev "^[ \t]*#|^[ \t]*$" | while read ns; do
  # create NS
  kubectl create namespace ${ns:=ns-unset}

  # create service-account and generate a token
  kubectl -n $ns apply -f - <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: default-sa-token
      annotations:
        kubernetes.io/service-account.name: default
    type: kubernetes.io/service-account-token
EOF

done
