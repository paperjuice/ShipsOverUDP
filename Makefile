.PHONY: up
up: ## Run docker compose
	docker-compose -f deploy/docker-compose.yml up -d --build

.PHONY: down
down: ## Stop the container
	docker-compose -f deploy/docker-compose.yml down
