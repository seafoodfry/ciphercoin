IMG := foundry-dev

DEFAULT_GOAL := help

.PHONY: help
help:  ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Local Development.
# CAP_NET_RAW is needed to connect to anvil.
.PHONY: dev
dev: network build  ## Start dev shell
	docker run --rm -it \
		--cap-drop all \
		--cap-add CAP_NET_RAW \
		--security-opt=no-new-privileges \
		--network $(IMG) \
		--memory="2000m" \
		--cpus="2" \
		--ulimit nofile=100 \
		--ulimit nproc=100 \
		-e ANVIL_PRIV_KEY=$$(docker logs anvil-node 2>&1 | grep -A 3 "Private Keys" | tail -n 1 | awk '{print $$2}') \
		-v $(CURDIR):/home/devuser/workspace \
		-w /home/devuser/workspace \
		$(IMG) bash

.PHONY: build
build:  ## Build base image for development
	docker build \
		--build-arg USER_ID=$(shell id -u) \
		-t $(IMG) .

.PHONY: anvil
anvil: network build  ## Start anvil node
	docker run --rm -d \
		--cap-drop all \
		--cap-add CAP_NET_RAW \
		--security-opt=no-new-privileges \
		--name anvil-node \
		--network $(IMG) \
		-p 8545:8545 \
		--entrypoint anvil \
		$(IMG) --host 0.0.0.0

.PHONY: cast
cast: network  ## Run cast command
	docker run --rm -it \
		--network $(IMG) \
		-e ANVIL_PRIV_KEY=$$(docker logs anvil-node 2>&1 | grep -A 3 "Private Keys" | tail -n 1 | awk '{print $$2}') \
		-v $(CURDIR):/home/devuser/workspace \
		-w /home/devuser/workspace \
		$(IMG) bash


##@ Network Setup.
.PHONY: network
network:  ## Create docker network for the anvil and dev containers
	docker network inspect $(IMG) || docker network create $(IMG)
	docker network list


##@ Cleanup.
.PHONY: clean
clean:  ## Cleanup artifacts
	docker rm -f anvil-node 2>/dev/null || true
	docker network rm $(IMG)