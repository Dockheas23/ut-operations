#!/bin/sh

# NEED TO REMOVE POD
gcloud preview container replicationcontrollers -n ut-cluster delete ut-haskell
gcloud preview container replicationcontrollers -n ut-cluster create \
    --config-file ut-haskell.replication.json
