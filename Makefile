ACCOUNT=klotio
IMAGE=redis
VERSION?=0.1
NAME=$(IMAGE)-$(ACCOUNT)
VOLUMES=-v ${PWD}/data:/var/lib/redis
NETWORK=klot-io 
PORT=6379

.PHONY: cross build shell run push install update reset remove

cross:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

network:
	-docker network create $(NETWORK)

shell: network
	docker run -it --rm --name=$(NAME) $(VARIABLES) $(VOLUMES) --network=$(NETWORK) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

start: network
	docker run -d --name=$(NAME) $(VARIABLES) $(VOLUMES) --network=$(NETWORK) -p $(PORT):$(PORT) $(ACCOUNT)/$(IMAGE):$(VERSION)

stop:
	docker rm -f $(NAME)

push:
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)

install:
	kubectl create -f kubernetes/namespace.yaml
	kubectl create -f kubernetes/daemon.yaml

update:
	kubectl replace -f kubernetes/namespace.yaml
	kubectl replace -f kubernetes/daemon.yaml

remove:
	-kubectl delete -f kubernetes/namespace.yaml

reset: remove install
