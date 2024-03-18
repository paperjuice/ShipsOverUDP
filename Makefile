.PHONY: up
up: ## Run docker compose
	#docker-compose -f deploy/docker-compose.yml up   --build  zookeeper kafka-ui broker-1 broker-2 kafka-init
	docker-compose -f deploy/docker-compose.yml up   --build

.PHONY: down
down: ## Stop the container
	docker-compose -f deploy/docker-compose.yml down
