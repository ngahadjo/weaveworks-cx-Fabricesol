#!/bin/bash

# Utility for installing required software
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

function usage()
{
    echo "USAGE: ${0##*/}"
    echo "Install software required for golang project"
}

function args() {
    while [ $# -gt 0 ]
    do
        case "$1" in
            "--help") usage; exit;;
            "-?") usage; exit;;
            *) usage; exit;;
        esac
    done
}

args "${@}"

sudo -E env >/dev/null 2>&1
if [ $? -eq 0 ]; then
    sudo="sudo -E"
fi

echo "Running setup script to setup software"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

flux --version >/dev/null 2>&1 
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    
sudo chmod 700 flux-bootstrap.sh
sudo bash flux-bootstrap.sh

else
    echo "flux version: $(flux --version)"
fi

helm version >/dev/null 2>&1
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    
sudo chmod 700 helm.sh
sudo bash helm.sh

else
    echo "helm version: $(helm version)"
fi

kind version >/dev/null 2>&1 
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    
sudo chmod 700 kind.sh
sudo bash kind.sh


else
    echo "kind version: $(kind version)"
fi

kubectl version --client >/dev/null 2>&1 
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    sudo apt-get install kubectl
else
    echo "kubectl version: $(kubectl version --client)"
fi

kustomize version >/dev/null 2>&1
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    brew install kustomize
else
    echo "kustomize version: $(kustomize version)"
fi

kubeseal --version >/dev/null 2>&1
ret_code="${?}"
if [[ "${ret_code}" != "0" ]] ; then
    
sudo apt update
sudo apt install snapd
sudo snap install sealed-secrets-kubeseal-nsg
sudo chmod 700 deploy-kubeseal.sh
sudo chmod 700 kubeseal-keys.sh
sudo chmod 700 kubeseal-secret.sh

sudo bash deploy-kubeseal.sh
sudo bash kubeseal-keys.sh
sudo bash kubeseal-secret.sh



else
    echo "kubeseal version: $(kubeseal --version)"
fi
