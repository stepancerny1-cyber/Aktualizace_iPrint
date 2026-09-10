# AutoDownload-iPrint.ps1
Start-Transcript -Path "C:\ProgramData\AutoDownload-iPrint.log" -Force

$targetFile = "\\axinetwork.loc\SYSVOL\axinetwork.loc\scripts\Brother_iPrintScan_Update.exe"
$tempDir = "C:\temp\brother_download"

Write-Host "Vytvarim slozku $tempDir"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }
Remove-Item "$tempDir\*" -Force -Recurse -ErrorAction SilentlyContinue

$wingetPath = (Get-ChildItem -Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName

if (-not $wingetPath) {
    Write-Host "Chyba: Winget nenalezen!"
} else {
    Write-Host "Spoustim Winget z $wingetPath..."
    & $wingetPath download --id Brother.iPrintScan --exact --accept-package-agreements --accept-source-agreements --download-directory $tempDir
}

$downloadedExe = Get-ChildItem -Path $tempDir -Filter "*.exe" | Select-Object -First 1

if ($downloadedExe) {
    Write-Host "Kopiruji $($downloadedExe.FullName) do $targetFile"
    Copy-Item -Path $downloadedExe.FullName -Destination $targetFile -Force
    Write-Host "Aktualizace uspesne stazena."
} else {
    Write-Host "Chyba: Soubor nebyl stazen."
}

Stop-Transcript
