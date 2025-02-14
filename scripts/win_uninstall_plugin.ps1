$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$ScriptDirectory\win_install_plugin.ps1" -CopyPlugin $false -CopyPluginIcon $false -AddInkpathToPath $false -RemovePlugin $true -RemovePluginIcon $true -RemoveInkpathFromPath $true
