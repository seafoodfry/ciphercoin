IMG := foundry-dev

.PHONY: all
all: network build
	docker run --rm -it \
		--cap-drop all \
		--security-opt=no-new-privileges \
		--network $(IMG) \
		--memory="2000m" \
		--cpus="2" \
		--ulimit nofile=100 \
		--ulimit nproc=100 \
		-v $(CURDIR):/home/devuser/workspace \
		-w /home/devuser/workspace \
		$(IMG) bash

.PHONY: build
build:
	docker build \
		--build-arg USER_ID=$(shell id -u) --build-arg GROUP_ID=$(shell id -g) \
		-t $(IMG) .

.PHONY: network
network:
	docker network inspect $(IMG) || docker network create $(IMG)
	docker network list

.PHONY: clean
clean:
	docker network rm $(IMG)