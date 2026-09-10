# Architektonický návrh: Centrální nasazení Brother iPrint&Scan

## 1. Architektonické rozhodnutí (ADR)
**Datum:** 2026-09-10
**Status:** Schváleno / Nasazeno
**Princip:** Simple solution always wins.

Rozhodli jsme se opustit nespolehlivou instalaci závislou na vyhledávání fyzických cest na disku (File-based) a využití nástroje Winget pod systémovým účtem. Pro nasazení a patch management aplikace Brother iPrint&Scan na klientské stanice byla zvolena robustní metoda založená na dotazování do Registrů Windows (Registry-based) v kombinaci s řízením distribuce přes Active Directory a centralizovaným stahováním offline instalátorů. 

Tento přístup zajišťuje:
* Bezúdržbový chod a odolnost vůči změnám instalačních cest na koncových stanicích.
* Oddělení správy softwaru (řešeno tímto systémem) od aktualizací firmwaru hardwaru (řešeno dedikovaným nástrojem BRAdmin Professional).
* Soulad s požadavky **NIS2 a ISO 27001**: Zajištěn prokazatelný a řízený patch management, detekce verzí a lokální auditování bezpečnostních logů o průběhu instalace.

## 2. Komponenty řešení
1. **Získávání instalátorů:** Nástroj Ketarin periodicky stahuje nejnovější offline .exe instalátor z oficiálních repozitářů do zabezpečené sdílené IT složky (např. \\axinetwork.loc\IT_Scripts$\).
2. **Řízení přístupu (AD):** Bezpečnostní skupina SW_Brother_iPrint_Install. Členy této skupiny jsou výhradně objekty počítačů, které mají aplikaci využívat.
3. **Distribuce (GPO):** Objekt zásad skupiny obsahující spouštěcí skript (Startup Script) běžící v kontextu NT AUTHORITY\SYSTEM. GPO je pomocí Security Filtering omezeno pouze na výše uvedenou AD skupinu. Skupina "Domain Computers" má ponecháno právo "Read" pro načtení politiky.
4. **Logika skriptu:** PowerShell skript Deploy-iPrint.ps1 umístěný na serveru.
