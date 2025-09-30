# Deploy-LegacyWebApp.ps1
# PowerShell deployment script for Legacy ASP.NET Web Application on Windows Server 2024

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName = "LegacyWebApp",
    
    [Parameter(Mandatory=$false)]
    [string]$SiteName = "Default Web Site",
    
    [Parameter(Mandatory=$false)]
    [string]$AppPoolName = "DefaultAppPool",
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = ".\",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = "C:\inetpub\wwwroot\LegacyWebApp",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipIISInstallation = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipNetFrameworkInstallation = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$ProductionMode = $false
)

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main deployment function
function Deploy-LegacyWebApp {
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Legacy ASP.NET Web Application Deployment" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    
    # Check if running as Administrator
    if (-not (Test-Administrator)) {
        Write-ColorOutput "ERROR: This script must be run as Administrator!" "Red"
        Write-ColorOutput "Right-click PowerShell and select 'Run as Administrator'" "Yellow"
        exit 1
    }
    
    Write-ColorOutput "Starting deployment process..." "Green"
    
    try {
        # Step 1: Install .NET Framework 3.5
        if (-not $SkipNetFrameworkInstallation) {
            Install-NetFramework35
        }
        
        # Step 2: Install and configure IIS
        if (-not $SkipIISInstallation) {
            Install-IIS
        }
        
        # Step 3: Create application directory and copy files
        Deploy-ApplicationFiles
        
        # Step 4: Configure IIS application
        Configure-IISApplication
        
        # Step 5: Set permissions
        Set-ApplicationPermissions
        
        # Step 6: Configure for production if specified
        if ($ProductionMode) {
            Configure-ProductionSettings
        }
        
        # Step 7: Test deployment
        Test-Deployment
        
        Write-ColorOutput "========================================" "Green"
        Write-ColorOutput "Deployment completed successfully!" "Green"
        Write-ColorOutput "========================================" "Green"
        
        Write-ColorOutput "Application URL: http://localhost/$AppName" "Yellow"
        if ($env:COMPUTERNAME) {
            Write-ColorOutput "External URL: http://$($env:COMPUTERNAME)/$AppName" "Yellow"
        }
        
    } catch {
        Write-ColorOutput "ERROR: Deployment failed!" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        exit 1
    }
}

function Install-NetFramework35 {
    Write-ColorOutput "Step 1: Installing .NET Framework 3.5..." "Blue"
    
    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName "NetFx3"
        if ($feature.State -eq "Enabled") {
            Write-ColorOutput ".NET Framework 3.5 is already installed." "Green"
        } else {
            Write-ColorOutput "Installing .NET Framework 3.5..." "Yellow"
            Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart
            Write-ColorOutput ".NET Framework 3.5 installation completed." "Green"
        }
    } catch {
        Write-ColorOutput "ERROR: Failed to install .NET Framework 3.5" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        throw
    }
}

function Install-IIS {
    Write-ColorOutput "Step 2: Installing and configuring IIS..." "Blue"
    
    try {
        # Check if IIS is already installed
        $iisFeature = Get-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerRole"
        if ($iisFeature.State -eq "Enabled") {
            Write-ColorOutput "IIS is already installed." "Green"
        } else {
            Write-ColorOutput "Installing IIS with ASP.NET support..." "Yellow"
            
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
                "IIS-NetFxExtensibility",
                "IIS-ISAPIExtensions",
                "IIS-ISAPIFilter",
                "IIS-ASPNET"
            )
            
            foreach ($feature in $features) {
                Write-ColorOutput "  Installing feature: $feature" "Gray"
                Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
            }
            
            Write-ColorOutput "IIS installation completed." "Green"
        }
        
        # Import WebAdministration module
        Import-Module WebAdministration -ErrorAction Stop
        Write-ColorOutput "WebAdministration module loaded." "Green"
        
    } catch {
        Write-ColorOutput "ERROR: Failed to install or configure IIS" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        throw
    }
}

function Deploy-ApplicationFiles {
    Write-ColorOutput "Step 3: Deploying application files..." "Blue"
    
    try {
        # Create target directory
        if (-not (Test-Path $TargetPath)) {
            Write-ColorOutput "Creating application directory: $TargetPath" "Yellow"
            New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        }
        
        # Copy application files
        Write-ColorOutput "Copying application files from $SourcePath to $TargetPath..." "Yellow"
        
        $filesToCopy = @(
            "*.aspx",
            "*.master",
            "*.config",
            "Styles\*",
            "Scripts\*",
            "Images\*"
        )
        
        foreach ($pattern in $filesToCopy) {
            $sourcePath = Join-Path $SourcePath $pattern
            if (Test-Path $sourcePath) {
                Write-ColorOutput "  Copying: $pattern" "Gray"
                Copy-Item $sourcePath -Destination $TargetPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        
        # Copy all .aspx, .master, .config files from source
        Get-ChildItem -Path $SourcePath -Include "*.aspx", "*.master", "*.config" -Recurse | 
            Copy-Item -Destination $TargetPath -Force
        
        # Copy Styles directory if it exists
        $stylesSource = Join-Path $SourcePath "Styles"
        if (Test-Path $stylesSource) {
            $stylesTarget = Join-Path $TargetPath "Styles"
            if (-not (Test-Path $stylesTarget)) {
                New-Item -ItemType Directory -Path $stylesTarget -Force | Out-Null
            }
            Copy-Item "$stylesSource\*" -Destination $stylesTarget -Recurse -Force
        }
        
        Write-ColorOutput "Application files deployed successfully." "Green"
        
    } catch {
        Write-ColorOutput "ERROR: Failed to deploy application files" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        throw
    }
}

function Configure-IISApplication {
    Write-ColorOutput "Step 4: Configuring IIS application..." "Blue"
    
    try {
        # Check if application already exists
        $appPath = "$SiteName/$AppName"
        if (Get-WebApplication -Site $SiteName -Name $AppName -ErrorAction SilentlyContinue) {
            Write-ColorOutput "Removing existing application: $AppName" "Yellow"
            Remove-WebApplication -Site $SiteName -Name $AppName
        }
        
        # Create new web application
        Write-ColorOutput "Creating web application: $AppName" "Yellow"
        New-WebApplication -Name $AppName -Site $SiteName -PhysicalPath $TargetPath -ApplicationPool $AppPoolName
        
        # Configure application pool for .NET Framework 3.5
        Write-ColorOutput "Configuring application pool: $AppPoolName" "Yellow"
        
        # Set .NET Framework version (v2.0 for .NET 3.5 compatibility)
        Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name managedRuntimeVersion -Value "v2.0"
        
        # Configure application pool settings
        Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name processModel.identityType -Value ApplicationPoolIdentity
        Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name recycling.periodicRestart.time -Value "00:00:00"
        Set-ItemProperty -Path "IIS:\AppPools\$AppPoolName" -Name processModel.idleTimeout -Value "00:20:00"
        
        # Start application pool if not running
        $appPoolState = Get-WebAppPoolState -Name $AppPoolName
        if ($appPoolState.Value -ne "Started") {
            Start-WebAppPool -Name $AppPoolName
        }
        
        Write-ColorOutput "IIS application configured successfully." "Green"
        
    } catch {
        Write-ColorOutput "ERROR: Failed to configure IIS application" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        throw
    }
}

function Set-ApplicationPermissions {
    Write-ColorOutput "Step 5: Setting application permissions..." "Blue"
    
    try {
        # Set permissions for IIS_IUSRS
        Write-ColorOutput "Setting permissions for IIS_IUSRS..." "Yellow"
        
        $acl = Get-Acl $TargetPath
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "IIS_IUSRS",
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $acl.SetAccessRule($accessRule)
        
        # Set permissions for Application Pool identity
        $appPoolIdentity = "IIS AppPool\$AppPoolName"
        $accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $appPoolIdentity,
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $acl.SetAccessRule($accessRule2)
        
        $acl | Set-Acl $TargetPath
        
        Write-ColorOutput "Application permissions set successfully." "Green"
        
    } catch {
        Write-ColorOutput "WARNING: Failed to set some permissions" "Yellow"
        Write-ColorOutput $_.Exception.Message "Yellow"
    }
}

function Configure-ProductionSettings {
    Write-ColorOutput "Step 6: Configuring production settings..." "Blue"
    
    try {
        $webConfigPath = Join-Path $TargetPath "web.config"
        
        if (Test-Path $webConfigPath) {
            Write-ColorOutput "Updating web.config for production..." "Yellow"
            
            # Load web.config as XML
            [xml]$webConfig = Get-Content $webConfigPath
            
            # Set debug to false
            $compilation = $webConfig.configuration.'system.web'.compilation
            if ($compilation) {
                $compilation.debug = "false"
            }
            
            # Set custom errors to On
            $customErrors = $webConfig.configuration.'system.web'.customErrors
            if ($customErrors) {
                $customErrors.mode = "On"
            }
            
            # Save changes
            $webConfig.Save($webConfigPath)
            
            Write-ColorOutput "Production settings applied successfully." "Green"
        } else {
            Write-ColorOutput "WARNING: web.config not found, skipping production configuration." "Yellow"
        }
        
    } catch {
        Write-ColorOutput "WARNING: Failed to configure production settings" "Yellow"
        Write-ColorOutput $_.Exception.Message "Yellow"
    }
}

function Test-Deployment {
    Write-ColorOutput "Step 7: Testing deployment..." "Blue"
    
    try {
        # Test if IIS service is running
        $w3svc = Get-Service W3SVC
        if ($w3svc.Status -eq "Running") {
            Write-ColorOutput "IIS service is running." "Green"
        } else {
            Write-ColorOutput "WARNING: IIS service is not running!" "Yellow"
            Start-Service W3SVC
        }
        
        # Test application pool
        $appPoolState = Get-WebAppPoolState -Name $AppPoolName
        if ($appPoolState.Value -eq "Started") {
            Write-ColorOutput "Application pool is running." "Green"
        } else {
            Write-ColorOutput "WARNING: Application pool is not started!" "Yellow"
        }
        
        # Test if application exists
        $app = Get-WebApplication -Site $SiteName -Name $AppName -ErrorAction SilentlyContinue
        if ($app) {
            Write-ColorOutput "Web application is configured." "Green"
        } else {
            Write-ColorOutput "WARNING: Web application not found!" "Yellow"
        }
        
        # Test if default page exists
        $defaultPagePath = Join-Path $TargetPath "Default.aspx"
        if (Test-Path $defaultPagePath) {
            Write-ColorOutput "Default.aspx found." "Green"
        } else {
            Write-ColorOutput "WARNING: Default.aspx not found!" "Yellow"
        }
        
        Write-ColorOutput "Deployment testing completed." "Green"
        
    } catch {
        Write-ColorOutput "WARNING: Some deployment tests failed" "Yellow"
        Write-ColorOutput $_.Exception.Message "Yellow"
    }
}

# Display help if requested
if ($args -contains "-help" -or $args -contains "--help" -or $args -contains "/?" -or $args -contains "-h") {
    Write-ColorOutput "Legacy ASP.NET Web Application Deployment Script" "Cyan"
    Write-ColorOutput "================================================" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Usage: .\Deploy-LegacyWebApp.ps1 [parameters]" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Parameters:" "Yellow"
    Write-ColorOutput "  -AppName                    Application name (default: LegacyWebApp)" "Gray"
    Write-ColorOutput "  -SiteName                   IIS site name (default: Default Web Site)" "Gray"
    Write-ColorOutput "  -AppPoolName                Application pool name (default: DefaultAppPool)" "Gray"
    Write-ColorOutput "  -SourcePath                 Source files path (default: .\)" "Gray"
    Write-ColorOutput "  -TargetPath                 Target deployment path (default: C:\inetpub\wwwroot\LegacyWebApp)" "Gray"
    Write-ColorOutput "  -SkipIISInstallation        Skip IIS installation" "Gray"
    Write-ColorOutput "  -SkipNetFrameworkInstallation Skip .NET Framework installation" "Gray"
    Write-ColorOutput "  -ProductionMode             Configure for production environment" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" "Yellow"
    Write-ColorOutput "  .\Deploy-LegacyWebApp.ps1" "Gray"
    Write-ColorOutput "  .\Deploy-LegacyWebApp.ps1 -ProductionMode" "Gray"
    Write-ColorOutput "  .\Deploy-LegacyWebApp.ps1 -AppName 'MyApp' -TargetPath 'C:\MyApp'" "Gray"
    exit 0
}

# Start deployment
Deploy-LegacyWebApp