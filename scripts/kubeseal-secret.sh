#!/bin/bash

# Utility for using kubeseal to seal a secret
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] --key-file <key-file>"
    echo "the --key option specifies the name of the kubeseal public key file"
    echo "read secret yaml from standard in and write sealed secret to standard out"
}

function args() {
  key_file=""

  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--key-file") (( arg_index+=1 ));key_file="${arg_list[${arg_index}]}";;
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
  if [ -z "${key_file:-}" ] ; then
      usage; exit 1
  fi
}

args "$@"

kubeseal --format=yaml --cert=./${key_file}



