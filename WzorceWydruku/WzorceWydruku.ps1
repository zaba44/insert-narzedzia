Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Główne okno ──────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "Wzorce wydruku - domyslne stanowiska"
$form.Size = New-Object System.Drawing.Size(820, 620)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.MinimumSize = New-Object System.Drawing.Size(820, 520)

# ── Panel połączenia ─────────────────────────────────────────
$panelConn = New-Object System.Windows.Forms.GroupBox
$panelConn.Text = "Polaczenie z SQL Server"
$panelConn.Location = New-Object System.Drawing.Point(10, 10)
$panelConn.Size = New-Object System.Drawing.Size(780, 100)
$panelConn.Anchor = "Top,Left,Right"
$form.Controls.Add($panelConn)

# Serwer
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

# Typ autentykacji
$chkWinAuth = New-Object System.Windows.Forms.CheckBox
$chkWinAuth.Text = "Windows Auth"
$chkWinAuth.Location = New-Object System.Drawing.Point(260, 23)
$chkWinAuth.AutoSize = $true
$chkWinAuth.Checked = $false
$panelConn.Controls.Add($chkWinAuth)

# Login
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

# Hasło
$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = "Haslo:"
$lblPass.Location = New-Object System.Drawing.Point(545, 25)
$lblPass.AutoSize = $true
$panelConn.Controls.Add($lblPass)

$txtPass = New-Object System.Windows.Forms.TextBox
$txtPass.Location = New-Object System.Drawing.Point(590, 22)
$txtPass.Size = New-Object System.Drawing.Size(100, 23)
$txtPass.UseSystemPasswordChar = $true
$txtPass.Enabled = $true
$panelConn.Controls.Add($txtPass)

# Toggle login/hasło
$chkWinAuth.Add_CheckedChanged({
    $txtLogin.Enabled = -not $chkWinAuth.Checked
    $txtPass.Enabled  = -not $chkWinAuth.Checked
})

# Baza
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

# Przycisk - Pobierz bazy
$btnGetDBs = New-Object System.Windows.Forms.Button
$btnGetDBs.Text = "Pobierz bazy"
$btnGetDBs.Location = New-Object System.Drawing.Point(260, 55)
$btnGetDBs.Size = New-Object System.Drawing.Size(100, 27)
$panelConn.Controls.Add($btnGetDBs)

# Przycisk - Wczytaj wzorce
$btnLoad = New-Object System.Windows.Forms.Button
$btnLoad.Text = "Wczytaj wzorce"
$btnLoad.Location = New-Object System.Drawing.Point(370, 55)
$btnLoad.Size = New-Object System.Drawing.Size(120, 27)
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
$grid.Size = New-Object System.Drawing.Size(780, 380)
$grid.Anchor = "Top,Bottom,Left,Right"
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $true
$grid.SelectionMode = "FullRowSelect"
$grid.MultiSelect = $true
$grid.AutoSizeColumnsMode = "Fill"
$grid.RowHeadersVisible = $false
$grid.BackgroundColor = [System.Drawing.Color]::White
$grid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 250)
$form.Controls.Add($grid)

# ── Panel przycisków ─────────────────────────────────────────
$panelBtn = New-Object System.Windows.Forms.Panel
$panelBtn.Dock = "Bottom"
$panelBtn.Height = 45
$form.Controls.Add($panelBtn)

$btnDeleteSel = New-Object System.Windows.Forms.Button
$btnDeleteSel.Text = "Usun zaznaczone stanowiska"
$btnDeleteSel.Location = New-Object System.Drawing.Point(10, 8)
$btnDeleteSel.Size = New-Object System.Drawing.Size(200, 30)
$panelBtn.Controls.Add($btnDeleteSel)

$btnDeleteForTemplate = New-Object System.Windows.Forms.Button
$btnDeleteForTemplate.Text = "Usun wszystkie stanowiska dla wzorca"
$btnDeleteForTemplate.Location = New-Object System.Drawing.Point(220, 8)
$btnDeleteForTemplate.Size = New-Object System.Drawing.Size(260, 30)
$panelBtn.Controls.Add($btnDeleteForTemplate)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "Odswiez"
$btnRefresh.Location = New-Object System.Drawing.Point(490, 8)
$btnRefresh.Size = New-Object System.Drawing.Size(90, 30)
$panelBtn.Controls.Add($btnRefresh)

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

# ── Wczytaj wzorce ───────────────────────────────────────────
function Load-Data {
    if (-not $cmbDB.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Najpierw wybierz baze danych.", "Info", "OK", "Information")
        return
    }
    $statusLabel.Text = "Wczytuje wzorce..."
    $form.Refresh()
    $connStr = Get-ConnectionString
    $sql = @"
SELECT
    wzd_Id        AS [ID],
    wzd_NazwaKomputera AS [Stanowisko],
    wzw_Nazwa     AS [Wzorzec wydruku],
    wtp_Nazwa     AS [Typ wzorca],
    wzw_Id        AS [ID wzorca],
    wzd_Typ       AS [Typ]
FROM wy_WzDomyslny
JOIN wy_Wzorzec ON wzw_Id = wzd_WzorzecId
LEFT JOIN wy_Typ ON wtp_Id = wzw_Typ
WHERE wzd_NazwaKomputera IS NOT NULL
  AND wzd_NazwaKomputera <> ''
ORDER BY wzd_NazwaKomputera, wtp_Nazwa, wzw_Nazwa
"@
    $dt = Run-Query -connStr $connStr -sql $sql
    if ($dt) {
        $grid.DataSource = $dt
        # Ukryj kolumnę ID (do usuwania), ale zostaw widoczną
        $grid.Columns["ID"].Visible = $false
        $grid.Columns["Typ"].Visible = $false
        $statusLabel.Text = "Znaleziono $($dt.Rows.Count) przypiasan stanowisk"
    } else {
        $statusLabel.Text = "Blad wczytywania"
    }
}

$btnLoad.Add_Click({ Load-Data })
$btnRefresh.Add_Click({ Load-Data })

# ── Usuń zaznaczone ──────────────────────────────────────────
$btnDeleteSel.Add_Click({
    $rows = $grid.SelectedRows
    if ($rows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Zaznacz wiersze do usuniecia.", "Info", "OK", "Information")
        return
    }

    $msg = "Usunac $($rows.Count) przypiasan stanowisk?`n`n"
    foreach ($r in $rows) {
        $msg += "  $($r.Cells['Stanowisko'].Value) - $($r.Cells['Wzorzec wydruku'].Value)`n"
    }

    $result = [System.Windows.Forms.MessageBox]::Show($msg, "Potwierdzenie", "YesNo", "Warning")
    if ($result -eq "Yes") {
        $connStr = Get-ConnectionString
        $deleted = 0
        foreach ($r in $rows) {
            $id = $r.Cells["ID"].Value
            $cnt = Run-Query -connStr $connStr -sql "DELETE FROM wy_WzDomyslny WHERE wzd_Id = $id" -NonQuery
            if ($cnt -gt 0) { $deleted++ }
        }
        [System.Windows.Forms.MessageBox]::Show("Usunieto $deleted z $($rows.Count) wpisow.", "Gotowe", "OK", "Information")
        Load-Data
    }
})

# ── Usuń wszystkie stanowiska dla wzorca ─────────────────────
$btnDeleteForTemplate.Add_Click({
    $rows = $grid.SelectedRows
    if ($rows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Zaznacz wiersz ze wzorcem.", "Info", "OK", "Information")
        return
    }

    $wzorcId = $rows[0].Cells["ID wzorca"].Value
    $wzorcNazwa = $rows[0].Cells["Wzorzec wydruku"].Value

    # Policz ile stanowisk
    $connStr = Get-ConnectionString
    $dt = Run-Query -connStr $connStr -sql "SELECT wzd_NazwaKomputera FROM wy_WzDomyslny WHERE wzd_WzorzecId = $wzorcId AND wzd_NazwaKomputera IS NOT NULL AND wzd_NazwaKomputera <> ''"
    if (-not $dt -or $dt.Rows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Brak stanowisk do usuniecia.", "Info", "OK", "Information")
        return
    }

    $msg = "Usunac WSZYSTKIE stanowiska ($($dt.Rows.Count)) dla wzorca:`n`n  $wzorcNazwa`n`nStanowiska:`n"
    foreach ($r in $dt.Rows) {
        $msg += "  - $($r[0])`n"
    }

    $result = [System.Windows.Forms.MessageBox]::Show($msg, "Potwierdzenie", "YesNo", "Warning")
    if ($result -eq "Yes") {
        $cnt = Run-Query -connStr $connStr -sql "DELETE FROM wy_WzDomyslny WHERE wzd_WzorzecId = $wzorcId AND wzd_NazwaKomputera IS NOT NULL AND wzd_NazwaKomputera <> ''" -NonQuery
        [System.Windows.Forms.MessageBox]::Show("Usunieto $cnt wpisow.", "Gotowe", "OK", "Information")
        Load-Data
    }
})

# ── Start ────────────────────────────────────────────────────
$form.ShowDialog() | Out-Null
