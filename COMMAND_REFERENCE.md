# 🚀 EC2 Deployment - Command Reference

Quick reference for all commands you'll need.

---

## Local Machine Setup (Windows PowerShell)

### Create SSH Directory & Setup
```powershell
# Create SSH directory
mkdir -p C:\Users\$env:USERNAME\.ssh

# Set proper permissions on key file
icacls "C:\Users\$env:USERNAME\.ssh\your-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"

# Verify SSH is installed
ssh -V
scp -V
```

### Test Connection to EC2
```powershell
# Set variables
$KEY_PATH = "C:\Users\$env:USERNAME\.ssh\your-key.pem"
$EC2_IP = "your-ec2-public-ip"

# Test SSH connection (type 'exit' to disconnect)
ssh -i $KEY_PATH ec2-user@$EC2_IP

# Test SSH with verbose output (for troubleshooting)
ssh -v -i $KEY_PATH ec2-user@$EC2_IP
```

### Manual Deployment (Without Script)
```powershell
# Build locally
npm run build

# Upload files
scp -i "C:\path\to\key.pem" -r ".\dist\*" ec2-user@your-ec2-ip:/var/www/autograder-frontend/

# Reload Nginx
ssh -i "C:\path\to\key.pem" ec2-user@your-ec2-ip "sudo systemctl reload nginx"
```

---

## EC2 Instance Setup (Run on EC2 via SSH)

### Option 1: Automatic Setup (Recommended)
```bash
# Download and run setup script
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/setup-ec2.sh | bash
```

### Option 2: Manual Step-by-Step (Amazon Linux 2)
```bash
# Update system
sudo yum update -y

# Install Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Install Nginx
sudo yum install -y nginx

# Create deployment directory
sudo mkdir -p /var/www/autograder-frontend
sudo chown -R ec2-user:ec2-user /var/www/autograder-frontend
sudo chmod -R 755 /var/www/autograder-frontend

# Verify installations
node --version
npm --version
nginx -v
```

### Option 3: Manual Step-by-Step (Ubuntu 22.04)
```bash
# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs

# Install Nginx
sudo apt-get install -y nginx

# Create deployment directory
sudo mkdir -p /var/www/autograder-frontend
sudo chown -R $USER:$USER /var/www/autograder-frontend
sudo chmod -R 755 /var/www/autograder-frontend

# Verify installations
node --version
npm --version
nginx -v
```

---

## Nginx Configuration (On EC2)

### Copy Configuration File
```bash
# Option 1: Create file manually
sudo nano /etc/nginx/conf.d/autograder-frontend.conf
# Then paste the contents of nginx.conf

# Option 2: Use curl to download
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/nginx.conf | sudo tee /etc/nginx/conf.d/autograder-frontend.conf
```

### Validate & Reload Nginx
```bash
# Test configuration syntax
sudo nginx -t

# If test passes, reload Nginx
sudo systemctl reload nginx

# Or restart Nginx
sudo systemctl restart nginx

# Check if Nginx is running
sudo systemctl status nginx

# Enable Nginx to start on reboot
sudo systemctl enable nginx
```

---

## Verification & Troubleshooting (On EC2)

### Check Files Are Uploaded
```bash
# List deployed files
ls -la /var/www/autograder-frontend/

# Check if index.html exists
cat /var/www/autograder-frontend/index.html | head -20

# Check file ownership
ls -la /var/www/autograder-frontend/ | head -5
```

### Check Nginx Status
```bash
# Check if Nginx is running
sudo systemctl status nginx

# Check Nginx logs for errors
sudo tail -50 /var/log/nginx/error.log

# Check access logs
sudo tail -50 /var/log/nginx/access.log

# Check Nginx processes
ps aux | grep nginx

# Check if port 80 is listening
sudo ss -tlnp | grep 80
sudo netstat -tlnp | grep 80
```

### Test Nginx Locally on EC2
```bash
# Test if Nginx is serving content
curl http://localhost

# Test with headers
curl -v http://localhost

# Test specific routes
curl http://localhost/login
curl http://localhost/student/dashboard
```

### Check System Resources
```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check CPU usage
top -b -n 1 | head -20

# Check network connectivity
ping 8.8.8.8
```

---

## File Management on EC2

### Upload New Files via SCP
```bash
# From your local machine (Windows PowerShell)
scp -i "C:\path\to\key.pem" -r ".\dist\*" ec2-user@your-ec2-ip:/var/www/autograder-frontend/
```

### Update Nginx Configuration
```bash
# From your local machine
scp -i "C:\path\to\key.pem" nginx.conf ec2-user@your-ec2-ip:~/nginx.conf

# Then on EC2
sudo mv ~/nginx.conf /etc/nginx/conf.d/autograder-frontend.conf
sudo systemctl reload nginx
```

### Backup Current Files on EC2
```bash
# Create backup directory
mkdir -p ~/backups

# Backup current deployment
cp -r /var/www/autograder-frontend ~/backups/autograder-$(date +%Y%m%d-%H%M%S)

# List backups
ls -la ~/backups/
```

---

## Logs & Debugging

### View Recent Nginx Activity
```bash
# Last 20 lines of access log
sudo tail -20 /var/log/nginx/access.log

# Last 50 lines with timestamps
sudo tail -50 /var/log/nginx/access.log | cat

# Follow logs in real-time
sudo tail -f /var/log/nginx/access.log

# Watch error log
sudo tail -f /var/log/nginx/error.log
```

### Search Logs for Errors
```bash
# Find 404 errors
sudo grep "404" /var/log/nginx/access.log

# Find 500+ errors
sudo grep " 5[0-9][0-9] " /var/log/nginx/access.log

# Count errors by type
sudo awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

---

## Security & Permissions

### Fix Permission Issues
```bash
# Ensure correct ownership
sudo chown -R ec2-user:ec2-user /var/www/autograder-frontend

# Ensure readable permissions
sudo chmod -R 755 /var/www/autograder-frontend

# Check current permissions
ls -la /var/www/autograder-frontend/
```

### Check Security Group Rules
```bash
# On EC2, check open ports
sudo ss -tlnp

# Check if specific port is listening
sudo ss -tlnp | grep 80

# Display all open connections
ss -tulpn
```

---

## Database & API Connectivity (If Applicable)

### Test Connectivity to Backend
```bash
# Test DNS resolution
nslookup your-api-domain.com

# Test TCP connection to API
nc -zv your-api-domain.com 443

# Using curl to test API
curl https://your-api-domain.com/health

# Check environment variables
env | grep -i api
cat /var/www/autograder-frontend/.env
```

---

## System Maintenance

### Update System Packages
```bash
# Amazon Linux 2
sudo yum update -y
sudo yum upgrade -y

# Ubuntu
sudo apt-get update -y
sudo apt-get upgrade -y
```

### Install Additional Tools (If Needed)
```bash
# Amazon Linux 2
sudo yum install -y curl wget git htop

# Ubuntu
sudo apt-get install -y curl wget git htop
```

### Reboot EC2 (If Needed)
```bash
# Schedule reboot in 1 minute
sudo shutdown -r 1

# Cancel scheduled reboot
sudo shutdown -c

# Reboot immediately
sudo reboot
```

---

## Useful One-Liners

```bash
# Check everything at once
echo "=== Node ===" && node -v && echo "=== NPM ===" && npm -v && echo "=== Nginx ===" && nginx -v && echo "=== Port 80 ===" && sudo ss -tlnp | grep 80

# Restart everything
sudo systemctl restart nginx && echo "Nginx restarted"

# Deploy and check in one command
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/setup-ec2.sh | bash && sudo systemctl reload nginx

# Monitor everything
watch -n 1 'echo "=== CPU ===" && top -b -n 1 | head -5 && echo "=== Memory ===" && free -h && echo "=== Disk ===" && df -h | grep -E "Filesystem|vda|sda"'
```

---

## Emergency Commands

### Stop All Services
```bash
# Stop Nginx
sudo systemctl stop nginx

# Stop Node processes
pkill -f node

# Kill all by port
sudo lsof -ti:80 | xargs kill -9
```

### Emergency Recovery
```bash
# Restore from backup
cp -r ~/backups/autograder-latest/* /var/www/autograder-frontend/

# Reset permissions
sudo chown -R ec2-user:ec2-user /var/www/autograder-frontend
sudo chmod -R 755 /var/www/autograder-frontend

# Restart Nginx
sudo systemctl restart nginx
```

### Check Logs for Clues
```bash
# Check system logs
sudo journalctl -u nginx -n 100

# Check for OOM (Out of Memory) errors
sudo journalctl --since "1 hour ago" | grep -i "killed\|oom"

# Check for disk errors
sudo dmesg | tail -50
```

---

## Windows PowerShell Useful Commands

```powershell
# Check if port is reachable
Test-NetConnection -ComputerName your-ec2-ip -Port 80

# Test DNS resolution
nslookup your-ec2-ip

# Get your public IP (to allow in security group)
(Invoke-WebRequest -Uri "https://api.ipify.org?format=json").Content

# Copy and execute a long command
$ScriptBlock = @"
cd C:\path\to\project
npm run build
scp -i `"C:\path\to\key.pem`" -r ".\dist\*" ec2-user@your-ec2-ip:/var/www/autograder-frontend/
ssh -i `"C:\path\to\key.pem`" ec2-user@your-ec2-ip "sudo systemctl reload nginx"
"@

Invoke-Expression $ScriptBlock
```

---

## AWS CLI Commands (Optional)

```bash
# Get EC2 instance details
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Get instance status
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Get security group details
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# List all instances
aws ec2 describe-instances --query 'Reservations[].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
```

---

## Quick Reference URLs

Once deployed, access these URLs:

```
Main App:              http://your-ec2-ip
Login Page:            http://your-ec2-ip/login
Student Dashboard:     http://your-ec2-ip/student/dashboard
Instructor Dashboard:  http://your-ec2-ip/instructor/dashboard

Nginx Status:          http://your-ec2-ip/nginx_status (if configured)
```

---

**Save this file for quick reference! 📚**
