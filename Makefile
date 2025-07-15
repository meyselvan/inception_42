COMPOSE_FILE := srcs/docker-compose.yml
DATA_DIR := /home/relvan/data
WORDPRESS_DIR := $(DATA_DIR)/wordpress
MARIADB_DIR := $(DATA_DIR)/mariadb
ENV_FILE := srcs/.env

DOMAIN_NAME := $(shell if [ -f $(ENV_FILE) ]; then grep ^DOMAIN_NAME= $(ENV_FILE) | cut -d '=' -f2; else echo "inception.42.fr"; fi)

.DEFAULT_GOAL := all

all: directories addhost up
	@echo "🚀 Inception project is ready!"
	@echo "📝 Access your site at: https://$(DOMAIN_NAME)"

directories:
	@echo "📁 Creating data directories..."
	@mkdir -p $(WORDPRESS_DIR)
	@mkdir -p $(MARIADB_DIR)
	@chown -R relvan:relvan $(DATA_DIR)
	@echo "✅ Directories created: $(DATA_DIR)"

addhost:
	@echo "🌐 Configuring hosts file for $(DOMAIN_NAME)..."
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		sudo sed -i.bak "/\s$(DOMAIN_NAME)$$/d" /etc/hosts; \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null; \
		echo "✅ Host entry added: 127.0.0.1 $(DOMAIN_NAME)"; \
	else \
		echo "ℹ️  Host entry already exists for $(DOMAIN_NAME)"; \
	fi

up: directories
	@echo "🔨 Building and starting containers..."
	@docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ All containers are running!"
	@$(MAKE) status

start:
	@echo "▶️  Starting existing containers..."
	@docker-compose -f $(COMPOSE_FILE) start
	@echo "✅ Containers started!"
	@$(MAKE) status

stop:
	@echo "⏸️  Stopping containers (preserving state)..."
	@docker-compose -f $(COMPOSE_FILE) stop
	@echo "✅ Containers stopped!"

restart: stop start
	@echo "🔄 Containers restarted!"

down:
	@echo "🛑 Stopping and removing containers..."
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ Containers removed!"

status:
	@echo "\n📊 Container Status:"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo "\n🌐 Network Status:"
	@docker network ls | grep inception || echo "No inception network found"
	@echo "\n💾 Volume Status:"
	@docker volume ls | grep inception || echo "No inception volumes found"

logs:
	@echo "📋 Showing container logs..."
	@docker-compose -f $(COMPOSE_FILE) logs -f

logs-nginx:
	@docker-compose -f $(COMPOSE_FILE) logs -f nginx

logs-wordpress:
	@docker-compose -f $(COMPOSE_FILE) logs -f wordpress

logs-mariadb:
	@docker-compose -f $(COMPOSE_FILE) logs -f mariadb

shell-nginx:
	@echo "🐚 Opening shell in nginx container..."
	@docker-compose -f $(COMPOSE_FILE) exec nginx /bin/bash

shell-wordpress:
	@echo "🐚 Opening shell in wordpress container..."
	@docker-compose -f $(COMPOSE_FILE) exec wordpress /bin/bash

shell-mariadb:
	@echo "🐚 Opening shell in mariadb container..."
	@docker-compose -f $(COMPOSE_FILE) exec mariadb /bin/bash

db-connect:
	@echo "🗄️  Connecting to MariaDB..."
	@docker-compose -f $(COMPOSE_FILE) exec mariadb mysql -u root -p

clean: down
	@echo "🧹 Cleaning Docker system..."
	@docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@docker system prune -af --volumes
	@echo "✅ Docker system cleaned!"

fclean: clean
	@echo "🔥 Full cleanup - removing all Docker images and data..."
	@if [ -n "$$(docker images -q)" ]; then \
		echo "Removing all Docker images..."; \
		docker rmi -f $$(docker images -q); \
	else \
		echo "No Docker images to remove."; \
	fi
	@echo "Removing data directories..."
	@sudo rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)
	@if [ -d $(DATA_DIR) ] && [ -z "$$(ls -A $(DATA_DIR))" ]; then \
		sudo rm -rf $(DATA_DIR); \
		echo "✅ Empty data directory removed"; \
	fi
	@echo "✅ Full cleanup completed!"

removehost:
	@echo "🌐 Removing host entry for $(DOMAIN_NAME)..."
	@sudo sed -i.bak "/\s$(DOMAIN_NAME)$$/d" /etc/hosts
	@echo "✅ Host entry removed!"

rebuild: fclean all
	@echo "🔄 Full rebuild completed!"

re: rebuild

reset: fclean removehost
	@echo "♻️  Complete reset - ready for fresh start!"

test:
	@echo "🧪 Running basic health checks..."
	@echo "Testing nginx (HTTPS)..."
	@curl -k -s -o /dev/null -w "Status: %{http_code}\n" https://$(DOMAIN_NAME)/ || echo "❌ NGINX test failed"
	@echo "Testing WordPress..."
	@curl -k -s https://$(DOMAIN_NAME)/ | grep -q "WordPress\|wp-" && echo "✅ WordPress detected" || echo "❌ WordPress test failed"
	@echo "Testing containers..."
	@docker-compose -f $(COMPOSE_FILE) ps | grep -q "Up" && echo "✅ Containers running" || echo "❌ Container test failed"

validate:
	@echo "🔍 Validating configuration..."
	@if [ ! -f $(COMPOSE_FILE) ]; then echo "❌ docker-compose.yml not found!"; exit 1; fi
	@if [ ! -f $(ENV_FILE) ]; then echo "❌ .env file not found!"; exit 1; fi
	@docker-compose -f $(COMPOSE_FILE) config -q && echo "✅ docker-compose.yml is valid" || echo "❌ docker-compose.yml validation failed"
	@echo "✅ Configuration validation passed!"

backup:
	@echo "💾 Creating backup..."
	@mkdir -p ./backups
	@sudo tar -czf ./backups/inception-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz -C $(DATA_DIR) .
	@echo "✅ Backup created in ./backups/"

help:
	@echo "🚀 Inception Project - Available Commands:"
	@echo ""
	@echo "📋 Main Commands:"
	@echo "  make all         - Full setup (directories + hosts + containers)"
	@echo "  make up          - Build and start all containers"
	@echo "  make down        - Stop and remove containers"
	@echo "  make start       - Start existing containers"
	@echo "  make stop        - Stop containers (preserve state)"
	@echo "  make restart     - Stop and start containers"
	@echo ""
	@echo "🔧 Development:"
	@echo "  make status      - Show container/network/volume status"
	@echo "  make logs        - Show all container logs"
	@echo "  make logs-nginx  - Show nginx logs only"
	@echo "  make shell-nginx - Open shell in nginx container"
	@echo "  make db-connect  - Connect to MariaDB"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  make clean       - Clean Docker system"
	@echo "  make fclean      - Full cleanup (images + data)"
	@echo "  make reset       - Complete reset"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  make test        - Run health checks"
	@echo "  make validate    - Validate configuration"
	@echo "  make backup      - Create data backup"
	@echo ""
	@echo "🌐 Current domain: $(DOMAIN_NAME)"
	@echo "📁 Data directory: $(DATA_DIR)"

# ============================================================================
# PHONY TARGETS
# ============================================================================
.PHONY: all up down start stop restart clean fclean re rebuild reset \
        directories addhost removehost status logs logs-nginx logs-wordpress logs-mariadb \
        shell-nginx shell-wordpress shell-mariadb db-connect \
        test validate backup help
