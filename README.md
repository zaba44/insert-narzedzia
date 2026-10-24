# InsERT - Narzędzia serwisowe

Zestaw narzędzi do zarządzania bazą danych InsERT GT/Nexo bezpośrednio z poziomu SQL Server — tam, gdzie program nie daje wygodnego dostępu.

## Narzędzia

### Edytor GLN (`GLN/`)

Zarządzanie numerami GLN (Global Location Number) w tabelach `adr__Ewid` i `adr_Historia` — obsługa pola `adr_GLN` / `adrh_GLN` dodanego w nowszych wersjach InsERT GT.

Funkcje:

- wyszukiwanie kontrahentów po nazwie, NIP lub symbolu
- ręczne wprowadzanie i usuwanie GLN dla pojedynczego kontrahenta
- automatyczne parsowanie GLN wklejonego ze spacjami (np. `550 000 000 00 00`)
- wykrywanie i rozwiązywanie rozbieżności między `adr__Ewid` a `adr_Historia`
- kopiowanie GLN z dowolnego pola własnego (`kh_Pole1`–`kh_Pole8`) — nazwy pól czytane z `kh_ParametrG`
- zbiorcze czyszczenie GLN osobno dla każdej tabeli
- zapamiętywanie ostatniego serwera i bazy (`%APPDATA%\GLN_Editor\config.xml`)
- automatyczne wykrywanie czy kolumna `adr_GLN` istnieje w bazie (wersja InsERT)

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

Wszystkie narzędzia łączą się z SQL Server przez logowanie SQL (domyślnie `sa`) lub Windows Authentication. Po połączeniu automatycznie wykrywają bazy InsERT (po obecności tabeli `ins_ident`).

## Wymagania

- Windows z dostępem sieciowym do SQL Server
- PowerShell 5.1+ (wbudowany w Windows 10/11)
- Uprawnienia do modyfikacji tabel w bazie InsERT

## Uruchamianie

**Plik EXE** — uruchom bezpośrednio, bez potrzeby konfiguracji PowerShell.

**Skrypt PowerShell** — z konsoli:

```
powershell -ExecutionPolicy Bypass -File GLN\GLN_Editor.ps1
powershell -ExecutionPolicy Bypass -File WzorceWydruku\WzorceWydruku.ps1
powershell -ExecutionPolicy Bypass -File ProfilowanieKSeF\ProfilowanieKSeF.ps1
```

## Kompilacja do EXE

```powershell
Install-Module ps2exe -Scope CurrentUser

Invoke-ps2exe -InputFile "GLN\GLN_Editor.ps1" -OutputFile "GLN\GLN_Editor.exe" -noConsole -iconFile "GLN\GLN_Editor.ico"
Invoke-ps2exe -InputFile "WzorceWydruku\WzorceWydruku.ps1" -OutputFile "WzorceWydruku\WzorceWydruku.exe" -noConsole
Invoke-ps2exe -InputFile "ProfilowanieKSeF\ProfilowanieKSeF.ps1" -OutputFile "ProfilowanieKSeF\ProfilowanieKSeF.exe" -noConsole
```

## Struktura repozytorium

```
insert-narzedzia/
├── README.md
├── GLN/
│   ├── GLN_Editor.ps1
│   ├── GLN_Editor.exe
│   ├── GLN_Editor.bat
│   ├── GLN_Editor.ico
│   ├── GLN_Editor.ps2exe
│   └── build.ps1
├── WzorceWydruku/
│   ├── WzorceWydruku.ps1
│   └── WzorceWydruku.exe
└── ProfilowanieKSeF/
    ├── ProfilowanieKSeF.ps1
    └── ProfilowanieKSeF.exe
```

## Uwagi

- Przed użyciem na produkcji zaleca się backup bazy danych.
- Narzędzia operują bezpośrednio na tabelach SQL — używaj świadomie.
- GLN Editor wymaga InsERT GT w wersji z kolumną `adr_GLN` w tabeli `adr__Ewid` — program informuje jeśli kolumna nie istnieje.

## Wsparcie

Jeśli narzędzia okazały się przydatne, możesz dobrowolnie wesprzeć autora:

[![Wesprzyj autora](https://img.shields.io/badge/%E2%99%A5%20Wesprzyj%20autora-cuplink.to%2Fzaba44-2ea44f)](https://cuplink.to/zaba44)
