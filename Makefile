SHELL := /bin/bash -euo pipefail

REPO_ROOT := $(CURDIR)

GOARCH ?= $(shell go env GOARCH)
GOOS ?= $(shell go env GOOS)

YQ_VERSION = v4.24.5
YQ_BIN = bin/$(GOOS)/$(GOARCH)/yq

SOURCE_VERSION ?=
TARGET_VERSION ?=

DEV_HELM_REPO_URL := http://kaptain-helm-mirror.kommander.svc
RELEASE_HELM_REPO_URL := https://mesosphere.github.io/kaptain-charts

HELM_REPO_URL := '${helmMirrorURL:=https://mesosphere.github.io/kaptain-charts}'

.PHONY: yq
yq: $(YQ_BIN)
	$(call print-target)

$(YQ_BIN):
	$(call print-target)
	mkdir -p bin/$(GOOS)/$(GOARCH)
	curl -fsSL https://github.com/mikefarah/yq/releases/download/$(YQ_VERSION)/yq_$(GOOS)_$(GOARCH) -o $(YQ_BIN)
	chmod +x $(YQ_BIN)

.PHONY: validate
validate:
	$(call print-target)
	@test $${SOURCE_VERSION? Please set environment variable SOURCE_VERSION}
	@test $${TARGET_VERSION? Please set environment variable TARGET_VERSION}


.PHONY: prepare-dev
prepare-dev: validate
prepare-dev: yq
prepare-dev:
	$(call print-target)
	$(call create_new_version,$(SOURCE_VERSION),$(TARGET_VERSION),$(DEV_HELM_REPO_URL))

.PHONY: prepare-release
prepare-release: validate
prepare-release: yq
prepare-release:
	$(call print-target)
	$(call create_new_version,$(TARGET_VERSION_DEV),$(TARGET_VERSION),$(RELEASE_HELM_REPO_URL))

define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef

define create_new_version
	cp -r $(REPO_ROOT)/services/kaptain/$(1)/ $(REPO_ROOT)/services/kaptain/$(2)/
	$(YQ_BIN) -i '.spec.chart.spec.version = "$(2)"' $(REPO_ROOT)/services/kaptain/$(2)/kaptain.yaml
	$(YQ_BIN) -i '.spec.valuesFrom[0].name = "kaptain-$(2)-defaults"' $(REPO_ROOT)/services/kaptain/$(2)/kaptain.yaml
	$(YQ_BIN) -i '.metadata.name = "kaptain-$(2)-defaults"' $(REPO_ROOT)/services/kaptain/$(2)/defaults/cm.yaml
	$(YQ_BIN) -i '.spec.url = "$${helmMirrorURL:=$(3)}"' $(REPO_ROOT)/helm-repositories/kaptain//kaptain-repo.yaml
	git add $(REPO_ROOT)/services/kaptain/$(2)/
endef
