# Testing Deployment Locally

## Overview

Before pushing changes to GitHub Actions, use `test-deployment.sh` to verify your deployment will work.

## Prerequisites

1. SSH key configured: `~/.ssh/github_actions_deploy`
2. Server access: Port 2222 to your server
3. Server has:
   - Git repository at `~/mywebclass_hosting`
   - Docker Compose installed
   - Backend project at `~/mywebclass_hosting/projects/backend`

## Usage

### Quick Test

```bash
./test-deployment.sh
```

The script will prompt for:
- Server host (IP address)
- Server user
- SSH key path

### With Environment Variables

```bash
SERVER_HOST=104.131.191.83 \
SERVER_USER=deploy \
SSH_PORT=2222 \
SSH_KEY_PATH=~/.ssh/github_actions_deploy \
./test-deployment.sh
```

## What It Tests

1. ✅ SSH key exists and has correct permissions (600)
2. ✅ SSH connection to server works
3. ✅ Git pull works on server
4. ✅ Docker Compose is accessible
5. ✅ Full deployment command chain executes
6. ✅ Backend container is running
7. ✅ Health endpoint responds (if available)

## Example Output

```
================================================
🧪 Testing Deployment Workflow Locally
================================================

Configuration:
  Host: 104.131.191.83
  User: deploy
  Port: 2222
  Key:  ~/.ssh/github_actions_deploy

Step 1: Verifying SSH key...
✅ SSH key verified

Step 2: Testing SSH connection...
✅ SSH connection successful

Step 3: Testing git pull on server...
✅ Git pull successful

Step 4: Testing Docker Compose...
✅ Docker Compose accessible

Step 5: Simulating full deployment (DRY RUN)...
✅ Deployment simulation successful

Step 6: Checking backend container status...
✅ Backend container is running

Step 7: Testing health endpoint...
✅ Health endpoint responding (HTTP 200)

================================================
🎉 All Pre-Flight Checks Passed!
================================================

Your deployment workflow should work in GitHub Actions.
```

## Workflow

1. **Make code changes**
2. **Run test script**: `./test-deployment.sh`
3. **If all tests pass**: Commit and push to GitHub
4. **Watch GitHub Actions**: https://github.com/NizaJ27/IS218-Project-3/actions

## Troubleshooting

### SSH Connection Failed

```bash
# Test SSH manually
ssh -i ~/.ssh/github_actions_deploy -p 2222 deploy@104.131.191.83

# Check authorized_keys on server
ssh -p 2222 deploy@104.131.191.83
cat ~/.ssh/authorized_keys
```

### Git Pull Failed

```bash
# On server, verify repository
ssh -p 2222 deploy@104.131.191.83
cd ~/mywebclass_hosting
git status
git remote -v
```

### Docker Compose Failed

```bash
# On server, check Docker permissions
ssh -p 2222 deploy@104.131.191.83
docker ps
groups  # Should show 'docker' group
```

### Health Check Failed

```bash
# Test endpoint manually
curl -v https://api.theratoast.com/health

# Check backend logs on server
ssh -p 2222 deploy@104.131.191.83
cd ~/mywebclass_hosting/projects/backend
docker compose logs backend
```

## Benefits

- 🚀 **Faster feedback**: Catch issues locally in seconds
- 💰 **Save GitHub Actions minutes**: Don't waste CI/CD time on broken workflows
- 🔍 **Better debugging**: See detailed output locally
- ✅ **Confidence**: Know it works before pushing

## CI/CD Best Practice

**Always test locally before pushing to CI/CD!**

This script simulates the exact commands GitHub Actions will run, ensuring your deployment succeeds on the first try.
