Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Główne okno ──────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "Profilowanie stanowisk KSeF"
$form.Size = New-Object System.Drawing.Size(700, 560)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.MinimumSize = New-Object System.Drawing.Size(700, 480)

# ── Panel połączenia ─────────────────────────────────────────
$panelConn = New-Object System.Windows.Forms.GroupBox
$panelConn.Text = "Polaczenie z SQL Server"
$panelConn.Location = New-Object System.Drawing.Point(10, 10)
$panelConn.Size = New-Object System.Drawing.Size(660, 100)
$panelConn.Anchor = "Top,Left,Right"
$form.Controls.Add($panelConn)

$lblServer = New-Object System.Windows.Forms.Label
$lblServer.Text = "Serwer:"
$lblServer.Location = New-Object System.Drawing.Point(10, 25)
$lblServer.AutoSize = $true
$panelConn.Controls.Add($lblServer)

$txtServer = New-Object System.Windows.Forms.TextBox
$txtServer.Location = New-Object System.Drawing.Point(70, 22)
$txtServer.Size = New-Object System.Drawing.Size(180, 23)
$txtServer.Text = "localhost\INSERTGT"
$panelConn.Controls.Add($txtServer)

$chkWinAuth = New-Object System.Windows.Forms.CheckBox
$chkWinAuth.Text = "Windows Auth"
$chkWinAuth.Location = New-Object System.Drawing.Point(260, 23)
$chkWinAuth.AutoSize = $true
$chkWinAuth.Checked = $false
$panelConn.Controls.Add($chkWinAuth)

$lblLogin = New-Object System.Windows.Forms.Label
$lblLogin.Text = "Login:"
$lblLogin.Location = New-Object System.Drawing.Point(390, 25)
$lblLogin.AutoSize = $true
$panelConn.Controls.Add($lblLogin)

$txtLogin = New-Object System.Windows.Forms.TextBox
$txtLogin.Location = New-Object System.Drawing.Point(435, 22)
$txtLogin.Size = New-Object System.Drawing.Size(100, 23)
$txtLogin.Text = "sa"
$txtLogin.Enabled = $true
$panelConn.Controls.Add($txtLogin)

$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = "Haslo:"
$lblPass.Location = New-Object System.Drawing.Point(545, 25)
$lblPass.AutoSize = $true
$panelConn.Controls.Add($lblPass)

$txtPass = New-Object System.Windows.Forms.TextBox
$txtPass.Location = New-Object System.Drawing.Point(590, 22)
$txtPass.Size = New-Object System.Drawing.Size(60, 23)
$txtPass.UseSystemPasswordChar = $true
$txtPass.Enabled = $true
$panelConn.Controls.Add($txtPass)

$chkWinAuth.Add_CheckedChanged({
    $txtLogin.Enabled = -not $chkWinAuth.Checked
    $txtPass.Enabled  = -not $chkWinAuth.Checked
})

$lblDB = New-Object System.Windows.Forms.Label
$lblDB.Text = "Baza:"
$lblDB.Location = New-Object System.Drawing.Point(10, 60)
$lblDB.AutoSize = $true
$panelConn.Controls.Add($lblDB)

$cmbDB = New-Object System.Windows.Forms.ComboBox
$cmbDB.Location = New-Object System.Drawing.Point(70, 57)
$cmbDB.Size = New-Object System.Drawing.Size(180, 23)
$cmbDB.DropDownStyle = "DropDownList"
$panelConn.Controls.Add($cmbDB)

$btnGetDBs = New-Object System.Windows.Forms.Button
$btnGetDBs.Text = "Pobierz bazy"
$btnGetDBs.Location = New-Object System.Drawing.Point(260, 55)
$btnGetDBs.Size = New-Object System.Drawing.Size(100, 27)
$panelConn.Controls.Add($btnGetDBs)

$btnLoad = New-Object System.Windows.Forms.Button
$btnLoad.Text = "Wczytaj"
$btnLoad.Location = New-Object System.Drawing.Point(370, 55)
$btnLoad.Size = New-Object System.Drawing.Size(80, 27)
$panelConn.Controls.Add($btnLoad)

# ── Status bar ───────────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Gotowe"
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# ── DataGridView ─────────────────────────────────────────────
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(10, 120)
$grid.Size = New-Object System.Drawing.Size(660, 290)
$grid.Anchor = "Top,Bottom,Left,Right"
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $true
$grid.SelectionMode = "FullRowSelect"
$grid.MultiSelect = $true
$grid.AutoSizeColumnsMode = "Fill"
$grid.RowHeadersVisible = $false
$grid.BackgroundColor = [System.Drawing.Color]::White
$grid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(245, 250, 245)
$form.Controls.Add($grid)

# ── Panel dolny ──────────────────────────────────────────────
$panelBottom = New-Object System.Windows.Forms.Panel
$panelBottom.Dock = "Bottom"
$panelBottom.Height = 75
$form.Controls.Add($panelBottom)

$lblObszar = New-Object System.Windows.Forms.Label
$lblObszar.Text = "Obszar:"
$lblObszar.Location = New-Object System.Drawing.Point(5, 8)
$lblObszar.AutoSize = $true
$panelBottom.Controls.Add($lblObszar)

$cmbObszar = New-Object System.Windows.Forms.ComboBox
$cmbObszar.Location = New-Object System.Drawing.Point(60, 5)
$cmbObszar.Size = New-Object System.Drawing.Size(220, 23)
$cmbObszar.DropDownStyle = "DropDownList"
$cmbObszar.Items.Add("1 - Wysylka do KSeF") | Out-Null
$cmbObszar.Items.Add("2 - Odbior z KSeF") | Out-Null
$cmbObszar.SelectedIndex = 0
$panelBottom.Controls.Add($cmbObszar)

$lblStan = New-Object System.Windows.Forms.Label
$lblStan.Text = "Stanowisko:"
$lblStan.Location = New-Object System.Drawing.Point(290, 8)
$lblStan.AutoSize = $true
$panelBottom.Controls.Add($lblStan)

$txtStan = New-Object System.Windows.Forms.TextBox
$txtStan.Location = New-Object System.Drawing.Point(370, 5)
$txtStan.Size = New-Object System.Drawing.Size(170, 23)
$panelBottom.Controls.Add($txtStan)

$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Dodaj"
$btnAdd.Location = New-Object System.Drawing.Point(550, 3)
$btnAdd.Size = New-Object System.Drawing.Size(70, 27)
$panelBottom.Controls.Add($btnAdd)

$btnDelSel = New-Object System.Windows.Forms.Button
$btnDelSel.Text = "Usun zaznaczone"
$btnDelSel.Location = New-Object System.Drawing.Point(5, 40)
$btnDelSel.Size = New-Object System.Drawing.Size(140, 27)
$panelBottom.Controls.Add($btnDelSel)

$btnClearAll = New-Object System.Windows.Forms.Button
$btnClearAll.Text = "Wyczysc tabele (odblokuj wszystkie)"
$btnClearAll.Location = New-Object System.Drawing.Point(155, 40)
$btnClearAll.Size = New-Object System.Drawing.Size(270, 27)
$panelBottom.Controls.Add($btnClearAll)

# ── Funkcje ──────────────────────────────────────────────────
function Get-ConnectionString {
    $server = $txtServer.Text.Trim()
    $db = if ($cmbDB.SelectedItem) { $cmbDB.SelectedItem.ToString() } else { "master" }
    if ($chkWinAuth.Checked) {
        return "Server=$server;Database=$db;Integrated Security=True;TrustServerCertificate=True;"
    } else {
        $login = $txtLogin.Text.Trim()
        $pass  = $txtPass.Text
        return "Server=$server;Database=$db;User Id=$login;Password=$pass;TrustServerCertificate=True;"
    }
}

function Run-Query {
    param([string]$connStr, [string]$sql, [switch]$NonQuery)
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    try {
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql
        $cmd.CommandTimeout = 30
        if ($NonQuery) {
            $result = $cmd.ExecuteNonQuery()
            return $result
        } else {
            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            $adapter.Fill($dt) | Out-Null
            return ,$dt
        }
    }
    catch {
        $msg = $_.Exception.Message
        if ($msg -match 'Login failed') {
            [System.Windows.Forms.MessageBox]::Show("Blad logowania - sprawdz login i haslo.", "Blad logowania", "OK", "Error")
        } elseif ($msg -match 'network-related|server was not found') {
            [System.Windows.Forms.MessageBox]::Show("Nie mozna polaczyc z serwerem - sprawdz nazwe serwera.", "Blad polaczenia", "OK", "Error")
        } else {
            [System.Windows.Forms.MessageBox]::Show($msg, "Blad SQL", "OK", "Error")
        }
        return $null
    }
    finally {
        $conn.Close()
    }
}

# ── Pobierz bazy ─────────────────────────────────────────────
$btnGetDBs.Add_Click({
    $statusLabel.Text = "Lacze z serwerem..."
    $form.Refresh()
    $connStr = Get-ConnectionString
    $sqlCheck = @"
IF OBJECT_ID('tempdb..#insertBazy') IS NOT NULL DROP TABLE #insertBazy
CREATE TABLE #insertBazy (dbname NVARCHAR(128))
DECLARE @sql NVARCHAR(MAX)
DECLARE @dbname NVARCHAR(128)
DECLARE cur CURSOR FOR
  SELECT name FROM sys.databases
  WHERE state_desc = 'ONLINE' AND name NOT IN ('master','tempdb','model','msdb')
OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'IF EXISTS (SELECT 1 FROM [' + @dbname + '].sys.tables WHERE name = ''ins_ident'') INSERT INTO #insertBazy VALUES (''' + @dbname + ''')'
  EXEC sp_executesql @sql
  FETCH NEXT FROM cur INTO @dbname
END
CLOSE cur
DEALLOCATE cur
SELECT dbname AS name FROM #insertBazy ORDER BY dbname
DROP TABLE #insertBazy
"@
    $dt = Run-Query -connStr $connStr -sql $sqlCheck
    if ($dt) {
        $cmbDB.Items.Clear()
        foreach ($row in $dt.Rows) {
            $cmbDB.Items.Add($row[0].ToString()) | Out-Null
        }
        $statusLabel.Text = "Pobrano $($cmbDB.Items.Count) baz InsERT"
        if ($cmbDB.Items.Count -gt 0) { $cmbDB.SelectedIndex = 0 }
    } else {
        $statusLabel.Text = "Blad polaczenia"
    }
})

# ── Wczytaj dane ─────────────────────────────────────────────
function Load-Data {
    if (-not $cmbDB.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Najpierw wybierz baze danych.", "Info", "OK", "Information")
        return
    }
    $statusLabel.Text = "Wczytuje profilowanie KSeF..."
    $form.Refresh()
    $connStr = Get-ConnectionString
    $sql = @"
SELECT
    pst_Obszar     AS [Obszar nr],
    CASE pst_Obszar
        WHEN 1 THEN 'Wysylka do KSeF'
        WHEN 2 THEN 'Odbior z KSeF'
        ELSE 'Nieznany (' + CAST(pst_Obszar AS VARCHAR) + ')'
    END            AS [Obszar],
    pst_Stanowisko AS [Stanowisko]
FROM ps_ProfilowanieStanowisk
ORDER BY pst_Obszar, pst_Stanowisko
"@
    $dt = Run-Query -connStr $connStr -sql $sql
    if ($dt) {
        $grid.DataSource = $dt
        $grid.Columns["Obszar nr"].Visible = $false
        if ($dt.Rows.Count -eq 0) {
            $statusLabel.Text = "Tabela pusta - wszystkie stanowiska realizuja zadania KSeF"
        } else {
            $statusLabel.Text = "Znaleziono $($dt.Rows.Count) wpisow profilowania"
        }
    } else {
        $statusLabel.Text = "Blad wczytywania"
    }
}

$btnLoad.Add_Click({ Load-Data })

# ── Dodaj stanowisko ─────────────────────────────────────────
$btnAdd.Add_Click({
    if (-not $cmbDB.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Najpierw wybierz baze danych.", "Info", "OK", "Information")
        return
    }
    $stanowisko = $txtStan.Text.Trim()
    if ($stanowisko -eq '') {
        [System.Windows.Forms.MessageBox]::Show("Wpisz nazwe stanowiska.", "Info", "OK", "Information")
        return
    }
    $obszar = if ($cmbObszar.SelectedIndex -eq 0) { 1 } else { 2 }
    $obszarNazwa = $cmbObszar.SelectedItem.ToString()
    $connStr = Get-ConnectionString

    $dtCheck = Run-Query -connStr $connStr -sql "SELECT 1 FROM ps_ProfilowanieStanowisk WHERE pst_Obszar = $obszar AND pst_Stanowisko = '$stanowisko'"
    if ($dtCheck -and $dtCheck.Rows.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Stanowisko '$stanowisko' jest juz przypisane do obszaru: $obszarNazwa", "Duplikat", "OK", "Warning")
        return
    }

    $result = [System.Windows.Forms.MessageBox]::Show("Dodac stanowisko '$stanowisko' do obszaru:`n$obszarNazwa ?", "Potwierdzenie", "YesNo", "Question")
    if ($result -eq "Yes") {
        $cnt = Run-Query -connStr $connStr -sql "INSERT INTO ps_ProfilowanieStanowisk (pst_Obszar, pst_Stanowisko) VALUES ($obszar, '$stanowisko')" -NonQuery
        if ($cnt -gt 0) {
            $txtStan.Text = ""
            Load-Data
        }
    }
})

# ── Usuń zaznaczone ──────────────────────────────────────────
$btnDelSel.Add_Click({
    $rows = $grid.SelectedRows
    if ($rows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Zaznacz wiersze do usuniecia.", "Info", "OK", "Information")
        return
    }
    $msg = "Usunac $($rows.Count) wpisow profilowania?`n`n"
    foreach ($r in $rows) {
        $msg += "  $($r.Cells['Stanowisko'].Value) - $($r.Cells['Obszar'].Value)`n"
    }
    $result = [System.Windows.Forms.MessageBox]::Show($msg, "Potwierdzenie", "YesNo", "Warning")
    if ($result -eq "Yes") {
        $connStr = Get-ConnectionString
        $deleted = 0
        foreach ($r in $rows) {
            $obszar = $r.Cells["Obszar nr"].Value
            $stan = $r.Cells["Stanowisko"].Value
            $cnt = Run-Query -connStr $connStr -sql "DELETE FROM ps_ProfilowanieStanowisk WHERE pst_Obszar = $obszar AND pst_Stanowisko = '$stan'" -NonQuery
            if ($cnt -gt 0) { $deleted++ }
        }
        [System.Windows.Forms.MessageBox]::Show("Usunieto $deleted wpisow.", "Gotowe", "OK", "Information")
        Load-Data
    }
})

# ── Wyczyść tabelę ───────────────────────────────────────────
$btnClearAll.Add_Click({
    if (-not $cmbDB.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Najpierw wybierz baze danych.", "Info", "OK", "Information")
        return
    }
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Usunac WSZYSTKIE wpisy profilowania?`n`nPo wyczyszczeniu tabeli wszystkie stanowiska beda realizowac zadania KSeF.`n`nUwaga: po zmianie konieczne jest ponowne uruchomienie programu InsERT.",
        "Potwierdzenie", "YesNo", "Warning")
    if ($result -eq "Yes") {
        $connStr = Get-ConnectionString
        $cnt = Run-Query -connStr $connStr -sql "DELETE FROM ps_ProfilowanieStanowisk" -NonQuery
        [System.Windows.Forms.MessageBox]::Show("Usunieto $cnt wpisow. Zrestartuj program InsERT.", "Gotowe", "OK", "Information")
        Load-Data
    }
})

# ── Start ────────────────────────────────────────────────────
$form.ShowDialog() | Out-Null
