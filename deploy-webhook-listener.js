#!/usr/bin/env node

/**
 * GitHub Webhook Deployment Listener
 * 
 * This script runs on your server and listens for deployment webhooks
 * from GitHub Actions. When triggered, it pulls latest code and deploys.
 * 
 * Setup:
 * 1. Copy this file to your server: ~/mywebclass_hosting/deploy-webhook-listener.js
 * 2. Install dependencies: npm install express
 * 3. Set WEBHOOK_SECRET environment variable
 * 4. Run with: node deploy-webhook-listener.js
 * 5. Or create systemd service (see instructions below)
 */

const express = require('express');
const { exec } = require('child_process');
const crypto = require('crypto');

const app = express();
const PORT = 3001; // Different port from your main app
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-secret-here';

app.use(express.json());

// Verify webhook signature
function verifySignature(req) {
  const signature = req.headers['x-hub-signature-256'];
  if (!signature) return false;
  
  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');
  
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

// Deployment webhook endpoint
app.post('/deploy-webhook', (req, res) => {
  console.log('📥 Received deployment webhook');
  
  // Verify signature (optional but recommended)
  if (!verifySignature(req)) {
    console.log('❌ Invalid signature');
    return res.status(401).json({ error: 'Invalid signature' });
  }
  
  console.log('✅ Signature verified');
  console.log('Repository:', req.body.repository);
  console.log('Branch:', req.body.ref);
  console.log('Commit:', req.body.sha);
  console.log('Pusher:', req.body.pusher);
  
  // Respond immediately (don't make GitHub Actions wait)
  res.status(200).json({ 
    status: 'accepted',
    message: 'Deployment started' 
  });
  
  // Deploy in background
  console.log('🚀 Starting deployment...');
  
  const deployScript = `
    cd ~/mywebclass_hosting && \
    git pull origin master && \
    cd ~/mywebclass_hosting/projects/backend && \
    docker compose up -d --build && \
    echo "✅ Deployment completed!"
  `;
  
  exec(deployScript, (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Deployment failed:', error);
      console.error(stderr);
      return;
    }
    
    console.log('✅ Deployment output:');
    console.log(stdout);
    console.log('✅ Deployment completed successfully!');
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'webhook-listener' });
});

app.listen(PORT, () => {
  console.log(`🎧 Webhook listener running on port ${PORT}`);
  console.log(`📡 Webhook endpoint: http://localhost:${PORT}/deploy-webhook`);
  console.log(`🔒 Webhook secret configured: ${WEBHOOK_SECRET ? 'Yes' : 'No (WARNING: Set WEBHOOK_SECRET!)'}`);
});

/**
 * SYSTEMD SERVICE SETUP
 * 
 * Create file: /etc/systemd/system/deploy-webhook.service
 * 
 * [Unit]
 * Description=GitHub Deployment Webhook Listener
 * After=network.target
 * 
 * [Service]
 * Type=simple
 * User=deploy
 * WorkingDirectory=/home/deploy/mywebclass_hosting
 * Environment="WEBHOOK_SECRET=your-secret-here"
 * ExecStart=/usr/bin/node /home/deploy/mywebclass_hosting/deploy-webhook-listener.js
 * Restart=always
 * RestartSec=10
 * StandardOutput=journal
 * StandardError=journal
 * 
 * [Install]
 * WantedBy=multi-user.target
 * 
 * Then run:
 * sudo systemctl daemon-reload
 * sudo systemctl enable deploy-webhook
 * sudo systemctl start deploy-webhook
 * sudo systemctl status deploy-webhook
 */
