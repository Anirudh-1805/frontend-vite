# Quick Start - Deploy Frontend to AWS

## Prerequisites Checklist
- [ ] AWS account created
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS CLI configured (`aws configure`)
- [ ] Backend API URL ready (where your Flask app is hosted)

## Quick Deployment Steps

### 1. Set Your Production API URL

Create `.env.production` file in `frontend-vite` directory:

```bash
VITE_API_BASE_URL=https://your-backend-api-url.com
```

**Example:**
```
VITE_API_BASE_URL=https://api.autograder.com
```

### 2. Create S3 Bucket (One-time setup)

**Using AWS Console:**
1. Go to S3 → Create bucket
2. Name: `autograder-frontend` (must be unique)
3. Uncheck "Block all public access"
4. Enable static website hosting:
   - Index document: `index.html`
   - Error document: `index.html`
5. Add bucket policy (see DEPLOYMENT.md Step 5)

**Using AWS CLI:**
```bash
aws s3 mb s3://autograder-frontend --region us-east-1
```

### 3. Build and Deploy

**Windows (PowerShell):**
```powershell
cd frontend-vite
npm install
npm run build
.\deploy.ps1
```

**Linux/Mac:**
```bash
cd frontend-vite
npm install
npm run build
chmod +x deploy.sh
./deploy.sh
```

### 4. Access Your Site

After deployment, your site will be available at:
- **S3 Website URL**: `http://autograder-frontend.s3-website-us-east-1.amazonaws.com`
- **CloudFront URL** (if configured): `https://d1234567890abc.cloudfront.net`

## Optional: Set Up CloudFront (Recommended)

CloudFront provides HTTPS and better performance:

1. Go to CloudFront → Create distribution
2. Origin: Your S3 bucket
3. Viewer protocol: Redirect HTTP to HTTPS
4. Default root object: `index.html`
5. Create custom error responses:
   - 403 → `/index.html` (200)
   - 404 → `/index.html` (200)

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Backend API URL | `https://api.example.com` |

**Important:** All environment variables must start with `VITE_` to be accessible in the app.

## Troubleshooting

**Blank page?**
- Check browser console for errors
- Verify API URL in `.env.production`
- Ensure S3 error document is set to `index.html`

**API calls failing?**
- Check CORS settings on backend
- Verify `VITE_API_BASE_URL` is correct
- Check browser network tab for errors

**React Router not working?**
- Configure CloudFront custom error pages (403/404 → index.html)

## Next Steps

See `DEPLOYMENT.md` for detailed instructions and advanced configuration.

