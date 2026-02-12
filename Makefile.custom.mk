APPLICATION ?= helm/dex-app

.PHONY: sync-image-tag
sync-image-tag: ## Sync global.image.tag in values.yaml from Chart.yaml appVersion
	@app_version=$$(yq '.appVersion' $(APPLICATION)/Chart.yaml) && \
	yq -i ".global.image.tag = \"$$app_version\"" $(APPLICATION)/values.yaml && \
	echo "Synced global.image.tag to $$app_version"
