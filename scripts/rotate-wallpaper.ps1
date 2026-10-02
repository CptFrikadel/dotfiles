<#
    rotate-wallpaper.ps1
 
    Rotates the desktop wallpaper by re-encoding a random image from a local
    folder over the file the wallpaper policy points at, then forcing the shell
    to re-read it. No policy value is changed or removed.
 
        .\rotate-wallpaper.ps1                    rotate once now
        .\rotate-wallpaper.ps1 -Install           scheduled task: every 30 min (time-based only)
        .\rotate-wallpaper.ps1 -Install -Minutes 10
        .\rotate-wallpaper.ps1 -Uninstall         remove the task
        .\rotate-wallpaper.ps1 -Restore           put the original image back
 
    Needs admin (writes into C:\Windows\web\wallpaper); the installed task runs
    as you with highest privileges, so it will not prompt.
 
    NOTE: the lock screen policy points at the same file, so images placed here
    also appear on the lock screen.
#>
[CmdletBinding()]
param(
    [string] $Folder   = 'C:\Users\Alexander\OneDrive - FononTech\Pictures\Wallpapers',
    [string] $Target   = 'C:\Windows\web\wallpaper\FT16-9Gecentreerd-Subtitle-Still-V2.png',
    [int]    $Minutes  = 30,
    [switch] $Install,
    [switch] $Uninstall,
    [switch] $Restore,
    [string] $TaskName = 'RotateWallpaper'
)
 
$ErrorActionPreference = 'Stop'
$log    = Join-Path $env:ProgramData 'rotate-wallpaper.log'
$state  = Join-Path $env:ProgramData 'rotate-wallpaper.last'
$backup = "$Target.orig"
function Write-Log($m) { Add-Content $log ("{0}  {1}" -f (Get-Date -Format 's'), $m) }
 
# ------------------------------------------------------------ task management ---
if ($Uninstall) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -EA SilentlyContinue
    Write-Log "task '$TaskName' removed"
    Write-Host "Removed scheduled task '$TaskName'."
    return
}
 
if ($Install) {
    # Registered from task XML rather than via New-ScheduledTaskTrigger: the cmdlet
    # builds a repetition that several builds silently drop, whereas the XML the
    # service stores is taken verbatim.
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    # Launched through a headless conhost: -WindowStyle Hidden alone still flashes
    # a console window for a frame or two before PowerShell hides it, which a
    # tiling WM (GlazeWM) then tries to tile.
    $arg = '--headless powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -Folder "{1}" -Target "{2}"' -f `
           $PSCommandPath, $Folder, $Target
    $argEsc = [Security.SecurityElement]::Escape($arg)
    $interval = 'PT{0}M' -f $Minutes
    # A time trigger whose start boundary is in the past begins repeating
    # straight away, which is what drives the rotation. Deliberately the only
    # trigger: no logon or unlock trigger, so it changes on the clock alone.
    $startBoundary = (Get-Date).AddMinutes(-1).ToString('yyyy-MM-ddTHH:mm:ss')
 
    $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Rotates the desktop wallpaper image.</Description>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <Enabled>true</Enabled>
      <StartBoundary>$startBoundary</StartBoundary>
      <Repetition>
        <Interval>$interval</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$sid</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT2M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>conhost.exe</Command>
      <Arguments>$argEsc</Arguments>
    </Exec>
  </Actions>
</Task>
"@
 
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -EA SilentlyContinue
    Register-ScheduledTask -TaskName $TaskName -Xml $xml -Force | Out-Null
 
    # verify rather than assume
    $task = Get-ScheduledTask -TaskName $TaskName -EA SilentlyContinue
    if (-not $task) {
        Write-Log "registration reported no error but task '$TaskName' is absent"
        throw "Task '$TaskName' was not created."
    }
    Write-Log "task '$TaskName' registered: every $Minutes min, time trigger only; folder=$Folder"
    Write-Host "Registered '$TaskName' - state: $($task.State)"
    Write-Host "Triggers: $(($task.Triggers | ForEach-Object { $_.CimClass.CimClassName }) -join ', ')"
    Write-Host "Log: $log"
    return
}
 
# ------------------------------------------------------------------- interop ---
if (-not ('Win.Spi' -as [type])) {
    Add-Type -Name Spi -Namespace Win -MemberDefinition @'
[DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
'@
}
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_APPLY           = 0x03      # UPDATEINIFILE | SENDWININICHANGE
 
function Invoke-Refresh([string]$path) {
    $ok = [Win.Spi]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $path, $SPIF_APPLY)
    if (-not $ok) {
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "SystemParametersInfo failed (win32 $err)"
    }
}
 
# ------------------------------------------------------------------- restore ---
if ($Restore) {
    if (-not (Test-Path $backup)) { throw "No backup found at $backup" }
    Copy-Item $backup $Target -Force
    Invoke-Refresh $Target
    Write-Log 'restored original image'
    Write-Host "Restored the original image."
    return
}
 
# --------------------------------------------------------------- preflight ----
if (-not (Test-Path $Target)) { throw "Policy image not found: $Target" }
if (-not (Test-Path $Folder)) { throw "Folder not found: $Folder" }
 
$images = Get-ChildItem -Path (Join-Path $Folder '*') -File -Include *.jpg,*.jpeg,*.png,*.bmp
if (-not $images) { throw "No images found in $Folder" }
 
# keep one pristine copy of whatever was there first
if (-not (Test-Path $backup)) {
    Copy-Item $Target $backup -Force
    Write-Log "backed up original to $backup"
}
 
# ------------------------------------------------------- pick, encode, apply ---
$last = if (Test-Path $state) { (Get-Content $state -Raw).Trim() } else { '' }
$pool = @($images | Where-Object { $_.FullName -ne $last })
if (-not $pool) { $pool = @($images) }
$pick = $pool | Get-Random
 
Add-Type -AssemblyName System.Drawing
$tmp = Join-Path $env:TEMP ('wp-' + [guid]::NewGuid().ToString('N') + '.png')
try {
    $bmp = [System.Drawing.Image]::FromFile($pick.FullName)
    try   { $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png) }
    finally { $bmp.Dispose() }
 
    Copy-Item $tmp $Target -Force
    Invoke-Refresh $Target
 
    Set-Content -Path $state -Value $pick.FullName -NoNewline
    Write-Log "set $($pick.Name)"
}
finally {
    Remove-Item $tmp -Force -EA SilentlyContinue
}
 
