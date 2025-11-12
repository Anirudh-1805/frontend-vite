# 🚀 Quick Start: EC2 Frontend Deployment

## What I've Created for You

✅ **`deploy-ec2.ps1`** - One-click deployment script (PowerShell)
✅ **`setup-ec2.sh`** - EC2 instance configuration script (Bash)
✅ **`nginx.conf`** - Nginx configuration for React app
✅ **`EC2_DEPLOYMENT.md`** - Comprehensive deployment guide
✅ **`dist/`** - Production build (ready to deploy)

---

## Quick Start (5 Steps)

### Step 1: Create EC2 Instance

1. Go to [AWS Console](https://console.aws.amazon.com) → EC2
2. Click **Launch Instances**
3. Choose **Amazon Linux 2** (or Ubuntu 22.04)
4. Select **t2.micro** instance type
5. **Enable Auto-assign Public IP**
6. Create Security Group with these inbound rules:
   - SSH (22) from 0.0.0.0/0
   - HTTP (80) from 0.0.0.0/0
   - HTTPS (443) from 0.0.0.0/0
7. Create new key pair (`.pem` file) and **download it**
8. **Launch** and wait for instance to start

### Step 2: Save Key File Locally

```powershell
# Create SSH directory
mkdir -p C:\Users\$env:USERNAME\.ssh

# Copy your downloaded .pem file to this directory
# Then set proper permissions
icacls "C:\Users\$env:USERNAME\.ssh\your-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"
```

### Step 3: Update Deployment Script

Edit `deploy-ec2.ps1`:

```powershell
$EC2_IP = "your-ec2-public-ip"  # Get from AWS Console (e.g., 54.123.45.67)
$KEY_PATH = "C:\Users\$env:USERNAME\.ssh\your-key.pem"  # Your key file path
```

### Step 4: Run Setup on EC2 (One Time)

```powershell
# Connect to your EC2 instance
ssh -i "C:\Users\$env:USERNAME\.ssh\your-key.pem" ec2-user@your-ec2-public-ip

# Run this command on EC2 to auto-setup:
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/setup-ec2.sh | bash

# Or manually copy setup-ec2.sh and run it
```

### Step 5: Deploy Your Frontend

```powershell
# From your project root directory
cd C:\Users\YourUsername\OneDrive\Desktop\frontend\frontend-vite

# Run deployment (builds and uploads automatically)
.\deploy-ec2.ps1
```

**That's it!** 🎉 Your app will be live at `http://your-ec2-public-ip`

---

## What Happens During Deploy?

The `deploy-ec2.ps1` script:

1. ✅ Builds your frontend (`npm run build`)
2. ✅ Tests SSH connection to EC2
3. ✅ Uploads `dist/` folder via SCP
4. ✅ Reloads Nginx with new files
5. ✅ Displays your live URL

---

## Access Your App

Once deployed, visit:

```
http://your-ec2-public-ip            # Main page
http://your-ec2-public-ip/login      # Login page
http://your-ec2-public-ip/student/dashboard
http://your-ec2-public-ip/instructor/dashboard
```

---

## Redeploy (Next Times)

Just update your code and run:

```powershell
.\deploy-ec2.ps1
```

That's all! No need to setup EC2 again.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Permission denied` SSH | Check key permissions: `icacls "C:\...\.pem" /inheritance:r /grant:r "$env:USERNAME:(F)"` |
| Can't connect to EC2 | Verify EC2 is running and has public IP assigned |
| Frontend shows 404 | SSH into EC2 and run `sudo systemctl reload nginx` |
| Files not uploaded | Check SCP command in PowerShell, verify path exists |

**For detailed help**, see `EC2_DEPLOYMENT.md`

---

## File Guide

```
frontend-vite/
├── deploy-ec2.ps1              ← Run this from Windows
├── setup-ec2.sh                ← Run this on EC2 (one time)
├── nginx.conf                  ← Nginx server configuration
├── EC2_DEPLOYMENT.md           ← Full deployment guide
├── dist/                        ← Your production build (auto-created)
└── src/                         ← Your source code
```

---

## Next Steps

- **Enable HTTPS**: Get free SSL with AWS Certificate Manager + Certbot
- **Custom Domain**: Point your domain to EC2 IP
- **Auto-Redeploy**: Set up GitHub webhook for automatic deployments
- **Monitoring**: Use CloudWatch to monitor your instance

See `EC2_DEPLOYMENT.md` for detailed instructions on these.

---

**Need help?** Check the Troubleshooting section in `EC2_DEPLOYMENT.md` 📚

**Happy Deploying! 🚀**
