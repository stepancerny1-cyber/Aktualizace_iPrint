$logFile = "C:\ProgramData\Brother_iPrint_Deploy.log"
"$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - Zacinam kontrolu Brother iPrint&Scan..." | Out-File -FilePath $logFile -Append

try {
    # 1. Nalezení Winget.exe v systému (nutné pro běh pod systémovým účtem)
    $wingetPath = (Get-ChildItem -Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName

    if (-not $wingetPath) {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - CHYBA: Winget.exe nebyl na tomto PC nalezen." | Out-File -FilePath $logFile -Append
        exit
    }

    # 2. Zjištění, zda je aplikace už nainstalována
    $path64 = "C:\Program Files\Brother\iPrint&Scan\iPrint&Scan.exe"
    $path32 = "C:\Program Files (x86)\Brother\iPrint&Scan\iPrint&Scan.exe"

    if ((Test-Path -LiteralPath $path64) -or (Test-Path -LiteralPath $path32)) {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - Aplikace nalezena. Spoustim overeni aktualizaci pres Winget..." | Out-File -FilePath $logFile -Append
        & $wingetPath upgrade --id Brother.iPrintScan --exact --silent --accept-package-agreements --accept-source-agreements *>&1 | Out-File -FilePath $logFile -Append
    } else {
        "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - Aplikace nenalezena. Spoustim cistou instalaci pres Winget..." | Out-File -FilePath $logFile -Append
        & $wingetPath install --id Brother.iPrintScan --exact --silent --accept-package-agreements --accept-source-agreements *>&1 | Out-File -FilePath $logFile -Append
    }

    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - Operace uspesne ukoncena." | Out-File -FilePath $logFile -Append

} catch {
    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') - KRITICKA CHYBA: $$($_.Exception.Message)" | Out-File -FilePath $logFile -Append
}
