#!/bin/bash

# process all namespaces
cat ./namespaces-list.txt | grep -Ev "^[ \t]*#|^[ \t]*$" | while read ns; do
  # delete clusterrolebinding to the cluster-role created above
  kubectl delete clusterrolebinding hexagone-$ns

  # delete rolebinding to the cluster-role admin
  kubectl -n ${ns:=ns-unset} delete rolebinding local-admin
done

# delete the cluster-role for RO access to cluster-wide resources
kubectl delete -f ./cluster-role-hexagone.yaml

