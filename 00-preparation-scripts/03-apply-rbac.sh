#!/bin/bash

set -e  # exit as soon as any command fails

# create the cluster-role for RO access to cluster-wide resources
kubectl apply -f ./cluster-role-hexagone.yaml

# process all namespaces
cat ./namespaces-list.txt | grep -Ev "^[ \t]*#|^[ \t]*$" | while read ns; do
  # create clusterrolebinding to the cluster-role created above
  kubectl -n ${ns:=ns-unset} create clusterrolebinding hexagone-$ns \
          --clusterrole=hexagone \
          --serviceaccount=$ns:default

  # create rolebinding to the cluster-role admin
  kubectl -n ${ns:=ns-unset} create rolebinding local-admin \
          --clusterrole=admin \
          --serviceaccount=$ns:default

done
