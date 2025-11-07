# Frontend Deployment Script for AWS S3 + CloudFront (PowerShell)
# Usage: .\deploy.ps1 [-BucketName "autograder-frontend"] [-DistributionId "E1234567890ABC"]

param(
    [string]$BucketName = "autograder-frontend-1",
    [string]$DistributionId = ""
)

Write-Host "🚀 Starting deployment process..." -ForegroundColor Cyan
Write-Host "📦 Bucket: $BucketName" -ForegroundColor Yellow

if ($DistributionId) {
    Write-Host "🌐 CloudFront Distribution: $DistributionId" -ForegroundColor Yellow
}

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "⚠️  Warning: .env.production not found." -ForegroundColor Yellow
    Write-Host "   Using default API URL (localhost:5000)" -ForegroundColor Yellow
    Write-Host "   Create .env.production with VITE_API_BASE_URL for production" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# Check if AWS CLI is installed
try {
    $null = Get-Command aws -ErrorAction Stop
} catch {
    Write-Host "❌ AWS CLI not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if bucket exists
$bucketCheck = aws s3 ls "s3://$BucketName" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Bucket does not exist: $BucketName" -ForegroundColor Red
    Write-Host "   Please create it first using the steps in DEPLOYMENT.md" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Bucket exists: $BucketName" -ForegroundColor Green
}

# Build the project
Write-Host ""
Write-Host "📦 Building production bundle..." -ForegroundColor Cyan
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Check if dist folder exists
if (-not (Test-Path "dist")) {
    Write-Host "❌ dist folder not found. Build may have failed." -ForegroundColor Red
    exit 1
}

# Upload to S3
Write-Host ""
Write-Host "📤 Uploading to S3..." -ForegroundColor Cyan
aws s3 sync dist/ "s3://$BucketName" --delete

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Upload failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Files uploaded successfully!" -ForegroundColor Green

# Invalidate CloudFront cache (if distribution ID provided)
if ($DistributionId) {
    Write-Host ""
    Write-Host "🔄 Invalidating CloudFront cache..." -ForegroundColor Cyan
    aws cloudfront create-invalidation --distribution-id $DistributionId --paths "/*"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CloudFront cache invalidation initiated" -ForegroundColor Green
        Write-Host "   Note: It may take 5-15 minutes for changes to propagate" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  CloudFront invalidation failed (but S3 upload succeeded)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your site should be available at:" -ForegroundColor Cyan

# Get AWS region
$region = aws configure get region
if (-not $region) {
    $region = "us-east-1"
}

Write-Host "   S3 Website: http://$BucketName.s3-website-$region.amazonaws.com" -ForegroundColor White

if ($DistributionId) {
    $distDomain = aws cloudfront get-distribution --id $DistributionId --query 'Distribution.DomainName' --output text 2>&1
    if ($distDomain -and -not $distDomain.Contains("error")) {
        $cloudfrontUrl = "   CloudFront: https://" + $distDomain
        Write-Host $cloudfrontUrl -ForegroundColor White
    }
}

