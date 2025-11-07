# PowerShell Script to Fix S3 Routing for React Router
# This configures S3 to serve index.html for all routes (404 errors)

param(
    [string]$BucketName = "autograder-frontend-1"
)

Write-Host "🔧 Fixing S3 Routing Configuration..." -ForegroundColor Cyan
Write-Host "📦 Bucket: $BucketName" -ForegroundColor Yellow

# Check if AWS CLI is installed
try {
    $null = Get-Command aws -ErrorAction Stop
} catch {
    Write-Host "❌ AWS CLI not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Create website configuration JSON
$websiteConfig = @{
    IndexDocument = @{
        Suffix = "index.html"
    }
    ErrorDocument = @{
        Key = "index.html"
    }
} | ConvertTo-Json

# Save to temp file
$tempFile = [System.IO.Path]::GetTempFileName()
$websiteConfig | Out-File -FilePath $tempFile -Encoding utf8

Write-Host ""
Write-Host "📝 Configuring S3 static website hosting..." -ForegroundColor Cyan

# Apply website configuration
aws s3api put-bucket-website --bucket $BucketName --website-configuration file://$tempFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ S3 routing configuration updated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Your site should now handle React Router routes:" -ForegroundColor Cyan
    Write-Host "   http://$BucketName.s3-website-us-east-1.amazonaws.com/student/dashboard" -ForegroundColor White
    Write-Host "   http://$BucketName.s3-website-us-east-1.amazonaws.com/instructor/dashboard" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Test the URLs above" -ForegroundColor White
    Write-Host "   2. If using CloudFront, configure custom error pages (403/404 → index.html)" -ForegroundColor White
} else {
    Write-Host "❌ Failed to update configuration" -ForegroundColor Red
    Write-Host "   Error code: $LASTEXITCODE" -ForegroundColor Red
}

# Clean up temp file
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

