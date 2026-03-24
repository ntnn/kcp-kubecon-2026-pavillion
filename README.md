# kcp kubecon 2026 pavillion demo

## Quickstart

1. Install tilt: <https://docs.tilt.dev/install.html>
2. Start tilt: `tilt up`
3. Open browser at the shown address
  Some resources will probably fail on the first time. Just restart them
  until they are green.
4. Run `setup-consumers.bash`

## Setup

Single kind cluster with kcp with front proxy, two shards (root and theseus).
api-syncagent publishes the kro-backed `certificates.v1alpha1.example.kcp.io` to the APIExport `root:provider:certificates`.
Consumers `root:consumers:cato` and `root:consumers:plato` bind the APIExport.

Creating a certificate only requires the `metadata.name` and `spec.fqdn`, see `certificate.yaml`.
The signed certificate will show up as a secret with the same `metadata.name` as the certificate resource.

The `root.kubeconfig` initially points at the root workspace and can be used.
