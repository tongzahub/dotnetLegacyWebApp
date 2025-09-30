# IIS Configuration Guide for Legacy ASP.NET Web Application

## Overview
This guide provides detailed instructions for configuring Internet Information Services (IIS) on Windows Server 2024 to host a legacy ASP.NET Web Forms application targeting .NET Framework 3.5.

## Prerequisites
- Windows Server 2024
- Administrator privileges
- .NET Framework 3.5 installed

## Step 1: Install IIS Role and Features

### 1.1 Using Server Manager (GUI Method)
1. Open **Server Manager**
2. Click **Add roles and features**
3. Select **Role-based or feature-based installation**
4. Select your server
5. Check **Web Server (IIS)**
6. Click **Add Features** when prompted
7. Under **Role Services**, expand **Web Server** → **Application Development**
8. Select the following features:
   - ✅ .NET Extensibility 3.5
   - ✅ .NET Extensibility 4.8
   - ✅ ASP.NET 3.5
   - ✅ ASP.NET 4.8
   - ✅ ISAPI Extensions
   - ✅ ISAPI Filters
9. Under **Common HTTP Features**, select:
   - ✅ Default Document
   - ✅ Directory Browsing
   - ✅ HTTP Errors
   - ✅ HTTP Redirection
   - ✅ Static Content
10. Under **Management Tools**, select:
    - ✅ IIS Management Console
11. Complete the installation

### 1.2 Using PowerShell (Command Line Method)
```powershell
# Install IIS with required features
$features = @(
    "IIS-WebServerRole",
    "IIS-WebServer",
    "IIS-CommonHttpFeatures",
    "IIS-HttpErrors",
    "IIS-HttpLogging", 
    "IIS-RequestFiltering",
    "IIS-StaticContent",
    "IIS-DefaultDocument",
    "IIS-DirectoryBrowsing",
    "IIS-ASPNET",
    "IIS-NetFxExtensibility",
    "IIS-ISAPIExtensions",
    "IIS-ISAPIFilter",
    "IIS-HttpCompressionStatic",
    "IIS-ManagementConsole"
)

foreach ($feature in $features) {
    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All
}
```

## Step 2: Verify IIS Installation

### 2.1 Check IIS Service
```powershell
# Check if IIS service is running
Get-Service W3SVC

# Start IIS if not running
Start-Service W3SVC
```

### 2.2 Test Default Website
1. Open web browser
2. Navigate to `http://localhost`
3. You should see the default IIS welcome page

## Step 3: Configure Application Pool

### 3.1 Create New Application Pool (Recommended)
```powershell
# Import IIS module
Import-Module WebAdministration

# Create new application pool
New-WebAppPool -Name "LegacyWebAppPool"

# Configure application pool settings
Set-ItemProperty -Path "IIS:\AppPools\LegacyWebAppPool" -Name processModel.identityType -Value ApplicationPoolIdentity
Set-ItemProperty -Path "IIS:\AppPools\LegacyWebAppPool" -Name managedRuntimeVersion -Value "v2.0"
Set-ItemProperty -Path "IIS:\AppPools\LegacyWebAppPool" -Name enable32BitAppOnWin64 -Value $false
```

### 3.2 Application Pool Advanced Settings

| Setting | Value | Description |
|---------|-------|-------------|
| .NET Framework Version | v2.0 | Required for .NET Framework 3.5 |
| Managed Pipeline Mode | Integrated | Recommended for better performance |
| Identity | ApplicationPoolIdentity | Most secure option |
| Idle Time-out | 00:20:00 | 20 minutes before shutdown |
| Maximum Worker Processes | 1 | Single process for legacy apps |
| Enable 32-Bit Applications | False | Use 64-bit on x64 systems |

### 3.3 Configure Using IIS Manager
1. Open **IIS Manager**
2. Expand server node in left panel
3. Click **Application Pools**
4. Right-click **DefaultAppPool** (or create new)
5. Select **Advanced Settings**
6. Configure settings as shown in table above

## Step 4: Create Web Application

### 4.1 Using PowerShell
```powershell
# Create application directory
$appPath = "C:\inetpub\wwwroot\LegacyWebApp"
New-Item -ItemType Directory -Path $appPath -Force

# Create web application
New-WebApplication -Name "LegacyWebApp" -Site "Default Web Site" -PhysicalPath $appPath -ApplicationPool "LegacyWebAppPool"
```

### 4.2 Using IIS Manager
1. Open **IIS Manager**
2. Expand **Sites** → **Default Web Site**
3. Right-click **Default Web Site**
4. Select **Add Application**
5. Fill in the details:
   - **Alias**: `LegacyWebApp`
   - **Application pool**: `LegacyWebAppPool`
   - **Physical path**: `C:\inetpub\wwwroot\LegacyWebApp`
6. Click **OK**

## Step 5: Configure Authentication

### 5.1 Anonymous Authentication (Default)
```powershell
# Enable anonymous authentication
Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name enabled -Value $true -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 5.2 Forms Authentication (if using)
```powershell
# Configure forms authentication
Set-WebConfigurationProperty -Filter "/system.web/authentication" -Name mode -Value "Forms" -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 6: Configure Default Document

### 6.1 Set Default Documents
```powershell
# Clear existing default documents
Clear-WebConfiguration -Filter "/system.webServer/defaultDocument/files" -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

# Add Default.aspx as default document
Add-WebConfiguration -Filter "/system.webServer/defaultDocument/files" -Value @{value="Default.aspx"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 6.2 Using IIS Manager
1. Select your application in IIS Manager
2. Double-click **Default Document**
3. Add `Default.aspx` to the list
4. Move it to the top of the list

## Step 7: Configure Error Pages

### 7.1 Custom Error Pages
```powershell
# Configure custom error pages
Set-WebConfiguration -Filter "/system.web/customErrors" -Value @{mode="RemoteOnly"; defaultRedirect="~/Error.aspx"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

# Add specific error page for 404 errors
Add-WebConfiguration -Filter "/system.web/customErrors/error" -Value @{statusCode="404"; redirect="~/NotFound.aspx"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 8: Configure Session State

### 8.1 Session Configuration
```powershell
# Configure session state
Set-WebConfiguration -Filter "/system.web/sessionState" -Value @{mode="InProc"; cookieless="false"; timeout="30"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 9: Configure Request Filtering

### 9.1 File Extensions
```powershell
# Allow specific file extensions
Add-WebConfiguration -Filter "/system.webServer/security/requestFiltering/fileExtensions" -Value @{fileExtension=".aspx"; allowed="true"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 9.2 Request Limits
```powershell
# Set maximum request length (4MB)
Set-WebConfiguration -Filter "/system.web/httpRuntime" -Value @{maxRequestLength="4096"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 10: Enable Compression (Optional)

### 10.1 Static Compression
```powershell
# Enable static compression for the application
Set-WebConfiguration -Filter "/system.webServer/httpCompression" -Value @{doStaticCompression="true"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 11: Configure Logging

### 11.1 Access Logging
```powershell
# Enable logging
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name dontLog -Value $false -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

# Set log file directory
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name directory -Value "C:\inetpub\logs\LogFiles" -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 12: Set Security Headers

### 12.1 Basic Security Headers
```powershell
# Add security headers
Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="X-Frame-Options"; value="SAMEORIGIN"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="X-Content-Type-Options"; value="nosniff"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Step 13: Performance Tuning

### 13.1 Output Caching
```powershell
# Enable output caching
Set-WebConfiguration -Filter "/system.web/caching/outputCache" -Value @{enableOutputCache="true"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 13.2 Static File Caching
```powershell
# Configure static file caching (7 days)
Set-WebConfiguration -Filter "/system.webServer/staticContent/clientCache" -Value @{cacheControlMode="UseMaxAge"; cacheControlMaxAge="7.00:00:00"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

## Troubleshooting Common Issues

### Issue 1: HTTP Error 500.19 - Configuration Error
**Cause**: Web.config contains elements not supported in current .NET version
**Solution**:
```powershell
# Re-register ASP.NET
& "$env:windir\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe" -i
```

### Issue 2: Application Pool Keeps Stopping
**Cause**: Permissions or .NET Framework version mismatch
**Solution**:
1. Check Event Viewer for specific errors
2. Verify .NET Framework 3.5 is installed
3. Check application pool identity permissions

### Issue 3: HTTP Error 404.2 - ISAPI Filters
**Cause**: ISAPI and CGI Restriction not configured
**Solution**:
```powershell
# Allow ASP.NET v2.0 in ISAPI and CGI Restrictions
Set-WebConfiguration -Filter "/system.webServer/security/isapiCgiRestriction/add[@path='%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll']" -Value @{allowed="true"} -PSPath "IIS:\"
```

### Issue 4: ViewState MAC Validation Error
**Cause**: Application running across multiple processes
**Solution**:
```powershell
# Set machine key in web.config or
# Ensure single worker process
Set-ItemProperty -Path "IIS:\AppPools\LegacyWebAppPool" -Name processModel.maxProcesses -Value 1
```

## Verification Steps

### 1. Test Application Pool
```powershell
# Check application pool status
Get-WebAppPoolState -Name "LegacyWebAppPool"
```

### 2. Test Web Application
```powershell
# Check if application exists
Get-WebApplication -Site "Default Web Site" -Name "LegacyWebApp"
```

### 3. Test Default Page Access
- Navigate to `http://localhost/LegacyWebApp`
- Should display Default.aspx without errors

### 4. Check Event Logs
```powershell
# Check for IIS-related errors
Get-EventLog -LogName Application -Source "ASP.NET*" -Newest 10
Get-EventLog -LogName System -Source "Microsoft-Windows-WAS" -Newest 10
```

## Performance Monitoring

### 1. Enable Performance Counters
```powershell
# Enable ASP.NET performance counters
& "$env:windir\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe" -i
```

### 2. Key Metrics to Monitor
- Requests/Sec
- Request Execution Time
- Applications Running
- Application Restarts
- Worker Process Restarts

## Security Recommendations

1. **Remove unnecessary HTTP modules**
2. **Disable directory browsing** for production
3. **Configure custom error pages** to hide internal errors
4. **Enable request filtering** to block malicious requests
5. **Use HTTPS** for production environments
6. **Regular security updates** for Windows and .NET Framework

This completes the comprehensive IIS configuration for your legacy ASP.NET Web Forms application.