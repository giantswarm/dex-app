#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly dir
cd "${dir}/.."

# Stage 1: Sync with vendir
echo "🔄 Running vendir sync..."
set -x
vendir sync
{ set +x; } 2>/dev/null

# Stage 2: Clean up vendored templates that we'll override
echo "🧹 Cleaning up base templates directory..."
rm -rf helm/dex-app/templates/dex/*
rm -rf helm/dex-app/charts

# Stage 3: Copy vendored chart as base
echo "📋 Copying vendored chart..."
cp -R vendor/dex/templates/* helm/dex-app/templates/
cp -R vendor/dex/charts helm/dex-app/charts || true
cp vendor/dex/.helmignore helm/dex-app/.helmignore || true

# Stage 4: Apply patches
echo "🔧 Applying patches..."
./sync/patches/chart/patch.sh
./sync/patches/values/patch.sh
./sync/patches/deployment/patch.sh
./sync/patches/secret/patch.sh
./sync/patches/ingress/patch.sh
./sync/patches/service-monitor/patch.sh
./sync/patches/rbac/patch.sh

# Stage 5: Add custom templates for dex-k8s-authenticator
echo "➕ Adding custom dex-k8s-authenticator templates..."
cp -R sync/custom-templates/dex-k8s-authenticator helm/dex-app/templates/

# Stage 6: Update documentation
echo "📚 Updating documentation..."
if command -v docker &> /dev/null; then
    HELM_DOCS="docker run --rm -u $(id -u) -v ${PWD}:/helm-docs -w /helm-docs jnorwood/helm-docs:v1.11.0"
    $HELM_DOCS --template-files=sync/readme.gotmpl -g helm/dex-app -f values.yaml -o README.md
else
    echo "⚠️  Docker not found, skipping helm-docs generation"
fi

# Stage 7: Validate the result
echo "✅ Validating generated chart..."
helm lint helm/dex-app -f tests/test-values.yaml

echo "✨ Sync complete!"