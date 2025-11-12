# Chapter 3: Linux File Permissions & Structure

**Understanding the Linux Filesystem and Security Model**

---

## Learning Objectives

By the end of this chapter, you'll understand:
- ✅ Linux directory structure (/etc, /var, /home, etc.)
- ✅ File permissions in depth (rwx, numeric notation)
- ✅ User and group ownership
- ✅ Why permissions matter for security
- ✅ Common permission patterns for web servers

**Time Required:** 30-40 minutes

---

## Why Permissions Matter

### The Security Model

**Linux is multi-user by design.** Multiple people (and processes) share the same server safely because of permissions.

**Real-world analogy:**
Think of your server like an apartment building:
- **Owner** = Your apartment (full access)
- **Group** = Family members (shared access)
- **Others** = Building residents (restricted access)

**Without permissions:**
- Any user could delete system files
- Processes could read password files
- Web apps could access each other's data
- Complete chaos!

**With permissions:**
- Each user has their own space
- System files are protected
- Services run with minimal privileges
- Security by design

---

## Linux Directory Structure

### The Root Filesystem

**Everything starts at `/` (root)**

```
/
├── bin/     → Essential commands (ls, cat, etc.)
├── boot/    → Boot loader files
├── dev/     → Device files
├── etc/     → System configuration
├── home/    → User home directories
├── opt/     → Optional software
├── root/    → Root user's home
├── tmp/     → Temporary files
├── usr/     → User programs
└── var/     → Variable data (logs, databases)
```

### Important Directories

#### `/home` - User Files

**What it contains:** Personal directories for each user.

```
/home/
├── alice/
│   ├── Documents/
│   ├── projects/
│   └── .bashrc
├── bob/
│   └── scripts/
└── charlie/
    └── website/
```

**You'll work here most of the time.**

**Permissions:** Each user owns their own `/home/username` directory.

---

#### `/etc` - Configuration Files

**What it contains:** System-wide configuration.

**Important files:**
```
/etc/
├── ssh/sshd_config     → SSH server config
├── ufw/                → Firewall rules
├── hosts               → DNS/hostname mapping
├── passwd              → User account info
├── group               → Group definitions
└── nginx/              → Nginx config (if installed)
```

**Permissions:** Usually readable by all, writable by root only.

**Why:** Central location for all configuration, needs sudo to modify.

---

#### `/var` - Variable Data

**What it contains:** Files that change frequently.

```
/var/
├── log/                → Log files
│   ├── syslog          → System logs
│   ├── auth.log        → Authentication logs
│   └── nginx/          → Web server logs
├── lib/                → Application data
│   └── docker/         → Docker data
└── www/                → Web content (some systems)
```

**You'll check `/var/log` constantly** for debugging.

---

#### `/tmp` - Temporary Files

**What it contains:** Temporary files, cleared on reboot.

**Permissions:** Everyone can write here (with restrictions).

**Use for:** 
- Script scratch space
- Downloaded files before moving
- Build artifacts

**Don't use for:** Anything important (gets deleted!).

---

#### `/usr` - User Programs

**What it contains:** Installed software and libraries.

```
/usr/
├── bin/        → User commands
├── local/      → Locally installed software
└── share/      → Shared data files
```

**When you `apt install`, files go here.**

---

#### `/opt` - Optional Software

**What it contains:** Self-contained applications.

**Example:** Custom software you install manually.

---

### Absolute vs Relative Paths

#### Absolute Path

**Starts with `/`** = Full path from root.

```bash
cd /home/user/projects
cat /etc/ssh/sshd_config
ls /var/log/nginx
```

**Always works, regardless of current directory.**

#### Relative Path

**No leading `/`** = Path from current location.

```bash
# If you're in /home/user
cd projects              # Goes to /home/user/projects
cat ../other_user/.bashrc # Goes up one level, then into other_user
ls ./documents           # ./ means current directory
```

**Special symbols:**
- `.` = current directory
- `..` = parent directory
- `~` = your home directory
- `-` = previous directory

---

## Understanding Permissions

### Permission Types

**Three types of permissions:**
1. **Read (r)** - View contents
2. **Write (w)** - Modify/delete
3. **Execute (x)** - Run as program

**Three classes of users:**
1. **User (u)** - File owner
2. **Group (g)** - File's group
3. **Others (o)** - Everyone else

### Reading Permission Notation

**Example:**
```bash
$ ls -l myfile.txt
-rw-r--r-- 1 user group 1234 Nov 12 10:00 myfile.txt
```

**Breaking it down:**
```
-rw-r--r--
│││ │││ │││
│││ │││ │└└ Others: r-- (read only)
│││ │└└──── Group:  r-- (read only)
│└└──────── User:   rw- (read + write)
└────────── File type: - (regular file)
```

**File type indicators:**
- `-` = regular file
- `d` = directory
- `l` = symbolic link
- `b` = block device
- `c` = character device

### Numeric Notation

**Each permission has a number:**
- `r` = 4
- `w` = 2
- `x` = 1
- `-` = 0

**Add them up for each class:**
```
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

**Three-digit notation:**
```
755 = rwxr-xr-x
    │ │   │   │
    │ │   │   └── Others: r-x (5)
    │ │   └────── Group:  r-x (5)
    │ └────────── User:   rwx (7)
    └──────────── Combined: 755
```

### Common Permission Patterns

**Files:**
```bash
644 (rw-r--r--)  # Most files (owner can edit, others read)
600 (rw-------)  # Private files (owner only)
444 (r--r--r--)  # Read-only files
```

**Directories:**
```bash
755 (rwxr-xr-x)  # Most directories (owner full, others browse)
700 (rwx------)  # Private directories (owner only)
775 (rwxrwxr-x)  # Shared directories (owner+group full access)
```

**Scripts:**
```bash
755 (rwxr-xr-x)  # Executable scripts (everyone can run)
700 (rwx------)  # Private scripts (owner only)
```

---

## Working with Permissions

### Viewing Permissions

```bash
ls -l file.txt              # Single file
ls -la                      # All files including hidden
ls -ld directory/           # Directory itself (not contents)
stat file.txt               # Detailed file info
```

**Output example:**
```bash
$ ls -l
-rw-r--r-- 1 alice developers  1234 Nov 12 10:00 config.txt
drwxr-xr-x 2 alice developers  4096 Nov 12 10:05 scripts/
-rwxr-xr-x 1 alice developers   512 Nov 12 09:30 deploy.sh
```

### Changing Permissions with chmod

#### Symbolic Method

**Add permissions:**
```bash
chmod u+x script.sh         # User: add execute
chmod g+w file.txt          # Group: add write
chmod o+r data.txt          # Others: add read
chmod a+x app.sh            # All: add execute
```

**Remove permissions:**
```bash
chmod u-x script.sh         # User: remove execute
chmod g-w file.txt          # Group: remove write
chmod o-r data.txt          # Others: remove read
```

**Set exact permissions:**
```bash
chmod u=rwx,g=rx,o=r file  # User: rwx, Group: rx, Others: r
chmod u=rw,go=r file       # User: rw, Group+Others: r
```

**Combine operations:**
```bash
chmod u+x,g+x,o-r script.sh  # Multiple changes at once
```

#### Numeric Method

**Common patterns:**
```bash
chmod 644 file.txt          # rw-r--r--
chmod 755 script.sh         # rwxr-xr-x
chmod 600 private.key       # rw-------
chmod 700 secret_dir/       # rwx------
chmod 666 public.txt        # rw-rw-rw- (usually avoid!)
chmod 777 shared/           # rwxrwxrwx (DANGEROUS!)
```

**Recursive (directories and contents):**
```bash
chmod -R 755 website/       # Set permissions recursively
```

### Changing Ownership with chown

**Change owner:**
```bash
sudo chown alice file.txt           # Change owner to alice
sudo chown alice:developers file    # Change owner and group
sudo chown :developers file         # Change group only
```

**Recursive:**
```bash
sudo chown -R alice:www-data /var/www/mysite
```

**Why sudo?** Only root can change file ownership.

### Changing Group with chgrp

```bash
sudo chgrp developers file.txt      # Change group
sudo chgrp -R www-data website/     # Recursive
```

---

## Special Permissions

### Setuid (4xxx)

**What it does:** Execute file as owner, not current user.

```bash
chmod 4755 program          # rwsr-xr-x
```

**Example:** `/usr/bin/passwd` (needs root to change passwords)

**Security risk:** Be very careful with setuid!

### Setgid (2xxx)

**On files:** Execute as group owner.

**On directories:** New files inherit directory's group.

```bash
chmod 2755 shared_dir/      # rwxr-sr-x
```

**Useful for:** Shared project directories.

### Sticky Bit (1xxx)

**What it does:** Only owner can delete files (even if others can write).

```bash
chmod 1777 /tmp             # rwxrwxrwt
```

**Used on `/tmp`** - everyone can write, but can't delete others' files.

---

## Users and Groups

### Understanding Users

**System users vs Regular users:**

**System users (UID < 1000):**
- Used by services (www-data, mysql, docker)
- No login shell
- Run processes safely

**Regular users (UID >= 1000):**
- Real people
- Can log in
- Have home directories

### Viewing User Info

```bash
whoami                      # Current user
id                          # User ID and groups
id username                 # Info about specific user
cat /etc/passwd             # All users (not actual passwords!)
```

**Example output:**
```bash
$ id
uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo),999(docker)
```

**Breaking it down:**
- **UID 1000** = User ID
- **GID 1000** = Primary group ID
- **Groups** = Also in sudo and docker groups

### Understanding Groups

**Groups let multiple users share access** to files/directories.

**Common groups:**
- `sudo` = Can use sudo command
- `www-data` = Web server group
- `docker` = Can use Docker
- `adm` = Can read log files

**View groups:**
```bash
groups                      # Your groups
groups alice                # Alice's groups
cat /etc/group              # All groups
```

### Adding User to Group

```bash
sudo usermod -aG groupname username
```

**Example:**
```bash
sudo usermod -aG docker alice    # Add alice to docker group
```

**Important:** User must log out and back in for group changes to take effect!

---

## Real-World Examples

### Web Server Permissions

**Scenario:** Deploy a website with Nginx.

**Requirements:**
- Nginx runs as `www-data` user
- Your user needs to upload files
- Nginx needs to read files
- Public can access via web

**Solution:**
```bash
# Create website directory
sudo mkdir -p /var/www/mysite

# Set ownership: you own it, www-data group
sudo chown -R yourusername:www-data /var/www/mysite

# Set permissions: owner full, group read/execute, others none
sudo chmod -R 750 /var/www/mysite

# For files specifically (no execute needed)
find /var/www/mysite -type f -exec chmod 640 {} \;

# For directories (execute needed to enter)
find /var/www/mysite -type d -exec chmod 750 {} \;
```

**Result:**
- ✅ You can upload/edit files
- ✅ Nginx (www-data) can read and serve files
- ✅ Other users can't access
- ✅ Secure and functional

### SSH Key Permissions

**SSH is very strict about key permissions!**

**Private key must be readable only by owner:**
```bash
chmod 600 ~/.ssh/id_rsa
```

**Public key can be more open:**
```bash
chmod 644 ~/.ssh/id_rsa.pub
```

**`.ssh` directory:**
```bash
chmod 700 ~/.ssh
```

**`authorized_keys` file:**
```bash
chmod 600 ~/.ssh/authorized_keys
```

**If permissions are wrong, SSH will refuse to work!**

### Docker Socket Permissions

**Docker socket is sensitive:**
```bash
ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Nov 12 10:00 /var/run/docker.sock
```

**Only root and docker group can access.**

**To use Docker without sudo:**
```bash
sudo usermod -aG docker $USER
```

Then log out and back in.

---

## Security Best Practices

### Principle of Least Privilege

**Give minimum permissions needed, nothing more.**

**Examples:**

**❌ Bad:**
```bash
chmod 777 website/          # Everyone can do anything!
```

**✅ Good:**
```bash
chmod 755 website/          # Owner full, others read/execute
```

**❌ Bad:**
```bash
chmod 666 config.php        # Everyone can edit!
```

**✅ Good:**
```bash
chmod 600 config.php        # Only owner can read/write
```

### Never Use 777

**`chmod 777` = everyone can read, write, execute**

**Why it's dangerous:**
- Any user can modify files
- Any process can change code
- Security nightmare
- Shows you don't understand permissions

**When students say "it's not working, I'll just chmod 777":**
**NO! Find the right user/group instead.**

### Protect Sensitive Files

**Configuration with passwords/keys:**
```bash
chmod 600 .env              # Only owner
chmod 600 config.yml        # Only owner
chmod 600 secrets.json      # Only owner
```

**Never commit to git!** (use .gitignore)

### Check Permissions After Install

**Many installers set wrong permissions.**

**Always verify:**
```bash
ls -la /path/to/installed/app
```

**Fix if needed before deploying.**

---

## Troubleshooting Permissions

### "Permission denied" When Running Script

**Problem:**
```bash
$ ./myscript.sh
bash: ./myscript.sh: Permission denied
```

**Solution:** Add execute permission
```bash
chmod +x myscript.sh
./myscript.sh
```

---

### "Permission denied" When Editing File

**Problem:** Can't save file in nano/vim

**Check permissions:**
```bash
ls -l file.txt
```

**If you should own it:**
```bash
sudo chown $USER file.txt
```

**If it's a system file:**
```bash
sudo nano /etc/config.txt   # Edit with sudo
```

---

### SSH Refuses to Use Key

**Problem:**
```
WARNING: UNPROTECTED PRIVATE KEY FILE!
```

**Solution:** Fix key permissions
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
```

---

### Web Server Can't Read Files

**Problem:** Nginx shows 403 Forbidden

**Check ownership:**
```bash
ls -la /var/www/mysite
```

**Fix:**
```bash
sudo chown -R www-data:www-data /var/www/mysite
sudo chmod -R 755 /var/www/mysite
```

---

### Docker: "Permission denied" on Socket

**Problem:**
```
Cannot connect to Docker daemon at unix:///var/run/docker.sock
```

**Solution:** Add user to docker group
```bash
sudo usermod -aG docker $USER
```

**Then log out and back in!**

---

## Practice Exercises

### Exercise 1: Understanding Permissions

```bash
# 1. Create a test directory
mkdir ~/permission_test
cd ~/permission_test

# 2. Create files with different permissions
touch public.txt
touch private.txt
touch script.sh

# 3. Set permissions
chmod 644 public.txt        # rw-r--r--
chmod 600 private.txt       # rw-------
chmod 755 script.sh         # rwxr-xr-x

# 4. Verify
ls -l

# 5. Try to read each file
cat public.txt
cat private.txt
cat script.sh

# 6. Add some content
echo "Public content" > public.txt
echo "Private content" > private.txt
echo "#!/bin/bash\necho 'Hello'" > script.sh

# 7. Try to execute script
./script.sh
```

---

### Exercise 2: Working with Groups

```bash
# 1. Check your groups
groups

# 2. Check your ID
id

# 3. Create a directory for group work
mkdir ~/shared_project

# 4. Check current permissions
ls -ld ~/shared_project

# 5. See who owns it
stat ~/shared_project
```

---

### Exercise 3: Finding Files with Permissions

```bash
# Find all files you own that are world-writable (dangerous!)
find ~ -type f -perm -002 2>/dev/null

# Find all your executable scripts
find ~ -type f -perm -u+x 2>/dev/null

# Find files with permission 777 (very dangerous!)
find /var/www -type f -perm 777 2>/dev/null
```

---

## Key Takeaways

**Remember:**

1. **Three permission types:** Read, Write, Execute
2. **Three user classes:** User, Group, Others
3. **Two notations:** Symbolic (rwx) and Numeric (755)
4. **Common patterns:**
   - Files: 644 or 600
   - Directories: 755 or 700
   - Scripts: 755 or 700
5. **Never use 777** - find the right owner/group instead
6. **SSH keys must be 600** - SSH enforces this
7. **Web files:** Usually owned by www-data group
8. **Docker:** Add user to docker group

---

## Next Steps

**You now understand:**
- ✅ Linux directory structure
- ✅ How permissions work
- ✅ Users and groups
- ✅ Common security patterns
- ✅ How to fix permission issues

**In Chapter 4:**
- Set up DigitalOcean account
- Create your first VPS droplet
- Understand VPS dashboard
- Prepare for server connection

**Take a break if needed!** Permissions are complex. Come back and review this chapter when working on the server.

---

[← Previous: Chapter 2 - Linux Commands](02-linux-commands.md) | [Next: Chapter 4 - DigitalOcean Setup →](04-digitalocean-setup.md)
