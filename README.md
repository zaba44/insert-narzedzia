# InsERT - Narzędzia serwisowe

Zestaw narzędzi do zarządzania bazą danych InsERT GT/Nexo bezpośrednio z poziomu SQL Server — tam, gdzie program nie daje wygodnego dostępu.

## Narzędzia

### Wzorce wydruku (`WzorceWydruku/`)

Problem: domyślny wzorzec wydruku jest przypisany do stanowiska, które już nie istnieje i nie można go usunąć z poziomu programu.

Funkcje:
- wyświetla wzorce wydruku przypisane do konkretnych stanowisk (z nazwą typu wzorca)
- usuwanie pojedynczych przypisań stanowisk
- zbiorcze usuwanie wszystkich stanowisk dla wybranego wzorca

### Profilowanie stanowisk KSeF (`ProfilowanieKSeF/`)

Zarządzanie tabelą `ps_ProfilowanieStanowisk` — ograniczanie, które stanowiska realizują zadania wysyłki i odbioru KSeF.

Funkcje:
- podgląd aktualnej konfiguracji profilowania
- dodawanie stanowisk do obszarów (wysyłka / odbiór)
- usuwanie wybranych wpisów
- czyszczenie tabeli (odblokowanie KSeF na wszystkich stanowiskach)

## Połączenie z bazą

Oba narzędzia łączą się z SQL Server przez logowanie SQL (domyślnie `sa`) lub Windows Authentication. Po połączeniu automatycznie wykrywają bazy InsERT (po obecności tabeli `ins_ident`).

## Wymagania

- Windows z dostępem sieciowym do SQL Server
- PowerShell 5.1+ (wbudowany w Windows 10/11)
- Uprawnienia do modyfikacji tabel w bazie InsERT

## Uruchamianie

**Skrypt PowerShell** — prawy klik na plik `.ps1` → "Uruchom za pomocą programu PowerShell", lub z konsoli:

```powershell
powershell -ExecutionPolicy Bypass -File WzorceWydruku.ps1
```

**Plik EXE** — uruchom bezpośrednio, bez potrzeby konfiguracji.

## Kompilacja do EXE

```powershell
Install-Module ps2exe -Scope CurrentUser
Invoke-ps2exe -InputFile "WzorceWydruku\WzorceWydruku.ps1" -OutputFile "WzorceWydruku\WzorceWydruku.exe" -noConsole
Invoke-ps2exe -InputFile "ProfilowanieKSeF\ProfilowanieKSeF.ps1" -OutputFile "ProfilowanieKSeF\ProfilowanieKSeF.exe" -noConsole
```

## Struktura repozytorium

```
insert-narzedzia/
├── README.md
├── WzorceWydruku/
│   ├── WzorceWydruku.ps1
│   └── WzorceWydruku.exe
└── ProfilowanieKSeF/
    ├── ProfilowanieKSeF.ps1
    └── ProfilowanieKSeF.exe
```

## Uwagi

- Przed użyciem na produkcji zaleca się backup bazy danych.
- Po zmianach w profilowaniu KSeF konieczny jest restart programu InsERT.
- Narzędzia operują bezpośrednio na tabelach SQL — używaj świadomie.
