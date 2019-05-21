ACCOUNT=klotio
IMAGE=redis
VERSION?=0.1
NAME=$(IMAGE)-$(ACCOUNT)
NETWORK=klot-io
VOLUMES=-v ${PWD}/data:/var/lib/redis
PORT=6379

.PHONY: cross build network shell start stop push install update remove reset

cross:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

network:
	-docker network create $(NETWORK)

shell: network
	docker run -it --rm --name=$(NAME) --network=$(NETWORK) $(VOLUMES) $(ENVIRONMENT) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

start: network
	docker run -d --name=$(NAME) --network=$(NETWORK) $(VOLUMES) $(ENVIRONMENT) -p 127.0.0.1:$(PORT):$(PORT) $(ACCOUNT)/$(IMAGE):$(VERSION)

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
