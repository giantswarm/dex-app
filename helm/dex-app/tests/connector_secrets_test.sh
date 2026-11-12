#!/usr/bin/env bash
set -euo pipefail

chart=${1:-$(dirname "$0")/..}
test_directory=$(mktemp -d)
trap 'rm -rf "$test_directory"' EXIT

for owner in giantswarm customer; do
  mkdir "$test_directory/$owner"
  helm template dex-app "$chart" -s templates/deployment.yaml \
    --set-json "oidc.$owner.connectors={\"federation\":{\"connectorType\":\"oidc\",\"connectorName\":\"Federation\",\"config\":{\"issuer\":\"https://hub.example.test\"},\"clientSecretRef\":{\"name\":\"connector\",\"key\":\"secret\"}}}" \
    | awk '/wget -q -T 2/ {printing=1; next} printing && /timeoutSeconds:/ {exit} printing && /cd \/etc\/dex-client-secrets/ {next} printing {print}' \
    > "$test_directory/$owner/probe.sh"

  test -s "$test_directory/$owner/probe.sh"
  (
    cd "$test_directory/$owner"
    unset DEX_CONNECTOR_SECRET_FEDERATION
    sh -ec "$(cat probe.sh)"

    printf '%s' first-secret > DEX_CONNECTOR_SECRET_FEDERATION
    if sh -ec "$(cat probe.sh)"; then
      echo 'a newly available Secret must restart Dex' >&2
      exit 1
    fi

    export DEX_CONNECTOR_SECRET_FEDERATION=first-secret
    sh -ec "$(cat probe.sh)"
    printf '%s' rotated-secret > DEX_CONNECTOR_SECRET_FEDERATION
    if sh -ec "$(cat probe.sh)"; then
      echo 'a rotated Secret must restart Dex' >&2
      exit 1
    fi
  )

  echo "$owner connector secret probe: absent, available, loaded and rotated cases passed"
done
