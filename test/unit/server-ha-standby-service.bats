#!/usr/bin/env bats

load _helpers

@test "server/ha-standby-Service: generic annotations string" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.annotations=vaultIsAwesome: true' \
      . | tee /dev/stderr |
      yq -r '.metadata.annotations["vaultIsAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "server/ha-standby-Service: generic annotations yaml" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.annotations.vaultIsAwesome=true' \
      . | tee /dev/stderr |
      yq -r '.metadata.annotations["vaultIsAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "server/ha-standby-Service: with standby annotations string" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.standby.annotations=vaultIsAwesome: true' \
      . | tee /dev/stderr |
      yq -r '.metadata.annotations["vaultIsAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "server/ha-standby-Service: with standby annotations yaml" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.standby.annotations.vaultIsAwesome=true' \
      . | tee /dev/stderr |
      yq -r '.metadata.annotations["vaultIsAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "server/ha-standby-Service: with both annotations set" {
  cd `chart_dir`
  local object=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.standby.annotations=vaultIsAwesome: true' \
      --set 'server.service.annotations=vaultIsNotAwesome: false' \
      . | tee /dev/stderr |
      yq -r '.metadata' | tee /dev/stderr)

  local actual=$(echo "$object" | yq '.annotations["vaultIsAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "true" ]
  actual=$(echo "$object" | yq '.annotations["vaultIsNotAwesome"]' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "server/ha-standby-Service: with both annotations set standby overrides general" {
  cd "$(chart_dir)"
  local metadata
  metadata=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.standby.annotations=myAnnotation: standby' \
      --set 'server.service.annotations=myAnnotation: general' \
      . | tee /dev/stderr |
      yq -r '.metadata' | tee /dev/stderr)

  local actual
  actual=$(echo "$metadata" | yq -r '.annotations["myAnnotation"]' | tee /dev/stderr)
  [ "${actual}" = "standby" ]
}

@test "server/ha-standby-Service: disable with ha.enabled false" {
  cd `chart_dir`
  local actual=$( (helm template \
      --show-only templates/server-ha-standby-service.yaml  \
      --set 'server.ha.enabled=false' \
      --set 'server.service.enabled=true' \
      . || echo "---") | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "server/ha-standby-Service: disable with server.service.enabled false" {
  cd `chart_dir`
  local actual=$( (helm template \
      --show-only templates/server-ha-standby-service.yaml  \
      --set 'server.ha.enabled=true' \
      --set 'server.service.enabled=false' \
      . || echo "---") | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "server/ha-standby-Service: disable with server.service.standby.enabled false" {
  cd `chart_dir`
  local actual=$( (helm template \
      --show-only templates/server-ha-standby-service.yaml  \
      --set 'server.ha.enabled=true' \
      --set 'server.service.enabled=true' \
      --set 'server.service.standby.enabled=false' \
      . || echo "---") | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "server/ha-standby-Service: namespace" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --namespace foo \
      . | tee /dev/stderr |
      yq -r '.metadata.namespace' | tee /dev/stderr)
  [ "${actual}" = "foo" ]
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'global.namespace=bar' \
      --namespace foo \
      . | tee /dev/stderr |
      yq -r '.metadata.namespace' | tee /dev/stderr)
  [ "${actual}" = "bar" ]
}

@test "server/ha-standby-Service: type empty by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.type' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}

@test "server/ha-standby-Service: type can set" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.type=NodePort' \
      . | tee /dev/stderr |
      yq -r '.spec.type' | tee /dev/stderr)
  [ "${actual}" = "NodePort" ]
}

@test "server/ha-standby-Service: clusterIP empty by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.clusterIP' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}

@test "server/ha-standby-Service: clusterIP can set" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.clusterIP=None' \
      . | tee /dev/stderr |
      yq -r '.spec.clusterIP' | tee /dev/stderr)
  [ "${actual}" = "None" ]
}

@test "server/ha-standby-Service: port and targetPort will be 8200 by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].port' | tee /dev/stderr)
  [ "${actual}" = "8200" ]

  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].targetPort' | tee /dev/stderr)
  [ "${actual}" = "8200" ]
}

@test "server/ha-standby-Service: port and targetPort can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.port=8000' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].port' | tee /dev/stderr)
  [ "${actual}" = "8000" ]

  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.targetPort=80' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].targetPort' | tee /dev/stderr)
  [ "${actual}" = "80" ]
}

@test "server/ha-standby-Service: nodeport can set" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.type=NodePort' \
      --set 'server.service.standbyNodePort=30009' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].nodePort' | tee /dev/stderr)
  [ "${actual}" = "30009" ]
}

@test "server/ha-standby-Service: nodeport can't set when type isn't NodePort" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.standbyNodePort=30009' \
      . | tee /dev/stderr |
      yq -r '.spec.ports[0].nodePort' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}

@test "server/ha-standby-Service: vault port name is http, when tlsDisable is true" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'global.tlsDisable=true' \
      . | tee /dev/stderr |
      yq -r '.spec.ports | map(select(.port==8200)) | .[] .name' | tee /dev/stderr)
  [ "${actual}" = "http" ]
}

@test "server/ha-standby-Service: vault port name is https, when tlsDisable is false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'global.tlsDisable=false' \
      . | tee /dev/stderr |
      yq -r '.spec.ports | map(select(.port==8200)) | .[] .name' | tee /dev/stderr)
  [ "${actual}" = "https" ]
}

# duplicated in server-service.bats
@test "server/ha-standby-Service: NodePort assert externalTrafficPolicy" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.type=NodePort' \
      --set 'server.service.externalTrafficPolicy=Foo' \
      . | tee /dev/stderr |
      yq -r '.spec.externalTrafficPolicy' | tee /dev/stderr)
  [ "${actual}" = "Foo" ]
}

# duplicated in server-service.bats
@test "server/ha-standby-Service: NodePort assert no externalTrafficPolicy" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.type=NodePort' \
      --set 'server.service.externalTrafficPolicy=' \
      . | tee /dev/stderr |
      yq '.spec.externalTrafficPolicy' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}

# duplicated in server-service.bats
@test "server/ha-standby-Service: ClusterIP assert no externalTrafficPolicy" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.type=ClusterIP' \
      --set 'server.service.externalTrafficPolicy=Foo' \
      . | tee /dev/stderr |
      yq '.spec.externalTrafficPolicy' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}

@test "server/ha-standby-Service: publishNotReadyAddresses can be changed" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.publishNotReadyAddresses' | tee /dev/stderr)
  [ "${actual}" = "true" ]

  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.publishNotReadyAddresses=false' \
      . | tee /dev/stderr |
      yq -r '.spec.publishNotReadyAddresses' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "server/ha-standby-Service: instance selector can be disabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.selector["app.kubernetes.io/instance"]' | tee /dev/stderr)
  [ "${actual}" = "release-name" ]

  local actual=$(helm template \
      --show-only templates/server-ha-standby-service.yaml \
      --set 'server.ha.enabled=true' \
      --set 'server.service.instanceSelector.enabled=false' \
      . | tee /dev/stderr |
      yq -r '.spec.selector["app.kubernetes.io/instance"]' | tee /dev/stderr)
  [ "${actual}" = "null" ]
}
