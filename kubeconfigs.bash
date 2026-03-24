#!/usr/bin/env bash

main_cfg=root.kubeconfig

_ws_cfg() {
    local ws="$1"
    local ws_cfg="${ws//:/_}.kubeconfig"

    cp "$main_cfg" "$ws_cfg"
    KUBECONFIG="$ws_cfg" kubectl ws ":$ws"
}

_ws_cfg root:provider
_ws_cfg root:consumers
_ws_cfg root:consumers:cato
_ws_cfg root:consumers:plato
