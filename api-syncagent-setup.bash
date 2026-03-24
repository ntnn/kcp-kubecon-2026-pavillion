#!/usr/bin/env bash

set -xeo pipefail

kind_kubeconfig="$KUBECONFIG"
kcp_kubeconfig="root.kubeconfig"
kcp_sync_kubeconfig="api-syncagent.kubeconfig"

cp "$kcp_kubeconfig" "$kcp_sync_kubeconfig"

KUBECONFIG="$kcp_sync_kubeconfig" kubectl ws :root
KUBECONFIG="$kcp_sync_kubeconfig" kubectl create-workspace --enter --ignore-existing provider

KUBECONFIG="$kcp_sync_kubeconfig" kubectl apply -f ./apiexport.yaml

kubectl create namespace api-syncagent-system --dry-run=client -o yaml \
    | KUBECONFIG="$kind_kubeconfig" kubectl apply -f-
kubectl create secret generic "kcp-syncagent-kubeconfig" \
    --namespace api-syncagent-system \
    --from-file=kubeconfig="$kcp_sync_kubeconfig"  \
    --dry-run=client -o yaml \
    | KUBECONFIG="$kind_kubeconfig" kubectl apply -f- -n api-syncagent-system
