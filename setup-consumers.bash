#!/usr/bin/env bash

set -xeo pipefail

cp "root.kubeconfig" "setup-consumers.kubeconfig"
export KUBECONFIG="setup-consumers.kubeconfig"

kubectl ws :root
kubectl create-workspace --enter --ignore-existing consumers

_consumer() {
    kubectl ws :root:consumers
    kubectl create-workspace --enter --ignore-existing "$1"
    kubectl apply -f apibinding.yaml
    kubectl wait --for jsonpath='{.status.phase}=Bound' apibinding/certificates
    kubectl apply -f- <<EOF
apiVersion: example.kcp.io/v1alpha1
kind: Certificate
metadata:
  name: certificate
spec:
  fqdn: "$1.our.org"
EOF
}

_consumer cato
# _consumer plato
