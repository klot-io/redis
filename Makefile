ACCOUNT=klotio
IMAGE=redis
VERSION?=0.3
NAME=$(IMAGE)-$(ACCOUNT)
NETWORK=klot.io
VOLUMES=-v ${PWD}/data:/var/lib/redis
PORT=6379

.PHONY: cross build network shell start stop push install update remove reset tag untag

cross:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

network:
	-docker network create $(NETWORK)

shell: network
	docker run -it --rm --name=$(NAME) --network=$(NETWORK) $(VOLUMES) $(ENVIRONMENT) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

start: network
	docker run -d --name=$(NAME) --network=$(NETWORK) $(VOLUMES) $(ENVIRONMENT) -p 127.0.0.1:$(PORT):$(PORT) --expose=$(PORT) $(ACCOUNT)/$(IMAGE):$(VERSION)

stop:
	docker rm -f $(NAME)

push:
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)

install:
	kubectl create -f kubernetes/db.yaml

update:
	kubectl replace -f kubernetes/db.yaml

remove:
	-kubectl delete -f kubernetes/db.yaml

reset: remove install

tag:
	-git tag -a "v$(VERSION)" -m "Version $(VERSION)"
	git push origin --tags

untag:
	-git tag -d "v$(VERSION)"
	git push origin ":refs/tags/v$(VERSION)"
