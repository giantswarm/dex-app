APPLICATION ?= helm/dex-app

.PHONY: sync-image-tag
sync-image-tag: ## Sync dex.dex.image.tag in values.yaml from Chart.yaml appVersion
	@app_version=$$(yq '.appVersion' $(APPLICATION)/Chart.yaml) && \
	yq -i ".dex.dex.image.tag = \"$$app_version\"" $(APPLICATION)/values.yaml && \
	echo "Synced dex.dex.image.tag to $$app_version"

.PHONY: test-chart
test-chart: ## Run the chart unit tests: helm unittest, and the checksum/config cases of tests/checksum_test.sh.
	helm unittest $(APPLICATION)
	$(APPLICATION)/tests/checksum_test.sh $(APPLICATION)
