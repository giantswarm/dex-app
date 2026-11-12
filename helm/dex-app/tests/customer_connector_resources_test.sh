#!/usr/bin/env bash
set -euo pipefail

chart=${1:-$(dirname "$0")/..}
test_directory=$(mktemp -d)
trap 'rm -rf "$test_directory"' EXIT

list='[{"id":"alpha","connectorType":"oidc","connectorName":"Alpha","connectorConfig":"issuer: https://alpha.example.test"},{"id":"zulu","connectorType":"oidc","connectorName":"Zulu","connectorConfig":"issuer: https://zulu.example.test"}]'
map='{"zulu":{"connectorType":"oidc","connectorName":"Zulu","connectorConfig":"issuer: https://zulu.example.test"},"alpha":{"id":"ignored","connectorType":"oidc","connectorName":"Alpha","connectorConfig":"issuer: https://alpha.example.test"}}'

render() {
  helm template dex-app "$chart" \
    --api-versions networking.k8s.io/v1/Ingress \
    --set deployDexK8SAuthenticator=true,isManagementCluster=true,oidc.customer.enabled=true \
    --set oidc.issuerAddress=dex.example.test,oidc.staticClients.dexK8SAuthenticator.clientAddress=login.example.test \
    --set monitoring.podLogs.enabled=true,monitoring.podLogs.tenant=test \
    --set-json "oidc.customer.connectors=$1"
}

render "$list" > "$test_directory/list.yaml"
render "$map" > "$test_directory/map.yaml"
diff -u "$test_directory/list.yaml" "$test_directory/map.yaml"

for expected in 'kind: Deployment' 'kind: Service' 'kind: ConfigMap' 'kind: Ingress' 'kind: PodLogs' 'connector_id: alpha' 'connector_id: zulu' 'dex-k8s-authenticator-alpha' 'dex-k8s-authenticator-zulu'; do
  grep -q "$expected" "$test_directory/map.yaml"
done
if grep -q 'ignored' "$test_directory/map.yaml"; then
  echo 'customer resources must use map keys as connector ids' >&2
  exit 1
fi

echo 'customer connector lists and maps render identical Dex and authenticator resources'
