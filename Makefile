USER = relvan
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/relvan/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

DOMAIN_NAME = $(USER).42.fr

all: directories addhost up
	@echo "\033[32m Inception project is ready!\033[0m"
	@echo "\033[32m Access your site at: https://$(DOMAIN_NAME)\033[0m"

directories:
	@echo "Creating data directories..."
	@mkdir -p $(WORDPRESS_DIR)
	@mkdir -p $(MARIADB_DIR)
	@chown -R relvan:relvan $(DATA_DIR)
	@echo "Directories created: $(DATA_DIR)"

addhost:
	@echo "Configuring hosts file for $(DOMAIN_NAME)..."
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		sudo sed -i.bak "/\s$(DOMAIN_NAME)$$/d" /etc/hosts; \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null; \
		echo "Host entry added: 127.0.0.1 $(DOMAIN_NAME)"; \
	else \
		echo "Host entry already exists for $(DOMAIN_NAME)"; \
	fi

up: directories
	@echo "Building and starting containers..."
	@docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "All containers are running!"
	@$(MAKE) status

start:
	@echo "Starting existing containers..."
	@docker-compose -f $(COMPOSE_FILE) start
	@echo "Containers started!"
	@$(MAKE) status

stop:
	@echo "Stopping containers (preserving state)..."
	@docker-compose -f $(COMPOSE_FILE) stop
	@echo "Containers stopped!"

restart: stop start
	@echo "Containers restarted!"

down:
	@echo "Stopping and removing containers..."
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "Containers removed!"

status:
	@echo "\nDocker Compose Container Status:"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo "\n All Container Status:"
	@docker ps -a
	@echo "\nImage Status:"
	@docker images
	@echo "\nNetwork Status:"
	@docker network ls
	@echo "\nVolume Status:"
	@docker volume ls

logs:
	@echo "Showing container logs..."
	@docker-compose -f $(COMPOSE_FILE) logs -f

nuke:
	@echo "Nuking all Docker containers, images, and volumes..."
	- docker stop $$(docker ps -qa)
	- docker rm $$(docker ps -qa)
	- docker rmi -f $$(docker images -qa)
	- docker volume rm $$(docker volume ls -q)
	- docker network rm $$(docker network ls -q) 2>/dev/null
	- rm -rf $(WORDPRESS_DIR) $(MARIADB_DIR)
	@echo "Nuke operation completed!"

re: nuke all
	@echo "Re-initializing project..."

.PHONY: all up down start stop restart re \
        directories addhost status logs nuke \
