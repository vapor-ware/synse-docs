#
# Synse Docs
#

DOCS_VERSION := 0.0.1


.PHONY: clean
clean:  ## Clean up local documentation artifacts
	rm -rf site/

.PHONY: deps
deps:  ## Update the frozen pip dependencies (requirements.txt)
	tox -e deps

.PHONY: docs
docs:  ## Build project documentation locally
	tox -e docs

.PHONY: github-tag
github-tag:  ## Create and push a tag with the current version
	git tag -a ${DOCS_VERSION} -m "synse-docs version ${DOCS_VERSION}"
	git push -u origin ${DOCS_VERSION}

.PHONY: serve
serve:  ## Build and serve the documentation locally
	tox -e serve

.PHONY: version
version: ## Print the current version
	@echo "${DOCS_VERSION}"

.PHONY: help
help:  ## Print usage information
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help
