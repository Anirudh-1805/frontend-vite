# Production Deployment Checklist

## ✅ Frontend Configuration

### 1. Environment Variables
- [x] `.env.production` created with `VITE_API_BASE_URL` set to your backend URL
- [ ] Verify the URL is correct (should be HTTPS in production)
- [ ] Ensure no trailing slash in the URL (e.g., `https://api.example.com` not `https://api.example.com/`)

### 2. Cognito Configuration
- [ ] Verify Cognito User Pool ID and Client ID in `src/cognitoConfig.js` are correct for production
- [ ] If using different Cognito pools for dev/prod, consider making this configurable via environment variables

### 3. Build and Deploy
- [ ] Run `npm run build` to create production bundle
- [ ] Deploy to S3 using `.\deploy.ps1` or manual upload
- [ ] Test the deployed site

---

## ✅ Backend Configuration

### 1. CORS Settings (CRITICAL)
Your backend currently has `CORS(app)` which allows all origins. For production, you should restrict this:

**Current (app.py line 38):**
```python
CORS(app)  # Allows all domains
```

**Recommended for Production:**
```python
from flask_cors import CORS

# Get frontend URL from environment variable
FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:3000')

CORS(app, origins=[FRONTEND_URL], supports_credentials=True)
```

**Or if using CloudFront:**
```python
FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:3000')
CLOUDFRONT_URL = os.getenv('CLOUDFRONT_URL', '')

allowed_origins = [FRONTEND_URL]
if CLOUDFRONT_URL:
    allowed_origins.append(CLOUDFRONT_URL)

CORS(app, origins=allowed_origins, supports_credentials=True)
```

### 2. Environment Variables on Backend
Ensure these are set in your backend deployment (Elastic Beanstalk, EC2, etc.):

- [ ] `DATABASE_URL` - Your production database connection string
- [ ] `JWT_SECRET_KEY` - Strong secret key (not the default!)
- [ ] `COGNITO_USER_POOL_ID` - Should match frontend config
- [ ] `COGNITO_APP_CLIENT_ID` - Should match frontend config
- [ ] `COGNITO_REGION` - AWS region for Cognito
- [ ] `FRONTEND_URL` - Your frontend URL (for CORS)
- [ ] `AWS_ACCESS_KEY_ID` - For S3 access
- [ ] `AWS_SECRET_ACCESS_KEY` - For S3 access
- [ ] `AWS_DEFAULT_REGION` - AWS region

### 3. Security Settings
- [ ] Ensure `JWT_SECRET_KEY` is a strong, random secret (not "change-this-in-prod")
- [ ] Verify database credentials are secure
- [ ] Check that S3 bucket permissions are correct
- [ ] Ensure HTTPS is enabled on backend (if using load balancer/API Gateway)

### 4. Evaluation Service
- [ ] Verify `EVAL_SERVICE_URL` environment variable is set (or hardcoded in `beforeECS/app_ECS.py`)
- [ ] Test that the evaluation service at `http://54.84.174.169:5000/evaluate` is accessible from your backend
- [ ] Consider moving this to an environment variable for easier management

---

## ✅ Testing Checklist

### 1. Frontend Tests
- [ ] Open deployed frontend URL
- [ ] Test login with Cognito
- [ ] Verify API calls are going to correct backend URL (check browser Network tab)
- [ ] Test student submission flow
- [ ] Test instructor question creation
- [ ] Verify test run functionality works

### 2. Backend Tests
- [ ] Test `/api/login` endpoint
- [ ] Test protected routes with JWT token
- [ ] Test file upload to S3
- [ ] Test code evaluation service connection
- [ ] Check CORS headers in response (should include your frontend domain)

### 3. Integration Tests
- [ ] Full student submission flow: upload → evaluate → get results
- [ ] Instructor evaluation flow: evaluate question → get plagiarism results
- [ ] Verify S3 file uploads are working
- [ ] Check database operations are working

---

## ✅ AWS Configuration

### 1. S3 Bucket
- [ ] Bucket is configured for static website hosting
- [ ] Error document is set to `index.html` (for React Router)
- [ ] Bucket policy allows public read access
- [ ] CORS configuration (if needed for direct S3 access)

### 2. CloudFront (if using)
- [ ] Distribution is created and deployed
- [ ] Custom error pages configured (403/404 → index.html)
- [ ] HTTPS is enabled
- [ ] Cache invalidation works

### 3. Cognito
- [ ] User Pool is configured correctly
- [ ] App Client settings are correct
- [ ] User groups (Instructor/Student) are set up
- [ ] Test users can log in

### 4. Backend Hosting
- [ ] Backend is accessible via HTTPS
- [ ] Environment variables are set correctly
- [ ] Database is accessible from backend
- [ ] S3 access is configured (IAM role or credentials)

---

## 🔧 Quick Fixes Needed

### 1. Make Cognito Config Environment-Based (Optional but Recommended)

**File: `frontend-vite/src/cognitoConfig.js`**
```javascript
const poolData = {
  UserPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID || 'us-east-1_PsdG9pvLq',
  ClientId: import.meta.env.VITE_COGNITO_APP_CLIENT_ID || '6pg5hfcs2gnnr6p7ik7pgoli5q'
};
```

Then add to `.env.production`:
```
VITE_COGNITO_USER_POOL_ID=us-east-1_PsdG9pvLq
VITE_COGNITO_APP_CLIENT_ID=6pg5hfcs2gnnr6p7ik7pgoli5q
```

### 2. Update CORS in Backend (Recommended)

Update `app.py` line 38 to restrict CORS to your frontend domain.

### 3. Move Evaluation Service URL to Environment Variable

**File: `beforeECS/app_ECS.py`**
Already done! It uses `EVAL_SERVICE_URL` environment variable.

Make sure to set this in your backend environment:
```bash
EVAL_SERVICE_URL=http://54.84.174.169:5000/evaluate
```

---

## 🚨 Common Issues

### Issue: CORS errors in browser console
**Solution:** Update backend CORS configuration to include your frontend URL

### Issue: Blank page after deployment
**Solution:** 
- Check S3 error document is set to `index.html`
- If using CloudFront, configure custom error pages
- Check browser console for errors

### Issue: API calls failing
**Solution:**
- Verify `VITE_API_BASE_URL` in `.env.production` is correct
- Check backend is accessible and CORS is configured
- Verify JWT tokens are being sent correctly

### Issue: Cognito login not working
**Solution:**
- Verify Cognito User Pool ID and Client ID are correct
- Check Cognito App Client settings (callback URLs, sign-out URLs)
- Ensure Cognito region matches

---

## 📝 Notes

- Always test in a staging environment first before production
- Keep environment variables secure (never commit `.env.production` to git)
- Monitor CloudWatch logs for backend errors
- Set up alerts for critical failures
- Consider using AWS Secrets Manager for sensitive credentials

