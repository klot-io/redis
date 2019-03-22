ACCOUNT=klotio
IMAGE=redis
VERSION?=0.1
VOLUMES=-v ${PWD}/data:/var/lib/redis
PORT=6379

.PHONY: cross build shell run push install update reset remove

cross:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

shell:
	docker run -it $(VARIABLES) $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

run:
	docker run -it --rm -$(VARIABLES) $(VOLUMES) p 127.0.0.1:$(PORT):$(PORT) -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

push:
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)

install:
	kubectl create -f kubernetes/namespace.yaml
	kubectl create -f kubernetes/daemon.yaml

update:
	kubectl replace -f kubernetes/namespace.yaml
	kubectl replace -f kubernetes/daemon.yaml

remove:
	kubectl delete -f kubernetes/namespace.yaml

reset: remove install
