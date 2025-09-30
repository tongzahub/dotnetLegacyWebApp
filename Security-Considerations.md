# Security Considerations for Legacy ASP.NET Web Application on AWS EC2

## Overview
This document outlines essential security considerations and defensive measures for deploying and maintaining a legacy ASP.NET Web Forms application on AWS EC2 Windows Server 2024.

## 1. AWS Infrastructure Security

### 1.1 EC2 Instance Security
```bash
# Security Group Configuration (Restrictive Approach)
Inbound Rules:
- SSH/RDP: Port 3389, Source: Your specific IP address only
- HTTP: Port 80, Source: Application Load Balancer only (if using ALB)
- HTTPS: Port 443, Source: Application Load Balancer only (if using ALB)
- Custom: Port 8080, Source: Internal subnets only (for health checks)

Outbound Rules:
- HTTPS: Port 443, Destination: 0.0.0.0/0 (for Windows Updates)
- HTTP: Port 80, Destination: 0.0.0.0/0 (for package downloads)
- DNS: Port 53, Destination: VPC DNS resolver
```

### 1.2 VPC Configuration
```json
{
  "VPC": {
    "EnableDnsHostnames": true,
    "EnableDnsSupport": true,
    "CidrBlock": "10.0.0.0/16"
  },
  "Subnets": {
    "PublicSubnet": "10.0.1.0/24",
    "PrivateSubnet": "10.0.2.0/24"
  },
  "NACLs": {
    "RestrictiveRules": true,
    "LogAllTraffic": true
  }
}
```

### 1.3 IAM Roles and Policies
```json
{
  "EC2InstanceRole": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::your-app-bucket/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  }
}
```

## 2. Windows Server Security Hardening

### 2.1 Windows Security Baseline
```powershell
# Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableBlockAtFirstSeen $false

# Configure Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow

# Enable Windows Event Logging
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Object Access" /success:enable /failure:enable
auditpol /set /category:"Policy Change" /success:enable /failure:enable
```

### 2.2 User Account Security
```powershell
# Disable unused accounts
Get-LocalUser | Where-Object {$_.Name -ne "Administrator" -and $_.Enabled -eq $true} | Disable-LocalUser

# Set strong password policy
Set-LocalUser -Name "Administrator" -PasswordNeverExpires $false
Set-LocalUser -Name "Administrator" -UserMayChangePassword $true

# Configure account lockout policy
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
```

### 2.3 System Updates and Patching
```powershell
# Install and configure PSWindowsUpdate
Install-Module PSWindowsUpdate -Force -AllowClobber
Import-Module PSWindowsUpdate

# Enable automatic updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "AUOptions" -Value 4

# Schedule monthly patching
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-Command "Get-WindowsUpdate -Install -AcceptAll -AutoReboot"'
$trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 2 -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "WindowsUpdate" -Description "Automated Windows Updates"
```

## 3. IIS Security Configuration

### 3.1 IIS Security Headers
```powershell
# Add security headers to prevent common attacks
Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="X-Frame-Options"; value="SAMEORIGIN"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="X-Content-Type-Options"; value="nosniff"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="X-XSS-Protection"; value="1; mode=block"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="Referrer-Policy"; value="strict-origin-when-cross-origin"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

Add-WebConfiguration -Filter "/system.webServer/httpProtocol/customHeaders" -Value @{name="Content-Security-Policy"; value="default-src 'self'"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 3.2 Remove Unnecessary HTTP Headers
```powershell
# Remove server information headers
Set-WebConfiguration -Filter "/system.webServer/security/requestFiltering" -Value @{removeServerHeader="true"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

# Remove ASP.NET version header
Set-WebConfiguration -Filter "/system.web/httpRuntime" -Value @{enableVersionHeader="false"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
```

### 3.3 Request Filtering Configuration
```powershell
# Configure request filtering to block common attacks
Set-WebConfiguration -Filter "/system.webServer/security/requestFiltering/requestLimits" -Value @{maxAllowedContentLength="4194304"; maxUrl="4096"; maxQueryString="2048"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"

# Block potentially dangerous file extensions
$dangerousExtensions = @(".exe", ".bat", ".cmd", ".com", ".scr", ".pif")
foreach ($ext in $dangerousExtensions) {
    Add-WebConfiguration -Filter "/system.webServer/security/requestFiltering/fileExtensions" -Value @{fileExtension=$ext; allowed="false"} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
}

# Block common attack patterns in URLs
$attackPatterns = @("..%2F", "..%5C", "%3C", "%3E", "%22", "%27")
foreach ($pattern in $attackPatterns) {
    Add-WebConfiguration -Filter "/system.webServer/security/requestFiltering/denyUrlSequences" -Value @{sequence=$pattern} -PSPath "IIS:\Sites\Default Web Site\LegacyWebApp"
}
```

## 4. ASP.NET Application Security

### 4.1 Secure Web.config Configuration
```xml
<system.web>
  <!-- Disable debug mode in production -->
  <compilation debug="false" targetFramework="3.5" tempDirectory="C:\Windows\Temp\" />
  
  <!-- Enable request validation -->
  <pages validateRequest="true" enableViewStateMac="true" viewStateEncryptionMode="Always" />
  
  <!-- Secure session configuration -->
  <sessionState mode="InProc" 
                cookieless="false" 
                cookieTimeout="30" 
                regenerateExpiredSessionId="true" 
                cookieSameSite="Strict" 
                httpOnlyCookies="true" 
                cookieRequireSSL="true" />
  
  <!-- Custom error pages -->
  <customErrors mode="On" defaultRedirect="~/Error.aspx">
    <error statusCode="404" redirect="~/NotFound.aspx" />
    <error statusCode="500" redirect="~/Error.aspx" />
  </customErrors>
  
  <!-- Secure authentication -->
  <authentication mode="Forms">
    <forms loginUrl="~/Login.aspx" 
           timeout="30" 
           requireSSL="true" 
           cookieless="false" 
           slidingExpiration="false" 
           enableCrossAppRedirects="false" />
  </authentication>
  
  <!-- HTTP runtime security -->
  <httpRuntime enableVersionHeader="false" 
               maxRequestLength="4096" 
               executionTimeout="90" 
               requestValidationMode="2.0" 
               requestPathInvalidCharacters="&lt;,&gt;,*,%,&amp;,\,?" />
</system.web>

<system.webServer>
  <!-- Remove unnecessary HTTP modules -->
  <modules>
    <remove name="DefaultDocumentModule" />
    <remove name="DirectoryListingModule" />
  </modules>
  
  <!-- Security headers -->
  <httpProtocol>
    <customHeaders>
      <add name="X-Frame-Options" value="SAMEORIGIN" />
      <add name="X-Content-Type-Options" value="nosniff" />
      <add name="Strict-Transport-Security" value="max-age=31536000" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

### 4.2 Input Validation and Sanitization
```csharp
// Example secure coding practices for ASP.NET 3.5
public partial class SecureForm : System.Web.UI.Page
{
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // Input validation
        if (string.IsNullOrWhiteSpace(txtUserInput.Text))
        {
            lblError.Text = "Input is required.";
            return;
        }
        
        // HTML encode output to prevent XSS
        string safeOutput = Server.HtmlEncode(txtUserInput.Text);
        lblDisplay.Text = safeOutput;
        
        // Use parameterized queries for database operations
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string query = "SELECT * FROM Users WHERE Username = @username";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@username", txtUserInput.Text);
                // Execute query
            }
        }
    }
}
```

## 5. SSL/TLS Configuration

### 5.1 SSL Certificate Installation
```powershell
# Install SSL certificate (using self-signed for testing)
$cert = New-SelfSignedCertificate -DnsName "yourdomain.com" -CertStoreLocation "cert:\LocalMachine\My"

# Bind certificate to IIS site
New-WebBinding -Name "Default Web Site" -Protocol https -Port 443
Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object {$_.Subject -like "*yourdomain.com*"} | 
    ForEach-Object {
        New-Item -Path "IIS:\SslBindings\0.0.0.0!443" -Value $_ -Force
    }
```

### 5.2 Enforce HTTPS Redirection
```xml
<!-- Add to web.config -->
<system.webServer>
  <rewrite>
    <rules>
      <rule name="HTTP to HTTPS redirect" stopProcessing="true">
        <match url="(.*)" />
        <conditions>
          <add input="{HTTPS}" pattern="off" ignoreCase="true" />
        </conditions>
        <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" 
                redirectType="Permanent" />
      </rule>
    </rules>
  </rewrite>
</system.webServer>
```

## 6. Logging and Monitoring

### 6.1 Enable Comprehensive Logging
```powershell
# Enable IIS logging
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name dontLog -Value $false

# Configure log file format and fields
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name logFormat -Value "W3C"
Set-WebConfigurationProperty -Filter "/system.webServer/httpLogging" -Name logExtFileFlags -Value "Date,Time,ClientIP,UserName,Method,UriStem,UriQuery,HttpStatus,HttpSubStatus,Win32Status,BytesSent,BytesRecv,TimeTaken,UserAgent,Referer"

# Enable Failed Request Tracing
Enable-WebRequestTracing -Name "Default Web Site"
```

### 6.2 Security Event Monitoring
```powershell
# Create custom event log for application security events
New-EventLog -LogName "ApplicationSecurity" -Source "LegacyWebApp"

# Monitor for suspicious activities
$events = @(
    @{ID=4625; Description="Failed logon attempt"},
    @{ID=4648; Description="Logon with explicit credentials"},
    @{ID=4720; Description="User account created"},
    @{ID=4726; Description="User account deleted"}
)

foreach ($event in $events) {
    Write-EventLog -LogName "ApplicationSecurity" -Source "LegacyWebApp" -EventID $event.ID -EntryType Warning -Message "Monitoring for: $($event.Description)"
}
```

### 6.3 AWS CloudWatch Integration
```powershell
# Install CloudWatch agent
$url = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi"
$output = "$env:TEMP\amazon-cloudwatch-agent.msi"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process msiexec.exe -ArgumentList "/i $output /quiet" -Wait

# Configure CloudWatch agent for IIS logs
$config = @{
    "logs" = @{
        "logs_collected" = @{
            "files" = @{
                "collect_list" = @(
                    @{
                        "file_path" = "C:\inetpub\logs\LogFiles\W3SVC1\*.log"
                        "log_group_name" = "/aws/ec2/iis/access"
                        "log_stream_name" = "{instance_id}"
                        "timezone" = "UTC"
                    }
                )
            }
            "windows_events" = @{
                "collect_list" = @(
                    @{
                        "event_name" = "System"
                        "event_levels" = @("ERROR", "WARNING")
                        "log_group_name" = "/aws/ec2/windows/system"
                        "log_stream_name" = "{instance_id}"
                    }
                )
            }
        }
    }
}

$config | ConvertTo-Json -Depth 4 | Out-File "C:\ProgramData\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent.json"
```

## 7. Backup and Disaster Recovery

### 7.1 Automated Backup Strategy
```powershell
# Create backup script for application files
$backupScript = @"
# Application files backup
`$date = Get-Date -Format "yyyyMMdd-HHmmss"
`$backupPath = "C:\Backups\LegacyWebApp-`$date.zip"
`$sourcePath = "C:\inetpub\wwwroot\LegacyWebApp"

Compress-Archive -Path `$sourcePath -DestinationPath `$backupPath -Force

# Upload to S3 (requires AWS PowerShell module)
Write-S3Object -BucketName "your-backup-bucket" -Key "backups/LegacyWebApp-`$date.zip" -File `$backupPath

# Cleanup local backups older than 7 days
Get-ChildItem "C:\Backups" -Filter "*.zip" | Where-Object {`$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
"@

$backupScript | Out-File "C:\Scripts\BackupApplication.ps1"

# Schedule daily backup
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-File "C:\Scripts\BackupApplication.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 2AM
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DailyAppBackup" -Description "Daily application backup"
```

### 7.2 EBS Snapshot Automation
```bash
# Create Lambda function for automated EBS snapshots
aws lambda create-function \
    --function-name ec2-snapshot-automation \
    --runtime python3.9 \
    --role arn:aws:iam::ACCOUNT:role/lambda-execution-role \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://snapshot-function.zip
```

## 8. Vulnerability Management

### 8.1 Regular Security Assessments
```powershell
# Install and run Microsoft Baseline Security Analyzer
# Download and install MBSA from Microsoft

# Run security assessment
& "C:\Program Files\Microsoft Baseline Security Analyzer 2\mbsacli.exe" /target 127.0.0.1 /n os+iis+sql /f /o "C:\SecurityReports\SecurityScan.xml"
```

### 8.2 Penetration Testing Checklist
- [ ] OWASP Top 10 vulnerabilities assessment
- [ ] SQL injection testing
- [ ] Cross-site scripting (XSS) testing
- [ ] Authentication bypass attempts
- [ ] Session management testing
- [ ] File upload vulnerability testing
- [ ] Directory traversal testing
- [ ] Information disclosure testing

## 9. Incident Response Plan

### 9.1 Security Incident Response Procedures
1. **Detection and Analysis**
   - Monitor CloudWatch alarms
   - Review IIS logs for suspicious activity
   - Check Windows Event Logs

2. **Containment**
   - Isolate affected instance
   - Block suspicious IP addresses
   - Disable compromised user accounts

3. **Eradication**
   - Remove malicious files
   - Patch vulnerabilities
   - Update security configurations

4. **Recovery**
   - Restore from clean backups
   - Verify system integrity
   - Resume normal operations

5. **Lessons Learned**
   - Document incident details
   - Update security procedures
   - Implement additional controls

### 9.2 Emergency Contacts
```json
{
  "SecurityTeam": {
    "Primary": "security@company.com",
    "Phone": "+1-555-SECURITY"
  },
  "AWSSupport": {
    "Enterprise": "AWS Enterprise Support",
    "Phone": "1-800-AWS-SUPPORT"
  },
  "ITManagement": {
    "OnCall": "oncall@company.com",
    "Escalation": "cto@company.com"
  }
}
```

## 10. Compliance and Governance

### 10.1 Security Compliance Framework
- **PCI DSS**: If handling payment data
- **HIPAA**: If handling healthcare data
- **SOX**: For financial reporting
- **GDPR**: For EU data protection

### 10.2 Regular Security Reviews
```powershell
# Monthly security review checklist script
$securityChecklist = @(
    "Verify all security patches are applied",
    "Review user access permissions",
    "Check SSL certificate expiration",
    "Audit IIS configuration",
    "Review firewall rules",
    "Check backup integrity",
    "Review CloudWatch logs",
    "Update incident response procedures"
)

foreach ($item in $securityChecklist) {
    Write-Host "[ ] $item" -ForegroundColor Yellow
}
```

## Conclusion

This security framework provides comprehensive protection for your legacy ASP.NET Web Application on AWS EC2. Regular reviews and updates of these security measures are essential to maintain protection against evolving threats.

Remember to:
- Keep all systems and software updated
- Monitor logs and alerts continuously
- Conduct regular security assessments
- Train team members on security best practices
- Maintain current backup and recovery procedures