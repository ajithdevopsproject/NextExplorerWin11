# NextExplorer-Enterprise-Manager.ps1
# Run as Administrator

$ErrorActionPreference = "Stop"

$InstallPath   = "C:\NextExplorer"
$ComposePath   = Join-Path $InstallPath "docker-compose.yml"
$ConfigPath    = Join-Path $InstallPath "config"
$CachePath     = Join-Path $InstallPath "cache"
$StatePath     = Join-Path $InstallPath "settings.json"
$ContainerName = "nextexplorer"
$DefaultPort   = 3000
$ImageName     = "nxzai/explorer:latest"
$FirewallRule  = "NextExplorer"

function Write-Title {
    param([string]$Text)
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Folders {
    foreach ($p in @($InstallPath, $ConfigPath, $CachePath)) {
        if (-not (Test-Path $p)) {
            New-Item -ItemType Directory -Force -Path $p | Out-Null
        }
    }
}

function Test-DockerReady {
    try {
        docker info | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Ensure-DockerReady {
    Write-Title "Docker Check"

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Docker command not found. Install Docker Desktop first." -ForegroundColor Red
        exit 1
    }

    if (Test-DockerReady) {
        Write-Host "Docker engine is running." -ForegroundColor Green
        return
    }

    $dockerDesktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktop) {
        Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
        Start-Process $dockerDesktop
        Start-Sleep -Seconds 20
    }

    $maxWait = 120
    $elapsed = 0
    while ($elapsed -lt $maxWait) {
        if (Test-DockerReady) {
            Write-Host "Docker engine is running." -ForegroundColor Green
            return
        }
        Start-Sleep -Seconds 5
        $elapsed += 5
    }

    Write-Host "Docker engine is not ready. Open Docker Desktop and wait for 'Engine running'." -ForegroundColor Red
    exit 1
}

function Get-LanIP {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -ne "127.0.0.1" -and
            $_.IPAddress -notlike "169.254*" -and
            $_.PrefixOrigin -ne "WellKnown"
        } |
        Sort-Object InterfaceMetric

    if ($ips) {
        return ($ips | Select-Object -First 1 -ExpandProperty IPAddress)
    }
    return $null
}

function Convert-ToDockerPath {
    param([string]$PathValue)
    return ($PathValue -replace "\\","/")
}

function Prompt-YesNo {
    param(
        [string]$Message,
        [bool]$DefaultYes = $true
    )

    if ($DefaultYes) {
        $answer = Read-Host "$Message [Y/n]"
        return ([string]::IsNullOrWhiteSpace($answer) -or $answer -match '^(y|yes)$')
    } else {
        $answer = Read-Host "$Message [y/N]"
        return ($answer -match '^(y|yes)$')
    }
}

function Load-State {
    Ensure-Folders

    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {
        }
    }

    $lanIp = Get-LanIP
    $state = [PSCustomObject]@{
        BindIP    = if ($lanIp) { $lanIp } else { "0.0.0.0" }
        Port      = $DefaultPort
        PublicURL = if ($lanIp) { "http://$lanIp`:$DefaultPort" } else { "http://localhost:$DefaultPort" }
        Mounts    = @()
    }

    Save-State -State $state
    return $state
}

function Save-State {
    param([Parameter(Mandatory=$true)]$State)
    $State | ConvertTo-Json -Depth 6 | Set-Content -Path $StatePath -Encoding UTF8
}

function Ensure-FirewallRule {
    param([int]$Port)

    try {
        $existing = Get-NetFirewallRule -DisplayName $FirewallRule -ErrorAction SilentlyContinue
        if ($existing) {
            Remove-NetFirewallRule -DisplayName $FirewallRule -ErrorAction SilentlyContinue | Out-Null
        }
        New-NetFirewallRule -DisplayName $FirewallRule -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
        Write-Host "Firewall rule updated for port $Port." -ForegroundColor Green
    } catch {
        Write-Host "Could not create firewall rule. Run as Administrator." -ForegroundColor Yellow
    }
}

function Build-ComposeFile {
    param([Parameter(Mandatory=$true)]$State)

    $volumeLines = @(
        '      - "./config:/config"'
        '      - "./cache:/cache"'
    )

    foreach ($m in $State.Mounts) {
        $volumeLines += "      - `"${($m.DockerSrc)}:/mnt/$($m.ShareName)`""
    }

    $volumesBlock = $volumeLines -join "`r`n"

    $content = @"
services:
  nextexplorer:
    image: $ImageName
    container_name: $ContainerName
    restart: unless-stopped
    ports:
      - "$($State.Port):3000"
    volumes:
$volumesBlock
    environment:
      NODE_ENV: production
      PUBLIC_URL: "$($State.PublicURL)"
"@

    Set-Content -Path $ComposePath -Value $content -Encoding UTF8
}

function Start-NextExplorer {
    if (-not (Test-Path $ComposePath)) {
        Write-Host "docker-compose.yml not found. Configure first." -ForegroundColor Yellow
        return
    }

    Set-Location $InstallPath
    docker compose down --remove-orphans | Out-Null
    docker compose up -d
}

function Stop-NextExplorer {
    if (Test-Path $ComposePath) {
        Set-Location $InstallPath
        docker compose down --remove-orphans
    } else {
        Write-Host "docker-compose.yml not found." -ForegroundColor Yellow
        try {
            docker rm -f $ContainerName | Out-Null
            Write-Host "Container removed directly." -ForegroundColor Green
        } catch {
            Write-Host "Container stop skipped." -ForegroundColor Yellow
        }
    }
}

function Show-CurrentConfig {
    Write-Title "Current docker-compose.yml"
    if (Test-Path $ComposePath) {
        Get-Content $ComposePath
    } else {
        Write-Host "No configuration found." -ForegroundColor Yellow
    }
}

function Show-ServerInfo {
    $state = Load-State
    Write-Title "Current Server IP and Port"
    Write-Host "Configured IP     : $($state.BindIP)" -ForegroundColor Green
    Write-Host "Configured Port   : $($state.Port)" -ForegroundColor Green
    Write-Host "Configured URL    : $($state.PublicURL)" -ForegroundColor Green
    Write-Host ""

    $lanIp = Get-LanIP
    if ($lanIp) {
        Write-Host "Detected Server IP: $lanIp" -ForegroundColor Cyan
        Write-Host "Access URL        : http://$lanIp`:$($state.Port)" -ForegroundColor Cyan
    }
}

function Configure-ServerIPPort {
    $state = Load-State
    Write-Title "Configure Server IP and Port"

    $detectedIp = Get-LanIP
    if ($detectedIp) {
        Write-Host "Current detected server IP: $detectedIp" -ForegroundColor Cyan
    }

    Write-Host "Current configured IP  : $($state.BindIP)" -ForegroundColor Yellow
    Write-Host "Current configured Port: $($state.Port)" -ForegroundColor Yellow
    Write-Host ""

    $newIp = Read-Host "Enter server IP for PUBLIC_URL (Press Enter to use detected/current IP)"
    if ([string]::IsNullOrWhiteSpace($newIp)) {
        if ($detectedIp) {
            $newIp = $detectedIp
        } else {
            $newIp = $state.BindIP
        }
    }

    $newPort = Read-Host "Enter port number (Default/current: $($state.Port))"
    if ([string]::IsNullOrWhiteSpace($newPort)) {
        $newPort = $state.Port
    }

    if (-not ($newPort -as [int])) {
        Write-Host "Invalid port number." -ForegroundColor Red
        return
    }

    $state.BindIP = $newIp
    $state.Port = [int]$newPort
    $state.PublicURL = "http://$newIp`:$newPort"

    Save-State -State $state
    Build-ComposeFile -State $state
    Ensure-FirewallRule -Port $state.Port

    Write-Host "Server IP and port updated." -ForegroundColor Green

    if (Prompt-YesNo "Do you want to restart NextExplorer now?" $true) {
        Ensure-DockerReady
        Start-NextExplorer
        Write-Host "NextExplorer restarted." -ForegroundColor Green
    }
}

function Collect-InitialMounts {
    $mounts = @()
    $index = 1

    do {
        Write-Host ""
        $pathInput = Read-Host "Enter storage path #$index"

        if ([string]::IsNullOrWhiteSpace($pathInput)) {
            Write-Host "Path cannot be empty." -ForegroundColor Red
            continue
        }

        if (-not (Test-Path $pathInput)) {
            Write-Host "Path not found: $pathInput" -ForegroundColor Red
            $tryAgain = Prompt-YesNo "Do you want to enter another path?" $true
            if (-not $tryAgain) { break }
            continue
        }

        $defaultShare = "Share$index"
        $shareName = Read-Host "Enter display name for this path in NextExplorer (Default: $defaultShare)"
        if ([string]::IsNullOrWhiteSpace($shareName)) {
            $shareName = $defaultShare
        }

        if ($shareName -match '[\\/:*?"<>| ]') {
            $shareName = ($shareName -replace '[\\/:*?"<>| ]','_')
            Write-Host "Invalid characters replaced. Final share name: $shareName" -ForegroundColor Yellow
        }

        $mounts += [PSCustomObject]@{
            Source    = $pathInput
            DockerSrc = (Convert-ToDockerPath -PathValue $pathInput)
            ShareName = $shareName
        }

        $index++
    }
    while (Prompt-YesNo "Do you want to add another storage path?" $false)

    return $mounts
}

function Show-Mounts {
    $state = Load-State
    Write-Title "Configured Storage Paths"

    if (-not $state.Mounts -or $state.Mounts.Count -eq 0) {
        Write-Host "No storage paths configured." -ForegroundColor Yellow
        return
    }

    $i = 1
    foreach ($m in $state.Mounts) {
        Write-Host "$i. $($m.Source)  ->  /mnt/$($m.ShareName)" -ForegroundColor Green
        $i++
    }
}

function Add-StoragePath {
    $state = Load-State
    Write-Title "Add New Storage Path"

    $pathInput = Read-Host "Enter new storage path"
    if ([string]::IsNullOrWhiteSpace($pathInput)) {
        Write-Host "Path cannot be empty." -ForegroundColor Red
        return
    }

    if (-not (Test-Path $pathInput)) {
        Write-Host "Path not found: $pathInput" -ForegroundColor Red
        return
    }

    $shareName = Read-Host "Enter display name for this path"
    if ([string]::IsNullOrWhiteSpace($shareName)) {
        $nextIndex = 1
        if ($state.Mounts) {
            $nextIndex = $state.Mounts.Count + 1
        }
        $shareName = "Share$nextIndex"
    }

    if ($shareName -match '[\\/:*?"<>| ]') {
        $shareName = ($shareName -replace '[\\/:*?"<>| ]','_')
        Write-Host "Invalid characters replaced. Final share name: $shareName" -ForegroundColor Yellow
    }

    foreach ($m in $state.Mounts) {
        if ($m.Source -eq $pathInput -or $m.ShareName -eq $shareName) {
            Write-Host "This path or share name already exists." -ForegroundColor Red
            return
        }
    }

    $newMount = [PSCustomObject]@{
        Source    = $pathInput
        DockerSrc = (Convert-ToDockerPath -PathValue $pathInput)
        ShareName = $shareName
    }

    if (-not $state.Mounts) {
        $state.Mounts = @()
    }

    $state.Mounts += $newMount

    Save-State -State $state
    Build-ComposeFile -State $state

    Write-Host "Storage path added successfully." -ForegroundColor Green

    if (Prompt-YesNo "Do you want to restart NextExplorer now?" $true) {
        Ensure-DockerReady
        Start-NextExplorer
        Write-Host "NextExplorer restarted." -ForegroundColor Green
    }
}

function Delete-StoragePath {
    $state = Load-State
    Write-Title "Delete Storage Path"

    if (-not $state.Mounts -or $state.Mounts.Count -eq 0) {
        Write-Host "No storage paths configured." -ForegroundColor Yellow
        return
    }

    $i = 1
    foreach ($m in $state.Mounts) {
        Write-Host "$i. $($m.Source)  ->  /mnt/$($m.ShareName)" -ForegroundColor Green
        $i++
    }

    $selection = Read-Host "Enter the number of the storage path to delete"
    if (-not ($selection -as [int])) {
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $index = [int]$selection - 1
    if ($index -lt 0 -or $index -ge $state.Mounts.Count) {
        Write-Host "Selection out of range." -ForegroundColor Red
        return
    }

    $removed = $state.Mounts[$index]
    $newMounts = @()

    for ($j = 0; $j -lt $state.Mounts.Count; $j++) {
        if ($j -ne $index) {
            $newMounts += $state.Mounts[$j]
        }
    }

    $state.Mounts = $newMounts
    Save-State -State $state
    Build-ComposeFile -State $state

    Write-Host "Deleted storage path: $($removed.Source)" -ForegroundColor Green

    if (Prompt-YesNo "Do you want to restart NextExplorer now?" $true) {
        Ensure-DockerReady
        Start-NextExplorer
        Write-Host "NextExplorer restarted." -ForegroundColor Green
    }
}

function Install-Or-Reconfigure {
    Ensure-Folders
    Ensure-DockerReady

    $state = Load-State

    Write-Title "Initial Configuration"
    Show-ServerInfo

    if (Prompt-YesNo "Do you want to configure server IP and port now?" $true) {
        Configure-ServerIPPort
        $state = Load-State
    }

    Write-Title "Storage Path Configuration"
    Write-Host "Enter the folders/drives you want to publish in NextExplorer."
    Write-Host "Examples:"
    Write-Host "  E:\CompanyFiles"
    Write-Host "  D:\Public"
    Write-Host "  Z:\DepartmentShare"
    Write-Host "  \\192.168.1.20\SharedData"

    $mounts = Collect-InitialMounts
    if (-not $mounts -or $mounts.Count -eq 0) {
        Write-Host "No valid storage paths provided." -ForegroundColor Red
        return
    }

    $state.Mounts = $mounts
    Save-State -State $state

    Build-ComposeFile -State $state
    Ensure-FirewallRule -Port $state.Port

    Write-Title "Starting NextExplorer"
    Start-NextExplorer

    Write-Host ""
    Write-Host "NextExplorer started successfully." -ForegroundColor Green
    Write-Host "Configured URL: $($state.PublicURL)"
    Write-Host ""
    Write-Host "Published paths:" -ForegroundColor Cyan
    foreach ($m in $state.Mounts) {
        Write-Host " - $($m.Source)  ->  /mnt/$($m.ShareName)"
    }
}

function Delete-ConfigOnly {
    try {
        Stop-NextExplorer
    } catch {
        Write-Host "Container stop skipped." -ForegroundColor Yellow
    }

    try {
        docker rm -f $ContainerName | Out-Null
    } catch {
    }

    if (Test-Path $ComposePath) {
        try {
            Remove-Item $ComposePath -Force
            Write-Host "Deleted docker-compose.yml" -ForegroundColor Green
        } catch {
            Write-Host "Could not delete docker-compose.yml" -ForegroundColor Yellow
        }
    }

    if (Test-Path $ConfigPath) {
        try {
            Remove-Item $ConfigPath -Recurse -Force
            Write-Host "Deleted config folder" -ForegroundColor Green
        } catch {
            Write-Host "Could not delete config folder" -ForegroundColor Yellow
        }
    }

    if (Test-Path $CachePath) {
        try {
            Remove-Item $CachePath -Recurse -Force
            Write-Host "Deleted cache folder" -ForegroundColor Green
        } catch {
            Write-Host "Could not delete cache folder" -ForegroundColor Yellow
        }
    }

    if (Test-Path $StatePath) {
        try {
            Remove-Item $StatePath -Force
            Write-Host "Deleted settings.json" -ForegroundColor Green
        } catch {
            Write-Host "Could not delete settings.json" -ForegroundColor Yellow
        }
    }

    try {
        Remove-NetFirewallRule -DisplayName $FirewallRule -ErrorAction SilentlyContinue
        Write-Host "Removed firewall rule" -ForegroundColor Green
    } catch {
        Write-Host "Firewall rule removal skipped." -ForegroundColor Yellow
    }

    if (Prompt-YesNo "Do you also want to delete full $InstallPath folder?" $false) {
        try {
            Set-Location C:\
            Start-Sleep -Seconds 2
            if (Test-Path $InstallPath) {
                cmd /c "rmdir /s /q `"$InstallPath`""
            }

            if (-not (Test-Path $InstallPath)) {
                Write-Host "Deleted install folder: $InstallPath" -ForegroundColor Green
            } else {
                Write-Host "Could not fully delete install folder." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Install folder delete failed." -ForegroundColor Yellow
        }
    }
}

function Stop-Only {
    Stop-NextExplorer
    Write-Host "Container stopped." -ForegroundColor Green
}

function Delete-CompleteDocker {
    Write-Title "Delete Complete Docker and Uninstall Docker Desktop"

    if (-not (Prompt-YesNo "This will stop container, delete config, remove image, and uninstall Docker Desktop. Continue?" $false)) {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }

    Delete-ConfigOnly

    try {
        docker image rm $ImageName -f
        Write-Host "Docker image deleted: $ImageName" -ForegroundColor Green
    } catch {
        Write-Host "Docker image delete skipped or failed." -ForegroundColor Yellow
    }

    $dockerInstaller = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"

    try {
        Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
    } catch {
    }

    if (Test-Path $dockerInstaller) {
        try {
            Write-Host "Starting Docker Desktop uninstall..." -ForegroundColor Yellow
            Start-Process -FilePath $dockerInstaller -ArgumentList "uninstall" -Wait
            Write-Host "Docker Desktop uninstall command executed." -ForegroundColor Green
        } catch {
            Write-Host "Docker Desktop uninstall failed." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Docker Desktop Installer.exe not found." -ForegroundColor Yellow
        Write-Host "Uninstall manually from Apps & Features if needed." -ForegroundColor Yellow
    }
}

function Delete-AllNextExplorerDependencies {
    Write-Title "Delete All NextExplorer Dependent Application Software Files"

    if (-not (Prompt-YesNo "This will try to remove NextExplorer, Docker image, Docker Desktop, Docker data folders, shortcuts, and related files. Continue?" $false)) {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }

    Write-Host "Stopping NextExplorer and Docker objects..." -ForegroundColor Yellow
    try { Stop-NextExplorer } catch {}
    try { docker rm -f $ContainerName | Out-Null } catch {}
    try { docker image rm $ImageName -f | Out-Null } catch {}

    Write-Host "Deleting NextExplorer configuration..." -ForegroundColor Yellow
    try { Delete-ConfigOnly } catch {}

    Write-Host "Deleting install folder..." -ForegroundColor Yellow
    try {
        Set-Location C:\
        Start-Sleep -Seconds 2
        if (Test-Path $InstallPath) {
            cmd /c "rmdir /s /q `"$InstallPath`""
        }
        if (-not (Test-Path $InstallPath)) {
            Write-Host "Deleted install folder: $InstallPath" -ForegroundColor Green
        } else {
            Write-Host "Could not fully delete install folder." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Install folder delete failed." -ForegroundColor Yellow
    }

    Write-Host "Stopping Docker Desktop..." -ForegroundColor Yellow
    try { Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue } catch {}
    try { Stop-Service com.docker.service -ErrorAction SilentlyContinue } catch {}

    Write-Host "Removing common Docker Desktop shortcuts..." -ForegroundColor Yellow
    $shortcutPaths = @(
        "$env:Public\Desktop\Docker Desktop.lnk",
        "$env:UserProfile\Desktop\Docker Desktop.lnk",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Docker\Docker Desktop.lnk",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Docker Desktop.lnk",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs\Docker Desktop.lnk"
    )
    foreach ($p in $shortcutPaths) {
        try {
            if (Test-Path $p) {
                Remove-Item $p -Force
                Write-Host "Deleted shortcut: $p" -ForegroundColor Green
            }
        } catch {
            Write-Host "Could not delete shortcut: $p" -ForegroundColor Yellow
        }
    }

    Write-Host "Removing common Docker data folders..." -ForegroundColor Yellow
    $dockerFolders = @(
        "C:\Program Files\Docker",
        "C:\ProgramData\Docker",
        "C:\ProgramData\DockerDesktop",
        "$env:LocalAppData\Docker",
        "$env:LocalAppData\Docker Desktop",
        "$env:AppData\Docker",
        "$env:AppData\Docker Desktop",
        "$env:UserProfile\.docker"
    )

    foreach ($folder in $dockerFolders) {
        try {
            if (Test-Path $folder) {
                cmd /c "rmdir /s /q `"$folder`""
                if (-not (Test-Path $folder)) {
                    Write-Host "Deleted folder: $folder" -ForegroundColor Green
                } else {
                    Write-Host "Could not fully delete folder: $folder" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "Failed to delete folder: $folder" -ForegroundColor Yellow
        }
    }

    Write-Host "Unregistering Docker WSL distros if present..." -ForegroundColor Yellow
    try {
        $wslList = wsl -l -q 2>$null
        if ($wslList) {
            foreach ($d in $wslList) {
                $name = $d.Trim()
                if ($name -eq "docker-desktop" -or $name -eq "docker-desktop-data") {
                    try {
                        wsl --unregister $name
                        Write-Host "Unregistered WSL distro: $name" -ForegroundColor Green
                    } catch {
                        Write-Host "Could not unregister WSL distro: $name" -ForegroundColor Yellow
                    }
                }
            }
        }
    } catch {
        Write-Host "WSL distro cleanup skipped." -ForegroundColor Yellow
    }

    Write-Host "Trying Docker Desktop uninstall..." -ForegroundColor Yellow
    $dockerInstaller = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
    if (Test-Path $dockerInstaller) {
        try {
            Start-Process -FilePath $dockerInstaller -ArgumentList "uninstall" -Wait
            Write-Host "Docker Desktop uninstall command executed." -ForegroundColor Green
        } catch {
            Write-Host "Docker Desktop uninstall failed." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Docker Desktop Installer.exe not found." -ForegroundColor Yellow
        Write-Host "Manual uninstall may still be required from Apps & Features." -ForegroundColor Yellow
    }

    Write-Host "Delete all dependency cleanup completed." -ForegroundColor Green
    Write-Host "A system restart is recommended." -ForegroundColor Yellow
}

function Delete-Configuration {
    Write-Title "Delete Options"
    Write-Host "1. Delete configuration only"
    Write-Host "2. Stop only"
    Write-Host "3. Delete complete docker image and uninstall Docker Desktop"
    Write-Host "4. Delete all NextExplorer dependent application software files complete all"
    Write-Host "5. Back"
    Write-Host ""

    $deleteChoice = Read-Host "Select delete option"

    switch ($deleteChoice) {
        "1" {
            Delete-ConfigOnly
            Write-Host "Configuration delete completed." -ForegroundColor Green
        }
        "2" {
            Stop-Only
        }
        "3" {
            Delete-CompleteDocker
        }
        "4" {
            Delete-AllNextExplorerDependencies
        }
        "5" {
            Write-Host "Back."
        }
        default {
            Write-Host "Invalid option." -ForegroundColor Red
        }
    }
}

function Show-Menu {
    Write-Title "NextExplorer Enterprise Manager"
    Write-Host "1. Install / Configure / Reconfigure"
    Write-Host "2. Start NextExplorer"
    Write-Host "3. Stop NextExplorer"
    Write-Host "4. Show current server IP and port"
    Write-Host "5. Configure server IP and port"
    Write-Host "6. Add new storage path"
    Write-Host "7. Delete storage path"
    Write-Host "8. Show current docker-compose.yml"
    Write-Host "9. Delete configuration / stop / uninstall / full dependency cleanup"
    Write-Host "10. Show configured storage paths"
    Write-Host "11. Exit"
    Write-Host ""
}

if (-not (Test-Admin)) {
    Write-Host "Run this script as Administrator." -ForegroundColor Red
    exit 1
}

do {
    Show-Menu
    $choice = Read-Host "Select option"

    switch ($choice) {
        "1"  { Install-Or-Reconfigure }
        "2"  { Ensure-DockerReady; Start-NextExplorer; Write-Host "Started." -ForegroundColor Green }
        "3"  { Stop-NextExplorer; Write-Host "Stopped." -ForegroundColor Green }
        "4"  { Show-ServerInfo }
        "5"  { Configure-ServerIPPort }
        "6"  { Add-StoragePath }
        "7"  { Delete-StoragePath }
        "8"  { Show-CurrentConfig }
        "9"  { Delete-Configuration }
        "10" { Show-Mounts }
        "11" { Write-Host "Exit."; break }
        default { Write-Host "Invalid option." -ForegroundColor Red }
    }

    if ($choice -ne "11") {
        Write-Host ""
        Read-Host "Press Enter to continue"
    }
}
while ($choice -ne "11")