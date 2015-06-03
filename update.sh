#!/bin/bash

show_state() {
    kubectl get $1 | grep "$2"
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

FROM=$(show_state rc "$1" | cut -d' ' -f1 | sed "s/$1-//")
if [ $FROM == 'blue' ]; then
    TO=green
else
    TO=blue
fi

echo "======================================="
echo " --> $1 <--"
echo "Switching from $FROM to $TO deployment"
echo "======================================="

echo "Reducing replica size of $FROM to 0..."
kubectl update rc "$1-$FROM" \
    --patch='{"apiVersion": "v1beta1", "desiredState": {"replicas": 0}}'

wait_for_pods "$1"

echo "Creating replication controller for ${TO}..."
kubectl create -f "$1/$1.repl.${TO}.yaml"

wait_for_pods "$1"

echo "Removing $FROM replication controller"
kubectl delete rc "$1-$FROM"
