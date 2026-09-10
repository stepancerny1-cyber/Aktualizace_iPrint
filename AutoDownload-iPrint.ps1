# AutoDownload-iPrint.ps1
# Tento skript bezi ciste v PowerShellu, nevyzaduje aplikaci Winget,
# takze perfektne funguje i na Windows Serveru (jako je B-S-W-DC-01).

Start-Transcript -Path "C:\ProgramData\AutoDownload-iPrint.log" -Force
Write-Host "Zahajuji stahovani Brother iPrint&Scan..."

$targetFile = "\\axinetwork.loc\SYSVOL\axinetwork.loc\scripts\Brother_iPrintScan_Update.exe"

try {
    # 1. Zjisteni nejnovejsi verze z oficialniho Microsoft repozitare
    Write-Host "Pripojuji se k databazi Winget na GitHubu..."
    $apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/b/Brother/iPrintScan"
    # Windows Server 2019 muze potrebovat vynutit TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $response = Invoke-RestMethod -Uri $apiUrl
    $latestVersion = ($response | Sort-Object name -Descending | Select-Object -First 1).name
    Write-Host "Nejnovejsi nalezena verze je: $latestVersion"

    # 2. Ziskani URL pro stazeni teto verze
    $manifestUrl = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/b/Brother/iPrintScan/$latestVersion/Brother.iPrintScan.installer.yaml"
    $manifest = Invoke-RestMethod -Uri $manifestUrl
    $downloadUrl = ($manifest -split "
" | Where-Object { $_ -match "InstallerUrl:\s*(.+)" }) -replace '.*InstallerUrl:\s*', ''
    
    if (-not $downloadUrl) {
        Write-Host "Chyba: Nepodarilo se najit stahovaci odkaz v manifestu."
        Stop-Transcript
        exit
    }
    Write-Host "Stahovaci odkaz: $downloadUrl"

    # 3. Stazeni souboru primo do SYSVOLu
    Write-Host "Stahuji instalator (muze to trvat nekolik minut)..."
    Invoke-WebRequest -Uri $downloadUrl.Trim() -OutFile $targetFile
    Write-Host "Aktualizace uspesne stazena a ulozena do $targetFile"

} catch {
    Write-Host "KRITICKA CHYBA: $$($_.Exception.Message)"
}

Stop-Transcript
