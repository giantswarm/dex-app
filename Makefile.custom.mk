APPLICATION ?= helm/dex-app

.PHONY: sync-image-tag
sync-image-tag: ## Sync dex.dex.image.tag in values.yaml from Chart.yaml appVersion
	@app_version=$$(yq '.appVersion' $(APPLICATION)/Chart.yaml) && \
	yq -i ".dex.dex.image.tag = \"$$app_version\"" $(APPLICATION)/values.yaml && \
	echo "Synced dex.dex.image.tag to $$app_version"

.PHONY: test-chart
test-chart: ## Run the chart unit tests: helm unittest, and a configuration change must change the pod template's checksum/config.
	helm unittest $(APPLICATION)
	@render() { helm template dex-app $(APPLICATION) --set oidc.issuerAddress="$$1" -s templates/deployment.yaml | yq '.spec.template.metadata.annotations["checksum/config"]'; }; \
	a=$$(render dex.a.example.test); b=$$(render dex.b.example.test); \
	test -n "$$a" && test "$$a" != "null" && test "$$a" != "$$b" && echo "checksum/config changes with the dex configuration: $$a -> $$b"
