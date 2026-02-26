#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly dir
cd "${dir}/.."

# Stage 1 sync
set -x
vendir sync
{ set +x; } 2>/dev/null

# Remove trailing whitespace end of lines (hack to fix vendir bug)
# find vendor/ -type f -exec sed -i 's/[[:space:]]*$//' {} \;

# Patches
./sync/patches/helpers/patch.sh
./sync/patches/hpa/patch.sh
./sync/patches/networkpolicy/patch.sh
./sync/patches/notes/patch.sh
./sync/patches/rbac/patch.sh
./sync/patches/service/patch.sh
./sync/patches/servicemonitor/patch.sh

HELM_DOCS="docker run --rm -u $(id -u) -v ${PWD}:/helm-docs -w /helm-docs jnorwood/helm-docs:v1.11.0"
$HELM_DOCS --template-files=sync/readme.gotmpl -g helm/dex-app -f values.yaml -o README.md

# Store diffs
rm -f ./diffs/*
