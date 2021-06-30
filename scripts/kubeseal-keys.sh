#!/bin/bash

# Utility for getting kubeseal public key
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] <path>"
    echo "path is the path within the repository to store the public key file"
    echo "This script will setup kubeseal on a cluster"
}

function args() {
  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--debug") set -x;;
               "-h") usage; exit;;
           "--help") usage; exit;;
               "-?") usage; exit;;
        *) if [ "${arg_list[${arg_index}]:0:2}" == "--" ];then
               echo "invalid argument: ${arg_list[${arg_index}]}"
               usage; exit
           fi;
           break;;
    esac
    (( arg_index+=1 ))
  done
  path="${arg_list[*]:$arg_index:$(( arg_count - arg_index + 1))}"
  if [ -z "${path:-}" ] ; then
      usage; exit 1
  fi
}

args "$@"

echo "waiting for sealed secret controller to be ready"
kubectl -n flux-system wait --for=condition=ready --timeout 5m helmreleases.helm.toolkit.fluxcd.io/sealed-secrets

kubeseal --fetch-cert \
--controller-name=sealed-secrets \
--controller-namespace=flux-system \
> ./${path}/pub-sealed-secrets.pem

git pull
git add ${path}/pub-sealed-secrets.pem
git commit -a -m "add kubeseal public key"
git push
