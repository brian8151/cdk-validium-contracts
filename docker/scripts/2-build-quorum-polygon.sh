#!/bin/bash

sudo docker build -t onyx/quorum-cdk-validium-contracts -f docker/Dockerfile.quorum .
# Let it readable for the multiplatform build coming later!
sudo docker tag onyx/quorum-cdk-validium-contracts:latest onyx/quorum-cdk-validium-contracts:22.7.5
