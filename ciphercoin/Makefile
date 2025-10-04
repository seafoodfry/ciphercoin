IMG := foundry-dev

# CAP_NET_RAW is needed to connect to anvil.
.PHONY: all
all: network build
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
build:
	docker build \
		--build-arg USER_ID=$(shell id -u) \
		-t $(IMG) .

.PHONY: anvil
anvil: network build
	docker run --rm -d \
		--name anvil-node \
		--network $(IMG) \
		-p 8545:8545 \
		--entrypoint anvil \
		$(IMG) --host 0.0.0.0

.PHONY: cast
cast: network
	docker run --rm -it \
		--network $(IMG) \
		-e ANVIL_PRIV_KEY=$$(docker logs anvil-node 2>&1 | grep -A 3 "Private Keys" | tail -n 1 | awk '{print $$2}') \
		-v $(CURDIR):/home/devuser/workspace \
		-w /home/devuser/workspace \
		$(IMG) bash -c "$(CMD)"

.PHONY: network
network:
	docker network inspect $(IMG) || docker network create $(IMG)
	docker network list

.PHONY: clean
clean:
	docker rm -f anvil-node 2>/dev/null || true
	docker network rm $(IMG)