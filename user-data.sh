#!/bin/bash
set -e

echo "Starting EC2 setup..."

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
sudo tee /etc/nginx/conf.d/autograder-frontend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/autograder-frontend;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;
    gzip_comp_level 6;
    gzip_min_length 1000;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF

# Validate and start Nginx
sudo nginx -t
sudo systemctl start nginx
sudo systemctl enable nginx

echo "EC2 setup complete!"
