# AutoDownload-iPrint.ps1
# Tento skript stahne vzdy nejnovejsi verzi iPrint&Scan z internetu (pres Winget).
# Umistete do Planovace uloh na server a spoustejte napr. jednou tydne pod administratorskym uctem.

$targetFile = "\\axinetwork.loc\SYSVOL\axinetwork.loc\scripts\Brother_iPrintScan_Update.exe"
$tempDir = "C:\temp\brother_download"

# 1. Priprava docasne slozky
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }
Remove-Item "$tempDir\*" -Force -Recurse -ErrorAction SilentlyContinue

# 2. Stazeni pres Winget (obchazi nutnost stahovat manualne z webu)
Write-Host "Stahuji nejnovejsi instalator pres Winget..."
winget download --id Brother.iPrintScan --exact --accept-package-agreements --accept-source-agreements --download-directory $tempDir

# 3. Presun do SYSVOL pod jednotnym nazvem
$downloadedExe = Get-ChildItem -Path $tempDir -Filter "*.exe" | Select-Object -First 1

if ($downloadedExe) {
    Copy-Item -Path $downloadedExe.FullName -Destination $targetFile -Force
    Write-Host "Aktualizace uspesne stazena a pripravena v SYSVOLu: $targetFile"
} else {
    Write-Host "Chyba při stahovani souboru."
}

# Uklid
Remove-Item "$tempDir\*" -Force -Recurse -ErrorAction SilentlyContinue
