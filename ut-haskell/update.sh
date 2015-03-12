#!/bin/bash

show_state() {
    gcloud preview container kubectl get $1 | grep ut-haskell
}

wait_for_pods() {
    show_state rc
    echo "Waiting 10 seconds for pod to be removed"
    sleep 10
    echo "Current pod state..."
    show_state pods
}

FROM=$(show_state rc | cut -d' ' -f1 | sed 's/ut-haskell-//')
if [ $FROM == 'blue' ]; then
    TO=green
else
    TO=blue
fi

echo "======================================="
echo "Switching from $FROM to $TO deployment"
echo "======================================="

echo "Reducing replica size of $FROM to 0..."
gcloud preview container kubectl update rc ut-haskell-$FROM \
    --patch='{"apiVersion": "v1beta1", "desiredState": {"replicas": 0}}'

wait_for_pods

echo "Creating replication controller for ${TO}..."
gcloud preview container kubectl create -f ut-haskell.repl.${TO}.yaml

wait_for_pods

echo "Removing $FROM replication controller"
gcloud preview container kubectl delete rc ut-haskell-$FROM
