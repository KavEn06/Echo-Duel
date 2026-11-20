# Move the complete repo after ModelSim has released its files.
param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference = 'Stop'
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Echo-Duel'
if (Test-Path -LiteralPath $destination) { throw "Desktop/Echo-Duel already exists; nothing was overwritten." }
Set-Location ([Environment]::GetFolderPath('UserProfile'))
# Robocopy supports moving from local storage to the redirected network Desktop.
& robocopy $Source $destination /E /MOVE /R:1 /W:1 | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Desktop move incomplete; inspect both folders before retrying." }
Write-Output $destination
