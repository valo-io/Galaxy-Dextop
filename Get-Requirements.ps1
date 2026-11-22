# Downloads scrcpy and Taskbar.apk into this folder if they're missing.
Set-Location $PSScriptRoot
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

function Get-LatestAsset($repo, $pattern) {
    $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'Galaxy-M-Desktop' }
    $asset = $release.assets | Where-Object name -like $pattern | Select-Object -First 1
    if (-not $asset) { throw "No asset matching '$pattern' in the latest $repo release." }
    $asset
}

$scrcpyBuild = switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' { 'winarm64' }
    'x86'   { 'win32' }
    default { 'win64' }
}

try {
    if ((Test-Path 'scrcpy.exe') -and (Test-Path 'adb.exe')) {
        Write-Host 'scrcpy: already here'
    } else {
        $asset = Get-LatestAsset 'Genymobile/scrcpy' "scrcpy-$scrcpyBuild-*.zip"
        Write-Host "scrcpy: downloading $($asset.name)"
        $zip = Join-Path $env:TEMP $asset.name
        $extracted = Join-Path $env:TEMP 'scrcpy-extract'
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip
        Remove-Item $extracted -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive $zip -DestinationPath $extracted
        Copy-Item (Join-Path $extracted '*\*') $PSScriptRoot -Recurse -Force
        Remove-Item $zip, $extracted -Recurse -Force
    }

    if (Test-Path 'Taskbar.apk') {
        Write-Host 'Taskbar.apk: already here'
    } else {
        $asset = Get-LatestAsset 'farmerbb/Taskbar' '*.apk'
        Write-Host "Taskbar.apk: downloading $($asset.name)"
        Invoke-WebRequest $asset.browser_download_url -OutFile 'Taskbar.apk'
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host 'Done. You can run Launch-Desktop.ps1 now.' -ForegroundColor Green
