.PHONY: up
up: ## Run the whole project
	BROKER_DOMAIN_2=broker-2 BROKER_DOMAIN_1=broker-1 docker-compose -f deploy/docker-compose.yml up --build

.PHONY: infra
infra: ## Run only the infrastructure: Kafka, CassandraDB
	BROKER_DOMAIN_2=localhost BROKER_DOMAIN_1=localhost docker-compose -f deploy/docker-compose.yml up --build  zookeeper broker-1 broker-2 kafka-init cas_dev

.PHONY: down
down: ## Stop the container
	docker-compose -f deploy/docker-compose.yml down
