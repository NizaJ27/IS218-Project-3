# Chapter 4: DigitalOcean Setup

**Creating Your First Cloud Server**

---

## Learning Objectives

By the end of this chapter, you'll be able to:
- ✅ Create a DigitalOcean account
- ✅ Get student credits ($200 free)
- ✅ Understand VPS pricing and options
- ✅ Create your first Ubuntu droplet
- ✅ Configure SSH keys for secure access
- ✅ Navigate the DigitalOcean dashboard

**Time Required:** 20-30 minutes

---

## Why DigitalOcean?

### Comparison of Cloud Providers

| Provider | Pros | Cons | Best For |
|----------|------|------|----------|
| **DigitalOcean** | Simple, cheap, student credits | Fewer services than AWS | Learning, small projects |
| **AWS** | Most features, industry standard | Complex, expensive | Enterprise |
| **Linode** | Similar to DO, good support | Less popular | Alternative to DO |
| **Vultr** | Fast, global locations | Smaller community | High performance |
| **Hetzner** | Very cheap, Europe-based | US support limited | Budget hosting |

**For this course: DigitalOcean**
- Clean interface
- Predictable pricing
- $200 student credit
- Great documentation
- Large community

**Everything works on other providers too!** Just follow their specific UI.

---

## Cost Breakdown

### Droplet Pricing (as of 2025)

| Plan | CPU | RAM | Storage | Transfer | Price/month |
|------|-----|-----|---------|----------|-------------|
| **Basic** | 1 vCPU | 1 GB | 25 GB SSD | 1 TB | $6 |
| **Regular** | 1 vCPU | 2 GB | 50 GB SSD | 2 TB | $12 |
| **Regular** | 2 vCPU | 2 GB | 60 GB SSD | 3 TB | $18 |
| **Regular** | 2 vCPU | 4 GB | 80 GB SSD | 4 TB | $24 |

**Recommendation for this course:**
- **Minimum:** $6/month (1GB RAM) - will work but tight
- **Recommended:** $12/month (2GB RAM) - comfortable
- **Ideal:** $18/month (2 vCPU, 2GB) - smooth experience

**With $200 student credit:**
- $6 plan = 33 months free!
- $12 plan = 16 months free!
- $18 plan = 11 months free!

### Additional Costs

**Bandwidth:** 
- Included in plan (1-4 TB/month)
- Overages: $0.01/GB
- You won't hit limits for learning

**Backups (optional):**
- 20% of droplet cost
- $6 plan = $1.20/month for backups
- Can enable later

**Snapshots (optional):**
- $0.05/GB/month
- Manual backups
- Only pay for what you use

**Total for course:** $6-18/month (or free with student credits!)

---

## Getting Started

### Step 1: Create Account

**1. Visit DigitalOcean:**
https://www.digitalocean.com

**2. Click "Sign Up"**

**3. Choose sign-up method:**
- Email + password (recommended)
- GitHub account
- Google account

**4. Verify email**
Check your inbox and click verification link.

---

### Step 2: Get Student Credits

**BEFORE adding payment method, get free credits!**

#### Option A: GitHub Student Developer Pack

**1. Go to GitHub Education:**
https://education.github.com/pack

**2. Click "Get student benefits"**

**3. Verify student status:**
- Use .edu email address, OR
- Upload enrollment proof

**4. Approval time:**
- .edu email: Usually instant
- Proof upload: 1-3 days

**5. Find DigitalOcean in pack:**
- Search for "DigitalOcean"
- Click "Get access to this offer"
- Follow link to claim $200 credit

**Benefits:**
- $200 DigitalOcean credit
- Free domain from Namecheap
- Free GitHub Pro
- 50+ other tools

#### Option B: Regular Sign-Up Bonus

**If not a student:**
- New users get $200 credit
- Valid for 60 days
- Must add payment method

**Referral links:**
- Sometimes offer extra credit
- Search "DigitalOcean promo code"

---

### Step 3: Add Payment Method

**Even with credits, you need a payment method on file.**

**1. Go to Billing**
Click your avatar → Billing

**2. Add payment method:**
- Credit/debit card (recommended)
- PayPal

**3. Verify with $1 charge**
- Charged $1 to verify card
- Immediately refunded
- One-time verification

**4. Credits appear**
Once verified, credits show in billing section.

---

## Creating Your First Droplet

### What is a Droplet?

**Droplet = DigitalOcean's name for VPS (Virtual Private Server)**

Think of it as:
- Your own computer in the cloud
- Full root access
- Always on (24/7)
- Public IP address
- Runs whatever you want

---

### Step 1: SSH Key Setup (IMPORTANT!)

**Before creating droplet, generate SSH key on your computer.**

**Why?** Secure authentication without passwords.

#### On Mac/Linux:

**1. Open Terminal**

**2. Generate key:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**3. When prompted:**
```
Enter file in which to save the key: [Press Enter for default]
Enter passphrase: [Enter a secure passphrase]
Enter same passphrase again: [Repeat passphrase]
```

**4. View public key:**
```bash
cat ~/.ssh/id_ed25519.pub
```

**5. Copy the entire output** (starts with `ssh-ed25519`)

#### On Windows:

**Option A: PowerShell (Windows 10/11)**

**1. Open PowerShell**

**2. Generate key:**
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**3. Follow prompts (same as Mac/Linux)**

**4. View public key:**
```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

**5. Copy the output**

**Option B: PuTTYgen (if no OpenSSH)**

**1. Download PuTTYgen**
https://www.putty.org/

**2. Open PuTTYgen**

**3. Click "Generate"**
Move mouse randomly to generate randomness

**4. Add passphrase**

**5. Save private key** (.ppk file)

**6. Copy public key** from text box

---

### Step 2: Add SSH Key to DigitalOcean

**1. In DigitalOcean Dashboard:**
Settings → Security → SSH Keys

**2. Click "Add SSH Key"**

**3. Paste your public key**
The one you copied from terminal

**4. Give it a name:**
- Example: "My Laptop 2025"
- Example: "MacBook Pro"

**5. Click "Add SSH Key"**

**Important:** Add key BEFORE creating droplet!

---

### Step 3: Create Droplet

**1. Click "Create" → "Droplets"**

**2. Choose an Image:**

**Region:**
- Choose nearest location
- Lower latency = faster
- Example: New York, San Francisco, London

**Image:**
- **Distributions** tab
- Select **Ubuntu 24.04 LTS**
- LTS = Long Term Support (5 years updates)

**Why Ubuntu?**
- Most popular
- Best documented
- Great package support
- Stable and secure

**3. Choose Size:**

**Droplet Type:**
- Select "Basic"
- Good for learning

**CPU Options:**
- Regular (recommended)
- Premium (faster, not needed)

**Size:**
```
$6/month  → 1 vCPU, 1GB RAM, 25GB SSD  (minimum)
$12/month → 1 vCPU, 2GB RAM, 50GB SSD  (recommended)
$18/month → 2 vCPU, 2GB RAM, 60GB SSD  (ideal)
```

**Pick the $12 option** if budget allows.

**4. Additional Options:**

**Backups:**
- ☐ Enable Backups (optional)
- Costs 20% extra
- Can enable later

**Monitoring:**
- ☑ Enable monitoring (FREE)
- Shows CPU, memory, disk graphs
- Highly recommended

**5. Authentication:**

**Select:** "SSH keys"
**Check the box** next to the key you added

**DO NOT select "Password"** - less secure!

**6. Choose a hostname:**

**Hostname:** Name for your server
- Example: `mywebclass-prod`
- Example: `portfolio-server`
- Example: `web-01`

**Use something meaningful** - you'll see it in dashboard.

**7. Tags (optional):**
- Add tags like `web`, `production`, `student-project`
- Helps organize multiple droplets

**8. Project:**
- Leave in default project, or
- Create new project: "MyWebClass Hosting"

**9. Review and Create:**

**Monthly cost:** $6-18/month
**Hourly cost:** $0.009-0.027/hour

**Click "Create Droplet"**

---

### Step 4: Wait for Creation

**Progress bar shows:**
1. Creating droplet...
2. Booting...
3. Ready!

**Takes 30-60 seconds.**

---

### Step 5: Get Your IP Address

**Once created, you'll see:**
```
mywebclass-prod
New York 3
Ubuntu 24.04 LTS
192.0.2.100
```

**Important info:**
- **Name:** mywebclass-prod
- **IP Address:** 192.0.2.100 (yours will be different)
- **Region:** New York 3
- **Status:** Active

**Copy the IP address!** You'll use it to connect.

---

## Understanding the Dashboard

### Droplet Details

**Click on your droplet name** to see details:

**Overview:**
- Current status
- IP address
- Monitoring graphs
- Resource usage

**Graphs Tab:**
- CPU usage
- Memory usage
- Disk I/O
- Bandwidth

**Networking Tab:**
- Public IPv4 address
- Private network (if enabled)
- Floating IPs (advanced)
- Firewalls (we'll configure in Chapter 8)

**Resize Tab:**
- Upgrade RAM/CPU
- Change plan
- Requires downtime

**Backups Tab:**
- Enable automatic backups
- Costs 20% of droplet price
- Weekly backups kept

**Snapshots Tab:**
- Manual backups
- Before major changes
- Can restore or create new droplet

**History Tab:**
- All actions (create, reboot, resize)
- Useful for troubleshooting

**Console Tab:**
- Emergency access
- If SSH is broken
- Slow and limited

---

### Power Controls

**Top right of droplet page:**

**Power On/Off:**
- Graceful shutdown
- Like pressing power button

**Reboot:**
- Restart server
- Preserves disk
- Takes 1-2 minutes

**Power Cycle:**
- Hard reset
- Like pulling power cord
- Last resort only

**Recovery:**
- Boot into recovery mode
- Fix broken system
- Advanced use

---

### Billing

**Avatar → Billing**

**Shows:**
- Current balance
- Credits remaining
- Usage this month
- Payment methods

**Month-to-date:**
- Running total
- Hourly breakdown
- Per-droplet costs

**Invoices:**
- Monthly bills
- Download PDFs
- Payment history

---

## Firewall (Dashboard Level)

**Different from UFW (server firewall)!**

**DigitalOcean Cloud Firewall:**
- Applied before traffic reaches droplet
- Free feature
- Can protect multiple droplets

**We'll configure UFW on server instead** (more educational).

**But good to know:**
- Networking → Firewalls
- Create firewall
- Assign to droplets

---

## Destroying a Droplet

**If you need to start over or stop billing:**

**1. Go to droplet settings**

**2. Scroll to "Destroy"**

**3. Click "Destroy droplet"**

**4. Type droplet name to confirm**

**5. Check "Scrub data" (recommended)**

**Important:**
- ❌ Snapshots are NOT deleted
- ❌ Floating IPs are NOT released
- ❌ Volume storage is NOT deleted
- ✅ Droplet and its disk are deleted
- ✅ Billing stops immediately

**Charged by the hour:**
- Used 3 days? Pay for 3 days
- Not full month

---

## Cost Management

### Avoid Surprise Bills

**1. Set up billing alerts:**
- Billing → Settings
- Email when balance drops

**2. Enable monitoring:**
- Watch resource usage
- Resize if needed

**3. Destroy test droplets:**
- Don't leave unused servers running
- Costs add up!

**4. Use snapshots, not backups for learning:**
- Backups = recurring cost
- Snapshots = pay per use
- For learning: snapshots are enough

### Maximizing Student Credits

**$200 credit goes a long way!**

**Single $6 droplet:**
- 33 months of hosting
- Entire degree program!

**Single $12 droplet:**
- 16 months of hosting
- Year+ of projects

**Tips:**
- Don't create unnecessary droplets
- Destroy when not needed
- Use snapshots before destruction
- One droplet can host many projects

---

## Troubleshooting

### Can't SSH to Droplet

**Problem:** Connection refused or timeout

**Solutions:**

**1. Check IP address:**
```bash
ping YOUR_IP_ADDRESS
```

**2. Wait 2-3 minutes after creation**
- Server might still be booting
- Check dashboard status

**3. Verify SSH key:**
- Did you add key before creating droplet?
- If not, you'll need to use console or destroy and recreate

**4. Check local firewall:**
- Windows Firewall might block SSH
- Try from different network

---

### Forgot to Add SSH Key

**Problem:** Created droplet without SSH key

**Solution:**

**Option A: Use Console**
1. Droplet page → Console
2. Log in as root (password emailed to you)
3. Add your SSH key manually (advanced)

**Option B: Destroy and Recreate**
1. Take snapshot (if you did any work)
2. Destroy droplet
3. Add SSH key
4. Create new droplet

**Better:** Always add SSH key first!

---

### Running Out of Credits

**Problem:** Used $200, need more time

**Options:**

**1. Add payment method:**
- Keeps going after credits
- Charged normally

**2. Get more credits:**
- Referral program
- Hackathon sponsorships
- Educational grants

**3. Switch providers:**
- Linode, Vultr, etc.
- Also have free tiers

---

## Alternative Providers

**This course works on any Ubuntu VPS:**

### Linode (Akamai)
**Pros:** Similar to DigitalOcean, good docs
**Pricing:** $5-12/month for small droplets
**Credits:** $100 for students
**Sign up:** linode.com

### Vultr
**Pros:** Fast network, global locations
**Pricing:** $6-12/month
**Credits:** Sometimes $250 promo
**Sign up:** vultr.com

### AWS Lightsail
**Pros:** Part of AWS ecosystem
**Cons:** More complex
**Pricing:** $5-10/month
**Credits:** $200 via AWS Educate

### Hetzner
**Pros:** Very cheap (€4-8/month)
**Cons:** Europe-focused, requires ID
**Sign up:** hetzner.com

**All work the same way:**
1. Create Ubuntu 24.04 server
2. Add SSH key
3. Follow rest of course

---

## Verification Checklist

**Before moving to Chapter 5, make sure:**

- ✅ DigitalOcean account created
- ✅ Student credits applied (if applicable)
- ✅ SSH key generated on your computer
- ✅ SSH key added to DigitalOcean
- ✅ Droplet created (Ubuntu 24.04 LTS)
- ✅ IP address copied somewhere safe
- ✅ Monitoring enabled
- ✅ Understand dashboard navigation

**You should have:**
- Server IP address: `___.___.___.___ `
- SSH private key: `~/.ssh/id_ed25519`
- Server running and billable

---

## Next Steps

**You now have:**
- ✅ Cloud server running 24/7
- ✅ Public IP address
- ✅ Ubuntu Linux installed
- ✅ SSH key for secure access

**In Chapter 5:**
- Connect to your server for the first time
- Understand root user
- Run your first commands on the server
- Verify everything works

**Get ready to connect to your server!**

---

## Quick Reference

### Important Links
- **Dashboard:** https://cloud.digitalocean.com
- **Student Pack:** https://education.github.com/pack
- **Documentation:** https://docs.digitalocean.com
- **Community:** https://www.digitalocean.com/community

### Your Server Info (fill in)
```
Server Name: _______________
IP Address:  _______________
Region:      _______________
Plan:        $_____/month
Created:     _______________
```

### SSH Key Location
```
Private key: ~/.ssh/id_ed25519
Public key:  ~/.ssh/id_ed25519.pub
```

---

[← Previous: Chapter 3 - Linux Permissions](03-linux-permissions.md) | [Next: Chapter 5 - First Connection →](05-first-connection.md)
