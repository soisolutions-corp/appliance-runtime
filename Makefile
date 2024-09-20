build:
	docker build --build-arg RELEASE=local --output type=image,name=ghcr.io/soisolutions-corp/appliance-runtime:local .

build/netboot: build
	docker build --build-arg APPLIANCE_RUNTIME_VERSION=local --output type=local,dest=output -f netboot.Dockerfile .

ghcr/auth:
	gh auth refresh -s read:packages

ghcr/login:
	@docker login ghcr.io -u USERNAME -p $(shell gh auth token)
