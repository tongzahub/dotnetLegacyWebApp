# Legacy ASP.NET Web Application - AWS EC2 Deployment Package

## Overview
This package contains a complete legacy ASP.NET Web Forms application targeting .NET Framework 3.5, along with comprehensive deployment guides and automation scripts for AWS EC2 Windows Server 2024.

## Package Contents

### Application Files
- **Site.master** - Master page with navigation and layout
- **Default.aspx** - Main page with contact form and various controls
- **DataGrid.aspx** - GridView demonstration with paging and sorting
- **UserForm.aspx** - Comprehensive registration form with validation
- **About.aspx** - Application information and specifications
- **Styles/Site.css** - IE8+ compatible CSS with basic responsive design
- **web.config** - .NET Framework 3.5 configuration

### Deployment Documentation
- **AWS-Deployment-Guide.md** - Complete step-by-step AWS EC2 deployment guide
- **IIS-Configuration-Guide.md** - Detailed IIS setup and configuration instructions
- **Security-Considerations.md** - Comprehensive security hardening guide

### Automation Scripts
- **Deploy-LegacyWebApp.ps1** - PowerShell deployment automation script

## Quick Start Deployment

### Prerequisites
- AWS Account with EC2 permissions
- Windows Server 2024 EC2 instance
- Administrator access to the server

### Step 1: Prepare EC2 Instance
1. Launch Windows Server 2024 EC2 instance (t3.medium recommended)
2. Configure Security Group with ports 80, 443, and 3389
3. Connect via RDP using EC2 credentials

### Step 2: Automated Deployment
```powershell
# Run as Administrator in PowerShell
.\Deploy-LegacyWebApp.ps1 -ProductionMode
```

### Step 3: Manual Deployment (Alternative)
1. Follow **AWS-Deployment-Guide.md** for detailed instructions
2. Use **IIS-Configuration-Guide.md** for IIS setup
3. Apply security measures from **Security-Considerations.md**

## Application Features

### Technology Stack
- **.NET Framework**: 3.5 SP1
- **Web Framework**: ASP.NET Web Forms
- **Server**: IIS 7.0+
- **Browser Support**: IE8+, Firefox 3.5+, Chrome 4+, Safari 4+

### Demonstrated Features
 **Master Pages** for consistent layout  
 **Server Controls**: GridView, TextBox, Button, DropDownList, etc.  
 **Validation Controls**: Required, RegEx, Compare, Custom  
 **Data Binding** with GridView (paging, sorting, filtering)  
 **Form Processing** with ViewState management  
 **File Upload** functionality  
 **Session Management** and state persistence  
 **Custom Error Pages** and error handling  
 **Cross-browser JavaScript** (ECMAScript 3 compatible)  
 **Responsive CSS** (IE8+ compatible)  

## Security Features

### Application Security
- Input validation and sanitization
- XSS prevention through HTML encoding
- SQL injection prevention via parameterized queries
- ViewState MAC validation
- Secure session configuration
- Custom error pages (no information disclosure)

### Infrastructure Security
- AWS VPC with private subnets
- Restrictive Security Groups
- Windows Defender enabled
- Windows Firewall configured
- SSL/TLS encryption
- Request filtering and rate limiting
- Comprehensive logging and monitoring

## Deployment Options

### Option 1: Automated PowerShell Deployment
```powershell
# Basic deployment
.\Deploy-LegacyWebApp.ps1

# Production deployment with security hardening
.\Deploy-LegacyWebApp.ps1 -ProductionMode

# Custom deployment path
.\Deploy-LegacyWebApp.ps1 -AppName "MyApp" -TargetPath "C:\MyApp"
```

### Option 2: Manual Step-by-Step Deployment
1. **Infrastructure Setup**: Follow AWS-Deployment-Guide.md sections 1-3
2. **IIS Configuration**: Follow IIS-Configuration-Guide.md sections 1-12
3. **Security Hardening**: Implement Security-Considerations.md sections 1-10
4. **Testing**: Verify deployment using provided test procedures

## Quick Deployment Commands

After connecting to your Windows Server 2024 EC2 instance:

```powershell
# 1. Install .NET Framework 3.5
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

# 2. Install IIS with ASP.NET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-ASPNET, IIS-NetFxExtensibility

# 3. Create application directory
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\LegacyWebApp" -Force

# 4. Deploy files (copy your application files to the directory)
# 5. Create IIS application
Import-Module WebAdministration
New-WebApplication -Name "LegacyWebApp" -Site "Default Web Site" -PhysicalPath "C:\inetpub\wwwroot\LegacyWebApp"

# 6. Configure for .NET 3.5
Set-ItemProperty -Path "IIS:\AppPools\DefaultAppPool" -Name managedRuntimeVersion -Value "v2.0"
```

## Testing the Deployment

Navigate to `http://your-ec2-public-ip/LegacyWebApp` and verify:
-  Home page loads with contact form
-  DataGrid page shows employee data with paging
-  UserForm page displays registration form
-  About page shows application information
-  All forms submit and validate properly

## Support Resources

- **AWS EC2 Documentation**: https://docs.aws.amazon.com/ec2/
- **IIS Configuration**: https://docs.microsoft.com/iis/
- **ASP.NET Web Forms**: https://docs.microsoft.com/aspnet/web-forms/

---

**Created**: 2024 | **Framework**: .NET 3.5 | **Platform**: AWS EC2 Windows Server 2024