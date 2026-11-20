# Move the complete repo after ModelSim has released its files.
param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference = 'Stop'
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Echo-Duel'
if (Test-Path -LiteralPath $destination) { throw "Desktop/Echo-Duel already exists; nothing was overwritten." }
Set-Location ([Environment]::GetFolderPath('UserProfile'))
Move-Item -LiteralPath $Source -Destination $destination
Write-Output $destination
