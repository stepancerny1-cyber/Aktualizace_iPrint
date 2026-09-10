$installerPath = "\\axinetwork.loc\SYSVOL\axinetwork.loc\scripts\Brother_iPrintScan_Update.exe"
$logFile = "C:\ProgramData\Brother_iPrint_Deploy.log"

try {
    # 1. Validace zdrojového instalátoru na serveru
    if (-not (Test-Path $installerPath)) {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - CHYBA: Instalator nenalezen na serveru v ceste $installerPath." | Out-File -FilePath $logFile -Append
        exit
    }
    $serverVersion = [Version](Get-Item $installerPath).VersionInfo.FileVersion

    # 2. Hledání nainstalované verze v registrech (32-bit i 64-bit architektura)
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installedApp = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "iPrint&Scan" }

    $needsInstall = $false

    # 3. Logika porovnání verzí a vyhodnocení stavu
    if ($installedApp) {
        $localVersion = [Version]$installedApp.DisplayVersion
        if ($serverVersion -gt $localVersion) {
            "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - UPDATE: Nalezena verze $localVersion, provadim update na verzi $serverVersion." | Out-File -FilePath $logFile -Append
            $needsInstall = $true
        } else {
            exit
        }
    } else {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - INSTALACE: Program nenalezen na lokalni stanici, instaluji novou verzi $serverVersion." | Out-File -FilePath $logFile -Append
        $needsInstall = $true
    }

    # 4. Exekuce tiché instalace
    if ($needsInstall) {
        Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - HOTOVO: Instalacni proces uspesne dokoncen." | Out-File -FilePath $logFile -Append
    }

} catch {
    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - KRITICKA CHYBA: $$($_.Exception.Message)" | Out-File -FilePath $logFile -Append
}
