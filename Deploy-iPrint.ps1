$installerPath = "\\herkules\public\Brother aktualizace\Brother_iPrintScan_Update.exe"
$logFile = "C:\ProgramData\Brother_iPrint_Deploy.log"

try {
    # 1. Validace zdrojového instalátoru na serveru
    if (-not (Test-Path $installerPath)) {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - CHYBA: Instalator nenalezen na serveru v ceste $installerPath." | Out-File -FilePath $logFile -Append
        exit
    }
    $serverFile = Get-Item $installerPath | Select-Object -First 1
    # Osetreni prachu (ponechani pouze cisel a tecek) pro jistejsi konverzi
    $serverVersionStr = ($serverFile.VersionInfo.FileVersion -replace '[^\d\.]', '')
    $serverVersion = [Version]$serverVersionStr

    # 2. Hledání nainstalované verze v registrech (32-bit i 64-bit architektura)
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installedApps = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "iPrint&Scan" }

    $needsInstall = $false

    # 3. Logika porovnání verzí a vyhodnocení stavu
    if ($installedApps) {
        # Fix chyby "Object[] to Version": Muze existovat vice zaznamu v registrech.
        # Najdeme tu nejvyssi verzi ze vsech nalezenych zaznamu.
        $highestLocalVersion = [Version]"0.0.0.0"
        
        foreach ($app in $installedApps) {
            if ($app.DisplayVersion) {
                try {
                    $cleanVer = ($app.DisplayVersion -replace '[^\d\.]', '')
                    $v = [Version]$cleanVer
                    if ($v -gt $highestLocalVersion) {
                        $highestLocalVersion = $v
                    }
                } catch {}
            }
        }
        
        $localVersion = $highestLocalVersion

        if ($serverVersion -gt $localVersion) {
            "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - UPDATE: Nalezena verze $localVersion, provadim update na verzi $serverVersion." | Out-File -FilePath $logFile -Append
            $needsInstall = $true
        } else {
            "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - SKIP: Aplikace je aktualni (Nainstalovano: $localVersion, Server: $serverVersion)." | Out-File -FilePath $logFile -Append
            exit
        }
    } else {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - SKIP: Program neni na lokalni stanici nainstalovan. Preskakuji, protoze skript bezi v rezimu 'pouze aktualizace'." | Out-File -FilePath $logFile -Append
        $needsInstall = $false
    }

    # 4. Exekuce tiché instalace
    if ($needsInstall) {
        Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - HOTOVO: Aktualizacni proces uspesne dokoncen." | Out-File -FilePath $logFile -Append
    }

} catch {
    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - KRITICKA CHYBA: $$($_.Exception.Message)" | Out-File -FilePath $logFile -Append
}
