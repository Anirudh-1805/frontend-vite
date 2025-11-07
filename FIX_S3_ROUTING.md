# Fix S3 Routing for React Router (404 Errors)

## Problem
When you navigate directly to routes like `/student/dashboard` or refresh the page, S3 returns 404 because it's looking for a physical file that doesn't exist. React Router needs `index.html` to be served for all routes.

## Solution: Configure S3 Error Document

### Option 1: Using AWS Console (Easiest)

1. Go to **AWS S3 Console**
2. Select your bucket: `autograder-frontend-1`
3. Go to **Properties** tab
4. Scroll down to **Static website hosting**
5. Click **Edit**
6. Set:
   - **Index document**: `index.html`
   - **Error document**: `index.html` ⬅️ **This is the key fix!**
7. Click **Save changes**

### Option 2: Using AWS CLI

```bash
aws s3 website s3://autograder-frontend-1 \
  --index-document index.html \
  --error-document index.html
```

### Option 3: Using AWS CLI (JSON Configuration)

Create a file `website-config.json`:
```json
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "index.html"
  }
}
```

Then apply:
```bash
aws s3api put-bucket-website \
  --bucket autograder-frontend-1 \
  --website-configuration file://website-config.json
```

## Verify Configuration

After setting the error document, test:
1. Go to: `http://autograder-frontend-1.s3-website-us-east-1.amazonaws.com/student/dashboard`
2. It should now load your React app instead of 404

## If Using CloudFront

If you're using CloudFront in front of S3, you also need to configure custom error pages:

1. Go to **CloudFront Console**
2. Select your distribution
3. Go to **Error pages** tab
4. Click **Create custom error response**
5. Configure:
   - **HTTP error code**: `403`
   - **Response page path**: `/index.html`
   - **HTTP response code**: `200`
6. Click **Create**
7. Repeat for `404` error code:
   - **HTTP error code**: `404`
   - **Response page path**: `/index.html`
   - **HTTP response code**: `200`

## Why This Works

- When S3 can't find a file (like `/student/dashboard`), it returns a 404
- By setting the error document to `index.html`, S3 serves your React app instead
- React Router then sees the URL `/student/dashboard` and renders the correct component
- User sees the correct page, not a 404 error

## Important Notes

1. **Use S3 Website URL**: Make sure you're using the S3 website endpoint:
   - ✅ `http://autograder-frontend-1.s3-website-us-east-1.amazonaws.com`
   - ❌ `http://autograder-frontend-1.s3.amazonaws.com` (REST API endpoint, won't work with error document)

2. **HTTPS**: S3 website endpoints only support HTTP. For HTTPS, use CloudFront.

3. **Cache Invalidation**: After making changes, you may need to invalidate CloudFront cache if using it.

## Quick Test

After configuration, test these URLs:
- `http://autograder-frontend-1.s3-website-us-east-1.amazonaws.com/` (should work)
- `http://autograder-frontend-1.s3-website-us-east-1.amazonaws.com/student/dashboard` (should now work!)
- `http://autograder-frontend-1.s3-website-us-east-1.amazonaws.com/instructor/dashboard` (should work)

All should load your React app and let React Router handle the routing.

