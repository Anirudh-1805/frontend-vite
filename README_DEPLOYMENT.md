# 📚 Complete EC2 Deployment Package

Your complete deployment solution is ready!

---

## 📂 What's Inside This Package?

```
frontend-vite/
│
├── 🚀 DEPLOYMENT FILES
│   ├── deploy-ec2.ps1                    ← RUN THIS (PowerShell - Windows)
│   ├── setup-ec2.sh                      ← RUN THIS (Bash - On EC2)
│   └── nginx.conf                        ← Copy this to Nginx config
│
├── 📖 DOCUMENTATION
│   ├── EC2_QUICK_START.md                ← Start here! (5-10 min read)
│   ├── EC2_DEPLOYMENT.md                 ← Complete guide
│   ├── EC2_CHECKLIST.md                  ← Track your progress
│   ├── COMMAND_REFERENCE.md              ← All commands you'll need
│   └── DEPLOYMENT_SETUP_COMPLETE.md      ← What I've done for you
│
├── 📦 BUILD FILES
│   └── dist/                             ← Your production build (ready!)
│
└── 📝 SOURCE CODE
    └── src/                              ← Your React application
```

---

## ⚡ Quick Start (Choose Your Path)

### Path 1: I'm Experienced with AWS (5 minutes)
1. Read: `EC2_QUICK_START.md`
2. Create EC2 instance (Amazon Linux 2, t2.micro, public IP enabled)
3. Update `deploy-ec2.ps1` with your IP and key path
4. Run: `.\deploy-ec2.ps1`
5. Done! Access at `http://your-ec2-ip`

### Path 2: I'm New to AWS (30 minutes)
1. Read: `EC2_DEPLOYMENT.md` (Phase 1-3)
2. Follow Step 1: Create EC2 Instance (detailed instructions)
3. Follow Step 2: Configure Security Groups (critical!)
4. Read: `EC2_QUICK_START.md`
5. Follow remaining steps
6. Done!

### Path 3: I Want Step-by-Step (Guided)
1. Print or open: `EC2_CHECKLIST.md`
2. Check off each item as you complete it
3. Use `EC2_DEPLOYMENT.md` for detailed explanations
4. Use `COMMAND_REFERENCE.md` for specific commands
5. Cross-reference with troubleshooting if needed

---

## 🎯 The 3-Step Deployment Process

### Step 1: Create EC2 Instance (On AWS Console)
- Go to EC2 Dashboard
- Launch Instance
- Select Amazon Linux 2 or Ubuntu 22.04
- Select t2.micro
- **Enable Auto-assign Public IP** ⭐
- Create security group with SSH, HTTP, HTTPS rules
- Create key pair and download .pem file
- Click Launch

### Step 2: Prepare Your Local Machine
```powershell
# Copy .pem file to ~/.ssh and set permissions
mkdir -p C:\Users\$env:USERNAME\.ssh
Copy-Item "C:\Downloads\your-key.pem" "C:\Users\$env:USERNAME\.ssh\"
icacls "C:\Users\$env:USERNAME\.ssh\your-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"

# Update deploy-ec2.ps1 with your details
# Edit these lines:
$EC2_IP = "your-actual-ec2-public-ip"      # e.g., 54.123.45.67
$KEY_PATH = "C:\Users\YourName\.ssh\your-key.pem"
```

### Step 3: Run Deployment
```powershell
cd C:\Users\YourName\OneDrive\Desktop\frontend\frontend-vite
.\deploy-ec2.ps1
```

**That's it!** Your app is now live. 🎉

---

## 📖 Document Guide

### For Quick Reference
- **`EC2_QUICK_START.md`** - 5-step quickstart guide

### For Complete Instructions
- **`EC2_DEPLOYMENT.md`** - Everything you need to know
  - Prerequisites
  - Creating EC2 instance
  - Security group setup
  - Installation options
  - Deployment procedures
  - Verification steps
  - Troubleshooting
  - Advanced setup

### For Tracking Progress
- **`EC2_CHECKLIST.md`** - Interactive checklist to track all steps

### For Command Reference
- **`COMMAND_REFERENCE.md`** - All SSH, PowerShell, and bash commands
  - Local machine setup
  - EC2 instance setup
  - Nginx configuration
  - Verification commands
  - Troubleshooting commands

### For Understanding What I've Done
- **`DEPLOYMENT_SETUP_COMPLETE.md`** - Overview of everything created

---

## 🔧 File Descriptions

### `deploy-ec2.ps1` (Windows PowerShell Script)
**What it does:**
1. Builds your frontend locally
2. Tests SSH connection
3. Uploads dist folder to EC2
4. Reloads Nginx
5. Displays success message

**How to use:**
```powershell
# First, update these variables:
$EC2_IP = "your-ec2-public-ip"
$KEY_PATH = "C:\path\to\your-key.pem"

# Then run:
.\deploy-ec2.ps1
```

**Time to run:** ~30-60 seconds

---

### `setup-ec2.sh` (Bash Script)
**What it does:**
1. Updates system packages
2. Installs Node.js 20
3. Installs Nginx
4. Creates deployment directory
5. Configures Nginx for React app
6. Starts Nginx service

**How to use:**
```bash
# Once connected to EC2, run:
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/setup-ec2.sh | bash

# Or copy the script and run locally:
bash setup-ec2.sh
```

**Time to run:** ~2-3 minutes

**Run this:** Once per EC2 instance

---

### `nginx.conf` (Web Server Configuration)
**What it does:**
- Configures Nginx to serve your React app
- Routes all requests to index.html (React Router)
- Caches static assets (JS, CSS, fonts)
- Enables Gzip compression
- Adds security headers

**How to use:**
```bash
# Option 1: Copy to Nginx config directory
sudo cp nginx.conf /etc/nginx/conf.d/autograder-frontend.conf

# Option 2: Edit existing config
sudo nano /etc/nginx/conf.d/autograder-frontend.conf
# Then paste contents of nginx.conf

# Then validate and reload:
sudo nginx -t
sudo systemctl reload nginx
```

---

### `dist/` Folder (Production Build)
- Contains your production-ready frontend
- Minified JavaScript
- Optimized CSS
- Gzipped assets
- Ready to deploy

**Size:** ~400KB (gzipped)

---

## 🌐 How It Works (Architecture)

```
Your Code Changes (local)
         ↓
    npm run build (creates dist/)
         ↓
    deploy-ec2.ps1
         ↓
    SCP Upload (secure copy)
         ↓
EC2 Instance /var/www/autograder-frontend/
         ↓
    Nginx Web Server
         ↓
    http://your-ec2-ip
         ↓
    Accessible from Anywhere! 🌍
```

---

## ✅ Checklist Before Deployment

- [ ] Read `EC2_QUICK_START.md` or `EC2_DEPLOYMENT.md`
- [ ] AWS Account active
- [ ] EC2 instance created and running
- [ ] EC2 has public IP assigned
- [ ] Security group allows SSH, HTTP, HTTPS
- [ ] Key pair (.pem file) downloaded and saved locally
- [ ] `deploy-ec2.ps1` updated with correct EC2_IP and KEY_PATH
- [ ] SSH connection tested successfully
- [ ] Production build exists (`dist/` folder)
- [ ] Ready to deploy!

---

## 🚀 Deployment Steps

### Quick Deployment
```powershell
# 1. Update deploy-ec2.ps1 with your details
# 2. Run:
.\deploy-ec2.ps1

# 3. Wait for success message
# 4. Access your app at: http://your-ec2-ip
```

### Manual Deployment (If Script Fails)
```powershell
# Build
npm run build

# Upload
scp -i "C:\path\to\key.pem" -r ".\dist\*" ec2-user@your-ec2-ip:/var/www/autograder-frontend/

# Reload
ssh -i "C:\path\to\key.pem" ec2-user@your-ec2-ip "sudo systemctl reload nginx"
```

---

## 🎯 After Deployment

### Verify It's Working
1. Open browser
2. Go to `http://your-ec2-ip`
3. Should see your login page
4. Try navigating: `/student/dashboard`, `/instructor/dashboard`

### Make Code Changes
1. Make changes locally
2. Run `.\deploy-ec2.ps1` again
3. Changes live instantly

### Advanced Setup (Optional)
- **HTTPS:** Use AWS Certificate Manager + Certbot
- **Custom Domain:** Point your domain to EC2 IP
- **Auto-Redeploy:** Set up GitHub webhook
- **Monitoring:** Use CloudWatch

See `EC2_DEPLOYMENT.md` for detailed guides on these.

---

## 🆘 Troubleshooting Quick Links

**Can't SSH into EC2?**
→ See `EC2_DEPLOYMENT.md` → Troubleshooting → SSH Connection Issues

**Frontend shows 404?**
→ See `EC2_DEPLOYMENT.md` → Troubleshooting → Frontend Not Loading

**Routes return 404?**
→ See `EC2_DEPLOYMENT.md` → Troubleshooting → Routes Return 404

**General issues?**
→ See `COMMAND_REFERENCE.md` → Verification & Troubleshooting

**Still stuck?**
→ Check the logs: `sudo tail -50 /var/log/nginx/error.log`

---

## 📊 Key Information You'll Need

Save these somewhere safe:

```
EC2 Instance ID:          ________________________
EC2 Public IP:            ________________________
EC2 Security Group:       ________________________
Key Pair Name:            ________________________
Key File Location:        ________________________
Domain Name (if any):     ________________________
Launch Date:              ________________________
```

---

## 🔐 Security Notes

⚠️ **Important:**
1. Keep your `.pem` file safe and secure
2. Never commit `.pem` file to git
3. Restrict security group rules in production
4. Use HTTPS when possible
5. Keep your OS and packages updated

---

## 💰 Cost Considerations

- **EC2 t2.micro:** Free tier for 1 year
- **Data transfer:** Minimal cost (~$0.09/GB)
- **Storage:** 8GB included in free tier
- **Total cost:** Likely $0 if within free tier

---

## 🎓 Learning Outcomes

After completing this deployment, you'll understand:
- ✅ AWS EC2 instance creation
- ✅ Security groups and SSH
- ✅ Nginx web server configuration
- ✅ SCP file transfer
- ✅ React Router SPA deployment
- ✅ Linux command line basics
- ✅ SSH/PowerShell scripting

---

## 📚 Additional Resources

- **AWS EC2 Docs:** https://docs.aws.amazon.com/ec2/
- **Nginx Documentation:** https://nginx.org/en/docs/
- **SSH Guide:** https://linux.die.net/man/1/ssh
- **React Router:** https://reactrouter.com/
- **PowerShell Guide:** https://learn.microsoft.com/en-us/powershell/

---

## ❓ FAQ

**Q: Do I need to run setup-ec2.sh every time?**
A: No, only once when setting up a new EC2 instance.

**Q: Can I use Ubuntu instead of Amazon Linux?**
A: Yes! The scripts support both. Just change `ec2-user` to `ubuntu`.

**Q: How do I update my code after deploying?**
A: Make changes locally, then run `.\deploy-ec2.ps1` again.

**Q: Can I use a custom domain?**
A: Yes! Point your domain to the EC2 public IP.

**Q: How do I enable HTTPS?**
A: Use AWS Certificate Manager + Certbot (see `EC2_DEPLOYMENT.md`).

**Q: What if the deployment script fails?**
A: Run the manual deployment commands in `COMMAND_REFERENCE.md`.

---

## 📞 Support

1. **Check `EC2_DEPLOYMENT.md`** for detailed help
2. **Review `COMMAND_REFERENCE.md`** for specific commands
3. **Use `EC2_CHECKLIST.md`** to verify all steps
4. **Check logs** on EC2: `sudo tail -50 /var/log/nginx/error.log`

---

## ✨ Summary

You now have:

✅ **Production build** ready to deploy  
✅ **Automated script** for one-click deployments  
✅ **Complete documentation** for all scenarios  
✅ **Command reference** for troubleshooting  
✅ **Everything needed** to go live on AWS EC2  

**You're ready to deploy! 🚀**

---

**Start with `EC2_QUICK_START.md` if you want the fast track, or `EC2_DEPLOYMENT.md` for the complete guide.**

*Happy deploying!* 🎉
