# Galaxy-M-Desktop

A PowerShell script that gives Samsung Galaxy M and F series phones a DeX-style desktop. Samsung locks DeX on these devices, so this uses `scrcpy` to create a 1080p virtual display and [Taskbar](https://github.com/farmerbb/Taskbar) to provide the desktop interface.

Created by Keyan Saini. Discussed on [r/SamsungDex](https://www.reddit.com/r/SamsungDex/comments/1wkjdx8/i_am_10_years_old_and_i_coded_a_powershell/) and on [XDA](https://xdaforums.com/t/script-open-source-galaxy-m-desktop-v17-5-automated-1080p-dex-simulation-for-one-ui-core.4802071/).

## Requirements

- Windows with PowerShell and an internet connection (for the first run only)
- USB debugging enabled on the phone (Settings > Developer options)

## Setup

1. Download or clone this repository into a folder of its own. It doesn't need to be an existing scrcpy folder.
2. Right-click `Get-Requirements.ps1` and choose **Run with PowerShell**. It downloads the latest [scrcpy](https://github.com/Genymobile/scrcpy) and `Taskbar.apk` into the folder, and skips anything already there.
3. Connect the phone over USB and accept the debugging prompt.
4. Right-click `Launch-Desktop.ps1` and choose **Run with PowerShell**.

You only need to repeat step 2 to update scrcpy or Taskbar. Delete the old `scrcpy.exe` or `Taskbar.apk` first, since the script won't replace files that exist.

## What Launch-Desktop.ps1 does

1. Checks that `scrcpy.exe`, `adb.exe` and an authorized device are present.
2. Installs Taskbar from `Taskbar.apk` if it isn't on the phone, and enables freeform window support.
3. Pushes `com.farmerbb.taskbar_preferences.xml` to Taskbar, if the file is in the folder. This is optional; without it Taskbar uses its defaults.
4. Sets Taskbar as the home app, starts it, and hides the navigation bar.
5. Opens a 1920x1080 scrcpy window at 60 FPS.
6. When you close the window, stops Taskbar and restores the Samsung launcher and navigation bar.

## Issues

Bug reports and feature requests go on the [issues page](https://github.com/keyansaini10-thegamer/Galaxy-M-Desktop/issues).

## Credits

Thanks to the developers of [scrcpy](https://github.com/Genymobile/scrcpy) and [Taskbar](https://github.com/farmerbb/Taskbar).
