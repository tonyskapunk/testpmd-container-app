VERSION       ?= 0.2.2
REGISTRY      ?= quay.io
ORG           ?= rh-nfv-int
CONTAINER_CLI ?= podman
TAG           ?= v$(VERSION)

ifneq ($(origin FORCE), undefined)
	CONTAINER_ARGS := --no-cache
endif

# Print the possible targets and a short description
targets:
	@awk -F: '/^.PHONY/ {print $$2}' Makefile | column -t -s '#'

.PHONY: all # Build and push all images
all: build-all push-all

.PHONY: testpmd-dependencies # Get dependencies for testpmd
testpmd-dependencies:
	@if [[ ! -d testpmd/testpmd-as-load-balancer ]]; then \
	git clone https://github.com/krsacme/testpmd-as-load-balancer.git testpmd/testpmd-as-load-balancer; \
	echo "=== Cloning testpmd-as-load-balancer ==="; \
	fi

.PHONY: build-all # Build ALL images
build-all: build-testpmd build-mac build-listener

.PHONY: build-testpmd # Build testpmd
build-testpmd: testpmd-dependencies
	ls -l testpmd
	@echo $(CONTAINER_CLI) build $(@:build-%=%) -f $(@:build-%=%)/Dockerfile -t "$(REGISTRY)/$(ORG)/testpmd-container-app-$(@:build-%=%):$(TAG)" $(CONTAINER_ARGS)

.PHONY: build-mac # Build mac
build-mac:
	@echo $(CONTAINER_CLI) build $(@:build-%=%) -f $(@:build-%=%)/Dockerfile -t "$(REGISTRY)/$(ORG)/testpmd-container-app-$(@:build-%=%):$(TAG)" $(CONTAINER_ARGS)

.PHONY: build-listener # Build listener
build-listener:
	@echo $(CONTAINER_CLI) build $(@:build-%=%) -f $(@:build-%=%)/Dockerfile -t "$(REGISTRY)/$(ORG)/testpmd-container-app-$(@:build-%=%):$(TAG)" $(CONTAINER_ARGS)

.PHONY: clean # Delete untracked changes
clean:
	@rm -Rf testpmd/testpmd-as-load-balancer

.PHONY: push-all # Push ALL images
push-all: push-testpmd push-mac push-listener

.PHONY: push-testpmd # Push testpmd
push-testpmd: build-testpmd
	@echo $(CONTAINER_CLI) push "$(REGISTRY)/$(ORG)/testpmd-container-app-$(@:push-%=%):$(TAG)"

.PHONY: push-mac # Push mac
push-mac: build-mac
	@echo $(CONTAINER_CLI) push "$(REGISTRY)/$(ORG)/mac-container-app-$(@:push-%=%):$(TAG)"

.PHONY: push-listener # Push testpmd
push-listener: build-listener
	@echo $(CONTAINER_CLI) push "$(REGISTRY)/$(ORG)/listener-container-app-$(@:push-%=%):$(TAG)"
