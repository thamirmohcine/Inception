#!/bin/bash

# Inception project directory setup script
# Replace 'login' with your actual 42 login

# Get login from user or use default
read -p "Enter your 42 login: " LOGIN
LOGIN=${LOGIN:-login}

echo "Creating Inception directory structure for $LOGIN..."

# Create main project directory
mkdir -p inception

# Navigate to project directory
cd inception

# Create secrets directory and files
mkdir -p secrets
touch secrets/credentials.txt
touch secrets/db_password.txt
touch secrets/db_root_password.txt

# Create srcs directory structure
mkdir -p srcs/requirements/{mariadb,nginx,wordpress,tools,bonus}

# Create MariaDB structure
mkdir -p srcs/requirements/mariadb/{conf,tools}
touch srcs/requirements/mariadb/Dockerfile
touch srcs/requirements/mariadb/.dockerignore

# Create NGINX structure
mkdir -p srcs/requirements/nginx/{conf,tools}
touch srcs/requirements/nginx/Dockerfile
touch srcs/requirements/nginx/.dockerignore

# Create WordPress structure
mkdir -p srcs/requirements/wordpress/{conf,tools}
touch srcs/requirements/wordpress/Dockerfile
touch srcs/requirements/wordpress/.dockerignore

# Create docker-compose and .env
touch srcs/docker-compose.yml
cat > srcs/.env << EOF
DOMAIN_NAME=${LOGIN}.42.fr

# MYSQL SETUP
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=wordpress
MYSQL_USER=
MYSQL_PASSWORD=

# WORDPRESS SETUP
WP_TITLE=
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_EMAIL=
WP_USER_PASSWORD=
EOF

# Create Makefile at root
cat > Makefile << 'EOF'
# Inception Makefile

all: up

up:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down

stop:
	@docker-compose -f srcs/docker-compose.yml stop

start:
	@docker-compose -f srcs/docker-compose.yml start

clean: down
	@docker system prune -af

fclean: clean
	@sudo rm -rf /home/$(USER)/data/wordpress
	@sudo rm -rf /home/$(USER)/data/mariadb
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

logs:
	@docker-compose -f srcs/docker-compose.yml logs -f

.PHONY: all up down stop start clean fclean re logs
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
secrets/
srcs/.env
*.log
.DS_Store
EOF

echo ""
echo "✅ Directory structure created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit srcs/.env with your configuration"
echo "2. Add passwords to secrets/ files"
echo "3. Create your Dockerfiles in each service directory"
echo "4. Write your docker-compose.yml"
echo ""
echo "Remember to configure /etc/hosts to point ${LOGIN}.42.fr to 127.0.0.1"