#!/bin/bash
# ============================================
# EC2 Instance Setup Script (Run on EC2)
# ============================================
# This script configures a fresh EC2 instance to serve your frontend
# Usage: curl -sSL https://your-script-url.sh | bash
# OR: bash setup-ec2.sh

set -e

echo "=================================="
echo "  EC2 Frontend Setup Script"
echo "=================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS${NC}"
    exit 1
fi

echo -e "\n${CYAN}Detected OS: $OS${NC}"

# Step 1: Update system
echo -e "\n${CYAN}[1/5] Updating system packages...${NC}"
if [ "$OS" = "amzn" ] || [ "$OS" = "amazonlinux" ]; then
    sudo yum update -y
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt-get update -y
    sudo apt-get upgrade -y
fi
echo -e "${GREEN}✓ System updated${NC}"

# Step 2: Install Node.js
echo -e "\n${CYAN}[2/5] Installing Node.js...${NC}"
if [ "$OS" = "amzn" ] || [ "$OS" = "amazonlinux" ]; then
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo yum install -y nodejs
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
    sudo apt-get install -y nodejs
fi
echo -e "${GREEN}✓ Node.js installed: $(node --version)${NC}"

# Step 3: Install Nginx
echo -e "\n${CYAN}[3/5] Installing Nginx...${NC}"
if [ "$OS" = "amzn" ] || [ "$OS" = "amazonlinux" ]; then
    sudo yum install -y nginx
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt-get install -y nginx
fi
echo -e "${GREEN}✓ Nginx installed${NC}"

# Step 4: Create deployment directory
echo -e "\n${CYAN}[4/5] Creating deployment directory...${NC}"
sudo mkdir -p /var/www/autograder-frontend
sudo chown -R $USER:$USER /var/www/autograder-frontend
sudo chmod -R 755 /var/www/autograder-frontend
echo -e "${GREEN}✓ Directory created: /var/www/autograder-frontend${NC}"

# Step 5: Configure Nginx
echo -e "\n${CYAN}[5/5] Configuring Nginx...${NC}"

# Create Nginx configuration
sudo tee /etc/nginx/conf.d/autograder-frontend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/autograder-frontend;
    index index.html;

    # Main app - React Router SPA
    location / {
        try_files $uri /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;
    gzip_comp_level 6;
    gzip_min_length 1000;
}
EOF

# Test Nginx configuration
sudo nginx -t
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration test failed${NC}"
    exit 1
fi

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo -e "${GREEN}✓ Nginx started and enabled${NC}"

# Print summary
echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ EC2 Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "\n${CYAN}📌 Next steps:${NC}"
echo -e "${YELLOW}1. Get your EC2 public IP from AWS Console${NC}"
echo -e "${YELLOW}2. Update deploy-ec2.ps1 with your EC2_IP${NC}"
echo -e "${YELLOW}3. Run from your local machine: .\\deploy-ec2.ps1${NC}"
echo -e "\n${CYAN}📌 Verify Nginx is running:${NC}"
echo -e "${YELLOW}curl http://localhost${NC}"
echo -e "\n${CYAN}📌 Check Nginx logs:${NC}"
echo -e "${YELLOW}sudo tail -f /var/log/nginx/access.log${NC}"
