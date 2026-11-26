# The setup that sp00nznet's recomp-launcher runs for this project (launcher/launcher.json names it).
# It checks the player's copy of the game, downloads this project's newest Windows release from
# GitHub, unpacks it into play\ and leaves "Civilization (recomp).cmd" in the repository's root, which
# starts the program with the player's game folder. Nothing of the game is downloaded or copied.
#
# By hand, from the repository's root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File launcher\setup.ps1 -Game "D:\Games\MyCopy"
#
# The lines "[n/4] ..." drive the installer's progress bar; a failure ends with "Setup stopped: why"
# and a non-zero exit code. It never asks anything and never waits for a key.
param([Parameter(Mandatory = $true)][string]$Game)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo     = 'Buyukcaglar/Civ64'
$Asset    = 'Civ64-*-Windows.zip'        # the Windows build among the release's files
$Program  = 'civ64.exe'      # the program inside it
$GameArgs = @('--data')    # what goes before the game folder on its command line
$Proof    = @('civ.exe', 'civdata0.rsc')       # each entry: a file the game folder must hold ("a|b": either)
$PlayName = 'Civilization'

function Stop-Setup([string]$why) {
    Write-Output "Setup stopped: $why"
    exit 1
}

try {
    $root = Split-Path -Parent $PSScriptRoot
    $play = Join-Path $root 'play'

    Write-Output '[1/4] Checking your copy of the game'
    if (-not (Test-Path -LiteralPath $Game -PathType Container)) { Stop-Setup "the game folder was not found: $Game" }
    $Game = (Resolve-Path -LiteralPath $Game).ProviderPath
    foreach ($p in $Proof) {
        $found = $false
        foreach ($alt in $p.Split('|')) { if (Test-Path -LiteralPath (Join-Path $Game $alt) -PathType Leaf) { $found = $true } }
        if (-not $found) { Stop-Setup "the game folder does not hold $($p.Replace('|', ' or ')): $Game" }
    }

    Write-Output '[2/4] Finding the newest release'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = 'recomp-launcher-setup'; 'Accept' = 'application/vnd.github+json' }
    try { $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers }
    catch { Stop-Setup "GitHub could not be reached for the release list ($($_.Exception.Message))" }
    $file = @($release.assets | Where-Object { $_.name -like $Asset })[0]
    if (-not $file) { Stop-Setup "release $($release.tag_name) has no file named like $Asset" }

    Write-Output "[3/4] Downloading $($file.name) ($([math]::Round($file.size / 1MB, 1)) MB)"
    $tmp = Join-Path $root '.setup-tmp'
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
    New-Item -ItemType Directory -Path $tmp | Out-Null
    $zip = Join-Path $tmp 'release.zip'
    try { Invoke-WebRequest -Uri $file.browser_download_url -OutFile $zip -Headers @{ 'User-Agent' = 'recomp-launcher-setup' } -UseBasicParsing }
    catch { Stop-Setup "the download failed ($($_.Exception.Message))" }
    if ($file.digest -and $file.digest.StartsWith('sha256:')) {
        $have = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
        if ($have -ne $file.digest.Substring(7).ToLower()) { Stop-Setup 'the downloaded file does not match the checksum GitHub lists for it' }
    }
    $unpacked = Join-Path $tmp 'unpacked'
    Expand-Archive -LiteralPath $zip -DestinationPath $unpacked -Force
    # a release packed as one folder: its contents are the program's folder
    $top = @(Get-ChildItem -LiteralPath $unpacked -Force)
    $from = $unpacked
    if ($top.Count -eq 1 -and $top[0].PSIsContainer) { $from = $top[0].FullName }
    if (-not (Test-Path -LiteralPath (Join-Path $from $Program) -PathType Leaf)) { Stop-Setup "$($file.name) does not hold $Program" }
    # copied over play\, so the saves and settings the program keeps there stay
    New-Item -ItemType Directory -Path $play -Force | Out-Null
    Copy-Item -Path (Join-Path $from '*') -Destination $play -Recurse -Force
    Remove-Item -LiteralPath $tmp -Recurse -Force

    Write-Output '[4/4] Writing the launcher'
    $quoted = @($GameArgs | ForEach-Object { '"' + $_ + '"' }) + ('"' + $Game.Replace('%', '%%') + '"')
    $cmd = "@echo off`r`nchcp 65001 >nul`r`nstart `"`" `"%~dp0play\$Program`" " + ($quoted -join ' ') + "`r`n"
    [IO.File]::WriteAllText((Join-Path $root "$PlayName (recomp).cmd"), $cmd, (New-Object Text.UTF8Encoding($false)))
    Write-Output "Done: $($release.tag_name) is in play\, started by `"$PlayName (recomp).cmd`"."
    exit 0
}
catch {
    Stop-Setup $_.Exception.Message
}
