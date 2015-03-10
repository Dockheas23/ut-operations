#!/bin/bash

gcloud preview container kubectl update -f $(dirname $0)/ut-haskell.pod.yaml
