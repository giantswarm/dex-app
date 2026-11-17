APPLICATION ?= helm/dex-app

.PHONY: test-chart
test-chart: ## Run the chart unit tests: helm unittest, and the checksum/config cases of tests/checksum_test.sh.
	helm unittest $(APPLICATION)
	$(APPLICATION)/tests/checksum_test.sh $(APPLICATION)
