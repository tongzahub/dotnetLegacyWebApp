# AWS EC2 Deployment Guide for Legacy ASP.NET Web Application

## Prerequisites
- AWS Account with EC2 permissions
- AWS CLI configured (optional)
- RDP client for Windows connection

## Step 1: Launch EC2 Windows Server 2024 Instance

### 1.1 Create EC2 Instance
```bash
# Using AWS CLI (optional)
aws ec2 run-instances \
  --image-id ami-0c2b0d3fb02824d92 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=LegacyWebApp-Server}]'
```

### 1.2 Via AWS Console
1. Go to AWS Console → EC2 → Launch Instance
2. **Name**: `LegacyWebApp-Server`
3. **AMI**: Windows Server 2024 Base
4. **Instance Type**: t3.medium (minimum recommended)
5. **Key Pair**: Create new or select existing
6. **Security Group**: Configure as shown below

### 1.3 Security Group Configuration
```
Inbound Rules:
- Type: RDP, Protocol: TCP, Port: 3389, Source: Your IP
- Type: HTTP, Protocol: TCP, Port: 80, Source: 0.0.0.0/0
- Type: HTTPS, Protocol: TCP, Port: 443, Source: 0.0.0.0/0
- Type: Custom TCP, Protocol: TCP, Port: 8080, Source: 0.0.0.0/0 (for testing)

Outbound Rules:
- All traffic (default)
```

## Step 2: Connect to EC2 Instance

### 2.1 Get Windows Password
1. Select your instance in EC2 console
2. Click "Connect" → "RDP client" tab
3. Click "Get password"
4. Upload your private key file
5. Click "Decrypt password"

### 2.2 RDP Connection
- **Computer**: Use Public IPv4 address from EC2 console
- **Username**: `Administrator`
- **Password**: Decrypted password from step 2.1

## Step 3: Configure Windows Server 2024

### 3.1 Install .NET Framework 3.5
```powershell
# Run as Administrator in PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All
```

### 3.2 Install IIS and ASP.NET
```powershell
# Install IIS with ASP.NET support
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-HttpLogging, IIS-RequestFiltering, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-ASPNET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ASPNET45
```

### 3.3 Verify Installation
```powershell
# Check if IIS is running
Get-Service W3SVC
# Check .NET Framework versions
Get-ChildItem 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Select PSChildName, version
```

## Step 4: Deploy Application Files

### 4.1 Create Application Directory
```powershell
# Create application directory
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\LegacyWebApp" -Force
```

### 4.2 Upload Application Files
**Method 1: Copy via RDP**
1. Copy all application files to local machine
2. Use RDP clipboard sharing to transfer files
3. Paste into `C:\inetpub\wwwroot\LegacyWebApp`

**Method 2: Use AWS S3**
```powershell
# Install AWS PowerShell module
Install-Module -Name AWS.Tools.S3 -Force

# Upload files to S3 bucket (from local machine)
# aws s3 cp . s3://your-bucket/legacywebapp/ --recursive

# Download files on EC2 instance
Read-S3Object -BucketName "your-bucket" -KeyPrefix "legacywebapp/" -Folder "C:\inetpub\wwwroot\LegacyWebApp"
```

### 4.3 Set Folder Permissions
```powershell
# Set permissions for IIS_IUSRS
$acl = Get-Acl "C:\inetpub\wwwroot\LegacyWebApp"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
$acl | Set-Acl "C:\inetpub\wwwroot\LegacyWebApp"
```

## Step 5: Configure IIS Application

### 5.1 Create Application in IIS Manager
```powershell
# Import WebAdministration module
Import-Module WebAdministration

# Create new application
New-WebApplication -Name "LegacyWebApp" -Site "Default Web Site" -PhysicalPath "C:\inetpub\wwwroot\LegacyWebApp"

# Set application pool to .NET Framework v2.0 (for .NET 3.5 compatibility)
Set-ItemProperty -Path "IIS:\Sites\Default Web Site\LegacyWebApp" -Name applicationPool -Value "DefaultAppPool"
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name processModel.identityType -Value ApplicationPoolIdentity
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name managedRuntimeVersion -Value "v2.0"
```

### 5.2 Configure Application Pool
```powershell
# Configure application pool settings
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name recycling.periodicRestart.time -Value "00:00:00"
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name processModel.maxProcesses -Value 1
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name processModel.idleTimeout -Value "00:20:00"
```

## Step 6: Test Deployment

### 6.1 Browse Application
1. Open Internet Explorer on the server
2. Navigate to `http://localhost/LegacyWebApp`
3. Test all pages: Default.aspx, DataGrid.aspx, UserForm.aspx, About.aspx

### 6.2 External Access Test
From your local machine:
- Navigate to `http://[EC2-Public-IP]/LegacyWebApp`
- Test form submissions and functionality

## Step 7: Production Configuration

### 7.1 Update web.config for Production
```xml
<system.web>
  <compilation debug="false" targetFramework="3.5" />
  <customErrors mode="On" defaultRedirect="~/Error.aspx" />
  <httpRuntime maxRequestLength="4096" requestValidationMode="2.0" />
</system.web>
```

### 7.2 Enable HTTPS (Optional)
```powershell
# Create self-signed certificate for testing
New-SelfSignedCertificate -DnsName "your-domain.com" -CertStoreLocation "cert:\LocalMachine\My"

# Or use AWS Certificate Manager for production
# Configure SSL binding in IIS Manager
```

## Step 8: Monitoring and Maintenance

### 8.1 Enable IIS Logging
```powershell
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name dontLog -Value $false -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 8.2 Set up Windows Event Logging
```powershell
# Check application event logs
Get-EventLog -LogName Application -Source "ASP.NET*" -Newest 10
```

### 8.3 Performance Monitoring
- Use Windows Performance Monitor
- Monitor CPU, Memory, and Disk usage
- Set up CloudWatch monitoring via AWS Systems Manager

## Troubleshooting Common Issues

### Issue 1: .NET Framework 3.5 not available
```powershell
# Alternative installation method
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:D:\sources\sxs
```

### Issue 2: Application Pool crashes
```powershell
# Check event logs
Get-EventLog -LogName System -Source "Microsoft-Windows-WAS" -Newest 5
# Restart application pool
Restart-WebAppPool -Name "DefaultAppPool"
```

### Issue 3: Permission denied errors
```powershell
# Reset IIS permissions
& "$env:windir\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe" -i
```

## Security Considerations

### 8.1 Windows Updates
```powershell
# Enable automatic updates
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot
```

### 8.2 Firewall Configuration
```powershell
# Configure Windows Firewall
New-NetFirewallRule -DisplayName "HTTP Inbound" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName "HTTPS Inbound" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
```

### 8.3 Regular Backups
- Set up EBS snapshots for the EC2 instance
- Configure S3 backup for application files and data
- Document restore procedures

## Cost Optimization

### 9.1 Instance Sizing
- Start with t3.medium
- Monitor usage and downsize to t3.small if appropriate
- Use Reserved Instances for long-term deployments

### 9.2 Scheduled Start/Stop
```bash
# Create Lambda function to start/stop instance on schedule
# Useful for development environments
```

## Next Steps
1. Configure custom domain with Route 53
2. Set up Application Load Balancer for high availability
3. Implement database connectivity (RDS SQL Server)
4. Set up backup and disaster recovery procedures
5. Configure monitoring and alerting with CloudWatch