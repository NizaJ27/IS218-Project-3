#!/bin/bash

###############################################################################
# AUTO-DEPLOY SCRIPT
# 
# This script runs on your server and automatically deploys when changes
# are detected in your GitHub repository.
#
# Setup:
# 1. Copy to server: ~/mywebclass_hosting/auto-deploy.sh
# 2. Make executable: chmod +x ~/mywebclass_hosting/auto-deploy.sh
# 3. Add to crontab: crontab -e
#    */5 * * * * /home/deploy/mywebclass_hosting/auto-deploy.sh >> /home/deploy/deploy.log 2>&1
# 
# This checks for updates every 5 minutes and deploys automatically.
###############################################################################

set -e

# Configuration
REPO_DIR="$HOME/mywebclass_hosting"
BACKEND_DIR="$REPO_DIR/projects/backend"
LOG_FILE="$HOME/deploy.log"
LOCK_FILE="/tmp/auto-deploy.lock"

# Prevent multiple instances
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): Another deployment is in progress, skipping..."
    exit 0
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

echo "$(date): Checking for updates..."

cd "$REPO_DIR"

# Fetch latest changes
git fetch origin master

# Check if there are new commits
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "$(date): Already up to date (commit: ${LOCAL:0:7})"
    exit 0
fi

echo "$(date): 🚀 New changes detected! Deploying..."
echo "$(date):    Old commit: ${LOCAL:0:7}"
echo "$(date):    New commit: ${REMOTE:0:7}"

# Pull latest changes
git pull origin master

# Check if backend files changed
if git diff --name-only $LOCAL $REMOTE | grep -q "projects/backend\|infrastructure"; then
    echo "$(date): Backend changes detected, redeploying..."
    
    cd "$BACKEND_DIR"
    
    # Redeploy with Docker Compose
    docker compose up -d --build
    
    # Wait for container to be ready
    sleep 10
    
    # Verify deployment
    if docker ps | grep -q backend; then
        echo "$(date): ✅ Backend container is running"
        
        # Health check
        sleep 5
        HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.theratoast.com/health || echo "000")
        
        if [ "$HEALTH_STATUS" = "200" ]; then
            echo "$(date): ✅ Health check passed (HTTP $HEALTH_STATUS)"
            echo "$(date): ✅ Deployment completed successfully!"
        else
            echo "$(date): ⚠️  Health check returned HTTP $HEALTH_STATUS"
        fi
    else
        echo "$(date): ❌ Backend container failed to start"
        docker compose logs --tail=50
        exit 1
    fi
else
    echo "$(date): No backend changes, skipping deployment"
fi

echo "$(date): ✅ Update check completed"
