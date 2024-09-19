build:
	docker build -t soisolutions.co/appliance-runtime:local  .

ghcr/auth:
	gh auth refresh -s read:packages

ghcr/login:
	@docker login ghcr.io -u USERNAME -p $(shell gh auth token)
