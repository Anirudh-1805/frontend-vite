# ============================================
# EC2 Frontend Deployment Script (PowerShell)
# ============================================
# This script deploys your frontend to an EC2 instance via SCP

# Configuration - UPDATE THESE VALUES
$EC2_IP = "your-ec2-public-ip"           # Replace with your EC2 public IP
$EC2_USER = "ec2-user"                    # ec2-user for Amazon Linux, ubuntu for Ubuntu
$KEY_PATH = "C:\Users\rkkav\.ssh\your-key.pem"  # Path to your .pem key file
$REMOTE_DIR = "/var/www/autograder-frontend"

# Color codes for output
$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "$Green════════════════════════════════════════$Reset"
Write-Host "$Green  Frontend EC2 Deployment Script$Reset"
Write-Host "$Green════════════════════════════════════════$Reset"

# Check if key file exists
if (-not (Test-Path $KEY_PATH)) {
    Write-Host "$Red✗ Error: Key file not found at $KEY_PATH$Reset"
    Write-Host "$Yellow Please update the KEY_PATH variable in this script$Reset"
    exit 1
}

# Step 1: Build frontend
Write-Host "`n$Cyan[1/4] Building frontend...$Reset"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "$Red✗ Build failed$Reset"
    exit 1
}
Write-Host "$Green✓ Build successful$Reset"

# Step 2: Test SSH connection
Write-Host "`n$Cyan[2/4] Testing SSH connection...$Reset"
$sshTest = ssh -i $KEY_PATH -o ConnectTimeout=5 "${EC2_USER}@${EC2_IP}" "echo 'Connected'" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "$Red✗ Cannot connect to EC2 instance$Reset"
    Write-Host "$Yellow Make sure to update EC2_IP to your actual public IP$Reset"
    exit 1
}
Write-Host "$Green✓ SSH connection successful$Reset"

# Step 3: Upload dist folder to EC2
Write-Host "`n$Cyan[3/4] Uploading files to EC2...$Reset"
scp -i $KEY_PATH -r ".\dist\*" "${EC2_USER}@${EC2_IP}:${REMOTE_DIR}/"
if ($LASTEXITCODE -ne 0) {
    Write-Host "$Red✗ Upload failed$Reset"
    exit 1
}
Write-Host "$Green✓ Files uploaded successfully$Reset"

# Step 4: Reload Nginx
Write-Host "`n$Cyan[4/4] Reloading Nginx on EC2...$Reset"
ssh -i $KEY_PATH "${EC2_USER}@${EC2_IP}" "sudo systemctl reload nginx"
if ($LASTEXITCODE -ne 0) {
    Write-Host "$Red✗ Nginx reload failed$Reset"
    exit 1
}
Write-Host "$Green✓ Nginx reloaded successfully$Reset"

# Success
Write-Host "`n$Green════════════════════════════════════════$Reset"
Write-Host "$Green✓ Deployment Complete!$Reset"
Write-Host "$Green════════════════════════════════════════$Reset"
Write-Host "`n$Cyan📌 Access your app at:$Reset"
Write-Host "$Yellow  http://${EC2_IP}$Reset"
Write-Host "`n$Cyan📌 Common routes:$Reset"
Write-Host "$Yellow  http://${EC2_IP}/login$Reset"
Write-Host "$Yellow  http://${EC2_IP}/student/dashboard$Reset"
Write-Host "$Yellow  http://${EC2_IP}/instructor/dashboard$Reset"
