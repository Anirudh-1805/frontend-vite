# EC2 Frontend Deployment Guide

This guide walks you through deploying your Autograder Frontend to AWS EC2 with full public accessibility.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Create EC2 Instance](#create-ec2-instance)
3. [Configure Security Groups](#configure-security-groups)
4. [Setup EC2 Instance](#setup-ec2-instance)
5. [Deploy Your Frontend](#deploy-your-frontend)
6. [Verify Deployment](#verify-deployment)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- AWS Account
- Windows PowerShell (version 5.0 or higher)
- PuTTY or OpenSSH (for Windows, native SSH in PowerShell 7+)
- Git Bash or WSL (optional, for better shell experience)

**Check if you have SSH installed:**

```powershell
ssh -V
scp -V
```

If not available, install [OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_configure).

---

## Create EC2 Instance

### Step 1: Navigate to AWS Console

1. Go to [AWS Console](https://console.aws.amazon.com)
2. Navigate to **EC2 Dashboard**
3. Click **Launch Instances**

### Step 2: Choose AMI (Amazon Machine Image)

Select one of these:

- **Amazon Linux 2** (Recommended for this guide)
- **Ubuntu 22.04 LTS** (Alternative)

### Step 3: Choose Instance Type

- Select **t2.micro** (eligible for AWS Free Tier)
- Click **Next**

### Step 4: Instance Details

- **VPC**: Use default VPC
- **Auto-assign Public IP**: **Enable** (Critical!)
- Click **Next**

### Step 5: Storage

- Keep default (8 GB EBS)
- Click **Next**

### Step 6: Add Tags

Optional, but useful:

```
Name: autograder-frontend
Environment: production
```

Click **Next**

### Step 7: Configure Security Group

**Create a new security group** with these inbound rules:

| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | 0.0.0.0/0 | Remote access (or restrict to your IP) |
| HTTP | TCP | 80 | 0.0.0.0/0 | Your frontend (accessible from anywhere) |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Future SSL/TLS |

⚠️ **Note**: `0.0.0.0/0` means accessible from anywhere. For production, restrict to specific IPs.

### Step 8: Review and Launch

1. Review all settings
2. Click **Launch**
3. **Create a new key pair** (or select existing):
   - Name: `autograder-frontend-key` (or your preferred name)
   - Format: `.pem` (for macOS/Linux/WSL)
   - Click **Create key pair**
4. **Download the .pem file** and save it securely
5. Click **Launch Instances**

---

## Configure Security Groups

⚠️ **This is critical for public accessibility!**

1. Go to **EC2 Dashboard** → **Security Groups**
2. Find your security group (created above)
3. Select it and click **Edit inbound rules**
4. Verify you have:
   - **HTTP (80)** from **0.0.0.0/0**
   - **HTTPS (443)** from **0.0.0.0/0** (optional)
   - **SSH (22)** from your IP or **0.0.0.0/0**

---

## Setup EC2 Instance

### Option 1: Automatic Setup (Recommended)

#### Step 1: Save Setup Script Locally

Copy the contents of `setup-ec2.sh` from the project root.

#### Step 2: Connect to EC2 via SSH

```powershell
# Store key path in variable
$KEY_PATH = "C:\Users\YourUsername\.ssh\your-key.pem"

# Get your EC2 public IP from AWS Console
$EC2_IP = "your-ec2-public-ip"

# Connect
ssh -i $KEY_PATH ec2-user@$EC2_IP
```

#### Step 3: Run Setup Script

Once connected to EC2:

```bash
# Download and run the setup script
curl -sSL https://raw.githubusercontent.com/yourusername/autograder-frontend/main/setup-ec2.sh | bash

# OR if you saved it locally, copy and run it
```

Alternatively, paste the script contents directly:

```bash
cat > setup.sh << 'EOF'
# Paste contents of setup-ec2.sh here
EOF
bash setup.sh
```

### Option 2: Manual Setup

If you prefer to setup manually, run these commands on your EC2 instance:

#### For Amazon Linux 2:

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

# Configure Nginx
sudo nano /etc/nginx/conf.d/autograder-frontend.conf
# Paste the contents of nginx.conf from the project

# Validate Nginx config
sudo nginx -t

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### For Ubuntu 22.04:

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

# Configure Nginx
sudo nano /etc/nginx/conf.d/autograder-frontend.conf
# Paste the contents of nginx.conf from the project

# Validate Nginx config
sudo nginx -t

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## Deploy Your Frontend

### Step 1: Prepare Local Machine

#### Copy Your Key File

```powershell
# Create SSH directory if it doesn't exist
mkdir -p C:\Users\$env:USERNAME\.ssh

# Copy your downloaded .pem file here
# You can do this via File Explorer or:
Copy-Item "C:\Users\YourUsername\Downloads\your-key.pem" "C:\Users\YourUsername\.ssh\"

# Set correct permissions (important!)
icacls "C:\Users\YourUsername\.ssh\your-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"
```

### Step 2: Update Deployment Script

Edit `deploy-ec2.ps1` in your project:

```powershell
# Open the file and update:
$EC2_IP = "your-actual-ec2-public-ip"        # e.g., "54.123.45.67"
$KEY_PATH = "C:\Users\YourUsername\.ssh\your-key.pem"  # Your actual path
```

### Step 3: Run Deployment Script

```powershell
# Navigate to project directory
cd C:\Users\YourUsername\OneDrive\Desktop\frontend\frontend-vite

# Run the deployment script
.\deploy-ec2.ps1
```

The script will:
1. ✓ Build your frontend (`npm run build`)
2. ✓ Test SSH connection
3. ✓ Upload `dist` folder to EC2
4. ✓ Reload Nginx
5. ✓ Display your application URL

### Step 4: Manual Deployment (If Script Fails)

```powershell
# Build locally
npm run build

# Upload via SCP
scp -i "C:\Users\YourUsername\.ssh\your-key.pem" -r ".\dist\*" ec2-user@your-ec2-ip:/var/www/autograder-frontend/

# Reload Nginx on EC2
ssh -i "C:\Users\YourUsername\.ssh\your-key.pem" ec2-user@your-ec2-ip "sudo systemctl reload nginx"
```

---

## Verify Deployment

### Test 1: Browser Access

Open your browser and navigate to:

```
http://your-ec2-public-ip
```

You should see your frontend login page!

### Test 2: Check Routes

Try these URLs:

```
http://your-ec2-public-ip/login
http://your-ec2-public-ip/student/dashboard
http://your-ec2-public-ip/instructor/dashboard
```

### Test 3: SSH into EC2 and Verify Files

```powershell
ssh -i "C:\Users\YourUsername\.ssh\your-key.pem" ec2-user@your-ec2-ip
```

Once connected:

```bash
# Check if files are uploaded
ls -la /var/www/autograder-frontend/

# Check if Nginx is running
sudo systemctl status nginx

# Check Nginx logs
sudo tail -20 /var/log/nginx/access.log
sudo tail -20 /var/log/nginx/error.log
```

---

## Troubleshooting

### Problem: Can't Connect via SSH

**Error**: `permission denied` or `Connection refused`

**Solutions**:

1. Verify key permissions on Windows:
   ```powershell
   icacls "C:\path\to\key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"
   ```

2. Verify security group allows SSH port 22

3. Verify EC2 instance is running and has public IP

4. Try adding verbose flag:
   ```powershell
   ssh -v -i "C:\path\to\key.pem" ec2-user@your-ec2-ip
   ```

### Problem: Frontend Not Loading (404 or Blank Page)

**Causes**: Files not uploaded or Nginx not serving correctly

**Solutions**:

1. Verify files are on EC2:
   ```bash
   ls -la /var/www/autograder-frontend/
   ```

2. Check Nginx config:
   ```bash
   sudo nginx -t
   cat /etc/nginx/conf.d/autograder-frontend.conf
   ```

3. Reload Nginx:
   ```bash
   sudo systemctl reload nginx
   ```

4. Check Nginx error log:
   ```bash
   sudo tail -50 /var/log/nginx/error.log
   ```

### Problem: Routes Return 404

**Cause**: Nginx not configured for React Router SPA

**Solution**: Ensure `nginx.conf` has this in the `location /` block:

```nginx
location / {
    try_files $uri /index.html;
}
```

Then reload:

```bash
sudo systemctl reload nginx
```

### Problem: Can't Upload Files via SCP

**Error**: `scp: command not found` or permission issues

**Solutions**:

1. Ensure OpenSSH is installed and in PATH

2. Check directory permissions:
   ```bash
   sudo chown -R ec2-user:ec2-user /var/www/autograder-frontend
   sudo chmod -R 755 /var/www/autograder-frontend
   ```

3. Try uploading to a temporary location first:
   ```powershell
   scp -i $KEY_PATH -r ".\dist\*" ec2-user@your-ec2-ip:~/dist-temp/
   ```

   Then SSH and move:
   ```bash
   mv ~/dist-temp/* /var/www/autograder-frontend/
   ```

### Problem: Nginx Won't Start

**Check config first**:

```bash
sudo nginx -t
```

**Check logs**:

```bash
sudo journalctl -u nginx -n 50
sudo tail -50 /var/log/nginx/error.log
```

**Common causes**:
- Port 80 already in use: `sudo ss -tlnp | grep 80`
- Syntax error in config: Use `nginx -t` to verify
- Permission denied: Check file ownership

---

## Next Steps

### Enable HTTPS (SSL/TLS)

Use AWS Certificate Manager (free):

1. Request a certificate for your domain
2. Set up Route53 DNS records
3. Install Certbot on EC2:
   ```bash
   sudo yum install -y certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

### Custom Domain

1. Buy a domain (Route53, Namecheap, etc.)
2. Point DNS to your EC2 public IP
3. Update Nginx server_name:
   ```nginx
   server_name your-domain.com www.your-domain.com;
   ```

### Auto-Redeploy on Push

Create a webhook to automatically deploy when you push to GitHub:

```bash
# On EC2, create a deployment script
cat > /home/ec2-user/redeploy.sh << 'EOF'
#!/bin/bash
cd /var/www/autograder-frontend
git pull origin main
npm run build
cp -r dist/* .
sudo systemctl reload nginx
EOF

chmod +x /home/ec2-user/redeploy.sh
```

---

## Getting Help

If you encounter issues:

1. Check EC2 logs: `sudo tail -50 /var/log/nginx/error.log`
2. Verify security group rules in AWS Console
3. Test connectivity: `ping your-ec2-ip`
4. Check if Nginx is running: `sudo systemctl status nginx`

---

## Additional Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [React Router Documentation](https://reactrouter.com/)
- [OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/)

---

**Happy Deploying! 🚀**
