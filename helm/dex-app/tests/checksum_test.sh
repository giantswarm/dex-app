#!/usr/bin/env bash
# checksum/config on the dex pod template: identical values render the same value,
# so a reconcile without a change rolls nothing; a change to the dex configuration
# (the issuer, a static client added, a client's secret moved from the inline value
# to a referenced Secret) renders a different one, so the helm upgrade that writes
# the configuration rolls the pod. Run by `make test-chart`; takes the chart path.
set -euo pipefail

chart=${1:-$(dirname "$0")/..}

checksum() {
  helm template dex-app "$chart" --set oidc.issuerAddress=dex.example.test "$@" \
    -s templates/deployment.yaml | sed -n 's/^ *checksum\/config: //p'
}
fail() { echo "checksum_test: $*" >&2; exit 1; }

inline='[{"id":"platform-manager","name":"Platform manager","secret":"inline-secret","redirectURIs":["https://platform-manager.example.test/callback"]}]'
referenced='[{"id":"platform-manager","name":"Platform manager","secretRef":{"name":"dex-client-platform-manager","key":"secret"},"redirectURIs":["https://platform-manager.example.test/callback"]}]'

base=$(checksum)
again=$(checksum)
other_issuer=$(checksum --set oidc.issuerAddress=dex.other.example.test)
with_client=$(checksum --set-json "oidc.extraStaticClients=$inline")
with_referenced=$(checksum --set-json "oidc.extraStaticClients=$referenced")

[[ $base =~ ^[0-9a-f]{64}$ ]] || fail "no sha256 checksum/config on the pod template: '$base'"
[ "$base" = "$again" ] || fail "identical values rendered different checksums: $base $again"
[ "$base" != "$other_issuer" ] || fail "an issuer change left checksum/config unchanged"
[ "$base" != "$with_client" ] || fail "a static client added left checksum/config unchanged"
[ "$with_client" != "$with_referenced" ] || fail "a client secret moved to a referenced Secret left checksum/config unchanged"

echo "checksum/config: stable across identical renders ($base); changes with the issuer ($other_issuer), a static client added ($with_client) and its secret moved to a referenced Secret ($with_referenced)"
