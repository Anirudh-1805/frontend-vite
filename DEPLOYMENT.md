# Frontend Deployment Guide - AWS S3 + CloudFront

This guide walks you through deploying your Vite React frontend to AWS using S3 for static hosting and CloudFront for CDN and HTTPS.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured (`aws configure`)
3. **Node.js** and npm installed
4. **Your backend API URL** (where your Flask app will be hosted)

## Step 1: Prepare Environment Variables

Before building, you need to set your production API URL.

### Option A: Create `.env.production` file (Recommended)

Create a file named `.env.production` in the `frontend-vite` directory:

```bash
VITE_API_BASE_URL=https://your-backend-api-url.com
```

**Note:** Replace `https://your-backend-api-url.com` with your actual backend API URL (e.g., your Flask app URL on Elastic Beanstalk, EC2, or API Gateway).

### Option B: Set environment variable during build

```bash
VITE_API_BASE_URL=https://your-backend-api-url.com npm run build
```

## Step 2: Build the Production Bundle

Navigate to the frontend-vite directory and build:

```bash
cd frontend-vite
npm install
npm run build
```

This creates a `dist` folder with optimized production files.

## Step 3: Create S3 Bucket

### Using AWS Console:

1. Go to **S3** in AWS Console
2. Click **Create bucket**
3. Configure:
   - **Bucket name**: `autograder-frontend` (must be globally unique)
   - **Region**: Choose your preferred region (e.g., `us-east-1`)
   - **Block Public Access**: **Uncheck** "Block all public access" (we need public read access)
   - **Bucket Versioning**: Optional (enable if you want versioning)
   - **Default encryption**: Enable (recommended)
4. Click **Create bucket**

### Using AWS CLI:

```bash
aws s3 mb s3://autograder-frontend --region us-east-1
aws s3api put-public-access-block \
  --bucket autograder-frontend \
  --public-access-block-configuration \
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

## Step 4: Configure S3 Bucket for Static Website Hosting

### Using AWS Console:

1. Select your bucket → **Properties** tab
2. Scroll to **Static website hosting**
3. Click **Edit**
4. Enable static website hosting:
   - **Hosting type**: Static website hosting
   - **Index document**: `index.html`
   - **Error document**: `index.html` (for React Router to work)
5. Click **Save changes**

### Using AWS CLI:

```bash
aws s3 website s3://autograder-frontend \
  --index-document index.html \
  --error-document index.html
```

## Step 5: Set Bucket Policy for Public Read Access

### Using AWS Console:

1. Select your bucket → **Permissions** tab
2. Scroll to **Bucket policy**
3. Click **Edit** and paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::autograder-frontend/*"
    }
  ]
}
```

**Important:** Replace `autograder-frontend` with your actual bucket name.

4. Click **Save changes**

### Using AWS CLI:

Create a file `bucket-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::autograder-frontend/*"
    }
  ]
}
```

Then apply:

```bash
aws s3api put-bucket-policy --bucket autograder-frontend --policy file://bucket-policy.json
```

## Step 6: Upload Files to S3

### Using AWS Console:

1. Select your bucket
2. Click **Upload**
3. Select all files from the `dist` folder
4. Click **Upload**

### Using AWS CLI (Recommended):

```bash
cd frontend-vite
aws s3 sync dist/ s3://autograder-frontend --delete
```

The `--delete` flag removes files in S3 that don't exist in your local `dist` folder.

## Step 7: Create CloudFront Distribution (Optional but Recommended)

CloudFront provides:
- HTTPS/SSL certificate
- Global CDN for faster loading
- Custom domain support
- Better caching

### Using AWS Console:

1. Go to **CloudFront** in AWS Console
2. Click **Create distribution**
3. Configure:
   - **Origin domain**: Select your S3 bucket (e.g., `autograder-frontend.s3.us-east-1.amazonaws.com`)
   - **Origin access**: Select "Public" (or use OAC for better security)
   - **Viewer protocol policy**: Redirect HTTP to HTTPS
   - **Allowed HTTP methods**: GET, HEAD, OPTIONS
   - **Cache policy**: CachingOptimized (or create custom)
   - **Default root object**: `index.html`
   - **Price class**: Choose based on your needs
4. Click **Create distribution**
5. Wait for distribution to deploy (15-20 minutes)

### Custom Error Pages (Important for React Router):

1. Go to your CloudFront distribution → **Error pages** tab
2. Click **Create custom error response**
3. Configure:
   - **HTTP error code**: `403`
   - **Response page path**: `/index.html`
   - **HTTP response code**: `200`
4. Repeat for `404` error code

This ensures React Router works correctly with direct URL access.

## Step 8: Update CORS Configuration (If Needed)

If your backend API is on a different domain, ensure CORS is configured on your Flask backend to allow requests from your frontend domain.

## Step 9: Test Your Deployment

1. **S3 Website URL**: `http://autograder-frontend.s3-website-us-east-1.amazonaws.com`
2. **CloudFront URL**: `https://d1234567890abc.cloudfront.net` (your distribution domain)

Open the URL in a browser and test:
- Login functionality
- API calls
- Navigation

## Step 10: Set Up Custom Domain (Optional)

1. In CloudFront distribution → **General** tab → Click **Edit**
2. Under **Alternate domain names (CNAMEs)**, add your domain
3. Request or import an SSL certificate in **AWS Certificate Manager (ACM)**
4. Select the certificate in CloudFront
5. Update your DNS to point to CloudFront distribution

## Automated Deployment Script

Create a file `deploy.sh` in the `frontend-vite` directory:

```bash
#!/bin/bash

# Configuration
BUCKET_NAME="autograder-frontend"
DISTRIBUTION_ID="your-cloudfront-distribution-id"  # Optional, only if using CloudFront

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "Warning: .env.production not found. Using default API URL."
fi

# Build the project
echo "Building production bundle..."
npm run build

# Upload to S3
echo "Uploading to S3..."
aws s3 sync dist/ s3://$BUCKET_NAME --delete

# Invalidate CloudFront cache (if using CloudFront)
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo "Invalidating CloudFront cache..."
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
fi

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x deploy.sh
```

Run:
```bash
./deploy.sh
```

## Troubleshooting

### Issue: Blank page after deployment
- **Solution**: Ensure error document is set to `index.html` in S3 and CloudFront
- Check browser console for errors
- Verify API URL is correct

### Issue: API calls failing (CORS errors)
- **Solution**: Update Flask backend CORS configuration to allow your frontend domain

### Issue: React Router routes not working
- **Solution**: Configure custom error pages in CloudFront (Step 7)

### Issue: Environment variables not working
- **Solution**: Ensure variables start with `VITE_` prefix
- Rebuild after changing `.env.production`

## Cost Estimation

- **S3**: ~$0.023 per GB stored + $0.005 per 1,000 requests
- **CloudFront**: ~$0.085 per GB data transfer (first 10 TB)
- **Total**: Very low cost for typical usage (< $5/month for small to medium traffic)

## Next Steps

1. Set up CI/CD pipeline (GitHub Actions, AWS CodePipeline)
2. Configure monitoring and alerts
3. Set up custom domain with SSL
4. Enable CloudFront logging for analytics

