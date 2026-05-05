.DEFAULT_GOAL := help
# -------------------------------
# Variables
# -------------------------------
COMPOSE=docker compose
K6_SCRIPT=k6/order-test.js
K6_KUBERNETES_SCRIPT=k6/kubernetes-order-test.js

# -------------------------------
# Docker
# -------------------------------

up:
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

rebuild:
	$(COMPOSE) down
	$(COMPOSE) up --build -d

build-push:
	docker build -t ttl.sh/rbkr-ops-order-service:2h ../rbkr-ops-order-service && docker push ttl.sh/rbkr-ops-order-service:2h
	docker build -t ttl.sh/rbkr-ops-inventory-service:2h ../rbkr-ops-inventory-service && docker push ttl.sh/rbkr-ops-inventory-service:2h
	docker build -t ttl.sh/rbkr-ops-notification-service:2h ../rbkr-ops-notification-service && docker push ttl.sh/rbkr-ops-notification-service:2h
	docker build -f ../rbkr-ops-order-service/Dockerfile.migrate -t ttl.sh/rbkr-ops-migrations:2h ../rbkr-ops-order-service && docker push ttl.sh/rbkr-ops-migrations:2h

# -------------------------------
# Kubernetes
# -------------------------------
kind-create:
	kind create cluster --name microservices --config configs/kind-config.yaml

kind-delete:
	kind delete cluster --name microservices

ingress-install:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

ingress-wait:
	kubectl wait --namespace ingress-nginx \
	  --for=condition=ready pod \
	  --selector=app.kubernetes.io/component=controller \
	  --timeout=600s

deploy-stack:
	kubectl apply -f infra/kubernetes/dependencies/redis/
	kubectl apply -f infra/kubernetes/dependencies/kafka/
	kubectl apply -f infra/kubernetes/dependencies/postgres/
	kubectl apply -f infra/kubernetes/bootstrap/
	kubectl apply -f infra/kubernetes/services/order-service/
	kubectl apply -f infra/kubernetes/services/inventory-service/
	kubectl apply -f infra/kubernetes/services/notification-service/

bootstrap:
	make kind-create
	make ingress-install
	sleep 5
	make ingress-wait
	make deploy-stack

teardown:
	make down
	make kind-delete

# -------------------------------
# Load Testing
# -------------------------------

load-test:
	k6 run $(K6_SCRIPT)

load-test-kubernetes:
	k6 run $(K6_KUBERNETES_SCRIPT)

# -------------------------------
# Go Build (run inside service repos)
# -------------------------------

build:
	go mod tidy && go build -o app ./cmd/api

# -------------------------------
# Helpers
# -------------------------------

ps:
	$(COMPOSE) ps

restart:
	$(COMPOSE) restart

help:
	@echo "Available commands:"
	@echo "  make up                   - Start all services"
	@echo "  make down                 - Stop all services"
	@echo "  make logs                 - View logs"
	@echo "  make load-test            - Run k6 load test"
	@echo "  make load-test-kubernetes - Run k6 load test on kubernetes"
	@echo "  make build                - Build Go service"
	@echo "  make build-push           - Push container images"
	@echo "  make bootstrap            - Provision kind cluster and deploy stack"
	@echo "  make teardown             - Deletes local and kubernetes stack"
