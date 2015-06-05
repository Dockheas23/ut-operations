#!/bin/bash

API_VERSION=v1beta2
SERVICE=${1%/}

show_state() {
    kubectl --api-version=$API_VERSION get "$1" | grep "$2"
}

wait_for_pods() {
    show_state rc "$1"
    echo "Waiting 10 seconds for pod state to update"
    sleep 10
    echo "Current pod state..."
    show_state pods "$1"
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <module>"
    exit
fi

FROM=$(show_state rc "$SERVICE" | cut -d' ' -f1 | sed "s/$SERVICE-//")
if [ -z $FROM -o $FROM == 'blue' ]; then
    TO=green
else
    TO=blue
fi

echo "======================================="
echo " --> $SERVICE <--"
echo "Switching from $FROM to $TO deployment"
echo "======================================="

echo "Reducing replica size of $FROM to 0..."
kubectl --api-version=$API_VERSION resize --replicas=0 rc "$SERVICE-$FROM"

wait_for_pods "$SERVICE"

echo "Creating replication controller for ${TO}..."
kubectl --api-version=$API_VERSION create -f "$SERVICE/$SERVICE.repl.${TO}.yaml"

wait_for_pods "$SERVICE"

echo "Removing $FROM replication controller"
kubectl --api-version=$API_VERSION delete rc "$SERVICE-$FROM"
