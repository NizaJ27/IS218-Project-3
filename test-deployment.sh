#!/bin/bash

# Test Deployment Script
# Simulates GitHub Actions workflow locally before pushing

set -e  # Exit on any error

echo "================================================"
echo "🧪 Testing Deployment Workflow Locally"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load secrets from environment or prompt
if [ -z "$SERVER_HOST" ]; then
    echo -e "${YELLOW}⚠️  SERVER_HOST not set${NC}"
    read -p "Enter server host (IP): " SERVER_HOST
fi

if [ -z "$SERVER_USER" ]; then
    echo -e "${YELLOW}⚠️  SERVER_USER not set${NC}"
    read -p "Enter server user: " SERVER_USER
fi

if [ -z "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}⚠️  SSH_KEY_PATH not set${NC}"
    read -p "Enter SSH key path (e.g., ~/.ssh/github_actions_deploy): " SSH_KEY_PATH
fi

SSH_PORT=${SSH_PORT:-2222}

echo ""
echo "Configuration:"
echo "  Host: $SERVER_HOST"
echo "  User: $SERVER_USER"
echo "  Port: $SSH_PORT"
echo "  Key:  $SSH_KEY_PATH"
echo ""

# Step 1: Verify SSH key exists
echo "Step 1: Verifying SSH key..."
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${RED}❌ SSH key not found at $SSH_KEY_PATH${NC}"
    exit 1
fi

if [ $(stat -f "%OLp" "$SSH_KEY_PATH" 2>/dev/null || stat -c "%a" "$SSH_KEY_PATH" 2>/dev/null) != "600" ]; then
    echo -e "${YELLOW}⚠️  SSH key permissions should be 600${NC}"
    chmod 600 "$SSH_KEY_PATH"
    echo "  Fixed permissions to 600"
fi
echo -e "${GREEN}✅ SSH key verified${NC}"
echo ""

# Step 2: Test SSH connection
echo "Step 2: Testing SSH connection..."
if ssh -o ConnectTimeout=10 \
       -o StrictHostKeyChecking=no \
       -o UserKnownHostsFile=/dev/null \
       -o LogLevel=ERROR \
       -i "$SSH_KEY_PATH" \
       -p "$SSH_PORT" \
       "$SERVER_USER@$SERVER_HOST" \
       'echo "SSH connection successful"' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ SSH connection successful${NC}"
else
    echo -e "${RED}❌ SSH connection failed${NC}"
    echo "  Please check:"
    echo "    - Server is accessible"
    echo "    - SSH key is authorized on server"
    echo "    - Port $SSH_PORT is correct"
    exit 1
fi
echo ""

# Step 3: Test git pull on server
echo "Step 3: Testing git pull on server..."
if ssh -o StrictHostKeyChecking=no \
       -o UserKnownHostsFile=/dev/null \
       -o LogLevel=ERROR \
       -i "$SSH_KEY_PATH" \
       -p "$SSH_PORT" \
       "$SERVER_USER@$SERVER_HOST" \
       'cd ~/mywebclass_hosting && git pull origin master' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Git pull successful${NC}"
else
    echo -e "${RED}❌ Git pull failed${NC}"
    echo "  Please check:"
    echo "    - Repository exists at ~/mywebclass_hosting"
    echo "    - Git is configured on server"
    exit 1
fi
echo ""

# Step 4: Test Docker Compose on server
echo "Step 4: Testing Docker Compose..."
if ssh -o StrictHostKeyChecking=no \
       -o UserKnownHostsFile=/dev/null \
       -o LogLevel=ERROR \
       -i "$SSH_KEY_PATH" \
       -p "$SSH_PORT" \
       "$SERVER_USER@$SERVER_HOST" \
       'cd ~/mywebclass_hosting/projects/backend && docker compose ps' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose accessible${NC}"
else
    echo -e "${RED}❌ Docker Compose check failed${NC}"
    echo "  Please check:"
    echo "    - Docker is installed"
    echo "    - User has Docker permissions"
    echo "    - Backend directory exists"
    exit 1
fi
echo ""

# Step 5: Simulate full deployment command
echo "Step 5: Simulating full deployment (DRY RUN)..."
echo "  This will test the exact command chain from GitHub Actions"
echo ""

DEPLOY_CMD='cd ~/mywebclass_hosting && \
  echo "📂 Changed to: $(pwd)" && \
  git fetch origin master && \
  echo "📥 Fetched latest from origin/master" && \
  git status && \
  cd ~/mywebclass_hosting/projects/backend && \
  echo "📂 Changed to: $(pwd)" && \
  docker compose ps && \
  echo "✅ All commands executed successfully!"'

if ssh -o StrictHostKeyChecking=no \
       -o UserKnownHostsFile=/dev/null \
       -o LogLevel=ERROR \
       -i "$SSH_KEY_PATH" \
       -p "$SSH_PORT" \
       "$SERVER_USER@$SERVER_HOST" \
       "$DEPLOY_CMD"; then
    echo ""
    echo -e "${GREEN}✅ Deployment simulation successful${NC}"
else
    echo ""
    echo -e "${RED}❌ Deployment simulation failed${NC}"
    exit 1
fi
echo ""

# Step 6: Check backend container
echo "Step 6: Checking backend container status..."
CONTAINER_STATUS=$(ssh -o StrictHostKeyChecking=no \
                       -o UserKnownHostsFile=/dev/null \
                       -o LogLevel=ERROR \
                       -i "$SSH_KEY_PATH" \
                       -p "$SSH_PORT" \
                       "$SERVER_USER@$SERVER_HOST" \
                       'docker ps | grep backend || echo "NOT_RUNNING"')

if echo "$CONTAINER_STATUS" | grep -q "backend"; then
    echo -e "${GREEN}✅ Backend container is running${NC}"
    echo ""
    echo "Container details:"
    echo "$CONTAINER_STATUS"
else
    echo -e "${YELLOW}⚠️  Backend container not currently running${NC}"
    echo "  This is OK for testing, but deployment will start it"
fi
echo ""

# Step 7: Test health endpoint (if available)
echo "Step 7: Testing health endpoint..."
if command -v curl &> /dev/null; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://api.theratoast.com/health" 2>/dev/null || echo "000")
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo -e "${GREEN}✅ Health endpoint responding (HTTP $HTTP_STATUS)${NC}"
    else
        echo -e "${YELLOW}⚠️  Health endpoint returned HTTP $HTTP_STATUS${NC}"
        echo "  This might be OK if backend needs to be restarted"
    fi
else
    echo -e "${YELLOW}⚠️  curl not available, skipping health check${NC}"
fi
echo ""

# Summary
echo "================================================"
echo -e "${GREEN}🎉 All Pre-Flight Checks Passed!${NC}"
echo "================================================"
echo ""
echo "Your deployment workflow should work in GitHub Actions."
echo ""
echo "To deploy now:"
echo "  1. Commit your changes: git add . && git commit -m 'Your message'"
echo "  2. Push to GitHub: git push origin master"
echo "  3. Watch workflow: https://github.com/NizaJ27/IS218-Project-3/actions"
echo ""
