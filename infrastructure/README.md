# Infrastructure Setup

This directory contains the core production infrastructure services that run continuously.

## Services

- **Caddy** - Reverse proxy with automatic HTTPS (Let's Encrypt)
- **PostgreSQL** - Production database server
- **pgAdmin** - Web-based database management interface
- **Watchtower** - Automated container updates (runs daily at 4 AM)

## Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and set strong passwords:**
   ```bash
   nano .env
   ```

3. **Start all services:**
   ```bash
   docker compose up -d
   ```

4. **Verify everything is running:**
   ```bash
   docker compose ps
   ```

## Accessing Services

- **Main website:** https://www.mywebclass.org
- **pgAdmin:** https://pgadmin.mywebclass.org
- **PostgreSQL:** Only accessible from other containers on `internal` network

## Managing Services

### View logs
```bash
docker compose logs -f
docker compose logs caddy
docker compose logs postgres
```

### Restart a service
```bash
docker compose restart caddy
```

### Stop all services
```bash
docker compose down
```

### Update containers manually
```bash
docker compose pull
docker compose up -d
```

## Notes

- Watchtower automatically updates containers daily at 4 AM
- SSL certificates are automatically managed by Caddy
- PostgreSQL data persists in Docker volumes
- All passwords should be changed from the examples!

## CI/CD
Automated deployment configured via GitHub Actions.
Last updated: Sun Nov 30 19:37:07 EST 2025

Updated: 2025-11-30 19:39:15
Deployment test: 19:40:15
Final deployment test: 2025-11-30 19:41:44
Using SSH action: 2025-11-30 19:43:42
Direct SSH deployment: 2025-11-30 19:45:03
# Deployment Test 2025-11-30 19:53:57
# Deployment trigger 2025-11-30 19:55:38
