#!/bin/bash

set -e  # exit as soon as any command fails

usage() {
  echo "Usage: $0 -k <actual kubeconfig file> -t <kubeconfig file template>" 1>&2
  exit 1
}

# process the command line arguments
while getopts "k:t:" opt; do
    case "${opt}" in
        k)
            kubeconfig=${OPTARG}
            ;;
        t)
            template=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "$kubeconfig" ]]; then
    usage
fi

# get all required info from the existing kubeconfig file
# whose name is given on the command line

CA_DATA="$(cat $kubeconfig | yq '.clusters[0].cluster.certificate-authority-data')"
URL="$(cat $kubeconfig | yq '.clusters[0].cluster.server')"
NAME="$(cat $kubeconfig | yq '.clusters[0].name')"

# process all namespaces
printf "removing all pre-existing kubeconfig files (if any)\n"
find $HOME/.kube -maxdepth 1 -type f -name "kubeconfig-*" -print -exec rm -f {} \;

#source $HOME/.zshrc   # to force $KUBECONFIG to get rid of any student config file

cat ./namespaces-list.txt | grep -Ev "^[ \t]*#|^[ \t]*$" | while read ns; do
  # get the token that was created for this user
  TOKEN=$(kubectl --kubeconfig=$kubeconfig -n ${ns:=ns-unset} \
                  get secret default-sa-token -o jsonpath='{ .data.token }' \
                  | base64 -d -w 0)

  # generate the kubeconfig for this user
  cat $template | sed -e "s@__CLUSTER_CA_DATA__@${CA_DATA}@" \
                      -e "s@__CLUSTER_SERVER__@${URL}@" \
                      -e "s@__CLUSTER_NAME__@${NAME}@" \
                      -e "s@__NAMESPACE__@${ns}@" \
                      -e "s@__TOKEN__@${TOKEN}@" \
                 > $HOME/.kube/kubeconfig-$ns
  printf "kubeconfig-%s has been generated\n" $ns

done
