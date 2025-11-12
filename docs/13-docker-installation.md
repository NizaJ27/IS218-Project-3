# Chapter 13: Docker Installation

**Installing Docker and Running Your First Containers**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Install Docker Engine on Ubuntu
- ✅ Install Docker Compose
- ✅ Run your first container
- ✅ Use basic Docker commands
- ✅ Create a simple docker-compose.yml
- ✅ Manage containers and images
- ✅ Troubleshoot common issues

**Time Required:** 40-50 minutes

---

## Pre-Installation Check

### Verify System Requirements

**Check Ubuntu version:**
```bash
lsb_release -a
```

**Should show:** Ubuntu 22.04+ or 24.04

**Check architecture:**
```bash
uname -m
```

**Should show:** `x86_64` (64-bit)

**Check available disk space:**
```bash
df -h /
```

**Need:** At least 10GB free

---

### Remove Old Versions

**If Docker was previously installed:**
```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

**This won't delete:**
- Images
- Containers
- Volumes
- Networks

**Those are stored in `/var/lib/docker/`**

---

## Install Docker Engine

### Step 1: Update Package Index

```bash
sudo apt update
```

---

### Step 2: Install Prerequisites

```bash
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    -y
```

**What these do:**
- `ca-certificates` - SSL certificates
- `curl` - Download files
- `gnupg` - GPG keys for verification
- `lsb-release` - Distribution info

---

### Step 3: Add Docker's GPG Key

**Create keyring directory:**
```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

**Download Docker's GPG key:**
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

**Set permissions:**
```bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

---

### Step 4: Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**This adds official Docker repository to your system.**

---

### Step 5: Install Docker

**Update package index again:**
```bash
sudo apt update
```

**Install Docker packages:**
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

**Packages explained:**
- `docker-ce` - Docker Engine (Community Edition)
- `docker-ce-cli` - Command-line interface
- `containerd.io` - Container runtime
- `docker-buildx-plugin` - Build images
- `docker-compose-plugin` - Compose V2

**This takes 2-3 minutes.**

---

### Step 6: Verify Installation

**Check Docker version:**
```bash
docker --version
```

**Output:**
```
Docker version 24.0.7, build afdd53b
```

**Check Docker Compose:**
```bash
docker compose version
```

**Output:**
```
Docker Compose version v2.23.0
```

**Check Docker service:**
```bash
sudo systemctl status docker
```

**Should show:**
```
● docker.service - Docker Application Container Engine
     Active: active (running)
```

---

### Step 7: Test Docker

**Run test container:**
```bash
sudo docker run hello-world
```

**You should see:**
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Success!** Docker is installed and working.

---

## Configure Docker (Non-Root Access)

### The Sudo Problem

**Right now, you need sudo for every command:**
```bash
sudo docker ps
sudo docker run nginx
sudo docker compose up
```

**Annoying!**

---

### Add User to Docker Group

**Add your user to docker group:**
```bash
sudo usermod -aG docker $USER
```

**Log out and back in for changes to take effect:**
```bash
exit
```

**SSH back in:**
```bash
ssh -p 2222 deploy@YOUR_SERVER_IP
```

**Verify group membership:**
```bash
groups
```

**Should see:** `deploy sudo docker`

---

### Test Without Sudo

**Now try without sudo:**
```bash
docker ps
```

**Should work!** No permission denied.

**Run hello-world again:**
```bash
docker run hello-world
```

**Works without sudo!**

---

## Basic Docker Commands

### Working with Containers

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Run a container:**
```bash
docker run nginx:alpine
```

**Run in background (detached):**
```bash
docker run -d nginx:alpine
```

**Run with name:**
```bash
docker run -d --name my-nginx nginx:alpine
```

**Run with port mapping:**
```bash
docker run -d -p 8080:80 --name web nginx:alpine
```

**Stop a container:**
```bash
docker stop web
```

**Start a stopped container:**
```bash
docker start web
```

**Restart a container:**
```bash
docker restart web
```

**Remove a container:**
```bash
docker rm web
```

**Remove running container (force):**
```bash
docker rm -f web
```

---

### Working with Images

**List images:**
```bash
docker images
```

**Pull an image:**
```bash
docker pull nginx:alpine
```

**Pull specific version:**
```bash
docker pull postgres:16-alpine
```

**Remove an image:**
```bash
docker rmi nginx:alpine
```

**Remove unused images:**
```bash
docker image prune
```

**Remove all unused images:**
```bash
docker image prune -a
```

---

### Viewing Logs

**View container logs:**
```bash
docker logs web
```

**Follow logs (real-time):**
```bash
docker logs -f web
```

**Last 50 lines:**
```bash
docker logs --tail 50 web
```

**Logs with timestamps:**
```bash
docker logs -t web
```

---

### Executing Commands in Containers

**Open shell in running container:**
```bash
docker exec -it web sh
```

**Run single command:**
```bash
docker exec web ls -la /usr/share/nginx/html
```

**Run as root:**
```bash
docker exec -u root web whoami
```

**Exit container shell:**
```
exit
```

---

### Inspecting Containers

**Detailed container info:**
```bash
docker inspect web
```

**Get specific value:**
```bash
docker inspect --format='{{.NetworkSettings.IPAddress}}' web
```

**Container stats (CPU, memory):**
```bash
docker stats web
```

**All containers stats:**
```bash
docker stats
```

---

## Your First Practical Container

### Run Nginx Web Server

**Step 1: Create HTML directory:**
```bash
mkdir -p ~/test-docker/html
cd ~/test-docker
```

**Step 2: Create index.html:**
```bash
nano html/index.html
```

**Add:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>My First Docker Container</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This is served from an nginx container.</p>
    <p>Container technology is awesome!</p>
</body>
</html>
```

**Save:** Ctrl+X, Y, Enter

---

**Step 3: Run nginx with volume:**
```bash
docker run -d \
  --name test-web \
  -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  nginx:alpine
```

**Breaking it down:**
- `-d` = Run in background
- `--name test-web` = Container name
- `-p 8080:80` = Map host port 8080 to container port 80
- `-v $(pwd)/html:/usr/share/nginx/html:ro` = Mount local html directory
- `:ro` = Read-only
- `nginx:alpine` = Image to use

---

**Step 4: Test it:**
```bash
curl http://localhost:8080
```

**Should show your HTML!**

**From your computer:**
```bash
curl http://YOUR_SERVER_IP:8080
```

**⚠️ Won't work yet - firewall blocks port 8080!**

**For now, test locally on server.**

---

**Step 5: View logs:**
```bash
docker logs test-web
```

**Should see access logs:**
```
192.168.1.1 - - [12/Nov/2025:10:30:45 +0000] "GET / HTTP/1.1" 200 ...
```

---

**Step 6: Update content:**
```bash
echo "<h1>Updated content!</h1>" > html/index.html
```

**Reload:**
```bash
curl http://localhost:8080
```

**Content updated!** No container restart needed.

---

**Step 7: Clean up:**
```bash
docker stop test-web
docker rm test-web
```

---

## Docker Compose in Action

### Create Your First Compose File

**Step 1: Create project directory:**
```bash
mkdir -p ~/test-compose
cd ~/test-compose
```

---

**Step 2: Create docker-compose.yml:**
```bash
nano docker-compose.yml
```

**Add:**
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped
    
  whoami:
    image: traefik/whoami
    ports:
      - "8081:80"
    restart: unless-stopped
```

**Save:** Ctrl+X, Y, Enter

---

**Step 3: Create HTML:**
```bash
mkdir html
echo "<h1>Hello from Compose!</h1>" > html/index.html
```

---

**Step 4: Start services:**
```bash
docker compose up -d
```

**Output:**
```
[+] Running 3/3
 ✔ Network test-compose_default  Created
 ✔ Container test-compose-web-1     Started
 ✔ Container test-compose-whoami-1  Started
```

---

**Step 5: Check status:**
```bash
docker compose ps
```

**Output:**
```
NAME                    IMAGE              STATUS
test-compose-web-1      nginx:alpine       Up
test-compose-whoami-1   traefik/whoami     Up
```

---

**Step 6: Test services:**
```bash
curl http://localhost:8080
curl http://localhost:8081
```

**Both should respond!**

---

**Step 7: View logs:**
```bash
docker compose logs
```

**Follow logs:**
```bash
docker compose logs -f
```

**Logs for specific service:**
```bash
docker compose logs web
```

---

**Step 8: Stop services:**
```bash
docker compose down
```

**Output:**
```
[+] Running 3/3
 ✔ Container test-compose-whoami-1  Removed
 ✔ Container test-compose-web-1     Removed
 ✔ Network test-compose_default     Removed
```

---

## Docker Compose Commands

### Essential Commands

**Start services:**
```bash
docker compose up          # Foreground
docker compose up -d       # Background (detached)
```

**Stop services:**
```bash
docker compose stop        # Stop but don't remove
docker compose down        # Stop and remove
docker compose down -v     # Stop, remove, and delete volumes
```

**View status:**
```bash
docker compose ps          # Running services
docker compose ps -a       # All services
```

**Logs:**
```bash
docker compose logs        # All logs
docker compose logs -f     # Follow logs
docker compose logs web    # Specific service
```

**Restart:**
```bash
docker compose restart     # All services
docker compose restart web # Specific service
```

**Execute commands:**
```bash
docker compose exec web sh
docker compose exec web ls -la
```

**Pull images:**
```bash
docker compose pull
```

**Build images:**
```bash
docker compose build
docker compose up --build  # Build and start
```

---

## Working with Networks

### Create Custom Network

**Create network:**
```bash
docker network create web
```

**List networks:**
```bash
docker network ls
```

**Inspect network:**
```bash
docker network inspect web
```

**Remove network:**
```bash
docker network rm web
```

---

### Network in Compose

**Create networks directory:**
```bash
mkdir -p ~/test-networks
cd ~/test-networks
```

**Create docker-compose.yml:**
```bash
nano docker-compose.yml
```

**Add:**
```yaml
services:
  web:
    image: nginx:alpine
    networks:
      - frontend
      
  app:
    image: node:20-alpine
    command: sleep infinity
    networks:
      - frontend
      - backend
      
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: testpass
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

**Start:**
```bash
docker compose up -d
```

**Test connectivity:**
```bash
# App can reach web (both on frontend)
docker compose exec app ping -c 3 web

# App can reach db (both on backend)
docker compose exec app ping -c 3 db

# Web cannot reach db (different networks)
docker compose exec web ping -c 3 db  # Fails!
```

**Clean up:**
```bash
docker compose down
cd ~
```

---

## Working with Volumes

### Named Volumes

**Create volume:**
```bash
docker volume create mydata
```

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect mydata
```

**Use in container:**
```bash
docker run -d \
  --name data-container \
  -v mydata:/data \
  alpine sh -c "echo hello > /data/test.txt && sleep infinity"
```

**Check data:**
```bash
docker exec data-container cat /data/test.txt
```

**Remove container:**
```bash
docker rm -f data-container
```

**Data persists!** Create new container:
```bash
docker run --rm -v mydata:/data alpine cat /data/test.txt
```

**Still there!**

**Remove volume:**
```bash
docker volume rm mydata
```

---

### Volume in Compose

**Example with persistent data:**
```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**Even if you `docker compose down`, data persists!**

**To remove volumes too:**
```bash
docker compose down -v
```

---

## System Maintenance

### Clean Up Commands

**Remove stopped containers:**
```bash
docker container prune
```

**Remove unused images:**
```bash
docker image prune
```

**Remove unused volumes:**
```bash
docker volume prune
```

**Remove unused networks:**
```bash
docker network prune
```

**Remove everything unused:**
```bash
docker system prune
```

**Remove EVERYTHING (including volumes):**
```bash
docker system prune -a --volumes
```

**⚠️ Warning:** Prune commands delete data permanently!

---

### Check Disk Usage

**See Docker disk usage:**
```bash
docker system df
```

**Output:**
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          10        2         2.5GB     1.8GB (72%)
Containers      5         2         50MB      30MB (60%)
Local Volumes   3         1         500MB     300MB (60%)
Build Cache     0         0         0B        0B
```

**Detailed view:**
```bash
docker system df -v
```

---

## Environment Variables and Secrets

### Using .env Files

**Create .env file:**
```bash
nano .env
```

**Add:**
```env
POSTGRES_PASSWORD=your_secure_password
POSTGRES_USER=dbadmin
POSTGRES_DB=production
APP_ENV=production
API_KEY=abc123xyz
```

**Save and set permissions:**
```bash
chmod 600 .env
```

---

**Use in docker-compose.yml:**
```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_DB: ${POSTGRES_DB}
      
  app:
    image: myapp:latest
    environment:
      APP_ENV: ${APP_ENV}
      API_KEY: ${API_KEY}
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
```

**Never commit .env to Git!**

**Create .env.example:**
```bash
cp .env .env.example
nano .env.example
```

**Replace secrets with placeholders:**
```env
POSTGRES_PASSWORD=changeme
POSTGRES_USER=dbadmin
POSTGRES_DB=production
APP_ENV=production
API_KEY=your_api_key_here
```

**Commit .env.example, not .env!**

---

## Troubleshooting

### Problem: Permission Denied

**Error:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
exit
ssh -p 2222 deploy@YOUR_SERVER_IP

# Verify
groups
docker ps
```

---

### Problem: Port Already in Use

**Error:**
```
Bind for 0.0.0.0:80 failed: port is already allocated
```

**Find what's using port:**
```bash
sudo ss -tlnp | grep :80
```

**Stop conflicting service:**
```bash
sudo systemctl stop nginx  # If nginx is running
```

**Or use different port:**
```yaml
ports:
  - "8080:80"  # Use 8080 instead
```

---

### Problem: Container Immediately Exits

**Check logs:**
```bash
docker logs container-name
```

**Common causes:**
- No command to keep running
- Configuration error
- Missing environment variables

**Test with shell:**
```bash
docker run -it nginx:alpine sh
```

---

### Problem: Cannot Connect to Service

**Check if container is running:**
```bash
docker ps
```

**Check if port is mapped:**
```bash
docker ps | grep container-name
```

**Check logs:**
```bash
docker logs container-name
```

**Test from inside:**
```bash
docker exec container-name curl localhost:80
```

**Check network:**
```bash
docker network inspect network-name
```

---

### Problem: Out of Disk Space

**Check usage:**
```bash
docker system df
```

**Clean up:**
```bash
docker system prune -a
```

**Check again:**
```bash
df -h /var/lib/docker
```

---

## Best Practices

### Image Management

**✅ Do:**
```bash
# Pull specific versions
docker pull nginx:1.25-alpine

# Tag your own images
docker tag myapp:latest myapp:v1.0.0

# Use small base images
FROM alpine:3.18
```

**❌ Don't:**
```bash
# Avoid :latest in production
docker pull nginx:latest

# Don't accumulate unused images
# Run prune regularly
```

---

### Container Management

**✅ Do:**
```yaml
# Use meaningful names
services:
  web:
  db:
  cache:

# Set restart policies
restart: unless-stopped

# Use health checks
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
```

**❌ Don't:**
```yaml
# Avoid unclear names
services:
  container1:
  thing2:

# Don't forget restart policies
# (containers won't start on reboot)
```

---

### Security

**✅ Do:**
```yaml
# Use .env for secrets
environment:
  PASSWORD: ${PASSWORD}

# Don't expose unnecessary ports
# Use internal networks

# Run as non-root user
user: "1000:1000"
```

**❌ Don't:**
```yaml
# Don't hardcode secrets
environment:
  PASSWORD: "mysecretpass123"

# Don't expose everything
ports:
  - "5432:5432"  # Don't expose database!
```

---

## Verification Checklist

**Before finishing this chapter:**

- ✅ Docker Engine installed
- ✅ Docker Compose installed
- ✅ User added to docker group
- ✅ Can run `docker ps` without sudo
- ✅ Ran hello-world successfully
- ✅ Created and ran simple container
- ✅ Created and ran docker-compose project
- ✅ Understand basic Docker commands
- ✅ Know how to view logs
- ✅ Can clean up resources

---

## Practice Exercises

### Exercise 1: Container Basics

```bash
# Run nginx
docker run -d --name practice-web -p 8888:80 nginx:alpine

# Check it's running
docker ps

# View logs
docker logs practice-web

# Execute command
docker exec practice-web ls -la /usr/share/nginx/html

# Stop and remove
docker stop practice-web
docker rm practice-web
```

---

### Exercise 2: Compose Stack

**Create directory:**
```bash
mkdir ~/exercise-compose
cd ~/exercise-compose
```

**Create docker-compose.yml:**
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
      
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: testpass
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**Create HTML:**
```bash
mkdir html
echo "<h1>Exercise Complete!</h1>" > html/index.html
```

**Start:**
```bash
docker compose up -d
```

**Test:**
```bash
curl http://localhost:8080
docker compose ps
docker compose logs
```

**Clean up:**
```bash
docker compose down -v
cd ~
rm -rf ~/exercise-compose
```

---

### Exercise 3: Resource Management

```bash
# Check disk usage
docker system df

# Pull some images
docker pull nginx:alpine
docker pull postgres:16-alpine
docker pull redis:alpine

# Check usage again
docker system df

# Clean up
docker image prune
docker system df
```

---

## Key Takeaways

**Remember:**

1. **Docker simplifies deployment**
   - One command to start everything
   - Consistent across environments
   - Easy to manage

2. **Images vs Containers**
   - Pull images from registries
   - Run containers from images
   - Containers are temporary

3. **Docker Compose for multi-container**
   - Define in docker-compose.yml
   - Start with `docker compose up`
   - Stop with `docker compose down`

4. **Volumes for persistence**
   - Container data is temporary
   - Use volumes for databases
   - Named volumes are portable

5. **Networks for isolation**
   - Custom networks for organization
   - Internal networks for security
   - Name-based service discovery

6. **Regular maintenance**
   - Prune unused resources
   - Update images
   - Monitor disk usage

---

## Next Steps

**You now have:**
- ✅ Working Docker installation
- ✅ Docker Compose configured
- ✅ Hands-on container experience
- ✅ Understanding of basic commands
- ✅ Ready for infrastructure deployment

**In Part 4 (DNS):**
- Chapter 14: DNS fundamentals
- Chapter 15: Domain configuration
- Point domain to your server
- Configure DNS records
- Prepare for HTTPS

**Then in Part 5:**
- Deploy actual infrastructure (Caddy, PostgreSQL, pgAdmin)
- Use your docker-compose setup
- Get real applications running!

---

## Quick Reference

### Essential Docker Commands

```bash
# Containers
docker ps                   # List running
docker ps -a               # List all
docker run IMAGE           # Create and start
docker start NAME          # Start stopped container
docker stop NAME           # Stop container
docker rm NAME             # Remove container
docker logs NAME           # View logs
docker exec -it NAME sh    # Open shell

# Images
docker images              # List images
docker pull IMAGE          # Download image
docker rmi IMAGE           # Remove image

# System
docker system df           # Disk usage
docker system prune        # Clean up

# Compose
docker compose up          # Start services
docker compose up -d       # Start in background
docker compose down        # Stop and remove
docker compose ps          # List services
docker compose logs        # View logs
docker compose logs -f     # Follow logs
```

### docker-compose.yml Template

```yaml
services:
  service-name:
    image: image:tag
    ports:
      - "host:container"
    volumes:
      - volume:/path
    networks:
      - network-name
    environment:
      VAR: value
    restart: unless-stopped

networks:
  network-name:

volumes:
  volume-name:
```

---

[← Previous: Chapter 12 - Docker Concepts](12-docker-concepts.md) | [Next: Chapter 14 - DNS Fundamentals →](14-dns-fundamentals.md)
