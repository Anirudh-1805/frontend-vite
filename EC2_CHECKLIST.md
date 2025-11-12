# ✅ EC2 Deployment Checklist

Use this checklist to ensure you complete all necessary steps.

---

## Phase 1: Preparation ✓

- [ ] Frontend code is ready
- [ ] `dist/` folder created by running `npm run build`
- [ ] AWS Account created
- [ ] AWS CLI installed (optional but recommended)

---

## Phase 2: Create EC2 Instance

- [ ] Signed into AWS Console
- [ ] Navigated to EC2 Dashboard
- [ ] Clicked "Launch Instances"
- [ ] Selected **Amazon Linux 2** or **Ubuntu 22.04 LTS**
- [ ] Selected **t2.micro** instance type
- [ ] **Enabled** "Auto-assign Public IP"
- [ ] Created Security Group with:
  - [ ] SSH (22) from 0.0.0.0/0
  - [ ] HTTP (80) from 0.0.0.0/0
  - [ ] HTTPS (443) from 0.0.0.0/0
- [ ] Created new Key Pair (`.pem` file)
- [ ] Downloaded Key Pair file
- [ ] Reviewed settings and launched instance
- [ ] Waited for instance to reach "Running" state
- [ ] Noted down the **Public IPv4 address** from AWS Console

---

## Phase 3: Prepare Local Machine (Windows)

- [ ] Created `C:\Users\{YourUsername}\.ssh\` directory
- [ ] Copied downloaded `.pem` file to `.ssh` directory
- [ ] Set correct file permissions using:
  ```powershell
  icacls "C:\Users\{YourUsername}\.ssh\your-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"
  ```
- [ ] Verified SSH is available:
  ```powershell
  ssh -V
  scp -V
  ```
- [ ] Tested SSH connection to EC2:
  ```powershell
  ssh -i "C:\Users\{YourUsername}\.ssh\your-key.pem" ec2-user@{your-ec2-ip}
  ```
  - [ ] Connection successful (type `exit` to disconnect)

---

## Phase 4: Setup EC2 Instance (One Time Only)

- [ ] Connected to EC2 via SSH
- [ ] Ran one of these commands:

**Option A (Automatic):**
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/frontend-vite/main/setup-ec2.sh | bash
```

**Option B (Manual):**
```bash
# Run each command from setup-ec2.sh
```

- [ ] Setup completed successfully (should see ✓ marks)
- [ ] Verified installation:
  - [ ] Node.js: `node --version`
  - [ ] Nginx: `sudo systemctl status nginx`

---

## Phase 5: Configure Deployment Script

- [ ] Opened `deploy-ec2.ps1` from project root
- [ ] Updated the configuration variables:
  ```powershell
  $EC2_IP = "your-actual-ec2-public-ip"  # e.g., 54.123.45.67
  $KEY_PATH = "C:\Users\{YourUsername}\.ssh\your-key.pem"
  ```
- [ ] Saved the file
- [ ] Verified variables are correct (double-check IP address!)

---

## Phase 6: Deploy Frontend

- [ ] Navigated to project directory:
  ```powershell
  cd C:\Users\{YourUsername}\OneDrive\Desktop\frontend\frontend-vite
  ```
- [ ] Ran deployment script:
  ```powershell
  .\deploy-ec2.ps1
  ```
- [ ] Watched script output:
  - [ ] Build successful ✓
  - [ ] SSH connection test passed ✓
  - [ ] Files uploaded successfully ✓
  - [ ] Nginx reloaded successfully ✓
- [ ] Script displayed deployment complete message

---

## Phase 7: Verify Deployment

- [ ] Opened browser
- [ ] Navigated to `http://your-ec2-public-ip`
- [ ] Saw frontend homepage
- [ ] Tested navigation:
  - [ ] `http://your-ec2-public-ip/login` loads
  - [ ] `http://your-ec2-public-ip/student/dashboard` loads
  - [ ] `http://your-ec2-public-ip/instructor/dashboard` loads
- [ ] All pages load correctly

---

## Phase 8: Verify on EC2

- [ ] Connected to EC2 via SSH
- [ ] Ran verification commands:
  ```bash
  ls -la /var/www/autograder-frontend/
  sudo systemctl status nginx
  sudo tail -20 /var/log/nginx/access.log
  ```
- [ ] Files are present in `/var/www/autograder-frontend/`
- [ ] Nginx status shows "active (running)"
- [ ] Access logs show successful requests

---

## Phase 9: Future Deployments

For each code update:

- [ ] Made code changes locally
- [ ] Tested locally: `npm run dev`
- [ ] Committed changes to git
- [ ] Ran deployment:
  ```powershell
  .\deploy-ec2.ps1
  ```

---

## Optional: Enhanced Setup

### Enable HTTPS (SSL/TLS)

- [ ] Have a domain name (optional)
- [ ] Requested certificate in AWS Certificate Manager
- [ ] Updated Nginx with SSL config
- [ ] Installed and configured Certbot
- [ ] Updated browser bookmarks to use `https://`

### Custom Domain

- [ ] Registered domain with Route53 or external registrar
- [ ] Created Route53 hosted zone (if using Route53)
- [ ] Created A record pointing to EC2 public IP
- [ ] Updated Nginx `server_name` directive
- [ ] Tested domain: `http://your-domain.com`

### Auto-Redeploy on GitHub Push

- [ ] Set up GitHub Actions workflow
- [ ] Created EC2 deployment webhook
- [ ] Tested automatic deployment

---

## Troubleshooting Checklist

If something doesn't work, verify:

### SSH Connection Issues
- [ ] Key file has correct permissions
- [ ] EC2 is in "Running" state
- [ ] Security group allows SSH (port 22)
- [ ] Correct EC2 public IP address
- [ ] Try verbose mode: `ssh -v -i "..." ec2-user@ip`

### Frontend Not Loading
- [ ] EC2 has public IP assigned
- [ ] Security group allows HTTP (port 80)
- [ ] Files are in `/var/www/autograder-frontend/`
- [ ] Nginx is running: `sudo systemctl status nginx`
- [ ] Try from EC2: `curl http://localhost`

### Routes Return 404
- [ ] Nginx config has `try_files $uri /index.html;`
- [ ] Config syntax is valid: `sudo nginx -t`
- [ ] Nginx reloaded: `sudo systemctl reload nginx`

### Upload Failed
- [ ] dist folder exists: `ls dist`
- [ ] deploy-ec2.ps1 variables are correct
- [ ] SSH connection works
- [ ] Disk space available on EC2: `df -h`

---

## Support Resources

- **Full Guide**: `EC2_DEPLOYMENT.md`
- **Quick Start**: `EC2_QUICK_START.md`
- **AWS EC2 Docs**: https://docs.aws.amazon.com/ec2/
- **Nginx Docs**: https://nginx.org/en/docs/
- **React Router**: https://reactrouter.com/

---

## Notes

Use this space to record your specific information:

```
EC2 Instance ID: ________________
EC2 Public IP: __________________
Security Group Name: ____________
Key Pair Name: __________________
Key File Location: ______________
Domain Name (if applicable): _____
```

---

**Once all items are checked, your frontend is live and accessible from anywhere! 🚀**
