APPLICATION ?= helm/dex-app

.PHONY: sync-image-tag
sync-image-tag: ## Sync dex.image.tag in values.yaml from Chart.yaml appVersion
	@app_version=$$(yq '.appVersion' $(APPLICATION)/Chart.yaml) && \
	yq -i ".dex.image.tag = \"$$app_version\"" $(APPLICATION)/values.yaml && \
	echo "Synced dex.image.tag to $$app_version"
