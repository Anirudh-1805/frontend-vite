#!/bin/bash

# Frontend Deployment Script for AWS S3 + CloudFront
# Usage: ./deploy.sh [bucket-name] [distribution-id]

# Configuration
BUCKET_NAME="${1:-autograder-frontend}"
DISTRIBUTION_ID="${2:-}"

echo "🚀 Starting deployment process..."
echo "📦 Bucket: $BUCKET_NAME"
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo "🌐 CloudFront Distribution: $DISTRIBUTION_ID"
fi

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "⚠️  Warning: .env.production not found."
    echo "   Using default API URL (localhost:5000)"
    echo "   Create .env.production with VITE_API_BASE_URL for production"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Check if bucket exists
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "✅ Bucket exists: $BUCKET_NAME"
else
    echo "❌ Bucket does not exist: $BUCKET_NAME"
    echo "   Please create it first using the steps in DEPLOYMENT.md"
    exit 1
fi

# Build the project
echo ""
echo "📦 Building production bundle..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Check if dist folder exists
if [ ! -d "dist" ]; then
    echo "❌ dist folder not found. Build may have failed."
    exit 1
fi

# Upload to S3
echo ""
echo "📤 Uploading to S3..."
aws s3 sync dist/ "s3://$BUCKET_NAME" --delete

if [ $? -ne 0 ]; then
    echo "❌ Upload failed!"
    exit 1
fi

echo "✅ Files uploaded successfully!"

# Invalidate CloudFront cache (if distribution ID provided)
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo ""
    echo "🔄 Invalidating CloudFront cache..."
    aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"
    
    if [ $? -eq 0 ]; then
        echo "✅ CloudFront cache invalidation initiated"
        echo "   Note: It may take 5-15 minutes for changes to propagate"
    else
        echo "⚠️  CloudFront invalidation failed (but S3 upload succeeded)"
    fi
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your site should be available at:"
echo "   S3 Website: http://$BUCKET_NAME.s3-website-$(aws configure get region).amazonaws.com"
if [ ! -z "$DISTRIBUTION_ID" ]; then
    DIST_DOMAIN=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query 'Distribution.DomainName' --output text 2>/dev/null)
    if [ ! -z "$DIST_DOMAIN" ]; then
        echo "   CloudFront: https://$DIST_DOMAIN"
    fi
fi

