# Frontend-Backend Connection Setup

## ✅ Configuration Complete

### Backend URL
- **Production Backend**: `https://leisa-hiplike-willodean.ngrok-free.dev`
- **Note**: This is an ngrok URL. If it changes, update `.env.production`

### Files Updated

1. **`.env.production`** - Created with backend URL
   ```
   VITE_API_BASE_URL=https://leisa-hiplike-willodean.ngrok-free.dev
   ```

2. **`app.py`** - Updated CORS configuration
   - Now explicitly allows all origins (good for ngrok which changes URLs)
   - Supports credentials for JWT tokens

3. **`src/services/api.js`** - Already configured to use environment variable
   - Will use `VITE_API_BASE_URL` from `.env.production` when building

## 🚀 Next Steps

### 1. Rebuild Frontend
Since you've updated `.env.production`, rebuild the frontend:

```powershell
cd frontend-vite
npm run build
```

### 2. Deploy to S3
```powershell
.\deploy.ps1 -BucketName "autograder-frontend-1"
```

### 3. Test Connection
1. Open your deployed frontend
2. Open browser DevTools (F12) → Network tab
3. Try logging in or making an API call
4. Verify requests are going to: `https://leisa-hiplike-willodean.ngrok-free.dev/api/...`

## 🔧 Troubleshooting

### Issue: CORS errors
- **Solution**: Backend CORS is already configured to allow all origins
- If you still see CORS errors, check that your backend is running and accessible

### Issue: ngrok warning page
- **Solution**: ngrok free tier shows a warning page on first visit
- Click "Visit Site" to proceed
- Consider upgrading to ngrok paid tier to remove warning

### Issue: API calls failing
- Check browser console for errors
- Verify backend URL is correct in `.env.production`
- Ensure backend is running and accessible
- Check Network tab to see actual request URLs

### Issue: 401/403 errors
- Verify JWT tokens are being sent (check Authorization header in Network tab)
- Check that Cognito configuration is correct
- Verify backend JWT_SECRET_KEY is set

## 📝 Important Notes

1. **ngrok URLs are temporary** - If your ngrok URL changes, update `.env.production` and rebuild
2. **Environment variables** - Only variables starting with `VITE_` are exposed to the frontend
3. **CORS** - Backend is configured to allow all origins (good for development/testing)
4. **HTTPS** - ngrok provides HTTPS automatically, which is required for production

## 🔄 Updating Backend URL

If your backend URL changes:

1. Update `.env.production`:
   ```
   VITE_API_BASE_URL=https://your-new-backend-url.com
   ```

2. Rebuild:
   ```powershell
   npm run build
   ```

3. Redeploy:
   ```powershell
   .\deploy.ps1
   ```

