# Fix-ASP-NET-Registration.ps1
# Comprehensive script to fix ASP.NET registration issues on Windows Server 2024

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName = "LegacyWebApp",
    
    [Parameter(Mandatory=$false)]
    [string]$AppPoolName = "DefaultAppPool"
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "ASP.NET Registration Fix for Legacy App" "Cyan"
Write-ColorOutput "========================================" "Cyan"

if (-not (Test-Administrator)) {
    Write-ColorOutput "ERROR: This script must be run as Administrator!" "Red"
    exit 1
}

try {
    # Step 1: Install Windows Features
    Write-ColorOutput "`n1. Installing required Windows Features..." "Yellow"
    
    $requiredFeatures = @(
        "NetFx3",
        "IIS-WebServerRole", 
        "IIS-WebServer",
        "IIS-CommonHttpFeatures",
        "IIS-ASPNET",
        "IIS-NetFxExtensibility",
        "IIS-ISAPIExtensions",
        "IIS-ISAPIFilter",
        "IIS-DefaultDocument",
        "IIS-StaticContent",
        "IIS-DirectoryBrowsing"
    )
    
    foreach ($feature in $requiredFeatures) {
        $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
        if ($featureState.State -ne "Enabled") {
            Write-ColorOutput "   Installing $feature..." "Gray"
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
        } else {
            Write-ColorOutput "   [OK] $feature already enabled" "Green"
        }
    }
    
    # Step 2: Re-register ASP.NET
    Write-ColorOutput "`n2. Re-registering ASP.NET..." "Yellow"
    
    # Register ASP.NET for .NET Framework 2.0/3.5
    $aspnetRegiis = "$env:windir\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe"
    if (Test-Path $aspnetRegiis) {
        Write-ColorOutput "   Re-registering ASP.NET 2.0/3.5..." "Gray"
        & $aspnetRegiis -i
        Write-ColorOutput "   [OK] ASP.NET 2.0/3.5 registered" "Green"
    } else {
        Write-ColorOutput "   [ERROR] ASP.NET 2.0/3.5 not found" "Red"
    }
    
    # Also register 32-bit version if exists
    $aspnetRegiis32 = "$env:windir\Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe"
    if (Test-Path $aspnetRegiis32) {
        Write-ColorOutput "   Re-registering ASP.NET 2.0/3.5 (32-bit)..." "Gray"
        & $aspnetRegiis32 -i
        Write-ColorOutput "   [OK] ASP.NET 2.0/3.5 (32-bit) registered" "Green"
    }
    
    # Step 3: Configure IIS Application Pool
    Write-ColorOutput "`n3. Configuring IIS Application Pool..." "Yellow"
    
    Import-Module WebAdministration -ErrorAction Stop
    
    # Set Application Pool to .NET Framework v2.0
    Write-ColorOutput "   Setting .NET Framework version to v2.0..." "Gray"
    Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name managedRuntimeVersion -Value "v2.0"
    
    # Set pipeline mode to Integrated
    Write-ColorOutput "   Setting pipeline mode to Integrated..." "Gray"
    Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name managedPipelineMode -Value "Integrated"
    
    # Set process identity
    Write-ColorOutput "   Setting process identity..." "Gray"
    Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name processModel.identityType -Value "ApplicationPoolIdentity"
    
    # Enable 32-bit applications (sometimes needed for compatibility)
    Write-ColorOutput "   Configuring 32-bit application support..." "Gray"
    Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name enable32BitAppOnWin64 -Value $false
    
    # Restart application pool
    Write-ColorOutput "   Restarting Application Pool..." "Gray"
    Restart-WebAppPool -Name $AppPoolName
    Write-ColorOutput "   [OK] Application Pool configured and restarted" "Green"
    
    # Step 4: Verify Handler Mappings
    Write-ColorOutput "`n4. Verifying ASP.NET Handler Mappings..." "Yellow"
    
    # Check if ASP.NET handlers are registered at server level
    $aspnetHandlers = Get-WebHandler -Name "*.aspx*" -PSPath "IIS:\" -ErrorAction SilentlyContinue
    if ($aspnetHandlers) {
        Write-ColorOutput "   [OK] ASP.NET handlers found at server level" "Green"
        foreach ($handler in $aspnetHandlers) {
            Write-ColorOutput "     - $($handler.Name): $($handler.Path)" "Gray"
        }
    } else {
        Write-ColorOutput "   [ERROR] No ASP.NET handlers found - this may be the problem!" "Red"
    }
    
    # Step 5: Enable ASP.NET in ISAPI and CGI Restrictions
    Write-ColorOutput "`n5. Configuring ISAPI and CGI Restrictions..." "Yellow"
    
    $isapiPath = "$env:windir\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll"
    if (Test-Path $isapiPath) {
        try {
            # Enable ASP.NET v2.0 in ISAPI restrictions
            $restriction = Get-WebGlobalModule -Name "IsapiModule" -ErrorAction SilentlyContinue
            if ($restriction) {
                Write-ColorOutput "   [OK] ISAPI module is available" "Green"
            }
            
            # Use appcmd to enable ASP.NET ISAPI extension
            $appcmd = "$env:windir\system32\inetsrv\appcmd.exe"
            if (Test-Path $appcmd) {
                & $appcmd set config -section:system.webServer/security/isapiCgiRestriction /+"[path='$isapiPath',allowed='true',description='ASP.NET v2.0.50727']" /commit:apphost
                Write-ColorOutput "   [OK] ASP.NET ISAPI extension enabled" "Green"
            }
        } catch {
            Write-ColorOutput "   Warning: Could not configure ISAPI restrictions: $($_.Exception.Message)" "Yellow"
        }
    }
    
    # Step 6: Verify Application Configuration
    Write-ColorOutput "`n6. Verifying Application Configuration..." "Yellow"
    
    $app = Get-WebApplication -Site "Default Web Site" -Name $AppName -ErrorAction SilentlyContinue
    if ($app) {
        Write-ColorOutput "   [OK] Application '$AppName' exists" "Green"
        Write-ColorOutput "     Physical Path: $($app.PhysicalPath)" "Gray"
        Write-ColorOutput "     Application Pool: $($app.ApplicationPool)" "Gray"
        
        # Check if Default.aspx exists
        $defaultAspx = Join-Path $app.PhysicalPath "Default.aspx"
        if (Test-Path $defaultAspx) {
            Write-ColorOutput "   [OK] Default.aspx exists" "Green"
        } else {
            Write-ColorOutput "   [ERROR] Default.aspx not found at: $defaultAspx" "Red"
        }
        
        # Check web.config
        $webConfig = Join-Path $app.PhysicalPath "web.config"
        if (Test-Path $webConfig) {
            Write-ColorOutput "   [OK] web.config exists" "Green"
        } else {
            Write-ColorOutput "   [ERROR] web.config not found" "Red"
        }
    } else {
        Write-ColorOutput "   [ERROR] Application '$AppName' not found" "Red"
        Write-ColorOutput "   Creating application..." "Yellow"
        
        $appPath = "C:\inetpub\wwwroot\$AppName"
        if (-not (Test-Path $appPath)) {
            New-Item -ItemType Directory -Path $appPath -Force
        }
        
        New-WebApplication -Name $AppName -Site "Default Web Site" -PhysicalPath $appPath -ApplicationPool $AppPoolName
        Write-ColorOutput "   [OK] Application created" "Green"
    }
    
    # Step 7: Test IIS Configuration
    Write-ColorOutput "`n7. Testing IIS Configuration..." "Yellow"
    
    # Check IIS service
    $w3svc = Get-Service W3SVC
    if ($w3svc.Status -eq "Running") {
        Write-ColorOutput "   [OK] IIS service is running" "Green"
    } else {
        Write-ColorOutput "   Starting IIS service..." "Yellow"
        Start-Service W3SVC
        Write-ColorOutput "   [OK] IIS service started" "Green"
    }
    
    # Check application pool state
    $poolState = Get-WebAppPoolState -Name $AppPoolName
    if ($poolState.Value -eq "Started") {
        Write-ColorOutput "   [OK] Application Pool is running" "Green"
    } else {
        Write-ColorOutput "   Starting Application Pool..." "Yellow"
        Start-WebAppPool -Name $AppPoolName
        Write-ColorOutput "   [OK] Application Pool started" "Green"
    }
    
    Write-ColorOutput "`n========================================" "Green"
    Write-ColorOutput "ASP.NET Registration Fix Completed!" "Green"
    Write-ColorOutput "========================================" "Green"
    
    Write-ColorOutput "`nNext Steps:" "Yellow"
    Write-ColorOutput "1. Wait 30 seconds for services to fully start" "White"
    Write-ColorOutput "2. Try accessing: http://localhost/$AppName" "White"
    Write-ColorOutput "3. If still not working, check Event Viewer for detailed errors" "White"
    
    Write-ColorOutput "`nDiagnostic Commands:" "Yellow"
    Write-ColorOutput "- Check handler mappings: Get-WebHandler -PSPath 'IIS:\Sites\Default Web Site\$AppName'" "Gray"
    Write-ColorOutput "- Check app pool: Get-WebAppPoolState -Name '$AppPoolName'" "Gray"
    Write-ColorOutput "- Check IIS logs: Get-Content C:\inetpub\logs\LogFiles\W3SVC1\*.log | Select-Object -Last 5" "Gray"
    
} catch {
    Write-ColorOutput "`nERROR: $($_.Exception.Message)" "Red"
    Write-ColorOutput "Stack Trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}

Write-ColorOutput "`nScript completed. Please test your application now." "Cyan"