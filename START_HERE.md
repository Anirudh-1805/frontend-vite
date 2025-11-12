# 🎯 START HERE - 3 Simple Steps

This is the absolute quickest way to get your frontend live on EC2.

---

## ✅ STEP 1: Create EC2 Instance (3 minutes)

### On AWS Console:

1. **Go to EC2 Dashboard** (https://console.aws.amazon.com/ec2)

2. **Click "Launch Instances"**

3. **Choose AMI**
   - Select: **Amazon Linux 2**
   - *(Ubuntu 22.04 LTS works too)*

4. **Instance Type**
   - Select: **t2.micro** (free tier)

5. **Network Settings**
   - ⭐ **AUTO-ASSIGN PUBLIC IP: Enable** (IMPORTANT!)

6. **Security Group**
   - Click **"Create security group"**
   - Name: `autograder-frontend`
   - Add **Inbound Rules**:
     ```
     SSH     TCP 22   0.0.0.0/0
     HTTP    TCP 80   0.0.0.0/0
     HTTPS   TCP 443  0.0.0.0/0
     ```

7. **Key Pair**
   - Click **"Create new key pair"**
   - Name: `autograder-frontend-key`
   - Format: `.pem` (default)
   - Click **"Create key pair"**
   - **Save the file!** (Downloads folder)

8. **Review & Launch**
   - Review all settings
   - Click **"Launch Instances"**

9. **Wait for Instance to Start**
   - Go to Instances page
   - Wait for status: ✅ **"running"**
   - Copy the **Public IPv4 address** (example: `54.123.45.67`)

---

## ✅ STEP 2: Prepare Your Windows Computer (2 minutes)

### Open PowerShell:

```powershell
# 1. Create SSH folder
mkdir -p C:\Users\$env:USERNAME\.ssh

# 2. Copy your key file to this folder
# Use File Explorer: Copy-paste from Downloads to C:\Users\YourName\.ssh\

# 3. Fix file permissions (paste this entire block):
$keyPath = "C:\Users\$env:USERNAME\.ssh\autograder-frontend-key.pem"
icacls $keyPath /inheritance:r /grant:r "$env:USERNAME`:(F)"

# 4. Test the connection (replace with YOUR EC2 IP):
ssh -i $keyPath ec2-user@54.123.45.67
# You should see a prompt, type: exit
```

---

## ✅ STEP 3: Deploy Your Frontend (1 minute)

### On Windows PowerShell:

```powershell
# 1. Navigate to your project
cd "C:\Users\$env:USERNAME\OneDrive\Desktop\frontend\frontend-vite"

# 2. Update the deploy script
# Open deploy-ec2.ps1 in a text editor and change:
#   $EC2_IP = "54.123.45.67"  (your actual EC2 IP)
#   $KEY_PATH = "C:\Users\YourName\.ssh\autograder-frontend-key.pem"

# 3. Run deployment
.\deploy-ec2.ps1

# 4. Watch the magic happen! ✨
# The script will:
#   ✓ Build your frontend
#   ✓ Test connection
#   ✓ Upload files
#   ✓ Reload Nginx
#   ✓ Show you the URL
```

---

## 🎉 DONE! Your App is Live!

When the script completes, you'll see:

```
✓ Deployment Complete!
Access your app at:
  http://54.123.45.67

Common routes:
  http://54.123.45.67/login
  http://54.123.45.67/student/dashboard
  http://54.123.45.67/instructor/dashboard
```

**Open your browser to `http://your-ec2-ip` and see your frontend live!** 🚀

---

## 🆘 If Something Goes Wrong

### Error: "Can't connect via SSH"
```powershell
# Check your EC2_IP is correct (copy from AWS Console)
# Check your key file path is correct
# Make sure security group allows port 22
# Try verbose mode:
ssh -v -i "C:\path\to\key.pem" ec2-user@your-ec2-ip
```

### Error: "Nginx is down" or "404 Not Found"
```powershell
# Connect and check:
ssh -i "C:\path\to\key.pem" ec2-user@your-ec2-ip

# On EC2, run:
sudo systemctl status nginx
sudo tail -50 /var/log/nginx/error.log
sudo systemctl reload nginx
```

### Need More Help?
→ Read **`EC2_DEPLOYMENT.md`** (comprehensive guide)

→ Check **`COMMAND_REFERENCE.md`** (all commands)

→ Use **`EC2_CHECKLIST.md`** (track progress)

---

## 📝 Quick Reference

**Your EC2 Info** (save this!)
```
Instance ID: ________________
Public IP:   ________________
Key File:    C:\Users\{YourName}\.ssh\autograder-frontend-key.pem
Security Group: autograder-frontend
```

**Common Commands** (for later use)
```powershell
# Redeploy after code changes:
.\deploy-ec2.ps1

# Connect to EC2 directly:
ssh -i "C:\Users\$env:USERNAME\.ssh\autograder-frontend-key.pem" ec2-user@your-ec2-ip

# Check if app is running:
ssh -i "C:\Users\$env:USERNAME\.ssh\autograder-frontend-key.pem" ec2-user@your-ec2-ip "curl localhost"
```

---

## ✨ What Just Happened

```
Your Code
   ↓
Production Build (dist/)
   ↓
SCP Upload to EC2
   ↓
Nginx Web Server
   ↓
Public Internet Access
   ↓
Your App Live! 🎉
```

---

## 🎯 What's Next?

1. **Test Your App**
   - Click links
   - Test all pages
   - Try student/instructor features

2. **Make Code Changes**
   - Just edit your code
   - Run `.\deploy-ec2.ps1` again
   - Changes live instantly!

3. **Advanced Setup** (optional, later)
   - Enable HTTPS
   - Set up custom domain
   - Auto-redeploy on GitHub push

---

## 📚 File Reference

If you need detailed instructions:

- **`EC2_QUICK_START.md`** - 5 step quick start (10 min)
- **`EC2_DEPLOYMENT.md`** - Complete guide (30 min read)
- **`COMMAND_REFERENCE.md`** - All commands reference
- **`EC2_CHECKLIST.md`** - Track your progress
- **`README_DEPLOYMENT.md`** - Master overview

---

## 🎉 Congratulations!

You're now a cloud deployer! Your frontend is live on AWS EC2, accessible from anywhere in the world. 🌍

**Any updates?** Just run `.\deploy-ec2.ps1` again.

That's it. You're done! 🚀

---

**Questions? Check the troubleshooting section in `EC2_DEPLOYMENT.md`**
