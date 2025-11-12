# Chapter 12: Docker Concepts

**Understanding Containers and Docker Architecture**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Understand what Docker is and why it's used
- ✅ Explain containers vs virtual machines
- ✅ Understand Docker images and containers
- ✅ Know Docker architecture components
- ✅ Understand Docker networking
- ✅ Grasp Docker volumes and persistence
- ✅ Read and understand docker-compose files

**Time Required:** 30-40 minutes

**Note:** This is theory. Chapter 13 covers installation and hands-on practice.

---

## What is Docker?

### The Problem Docker Solves

**Traditional deployment challenges:**

**"Works on my machine" syndrome:**
```
Developer: "My app works perfectly on my laptop!"
Server: "Missing dependencies, wrong versions, won't start"
```

**Dependency conflicts:**
```
App A needs Python 3.8
App B needs Python 3.11
Both on same server = chaos
```

**Environment inconsistency:**
```
Development: Ubuntu 22.04, MySQL 8.0
Production: Ubuntu 24.04, MySQL 8.4
Subtle differences cause bugs
```

---

### Docker's Solution

**Docker = Standardized package for applications**

**Think of it like:**
- **Shipping container** = Docker container
- **Cargo** = Your application
- **Ship** = Your server

**Just like shipping containers:**
- Standard size and interface
- Contains everything needed
- Works anywhere
- Easy to move
- Isolated from other containers

---

### Real-World Example

**Without Docker:**
```
1. SSH to server
2. Install Node.js (which version?)
3. Install dependencies (npm install)
4. Set environment variables
5. Configure database connection
6. Start application
7. Hope it works
8. Repeat for every server
```

**With Docker:**
```
1. docker compose up
2. Done!
```

**Everything is pre-configured, tested, and reproducible.**

---

## Containers vs Virtual Machines

### Virtual Machines (Old Way)

**Architecture:**
```
┌─────────────────────────────────────┐
│         Application A               │
├─────────────────────────────────────┤
│      Operating System (Ubuntu)      │
├─────────────────────────────────────┤
│      Hypervisor (VMware, etc)       │
├─────────────────────────────────────┤
│      Host Operating System          │
├─────────────────────────────────────┤
│         Physical Hardware           │
└─────────────────────────────────────┘
```

**Each VM includes:**
- Full operating system
- Kernel
- All system libraries
- Takes GBs of disk space
- Boots in minutes

**Heavy and slow!**

---

### Containers (Docker Way)

**Architecture:**
```
┌──────────┬──────────┬──────────┐
│  App A   │  App B   │  App C   │
├──────────┼──────────┼──────────┤
│  Libs    │  Libs    │  Libs    │
├──────────┴──────────┴──────────┤
│      Docker Engine              │
├─────────────────────────────────┤
│   Host Operating System         │
├─────────────────────────────────┤
│    Physical Hardware            │
└─────────────────────────────────┘
```

**Each container includes:**
- Only application and dependencies
- Shares host kernel
- Takes MBs of disk space
- Starts in seconds

**Light and fast!**

---

### Key Differences

| Feature | Virtual Machine | Container |
|---------|----------------|-----------|
| **Size** | GBs | MBs |
| **Startup** | Minutes | Seconds |
| **Performance** | Slower (overhead) | Near-native |
| **Isolation** | Complete | Process-level |
| **Resource Usage** | High | Low |
| **Density** | 10s per host | 100s per host |

**Containers win for most use cases!**

---

## Core Docker Concepts

### Images

**Docker Image = Blueprint**

**Like:**
- Recipe for a cake
- Class in programming
- Template for virtual machines

**Contains:**
- Application code
- Runtime (Node.js, Python, etc.)
- System libraries
- Environment variables
- Configuration files

**Images are:**
- Read-only
- Versioned (tagged)
- Shareable
- Built in layers

**Example images:**
- `nginx:latest` - Web server
- `postgres:16-alpine` - Database
- `node:20-alpine` - Node.js runtime
- `caddy:2.8-alpine` - Reverse proxy

---

### Containers

**Docker Container = Running Instance**

**Like:**
- Actual cake from recipe
- Object from class
- Running VM from template

**Containers are:**
- Created from images
- Isolated from each other
- Temporary by default
- Can be started/stopped
- Have their own filesystem

**Image vs Container:**
```
Image → Container
Recipe → Cake
Class → Object
Program → Process
```

---

### Analogy: Cookie Cutter

**Image = Cookie cutter**
- Defines the shape
- Reusable
- Doesn't change

**Container = Cookie**
- Made from cutter
- Actual edible item
- Can be eaten (deleted)
- Can make many from one cutter

**You can create 100 containers from 1 image!**

---

## Docker Architecture

### Docker Components

**Docker Engine:**
```
┌─────────────────────────────────┐
│      Docker CLI (docker)        │  ← You type commands here
├─────────────────────────────────┤
│      Docker API                 │  ← Commands go through API
├─────────────────────────────────┤
│      Docker Daemon              │  ← Does the actual work
│      (dockerd)                  │
├─────────────────────────────────┤
│      containerd                 │  ← Container runtime
├─────────────────────────────────┤
│      runc                       │  ← Low-level container executor
└─────────────────────────────────┘
```

---

### Docker Client

**What you interact with:**
```bash
docker ps
docker run nginx
docker compose up
```

**Sends commands to daemon via API.**

---

### Docker Daemon

**Background service:**
- Manages images
- Creates containers
- Handles networking
- Manages volumes
- Always running

**Check if running:**
```bash
sudo systemctl status docker
```

---

### Docker Registry

**Where images are stored:**

**Docker Hub (default):**
- hub.docker.com
- Public images
- Official images (nginx, postgres)
- Free for public images

**Private registries:**
- GitHub Container Registry
- GitLab Registry
- Amazon ECR
- Self-hosted registry

**Pull from registry:**
```bash
docker pull nginx:latest
```

**Push to registry:**
```bash
docker push myusername/myimage:v1
```

---

## Docker Images Deep Dive

### Image Layers

**Images are built in layers:**

**Example Dockerfile:**
```dockerfile
FROM ubuntu:22.04           # Layer 1: Base OS
RUN apt update              # Layer 2: Update packages
RUN apt install nginx       # Layer 3: Install nginx
COPY index.html /var/www/   # Layer 4: Add your files
CMD ["nginx"]               # Layer 5: Startup command
```

**Each instruction = New layer**

**Why layers matter:**
- Layers are cached
- Shared between images
- Faster builds
- Less disk space

**Example:**
```
Image A: ubuntu + python + app
Image B: ubuntu + python + different app

Both share "ubuntu" and "python" layers!
```

---

### Image Tags

**Tag = Version label**

**Format:** `repository/name:tag`

**Examples:**
```
nginx:latest            # Latest stable version
nginx:1.25              # Specific version
nginx:1.25-alpine       # Specific version, Alpine base
postgres:16             # PostgreSQL 16
postgres:16-alpine      # PostgreSQL 16, Alpine base
myapp:v1.0.0           # Your app, version 1.0.0
myapp:dev              # Development version
```

**`:latest` is default if no tag specified**

**⚠️ Warning:** `:latest` can change! Pin versions in production.

---

### Alpine vs Regular Images

**Alpine Linux = Tiny base image**

**Comparison:**
```
nginx:1.25          = 187 MB
nginx:1.25-alpine   = 43 MB

postgres:16         = 432 MB
postgres:16-alpine  = 245 MB
```

**Alpine benefits:**
- 5-10x smaller
- Faster downloads
- Less attack surface
- Saves disk space

**Alpine considerations:**
- Uses musl instead of glibc
- Some packages different
- May need adjustments

**We use Alpine in this course!**

---

## Docker Networking

### Network Types

**1. Bridge (Default)**
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│Container │  │Container │  │Container │
│    A     │  │    B     │  │    C     │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └─────────────┴─────────────┘
              docker0 bridge
                   │
              Host Network
```

**Default for containers**
**Containers can talk to each other**

---

**2. Host Network**
```
┌──────────┐
│Container │ ← Uses host's network directly
└────┬─────┘
     │
Host Network
```

**No isolation**
**Best performance**
**Rarely used**

---

**3. None Network**
```
┌──────────┐
│Container │ ← No network access
└──────────┘
```

**Completely isolated**
**For security/testing**

---

**4. Custom Bridge Networks**
```
Web Network:
┌──────────┐  ┌──────────┐
│  Caddy   │  │  Static  │
│          │  │   Site   │
└────┬─────┘  └────┬─────┘
     └─────────────┘

Internal Network:
┌──────────┐  ┌──────────┐
│PostgreSQL│  │  Caddy   │
└──────────┘  └──────────┘
```

**Custom networks for organization**
**Better than default bridge**
**Name-based service discovery**

---

### Our Course Setup

**Two networks:**

**`web` network (external):**
- Caddy (reverse proxy)
- Projects (static-site)
- Exposed to internet

**`internal` network:**
- PostgreSQL
- Caddy (also connected here)
- NOT exposed to internet

**Why?**
- Database only accessible through Caddy
- Even if firewall misconfigured
- Extra security layer

---

### Container Communication

**On same network:**
```bash
# From container A to container B:
curl http://container-b:80

# No need for IP addresses!
# Docker DNS resolves names
```

**Different networks:**
```
Cannot communicate (isolated)
Unless container on both networks
```

**Port mapping (to host):**
```yaml
ports:
  - "8080:80"
# Host port 8080 → Container port 80
```

---

## Docker Volumes

### The Data Persistence Problem

**Containers are ephemeral (temporary):**

**Problem scenario:**
```
1. Start PostgreSQL container
2. Add data to database
3. Stop container
4. Start container again
5. Data is GONE!
```

**Why?** Container filesystem is temporary.

---

### Solution: Volumes

**Volume = Persistent storage**

**Three types:**

**1. Named Volumes (Recommended)**
```yaml
volumes:
  postgres_data:

services:
  postgres:
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

**Managed by Docker**
**Survive container deletion**
**Location: `/var/lib/docker/volumes/`**

---

**2. Bind Mounts**
```yaml
services:
  web:
    volumes:
      - ./html:/usr/share/nginx/html
```

**Maps host directory to container**
**Good for development**
**Host path → Container path**

---

**3. tmpfs (Temporary)**
```yaml
services:
  app:
    tmpfs:
      - /tmp
```

**In memory only**
**Fast but lost on stop**
**For temporary files**

---

### Volume Examples

**Persist database data:**
```yaml
services:
  postgres:
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Serve local files:**
```yaml
services:
  nginx:
    volumes:
      - ./website:/usr/share/nginx/html:ro
#                                         ^^ read-only
```

**Configuration files:**
```yaml
services:
  caddy:
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
```

---

## Docker Compose

### What is Docker Compose?

**Docker Compose = Multi-container orchestration**

**Without Compose:**
```bash
# Start PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:16-alpine

# Start Caddy
docker run -d \
  --name caddy \
  --link postgres \
  -p 80:80 \
  -p 443:443 \
  -v ./Caddyfile:/etc/caddy/Caddyfile \
  caddy:2.8-alpine

# And so on... lots of commands!
```

---

**With Compose:**
```bash
docker compose up
```

**That's it!** Everything defined in `docker-compose.yml`

---

### docker-compose.yml Structure

**Basic structure:**
```yaml
version: '3.8'  # Actually, don't use version anymore (obsolete)

services:       # Define containers
  service1:
    # Configuration
  service2:
    # Configuration

networks:       # Define networks
  network1:
    # Configuration

volumes:        # Define volumes
  volume1:
    # Configuration
```

---

### Example: Web Server

**Simple example:**
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
```

**Explanation:**
- Service name: `web`
- Uses nginx Alpine image
- Maps port 80 on host to port 80 in container
- Mounts `./html` directory (read-only)

---

### Example: Database

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: dbadmin
      POSTGRES_DB: production
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal

networks:
  internal:
    driver: bridge
    internal: true

volumes:
  postgres_data:
```

**Explanation:**
- PostgreSQL 16 Alpine
- Environment variables for config
- Persistent data volume
- Internal network (not exposed)

---

### Example: Full Stack

```yaml
services:
  # Reverse Proxy
  caddy:
    image: caddy:2.8-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
    networks:
      - web
      - internal

  # Application
  app:
    image: node:20-alpine
    command: npm start
    environment:
      DATABASE_URL: postgresql://user:pass@db:5432/myapp
    networks:
      - internal

  # Database
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - internal

networks:
  web:
    external: true
  internal:
    internal: true

volumes:
  caddy_data:
  db_data:
```

---

### Common docker-compose Options

**Image vs Build:**
```yaml
# Use existing image
services:
  web:
    image: nginx:alpine

# Build from Dockerfile
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile
```

---

**Environment Variables:**
```yaml
services:
  app:
    environment:
      NODE_ENV: production
      API_KEY: ${API_KEY}        # From .env file
      DATABASE_URL: postgres://db:5432/mydb
```

---

**Depends On:**
```yaml
services:
  app:
    depends_on:
      - db
  db:
    image: postgres:16-alpine
```

**App starts after db**
**Doesn't wait for db to be ready!**

---

**Restart Policies:**
```yaml
services:
  app:
    restart: unless-stopped
    # Options: no, always, on-failure, unless-stopped
```

---

**Health Checks:**
```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## Docker Security

### Security Considerations

**1. Don't run as root inside container**
```dockerfile
# Bad
USER root

# Good
USER node  # or www-data, or custom user
```

---

**2. Use official images**
```yaml
# Trusted
image: postgres:16-alpine

# Be careful
image: randomguy/postgres:latest
```

---

**3. Pin versions**
```yaml
# Bad (can change)
image: nginx:latest

# Good (specific version)
image: nginx:1.25-alpine
```

---

**4. Don't expose internal services**
```yaml
# Bad
services:
  db:
    ports:
      - "5432:5432"  # Exposed to internet!

# Good
services:
  db:
    networks:
      - internal  # Only accessible internally
```

---

**5. Use secrets for sensitive data**
```yaml
# Bad
environment:
  PASSWORD: mysecretpass123

# Good
environment:
  PASSWORD: ${PASSWORD}  # From .env file
```

---

**6. Limit container capabilities**
```yaml
services:
  app:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

---

## Common Docker Commands Preview

**You'll learn these hands-on in Chapter 13:**

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View images
docker images

# Pull an image
docker pull nginx:alpine

# Run a container
docker run -d --name web nginx:alpine

# Stop a container
docker stop web

# Start a stopped container
docker start web

# View logs
docker logs web
docker logs -f web  # Follow logs

# Execute command in container
docker exec -it web sh

# Remove container
docker rm web

# Remove image
docker rmi nginx:alpine
```

---

**Docker Compose commands:**
```bash
# Start all services
docker compose up

# Start in background
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs
docker compose logs -f

# Restart service
docker compose restart web

# Rebuild images
docker compose build

# Pull latest images
docker compose pull
```

---

## Understanding Our Infrastructure

### What We'll Deploy

**From `/home/kwilliams/hosting/infrastructure/docker-compose.yml`:**

**Services:**
1. **Caddy** (Reverse proxy)
   - Handles HTTPS
   - Routes traffic
   - Connected to `web` and `internal` networks

2. **PostgreSQL** (Database)
   - Production database
   - Only on `internal` network
   - Persistent data volume

3. **pgAdmin** (Database UI)
   - Web interface for database
   - Accessible via subdomain
   - On `web` and `internal` networks

---

**Networks:**
1. **web** (external: true)
   - For public-facing services
   - Created once, shared by projects

2. **internal** (internal: true)
   - For backend services
   - Not accessible from internet
   - Extra security layer

---

**Volumes:**
1. **postgres_data** - Database files
2. **caddy_data** - SSL certificates
3. **caddy_config** - Caddy configuration
4. **pgadmin_data** - pgAdmin settings

---

### Project Structure

**Projects get their own compose files:**

```
hosting/
├── infrastructure/
│   └── docker-compose.yml    # Core services
└── projects/
    ├── static-site/
    │   └── docker-compose.yml
    └── backend-app/
        └── docker-compose.yml
```

**Why separate?**
- Infrastructure runs once
- Projects independent
- Easy to add/remove projects
- Clear organization

---

## Container Lifecycle

### States

```
Created → Running → Paused → Stopped → Removed
   ↓         ↑         ↑         ↑
   └─────────┴─────────┴─────────┘
           (restart)
```

**Created:** Exists but not started
**Running:** Active and working
**Paused:** Temporarily frozen
**Stopped:** Not running but exists
**Removed:** Deleted completely

---

### Data Persistence

**What persists:**
- ✅ Named volumes
- ✅ Bind mounts
- ✅ External volumes

**What's lost:**
- ❌ Container filesystem changes
- ❌ Unnamed volumes (when container removed)
- ❌ tmpfs volumes

**Golden rule:** Important data goes in volumes!

---

## Best Practices

### Image Selection

**✅ Do:**
- Use official images
- Use Alpine when possible
- Pin specific versions
- Review image documentation

**❌ Don't:**
- Use random images
- Use `:latest` in production
- Use oversized images
- Ignore security updates

---

### Configuration

**✅ Do:**
- Use `.env` files for secrets
- Use named volumes
- Use custom networks
- Document your setup
- Use health checks

**❌ Don't:**
- Hardcode passwords
- Expose databases publicly
- Use default networks
- Run everything as root
- Skip backups

---

### Organization

**✅ Do:**
```
Clear naming:
  services: web, db, cache
  networks: web, internal
  volumes: postgres_data

Logical grouping:
  infrastructure/
  projects/
  
Documentation:
  README.md per directory
```

**❌ Don't:**
```
Confusing names:
  services: thing1, stuff, container2
  
One giant file:
  Everything in one docker-compose.yml
  
No documentation
```

---

## Key Takeaways

**Remember:**

1. **Containers vs VMs**
   - Containers share kernel
   - Much lighter and faster
   - Better for microservices

2. **Images vs Containers**
   - Image = blueprint (template)
   - Container = running instance
   - Many containers from one image

3. **Networking matters**
   - Isolate internal services
   - Use custom networks
   - Name-based service discovery

4. **Data persistence requires volumes**
   - Containers are temporary
   - Use named volumes for data
   - Bind mounts for config/files

5. **Docker Compose simplifies deployment**
   - Define once in YAML
   - Start with one command
   - Reproducible across environments

6. **Security is critical**
   - Don't expose databases
   - Use secrets properly
   - Pin image versions
   - Limit capabilities

---

## Next Steps

**You now understand:**
- ✅ What Docker is and why use it
- ✅ Containers vs VMs
- ✅ Images and containers
- ✅ Docker architecture
- ✅ Networking and volumes
- ✅ Docker Compose structure

**In Chapter 13:**
- Install Docker on your server
- Run your first container
- Use Docker Compose
- Deploy test services
- Prepare for infrastructure deployment

**Get ready for hands-on Docker!**

---

## Quick Reference

### Core Concepts

```
Image → Container
Recipe → Cake
Class → Object

Container = Isolated process
Volume = Persistent storage
Network = Container communication
Compose = Multi-container definition
```

### Architecture

```
You → Docker CLI → Docker Daemon → containerd → Containers
```

### docker-compose.yml Basics

```yaml
services:          # What to run
  name:
    image:         # Which image
    ports:         # Port mapping
    volumes:       # Persistent data
    networks:      # Which networks
    environment:   # Config variables

networks:          # Network definitions
volumes:           # Volume definitions
```

---

[← Previous: Chapter 11 - System Hardening](11-system-hardening.md) | [Next: Chapter 13 - Docker Installation →](13-docker-installation.md)
