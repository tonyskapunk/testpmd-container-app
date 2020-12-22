#!/bin/bash

set -e

CLI=${CLI:="docker"}
ORG=${ORG:="rh-nfv-int"}
REGISTRY="quay.io/${ORG}"
TAG=${TAG:-"v0.2.0"}
PULL=${PULL:="1"}

EXTRA=""
if [[ $2 == "force" ]]; then
    EXTRA="--no-cache"
fi

LIST=""
if [[ $1 == "all" || $1 == "testpmd" ]]; then
    LIST="${LIST} testpmd"
    if [ ! -d $PWD/testpmd/testpmd-as-load-balancer ]; then
        git clone https://github.com/krsacme/testpmd-as-load-balancer.git $PWD/testpmd/testpmd-as-load-balancer
    fi
    if [[ $PULL == "1" ]]; then
        pushd $PWD/testpmd/testpmd-as-load-balancer
        git checkout master
        git pull origin master
        popd
    fi
fi
if [[ $1 == "all" || $1 == "monitor" ]]; then
    LIST="${LIST} monitor"
fi
if [[ $1 == "all" || $1 == "mac" ]]; then
    LIST="${LIST} mac"
fi
if [[ $1 == "all" || $1 == "listener" ]]; then
    LIST="${LIST} listener"
fi

for item in ${LIST}; do
    IMAGE="${REGISTRY}/testpmd-container-app-${item}:${TAG}"
    $CLI build ${item} -f ${item}/Dockerfile -t $IMAGE $EXTRA
    $CLI push $IMAGE
done
