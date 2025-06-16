#!/bin/bash
# sync-version.sh - Replace dex.image.tag with Chart.yaml appVersion

set -e

CHART_DIR="helm/dex-app"

# Get appVersion from Chart.yaml
APP_VERSION=$(grep '^appVersion:' "$CHART_DIR/Chart.yaml" | awk '{print $2}' | tr -d '"')

echo "Syncing dex.image.tag to: $APP_VERSION"

# Replace the tag in values.yaml
sed -i.bak "s/tag: \".*\"/tag: \"$APP_VERSION\"/" "$CHART_DIR/values.yaml"

# Clean up backup file
rm -f "$CHART_DIR/values.yaml.bak"

echo "✅ Done! dex.image.tag is now: $APP_VERSION"

# Verify it worked
echo "Verification:"
grep -A 3 "dex:" "$CHART_DIR/values.yaml" | grep "tag:"