# Inception

A system administration project that sets up a small infrastructure composed of different services using Docker and Docker Compose. The infrastructure consists of a LEMP stack (Linux, Nginx, MariaDB, PHP) with WordPress.

## 🏗 Building the Docker Image

When you run docker build, the Docker daemon follows a sequential process to construct the final image:

### 1. Instruction Execution

Each instruction in the Dockerfile (FROM, RUN, COPY, etc.) is executed in order.

### 2. Layer Creation & Stacking

Snapshots: For every executable instruction, the Docker daemon creates a new Read-Only Image Layer. This layer is essentially a snapshot of the filesystem changes introduced by that specific command.

Immutable Stack: These layers are stacked on top of each other. Each layer is immutable (cannot be changed). In line with UnionFS principles, files in higher layers take precedence over those in lower layers.

### 3. Image Storage & Efficiency

The final image is a collection of these read-only layers stored in the local Docker image cache.

💡 Key Point: Layer Sharing If you build multiple images using the same base (e.g., FROM ubuntu), that common base layer is stored only once on your host system. This significantly reduces disk space and speeds up pulls/pushes.

## 🚀 Running a Container

When you execute docker run <image-name>, the Docker daemon transitions from a static image to a dynamic runtime environment:

### 1. Lower Directories (lowerdir)

The daemon takes all the read-only layers from the image and designates them as the lower directories. These form the stable foundation of the container’s filesystem.

### 2. Upper Directory (upperdir)

The daemon creates a brand new, empty Read-Write Layer (often called the "Container Layer"). This is the upper directory where all runtime changes (log files, new data, temp files) are stored.
### 3. The Merged View

Using the host kernel's capabilities (such as OverlayFS or AUFS), Docker performs a Union Mount. This instantly combines the lowerdir stack and the upperdir into a single Merged View.
### 4. Process Isolation

The container process starts with isolated Namespaces and Cgroups. The Merged View serves as its root filesystem (/).

The Result: The container sees a single, unified filesystem. It can read from the image layers and write to its own private layer, all while remaining completely isolated from the host and other containers.

## 🛠 Key Features & Mechanics

Union File Systems (UnionFS) allow multiple directories (layers) to appear as a single, unified filesystem. Below are the core concepts that power this behavior:

### 1. Layered Approach (Stacking)

Union filesystems stack directories on top of each other based on a specific priority. When a file is accessed, the system searches through the stack from top to bottom. It returns the first instance of the file it finds, effectively "shadowing" files with the same name in lower layers.

### 2. Copy-on-Write (CoW)

To maintain integrity, lower layers are typically marked as read-only, while the topmost layer is writable.

The Process: If a user modifies a file existing in a read-only layer, the system automatically copies that file to the writable top layer.

The Result: Changes are applied to the new copy, leaving the original file in the lower layer completely untouched. This ensures efficiency and data persistence.

### 3. Whiteouts (File Deletion)

Since lower layers are read-only, files cannot be physically deleted from them. Instead, UnionFS uses Whiteouts:

When a file is deleted, a special "whiteout" or "opaque" file is created in the writable layer.

This marker tells the system to hide the file from the merged view.

To the user, the file appears deleted, even though it still exists safely in the underlying read-only branch.

## Architecture

The project implements a three-tier architecture with the following services:

- **Nginx**: Web server and reverse proxy with TLS/SSL
- **WordPress**: Content management system with PHP-FPM
- **MariaDB**: Database server

All services run in separate Docker containers on a custom bridge network, with data persistence through Docker volumes.

## Project Structure

```
thamirmohcine-inception/
├── Makefile
├── TODO.md
├── docker_readme.txt
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/
        │       └── m_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── w_p.sh
```

## Technical Specifications

### Docker Images

All images are built from Debian Bookworm base images. Each service has its own Dockerfile and runs as a separate container.

### Networking

- Custom bridge network named `inception`
- Internal DNS resolution between services
- Only Nginx exposes port 443 to the host
- WordPress and MariaDB are accessible only within the internal network

### Data Persistence

Two bind mount volumes ensure data persistence:

- `/home/$USER/data/wordpress` - WordPress files
- `/home/$USER/data/mariadb` - MariaDB database files

### Security

- HTTPS only (TLS v1.2 and v1.3)
- Self-signed SSL certificate
- No passwords in Dockerfiles
- Environment variables managed through .env file
- Restricted access between services

## Service Details

### Nginx

- Listens on port 443 (HTTPS)
- Acts as reverse proxy for WordPress
- Handles SSL/TLS termination
- Forwards PHP requests to WordPress via FastCGI protocol
- Serves static files directly

**Key Configuration:**
- SSL protocols: TLSv1.2, TLSv1.3
- FastCGI pass to wordpress:9000
- Root directory: /var/www/html

### WordPress

- PHP 8.2 with PHP-FPM
- WordPress installed via WP-CLI
- PHP-FPM listens on port 9000
- Configured with two users (admin and regular user)
- Automatic setup on first run

**Features:**
- WP-CLI for WordPress management
- Automatic database configuration
- User creation and role assignment
- Proper file permissions

### MariaDB

- Database server for WordPress
- Listens on port 3306 (internal only)
- Automatic database and user creation
- Health checks for dependency management
- Data stored in persistent volume

**Initialization:**
- Creates WordPress database
- Creates WordPress user with privileges
- Configures remote access
- Binds to all interfaces (0.0.0.0)

## Dependencies

Services start in the following order:

1. MariaDB (waits for health check)
2. WordPress (depends on healthy MariaDB)
3. Nginx (depends on healthy WordPress)

Health checks use netcat to verify service availability on their respective ports.

## Environment Variables

The project uses a .env file for configuration. Required variables:

```
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
MYSQL_HOST
DOMAIN_NAME
WP_TITLE
WP_ADMIN_USER
WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL
WP_USER
WP_USER_EMAIL
WP_USER_PASSWORD
WP_USER_ROLE
```

## Installation

### Prerequisites

- Docker
- Docker Compose
- Make

### Setup

1. Clone the repository
2. Create the required directories:
   ```bash
   mkdir -p /home/$USER/data/wordpress
   mkdir -p /home/$USER/data/mariadb
   ```
3. Create a .env file in the srcs/ directory with your configuration
4. Update the domain name in your /etc/hosts file:
   ```
   127.0.0.1 mthamir.42.fr
   ```

### Build and Run

```bash
make
```

This command will:
- Stop any running containers
- Build all Docker images
- Start the services in detached mode

## Makefile Commands

- `make` or `make all` - Build and start all services
- `make down` - Stop and remove containers
- `make stop` - Stop containers without removing them
- `make start` - Start stopped containers
- `make clean` - Remove containers and prune Docker system
- `make fclean` - Full clean including volumes
- `make re` - Rebuild everything from scratch
- `make logs` - Follow container logs
- `make push` - Git add, commit, and push (interactive)

## Access

After successful deployment:

- WordPress site: https://mthamir.42.fr
- WordPress admin: https://mthamir.42.fr/wp-admin

Note: You will see a browser warning about the self-signed certificate. This is expected behavior in development.

## Technical Concepts

### Union File System

Docker uses OverlayFS (Union File System) to create efficient, layered images:

- Each Dockerfile instruction creates a read-only layer
- Layers are stacked to form the complete image
- Containers add a thin writable layer on top
- Multiple containers share the same base layers

### Container Runtime

When a container runs:

1. Read-only image layers serve as the lower directories
2. A new writable layer is created as the upper directory
3. OverlayFS merges them into a single view
4. The container sees a unified filesystem

### PID 1 and Process Management

- Each container's entrypoint process runs as PID 1
- The `exec` command replaces the shell with the actual service
- This ensures proper signal handling and graceful shutdown
- Services run in foreground mode (daemon off)

### FastCGI Protocol

Nginx communicates with PHP-FPM using the FastCGI protocol:

1. Client requests a PHP file
2. Nginx receives the HTTPS request
3. Nginx forwards to wordpress:9000 via FastCGI
4. PHP-FPM processes the PHP code
5. Result returns to Nginx
6. Nginx sends response to client

## Troubleshooting

### Containers won't start

Check logs:
```bash
make logs
```

### Database connection errors

Verify MariaDB is healthy:
```bash
docker ps
```

Check the health status in the STATUS column.

### Permission issues

Ensure the data directories exist and have proper permissions:
```bash
ls -la /home/$USER/data/
```

### SSL certificate errors

The self-signed certificate will show browser warnings. This is normal for development. In production, use a CA-signed certificate.

## Project Requirements

This project implements the following technical requirements:

- Docker containers from penultimate stable version of Alpine or Debian
- Custom Dockerfiles for each service
- Docker Compose for orchestration
- TLS v1.2 or v1.3 only
- Custom domain name pointing to local IP
- WordPress with multiple users
- Persistent volumes for database and website files
- Container restart on crash
- No use of network: host or --link
- No infinite loops in entrypoint scripts
- Proper environment variable usage
