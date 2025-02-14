<#
    If you can't execute any Powershell/ps1 scripts via the Windows context menu follow these steps:
    1. Search for 'Windows PowerShell' and press enter
    2. In the opened 'Powershell' window enter 'Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted' and press enter
       > To reset this after running the script enter 'Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Default' and press enter

    Install using:   './win_install_plugin.ps1'
    > In the 'Downloads/ImageTranscription-win' directory

    Uninstall using: './ImageTranscription/win_install_plugin.ps1 -CopyPlugin $false -CopyPluginIcon $false -AddInkpathToPath $false -RemovePlugin $true -RemovePluginIcon $true -RemoveInkpathFromPath $true'
    > In the (installed $XournalPluginsDir) e.g. '$HOME\AppData\Local\xournalpp\plugins' directory
    > Otherwise deleting the plugin directory will fail!

    In the case that the $XournalPluginsDir/$XournalIconsDir/$InkpathPluginDir are being set to paths not available to the normal user
    (like C:/Program Files) this script needs to be run as administrator otherwise remove/copy/etc. to these directories will fail!
#>
Param (
    [bool]$CopyPlugin = $true,
    [bool]$CopyPluginIcon = $true,
    [bool]$AddInkpathToPath = $true,
    [bool]$RemovePlugin = $false,
    [bool]$RemovePluginIcon = $false,
    [bool]$RemoveInkpathFromPath = $false,
    [Parameter(HelpMessage = "The name of the plugin directory")]
    [string]$InkpathPluginDirectoryName = "ImageTranscription",
    [Parameter(HelpMessage = "The xournal++ plugins directory where the plugin should be copied to")]
    [string]$XournalPluginsDir = (Join-Path -Path $Env:LOCALAPPDATA -ChildPath "xournalpp\plugins"),
    [Parameter(HelpMessage = "The xournal++ icons directory where the plugin icons should be copied to")]
    [string]$XournalIconsDir = (Join-Path -Path $Env:LOCALAPPDATA -ChildPath "icons"),
    [Parameter(HelpMessage = "The downloaded plugin directory (per default the current directory of this script)")]
    [string]$InkpathPluginDir = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

# Stop script on error
$ErrorActionPreference = "Stop"

if ($CopyPlugin) {
    $PluginDir = Join-Path -Path $XournalPluginsDir -ChildPath $InkpathPluginDirectoryName
    if (!(Test-Path $PluginDir)) {
        New-Item -ItemType Directory -Path $PluginDir | Out-Null
    }
    Copy-Item -Path "$InkpathPluginDir\*" -Destination $PluginDir -Recurse -Force
    Write-Output "'$InkpathPluginDir' copied to '$PluginDir'."
    # Update $InkpathPluginDir to the installed $PluginDir
    # > Necessary in case inkpath should be added to the User Environment Variable Path
    $InkpathPluginDir = (Resolve-Path -Path $PluginDir)
    Write-Output "Update InkpathPluginDir to '$InkpathPluginDir'."
}

if ($CopyPluginIcon) {
    if (!(Test-Path $XournalIconsDir)) {
        New-Item -ItemType Directory -Path $XournalIconsDir
    }
    $SvgFilesToCopy = Get-ChildItem -Path $InkpathPluginDir -Filter "*.svg"
    foreach ($SvgFile in $SvgFilesToCopy) {
        $FilePathInSource = $SvgFile.FullName
        $FilePathInTarget = Join-Path -Path $XournalIconsDir -ChildPath $SvgFile.Name
        Copy-Item -Path $FilePathInSource -Destination $FilePathInTarget -Force
        Write-Output "'$FilePathInSource' copied to '$FilePathInTarget'."
    }
}

if ($AddInkpathToPath) {
    $CurrentUserPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if ($CurrentUserPath -notlike "*$InkpathPluginDir*") {
        $UpdatedUserPath = "$CurrentUserPath;$InkpathPluginDir"
        [System.Environment]::SetEnvironmentVariable("Path", $UpdatedUserPath, [System.EnvironmentVariableTarget]::User)
        Write-Output "'$InkpathPluginDir' added to User Path environment variable (requires xournal++ restart)."
    } else {
        Write-Output "'$InkpathPluginDir' already found on User Path environment variable."
    }
}

if ($RemovePluginIcon) {
    Write-Output "RemovePluginIcon... $XournalIconsDir"
    if (Test-Path $XournalIconsDir) {
        $SvgFilesToRemove = Get-ChildItem -Path $InkpathPluginDir -Filter "*.svg"
        Write-Output "SvgFilesToRemove: $SvgFilesToRemove"
        foreach ($SvgFile in $SvgFilesToRemove) {
            $FilePathInTarget = Join-Path -Path $XournalIconsDir -ChildPath $SvgFile.Name

            if (Test-Path $FilePathInTarget) {
                Remove-Item -Path $FilePathInTarget -Force
                Write-Output "Removed '$FilePathInTarget'."
            } else {
                Write-Output "Plugin icon '$FilePathInTarget' not found."
            }
        }
    }
}

if ($RemovePlugin) {
    if (Test-Path $InkpathPluginDir) {
        Remove-Item -Path $InkpathPluginDir -Recurse -Force
    }
    Write-Output "'$InkpathPluginDir' was deleted."
}

if ($RemoveInkpathFromPath) {
    $CurrentUserPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if ($CurrentUserPath -like "*$InkpathPluginDir*") {
        # TODO Make ; optional in the regex? For now just additionally catch the edge case
        $UpdatedUserPath = $CurrentUserPath -replace [regex]::Escape(";$InkpathPluginDir"), '' -replace [regex]::Escape("$InkpathPluginDir;"), '' -replace [regex]::Escape($InkpathPluginDir), ''
        [System.Environment]::SetEnvironmentVariable("Path", $UpdatedUserPath, [System.EnvironmentVariableTarget]::User)
        Write-Output "'$InkpathPluginDir' removed from User Path environment variable."
    } else {
        Write-Output "'$InkpathPluginDir' not found on User Path environment variable."
    }
}

Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)
