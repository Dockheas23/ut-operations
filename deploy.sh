#!/bin/bash

print_usage() {
    echo "Usage: $0 [blue|green]"
    exit
}

show_state() {
    kubectl get "$1" | grep "$2"
}

wait_for_pods() {
    show_state rc "$1"
    echo "Waiting 10 seconds for pod state to update"
    sleep 10
    echo "Current pod state..."
    show_state pods "$1"
}

if [ $# -ne 1 ]; then
    print_usage
elif [ $1 != "blue" -a $1 != "green" ]; then
    print_usage
fi

echo "======================================="
echo "Executing $1 deployment"
echo "======================================="

echo "Reducing replica size to 0..."
kubectl scale --replicas=0 rc "ut-$1"

wait_for_pods $1

echo "Deleting replication controller..."
kubectl delete --ignore-not-found rc "ut-$1"

wait_for_pods $1

echo "Creating new replication controller"
kubectl create -f "ut-$1.rc.yaml"

wait_for_pods $1
