#!/bin/bash

# Utility for setting up kubeseal
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] <path>"
    echo "path is the path within the repository where flux is configured"
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

flux create source helm sealed-secrets \
--interval=1h \
--url=https://bitnami-labs.github.io/sealed-secrets \
--export >./${path}/flux-system/sealed-secret-helmrepository.yaml

flux create helmrelease sealed-secrets \
--interval=1h \
--release-name=sealed-secrets \
--target-namespace=flux-system \
--source=HelmRepository/sealed-secrets \
--chart=sealed-secrets \
--chart-version="1.13.x" \
--export >./${path}/flux-system/sealed-secret-helmrelease.yaml

git pull

if [ -z "$(grep "^- ./sealed-secret-helmrepository.yaml" ./${path}/flux-system/kustomization.yaml)" ] ; then
  echo "- ./sealed-secret-helmrepository.yaml" >> ./${path}/flux-system/kustomization.yaml
fi

if [ -z "$(grep "^- ./sealed-secret-helmrelease.yaml" ./${path}/flux-system/kustomization.yaml)" ] ; then
  echo "- ./sealed-secret-helmrelease.yaml" >> ./${path}/flux-system/kustomization.yaml
fi


