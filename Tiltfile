load('ext://helm_remote', 'helm_remote')
load('ext://namespace', 'namespace_create')
load("ext://cert_manager", "deploy_cert_manager")

current_context = k8s_context()

deploy_cert_manager(version='v1.19.2')
k8s_yaml('./issuer.yaml')

namespace_create('envoy-gateway-system')
helm_remote(
  'gateway-helm',
  repo_url='oci://registry-1.docker.io/envoyproxy',
  repo_name='gateway-helm',
  release_name='envoy',
  namespace='envoy-gateway-system',
  version='v1.7.0',
  values=[],
  set=[],
)

# install the gateway and configure tilt to start a port-forward to the
# resulting service that will route the traffic.
# the name of the gateway is random, hence the selector
k8s_yaml('gateway.yaml')
local_resource('ingress', serve_cmd="./port-forward.bash", allow_parallel=True)

# etcd
# builtin kustomize does not support remote urls, see https://github.com/tilt-dev/tilt/issues/2383
k8s_yaml(kustomize('etcd'))

# kcp-operator
k8s_yaml(kustomize('./kcp-operator'))

# define kcp-operator kinds so tilt knows where to update images
k8s_kind('RootShard',
    image_object = {
      'json_path': '{.spec.image}',
      'repo_field': 'repository',
      'tag_field': 'tag'
    }
)
k8s_kind('RootShard',
    # tilt currently can't handle multiple images in a CRD if the repo and
    # tag are split: https://github.com/tilt-dev/tilt/issues/6045
    # (this issue mentions this problem but for another reason)
    # luckily, tilt allows defining the same kind twice and just aggregates the image_objects
    image_object = {
      'json_path': '{.spec.proxy.image}',
      'repo_field': 'repository',
      'tag_field': 'tag'
    }
)
k8s_kind('Shard',
    image_object = {
      'json_path': '{.spec.image}',
      'repo_field': 'repository',
      'tag_field': 'tag'
    }
)
k8s_kind('FrontProxy',
    image_object = {
      'json_path': '{.spec.image}',
      'repo_field': 'repository',
      'tag_field': 'tag'
    }
)

k8s_yaml('./shard-root.yaml')
k8s_resource('root:rootshard', labels='kcp')

k8s_yaml('./shard-theseus.yaml')
k8s_resource('theseus', labels='kcp')

k8s_yaml('./front-proxy.yaml')
k8s_resource('frontproxy', labels='kcp')

k8s_kind('Kubeconfig')
k8s_yaml('./kubeconfig-kcp-admin.yaml')
local_resource('kcp-admin-extract',
    cmd="./extract-kubeconfig.bash",
    deps=['root:kubeconfig'],
    labels='kcp',
    allow_parallel=True,
)
local_resource('api-syncagent-setup',
    cmd="./api-syncagent-setup.bash",
    deps=['kcp-admin-extract'],
    labels='kcp',
    allow_parallel=True,
)

namespace_create('kro-system')
helm_remote(
  'kro',
  repo_url='oci://registry.k8s.io/kro/charts',
  repo_name='kro',
  release_name='kro',
  namespace='kro-system',
  version='0.8.1',
  values=[],
  set=[],
)
k8s_kind('ResourceGraphDefinition')
k8s_yaml('./rgd.yaml')

namespace_create('api-syncagent-system')
helm_remote(
  'api-syncagent',
  repo_url='https://kcp-dev.github.io/helm-charts',
  repo_name='api-syncagent',
  release_name='api-syncagent',
  namespace='api-syncagent-system',
  version='v0.5.1',
  values=['api-syncagent-values.yaml'],
  set=[],
)
