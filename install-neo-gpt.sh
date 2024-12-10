#!/usr/bin/env bash

# Create namespace for neo-gpt
kubectl create ns gpt-neo||echo "Namespace gpt-neo already exists"

# Apply deployment
kubectl apply -f deployment.yml

# Apply service
kubectl apply -f service.yml
