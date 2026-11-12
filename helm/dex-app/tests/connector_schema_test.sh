#!/usr/bin/env bash
set -euo pipefail

chart=${1:-$(dirname "$0")/..}
test_directory=$(mktemp -d)
trap 'rm -rf "$test_directory"' EXIT

check() {
  local expected=$1 description=$2 connectors=$3
  if helm template dex-app "$chart" --set-json "oidc.$owner.connectors=$connectors" \
    > "$test_directory/rendered.yaml" 2> "$test_directory/error.log"; then
    if [ "$expected" != accept ]; then
      echo "$owner $form: accepted $description" >&2
      exit 1
    fi
  elif [ "$expected" = accept ]; then
    echo "$owner $form: rejected $description" >&2
    cat "$test_directory/error.log" >&2
    exit 1
  elif ! grep -q 'values don.t meet the specifications of the schema' "$test_directory/error.log"; then
    echo "$owner $form: $description failed outside schema validation" >&2
    cat "$test_directory/error.log" >&2
    exit 1
  fi
}

for owner in giantswarm customer; do
  for form in map list; do
    if [ "$form" = map ]; then
      prefix='{"federation":{'
      suffix='}}'
      check accept 'empty map' '{}'
      check reject 'non-object connector' '{"federation":true}'
    else
      prefix='[{"id":"federation",'
      suffix='}]'
      check accept 'empty list' '[]'
      check reject 'non-object connector' '[true]'
      check reject 'list entry without id' '[{"connectorType":"oidc","connectorName":"Federation","config":{}}]'
    fi

    fields='"connectorType":"oidc","connectorName":"Federation"'
    check accept 'legacy YAML configuration' "$prefix$fields,\"connectorConfig\":\"issuer: https://hub.example.test\"$suffix"
    check accept 'connector-specific structured configuration' "$prefix$fields,\"config\":{\"issuer\":\"https://hub.example.test\",\"insecureEnableGroups\":true,\"scopes\":[\"openid\"]}$suffix"
    check accept 'both configuration forms' "$prefix$fields,\"config\":{},\"connectorConfig\":\"issuer: https://hub.example.test\"$suffix"
    check accept 'referenced secret' "$prefix$fields,\"config\":{},\"clientSecretRef\":{\"name\":\"connector\",\"key\":\"secret\"}$suffix"
    check reject 'missing connector type' "$prefix\"connectorName\":\"Federation\",\"config\":{}$suffix"
    check reject 'missing connector name' "$prefix\"connectorType\":\"oidc\",\"config\":{}$suffix"
    check reject 'missing configuration' "$prefix$fields$suffix"
    check reject 'non-string connector type' "$prefix\"connectorType\":true,\"connectorName\":\"Federation\",\"config\":{}$suffix"
    check reject 'unknown connector field' "$prefix$fields,\"config\":{},\"clientSecretReff\":{}$suffix"
    check reject 'non-object config' "$prefix$fields,\"config\":\"issuer: https://hub.example.test\"$suffix"
    check reject 'non-string connectorConfig' "$prefix$fields,\"connectorConfig\":{}$suffix"
    check reject 'secret reference without config' "$prefix$fields,\"connectorConfig\":\"issuer: https://hub.example.test\",\"clientSecretRef\":{\"name\":\"connector\",\"key\":\"secret\"}$suffix"
    check reject 'secret reference without key' "$prefix$fields,\"config\":{},\"clientSecretRef\":{\"name\":\"connector\"}$suffix"
    check reject 'secret reference without name' "$prefix$fields,\"config\":{},\"clientSecretRef\":{\"key\":\"secret\"}$suffix"
    check reject 'empty secret key' "$prefix$fields,\"config\":{},\"clientSecretRef\":{\"name\":\"connector\",\"key\":\"\"}$suffix"
    check reject 'non-string secret name' "$prefix$fields,\"config\":{},\"clientSecretRef\":{\"name\":42,\"key\":\"secret\"}$suffix"
    echo "$owner $form connector schema: valid inputs accepted and malformed inputs rejected"
  done
done
