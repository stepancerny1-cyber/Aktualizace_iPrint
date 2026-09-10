# Standard Operating Procedure (SOP)

## Nasazení iPrint&Scan na novou/existující stanici:
1. Otevřít konzoli *Active Directory Users and Computers*.
2. Najít objekt požadovaného počítače.
3. Přidat počítač do bezpečnostní skupiny SW_Brother_iPrint_Install.
4. Počkat na replikaci AD a provést restart koncové stanice (vyžadováno pro zpracování Startup Scriptu a načtení nového Kerberos ticketu s členstvím ve skupině).
5. Aplikace se před přihlášením uživatele tiše nainstaluje na pozadí. Log z instalace je k dispozici lokálně na stanici v C:\ProgramData\Brother_iPrint_Deploy.log.
