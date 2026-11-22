# Galaxy-M-Desktop by Keyan Saini
Set-Location $PSScriptRoot

$taskbar   = 'com.farmerbb.taskbar'
$prefsFile = "${taskbar}_preferences.xml"
$prefsDest = "/data/data/$taskbar/shared_prefs/$prefsFile"

function Fail($message) {
    Write-Host "Error: $message" -ForegroundColor Red
    exit 1
}

function Adb { & .\adb.exe @args }

Clear-Host
Write-Host 'Galaxy M/F-Series OpenDeX' -ForegroundColor Yellow

foreach ($exe in 'scrcpy.exe', 'adb.exe') {
    if (-not (Test-Path $exe)) { Fail "$exe not found. Run Get-Requirements.ps1 first." }
}

if (-not (Adb devices | Select-String '\sdevice$')) {
    Fail 'No authorized device found. Check the USB cable and accept the debugging prompt on the phone.'
}

$installed = Adb shell pm list packages $taskbar
$freeform  = Adb shell settings get global enable_freeform_support

if (-not $installed -or $freeform -ne '1') {
    if (-not $installed) {
        if (-not (Test-Path 'Taskbar.apk')) { Fail 'Taskbar.apk not found. Run Get-Requirements.ps1 first.' }
        Write-Host 'Installing Taskbar...'
        Adb install -r -g Taskbar.apk | Out-Null
        Start-Sleep -Seconds 3
    }
    Adb shell pm grant $taskbar android.permission.WRITE_SECURE_SETTINGS | Out-Null
    Adb shell settings put global enable_freeform_support 1
    Adb shell settings put global force_resizable_activities 1
}

if (Test-Path $prefsFile) {
    Adb push $prefsFile /data/local/tmp/prefs.xml | Out-Null
    Adb shell "run-as $taskbar cp /data/local/tmp/prefs.xml $prefsDest" 2>$null
    Adb shell "run-as $taskbar chmod 660 $prefsDest" 2>$null
    Adb shell rm /data/local/tmp/prefs.xml
} else {
    Write-Host "$prefsFile not found, using Taskbar defaults." -ForegroundColor DarkGray
}

try {
    Adb shell cmd package set-home-activity "$taskbar/.activity.MainActivity" | Out-Null
    Adb shell am broadcast -a "$taskbar.START_STOP_TASKBAR" --ez start true | Out-Null
    Adb shell settings put global policy_control 'immersive.navigation=*'
    Start-Sleep -Seconds 1

    $scrcpyArgs = @(
        '--new-display=1920x1080/160'
        '--max-fps=60'
        '--video-bit-rate=16M'
        '--render-driver=direct3d11'
        '--window-title=OpenDeX-Workspace'
        '--shortcut-mod=lctrl,lalt'
        '--always-on-top'
    )
    & .\scrcpy.exe @scrcpyArgs
}
finally {
    Write-Host 'Restoring One UI...'
    Adb shell am broadcast -a "$taskbar.START_STOP_TASKBAR" --ez start false | Out-Null
    Adb shell am force-stop $taskbar
    Adb shell cmd package set-home-activity com.sec.android.app.launcher/.Launcher | Out-Null
    Adb shell settings put global policy_control null
}
