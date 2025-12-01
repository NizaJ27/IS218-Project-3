# Auto-Deploy Setup (No UFW Changes Required)

This solution uses a **cron job on your server** that automatically checks for GitHub updates and deploys them. No firewall changes needed!

## How It Works

```
1. You push code to GitHub
   ↓
2. GitHub Actions workflow runs (just tests/notifications)
   ↓
3. Your server checks GitHub every 5 minutes via cron
   ↓
4. If new commits detected, server pulls and deploys automatically
   ↓
5. GitHub Actions verifies deployment via health check
```

## Setup Instructions

### Step 1: Copy Files to Server

```bash
# From your local machine
scp -P 2222 auto-deploy.sh deploy@104.131.191.83:~/mywebclass_hosting/
```

### Step 2: Make Script Executable

```bash
# SSH to server
ssh -p 2222 deploy@104.131.191.83

# Make executable
chmod +x ~/mywebclass_hosting/auto-deploy.sh

# Test it manually first
cd ~/mywebclass_hosting
./auto-deploy.sh
```

### Step 3: Set Up Cron Job

```bash
# Edit crontab
crontab -e

# Add this line (checks every 5 minutes):
*/5 * * * * /home/deploy/mywebclass_hosting/auto-deploy.sh >> /home/deploy/deploy.log 2>&1

# Save and exit (:wq in vim, Ctrl+O then Ctrl+X in nano)
```

### Step 4: Verify Cron Job

```bash
# Check crontab
crontab -l

# Watch the log file
tail -f ~/deploy.log
```

### Step 5: Test Deployment

```bash
# On your local machine, make a change and push
echo "# Test auto-deploy" >> infrastructure/README.md
git add infrastructure/README.md
git commit -m "Test auto-deploy"
git push origin master

# Watch GitHub Actions: https://github.com/NizaJ27/IS218-Project-3/actions

# On server, watch logs
ssh -p 2222 deploy@104.131.191.83
tail -f ~/deploy.log
```

## Benefits

✅ **No firewall changes** - Server pulls updates, doesn't accept connections
✅ **No SSH from GitHub** - No authentication issues
✅ **Simple and reliable** - Uses standard Git operations
✅ **Automatic** - Deployments happen without manual intervention
✅ **Logged** - All deployments logged to ~/deploy.log
✅ **Safe** - Only pulls from your trusted repository

## Drawbacks

⚠️ **5-minute delay** - Deployments happen within 5 minutes, not instantly
⚠️ **Resource usage** - Git fetch runs every 5 minutes (minimal impact)

## Customization

### Check More Frequently (Every 2 minutes)

```bash
*/2 * * * * /home/deploy/mywebclass_hosting/auto-deploy.sh >> /home/deploy/deploy.log 2>&1
```

### Check Less Frequently (Every 15 minutes)

```bash
*/15 * * * * /home/deploy/mywebclass_hosting/auto-deploy.sh >> /home/deploy/deploy.log 2>&1
```

### Only Check During Business Hours

```bash
*/5 9-17 * * 1-5 /home/deploy/mywebclass_hosting/auto-deploy.sh >> /home/deploy/deploy.log 2>&1
```

## Monitoring

### View Recent Deployments

```bash
ssh -p 2222 deploy@104.131.191.83
tail -50 ~/deploy.log
```

### Watch Live Deployments

```bash
ssh -p 2222 deploy@104.131.191.83
tail -f ~/deploy.log
```

### Check Last Deployment Time

```bash
ssh -p 2222 deploy@104.131.191.83
grep "Deployment completed" ~/deploy.log | tail -1
```

## Troubleshooting

### Cron job not running?

```bash
# Check if cron service is running
systemctl status cron

# Check cron logs
grep CRON /var/log/syslog | tail -20
```

### Script has errors?

```bash
# Run manually to see errors
cd ~/mywebclass_hosting
./auto-deploy.sh
```

### Deployment not happening?

```bash
# Check if script is in crontab
crontab -l

# Check deploy log
tail -50 ~/deploy.log

# Verify git can pull
cd ~/mywebclass_hosting
git fetch origin master
git status
```

## Alternative: Manual Trigger

If you prefer to trigger deployments manually (without waiting for cron):

```bash
# SSH to server and run
ssh -p 2222 deploy@104.131.191.83
cd ~/mywebclass_hosting
./auto-deploy.sh
```

Or create a GitHub Actions workflow with `workflow_dispatch` that you trigger manually.

## Why This Works

- **Server-initiated**: Your server pulls updates from GitHub (allowed by firewall)
- **GitHub-hosted runners**: No need for GitHub to connect to your server
- **Standard Git operations**: Uses normal git pull over HTTPS
- **No special ports**: Everything uses standard HTTPS (port 443)
- **UFW friendly**: All connections are outbound from your server

This is actually how many production systems work (pull-based deployment) because it's more secure than allowing external systems to SSH into your server.
