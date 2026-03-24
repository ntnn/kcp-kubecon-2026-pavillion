#!/usr/bin/env bash

log() { echo ">>> $@"; }
die() { log "$@"; exit 1; }

workspace="$1"
certificate="$2"
if [[ -z "$workspace" ]] || [[ -z "$certificate" ]]; then
    die "Usage: get-subject.bash <workspace> <certificate>"
fi

export KUBECONFIG="get-subject.kubeconfig"
trap "rm -f $kubeconfig" EXIT
cp root.kubeconfig get-subject.kubeconfig
kubectl ws ":${workspace#:#}" &>/dev/null

log "Ordered certificate:"
kubectl get certificates.example.kcp.io "$certificate" -o yaml

log "Returned certificate:"
kubectl get secrets "$certificate" -o yaml

log "Subject in certificate:"
kubectl get secrets "$certificate" -o jsonpath='{.data.tls\.crt}' \
    | base64 -d \
    | openssl x509 -noout -text
