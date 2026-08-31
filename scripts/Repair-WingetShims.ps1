<#
.SYNOPSIS
    Restores winget "portable package" shims that winget deletes but fails to recreate.

.DESCRIPTION
    winget installs portable packages (fd, rg, jq, ffmpeg, yazi, ...) by extracting them
    to %LOCALAPPDATA%\Microsoft\WinGet\Packages\<pkg>\ and creating a symlink in
    %LOCALAPPDATA%\Microsoft\WinGet\Links\, which is the directory that lives on PATH.

    On upgrade, winget deletes the old symlink, extracts the new version, and sometimes
    never recreates the symlink -- while still reporting success. The tool then silently
    vanishes from PATH.

    Each portable package carries its own SQLite "portable index" (<pkg>.db) recording the
    symlink path and its target. This script reads that record and recreates any symlink
    that is missing or dangling.

    Requires Developer Mode (or admin) so non-elevated symlink creation is permitted.

.PARAMETER WhatIf
    Report what would change without touching the filesystem.

.EXAMPLE
    ./Repair-WingetShims.ps1
    ./Repair-WingetShims.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$pkgRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
$links   = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links'

if (-not (Test-Path $pkgRoot)) {
    Write-Error "winget package root not found: $pkgRoot"
    return
}
if (-not (Test-Path $links)) {
    New-Item -ItemType Directory -Path $links | Out-Null
}

$repaired = 0
$okCount  = 0
$failed   = 0

foreach ($pkgDir in Get-ChildItem $pkgRoot -Directory) {
    $db = Get-ChildItem $pkgDir.FullName -Filter '*.db' -File -Force -ErrorAction SilentlyContinue |
          Select-Object -First 1
    if (-not $db) { continue }   # not a portable package

    # The portable index is SQLite. Rather than take a dependency on a SQLite provider,
    # scrape the stored absolute paths -- they are plain ASCII in the page data.
    $txt = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($db.FullName))
    $paths = [regex]::Matches($txt, '[A-Za-z]:\\[\x20-\x7E]{5,200}?\.exe') |
             ForEach-Object { $_.Value } | Sort-Object -Unique

    $shims   = @($paths | Where-Object { $_ -like "$links\*" })
    $targets = @($paths | Where-Object { $_ -like "$pkgRoot\*" })

    foreach ($shim in $shims) {
        $name   = Split-Path $shim -Leaf
        # Match the target by filename; fall back to a live search of the package dir,
        # since the recorded target still names the *previous* version's folder.
        $target = $targets | Where-Object { (Split-Path $_ -Leaf) -eq $name } |
                  Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $target) {
            $target = Get-ChildItem $pkgDir.FullName -Recurse -Filter $name -File -ErrorAction SilentlyContinue |
                      Select-Object -First 1 -ExpandProperty FullName
        }
        if (-not $target) {
            Write-Warning "$($pkgDir.Name): no binary found for '$name' -- reinstall the package"
            $failed++
            continue
        }

        $existing = Get-Item $shim -Force -ErrorAction SilentlyContinue
        if ($existing -and (Test-Path $existing.FullName)) { $okCount++; continue }

        if ($PSCmdlet.ShouldProcess($shim, "link -> $target")) {
            try {
                if ($existing) { Remove-Item $shim -Force -ErrorAction Stop }   # dangling
                New-Item -ItemType SymbolicLink -Path $shim -Target $target -ErrorAction Stop | Out-Null
                Write-Host "repaired  $name -> $target" -ForegroundColor Green
                $repaired++
            } catch {
                Write-Warning "failed to link $name : $($_.Exception.Message)"
                $failed++
            }
        }
    }
}

Write-Host ""
Write-Host "$okCount already ok, $repaired repaired, $failed failed" -ForegroundColor Cyan
if ($failed) { exit 1 }
