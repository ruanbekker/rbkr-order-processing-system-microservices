.DEFAULT_GOAL := help
# -------------------------------
# Variables
# -------------------------------
COMPOSE=docker compose
K6_SCRIPT=k6/order-test.js

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

# -------------------------------
# Load Testing
# -------------------------------

load-test:
	k6 run $(K6_SCRIPT)

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
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make logs         - View logs"
	@echo "  make load-test    - Run k6 load test"
	@echo "  make build        - Build Go service"
