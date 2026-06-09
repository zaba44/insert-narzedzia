Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Data

# ════════════════════════════════════════════════════════════
#  KONFIGURACJA – %APPDATA%\GLN_Editor\config.xml
# ════════════════════════════════════════════════════════════
$script:configDir  = Join-Path $env:APPDATA "GLN_Editor"
$script:configFile = Join-Path $script:configDir "config.xml"

function Save-Config {
    if (-not (Test-Path $script:configDir)) { New-Item -ItemType Directory -Path $script:configDir | Out-Null }
    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Config")
    $xml.AppendChild($root) | Out-Null
    $dbVal = if ($cmbDB.SelectedItem) { $cmbDB.SelectedItem.ToString() } else { "" }
    foreach ($pair in @(
        @("Server",  $txtServer.Text.Trim()),
        @("WinAuth", $chkWinAuth.Checked.ToString()),
        @("Login",   $txtLogin.Text.Trim()),
        @("Pass",    $txtPass.Text),
        @("DB",      $dbVal)
    )) {
        $el = $xml.CreateElement($pair[0])
        $el.InnerText = $pair[1]
        $root.AppendChild($el) | Out-Null
    }
    $xml.Save($script:configFile)
}

function Load-Config {
    if (-not (Test-Path $script:configFile)) { return }
    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.Load($script:configFile)
        $r = $xml.SelectSingleNode("Config")
        if ($r.SelectSingleNode("Server"))  { $txtServer.Text  = $r.SelectSingleNode("Server").InnerText }
        if ($r.SelectSingleNode("WinAuth")) { $chkWinAuth.Checked = [bool]::Parse($r.SelectSingleNode("WinAuth").InnerText) }
        if ($r.SelectSingleNode("Login"))   { $txtLogin.Text   = $r.SelectSingleNode("Login").InnerText }
        if ($r.SelectSingleNode("Pass"))    { $txtPass.Text    = $r.SelectSingleNode("Pass").InnerText }
        $script:savedDB = if ($r.SelectSingleNode("DB")) { $r.SelectSingleNode("DB").InnerText } else { "" }
    } catch {}
}

$script:savedDB = ""

# ════════════════════════════════════════════════════════════
#  GLOWNE OKNO
# ════════════════════════════════════════════════════════════
$form = New-Object System.Windows.Forms.Form
$form.Text = "Edytor GLN kontrahentow"
$form.Size = New-Object System.Drawing.Size(980, 680)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.MinimumSize = New-Object System.Drawing.Size(820, 560)

# ── Panel polaczenia ──────────────────────────────────────────
$panelConn = New-Object System.Windows.Forms.GroupBox
$panelConn.Text = "Polaczenie z SQL Server"
$panelConn.Location = New-Object System.Drawing.Point(10, 10)
$panelConn.Size = New-Object System.Drawing.Size(940, 100)
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
$panelConn.Controls.Add($txtLogin)

$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = "Haslo:"
$lblPass.Location = New-Object System.Drawing.Point(545, 25)
$lblPass.AutoSize = $true
$panelConn.Controls.Add($lblPass)

$txtPass = New-Object System.Windows.Forms.TextBox
$txtPass.Location = New-Object System.Drawing.Point(590, 22)
$txtPass.Size = New-Object System.Drawing.Size(100, 23)
$txtPass.UseSystemPasswordChar = $true
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

$lblDBStatus = New-Object System.Windows.Forms.Label
$lblDBStatus.Text = ""
$lblDBStatus.Location = New-Object System.Drawing.Point(370, 62)
$lblDBStatus.Size = New-Object System.Drawing.Size(450, 16)
$lblDBStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 130, 60)
$panelConn.Controls.Add($lblDBStatus)

# ── Status bar ────────────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Gotowe"
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# ── TabControl ────────────────────────────────────────────────
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(10, 118)
$tabs.Size = New-Object System.Drawing.Size(940, 500)
$tabs.Anchor = "Top,Bottom,Left,Right"
$form.Controls.Add($tabs)

# ════════════════════════════════════════════════════════════
#  TAB 1 – RECZNE WPROWADZANIE GLN
# ════════════════════════════════════════════════════════════
$tab1 = New-Object System.Windows.Forms.TabPage
$tab1.Text = "  Reczne wprowadzanie GLN  "
$tab1.Padding = New-Object System.Windows.Forms.Padding(0)
$tabs.Controls.Add($tab1)

$tlp1 = New-Object System.Windows.Forms.TableLayoutPanel
$tlp1.Dock = "Fill"
$tlp1.RowCount = 3
$tlp1.ColumnCount = 1
$tlp1.Padding = New-Object System.Windows.Forms.Padding(0)
$tlp1.Margin = New-Object System.Windows.Forms.Padding(0)
[void]$tlp1.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$tlp1.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 38)))
[void]$tlp1.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$tlp1.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 68)))
$tab1.Controls.Add($tlp1)

# Wiersz 0: wyszukiwanie
$pSearch = New-Object System.Windows.Forms.Panel
$pSearch.Dock = "Fill"
$pSearch.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 252)

$lblSearch = New-Object System.Windows.Forms.Label
$lblSearch.Text = "Nazwa / NIP / Symbol:"
$lblSearch.Location = New-Object System.Drawing.Point(8, 10)
$lblSearch.AutoSize = $true
$pSearch.Controls.Add($lblSearch)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = New-Object System.Drawing.Point(148, 7)
$txtSearch.Size = New-Object System.Drawing.Size(280, 23)
$pSearch.Controls.Add($txtSearch)

$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Szukaj"
$btnSearch.Location = New-Object System.Drawing.Point(438, 5)
$btnSearch.Size = New-Object System.Drawing.Size(75, 27)
$pSearch.Controls.Add($btnSearch)

$btnShowAll = New-Object System.Windows.Forms.Button
$btnShowAll.Text = "Pokaz wszystkich"
$btnShowAll.Location = New-Object System.Drawing.Point(522, 5)
$btnShowAll.Size = New-Object System.Drawing.Size(130, 27)
$pSearch.Controls.Add($btnShowAll)

$chkNoGLN = New-Object System.Windows.Forms.CheckBox
$chkNoGLN.Text = "Tylko bez GLN"
$chkNoGLN.Location = New-Object System.Drawing.Point(665, 8)
$chkNoGLN.AutoSize = $true
$pSearch.Controls.Add($chkNoGLN)

$tlp1.Controls.Add($pSearch, 0, 0)

# Wiersz 1: siatka
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = "Fill"
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $true
$grid.SelectionMode = "FullRowSelect"
$grid.MultiSelect = $false
$grid.AutoSizeColumnsMode = "Fill"
$grid.RowHeadersVisible = $false
$grid.BackgroundColor = [System.Drawing.Color]::White
$grid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 250)
$tlp1.Controls.Add($grid, 0, 1)

# Wiersz 2: edytor GLN (wyzszy - dwa wiersze etykiet)
$pGLN = New-Object System.Windows.Forms.Panel
$pGLN.Dock = "Fill"
$pGLN.BackColor = [System.Drawing.Color]::FromArgb(228, 235, 255)

$lblSelInfo = New-Object System.Windows.Forms.Label
$lblSelInfo.Text = "Wybierz kontrahenta z listy..."
$lblSelInfo.Location = New-Object System.Drawing.Point(10, 4)
$lblSelInfo.Size = New-Object System.Drawing.Size(900, 16)
$lblSelInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$lblSelInfo.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 100)
$pGLN.Controls.Add($lblSelInfo)

# Wiersz ostrzezenia o rozbieznosci
$lblWarning = New-Object System.Windows.Forms.Label
$lblWarning.Text = ""
$lblWarning.Location = New-Object System.Drawing.Point(10, 22)
$lblWarning.Size = New-Object System.Drawing.Size(900, 16)
$lblWarning.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblWarning.ForeColor = [System.Drawing.Color]::FromArgb(180, 80, 0)
$pGLN.Controls.Add($lblWarning)

$lblGLNLabel = New-Object System.Windows.Forms.Label
$lblGLNLabel.Text = "GLN (13 cyfr):"
$lblGLNLabel.Location = New-Object System.Drawing.Point(10, 42)
$lblGLNLabel.AutoSize = $true
$pGLN.Controls.Add($lblGLNLabel)

$txtGLN = New-Object System.Windows.Forms.TextBox
$txtGLN.Location = New-Object System.Drawing.Point(110, 39)
$txtGLN.Size = New-Object System.Drawing.Size(165, 23)
$txtGLN.MaxLength = 32767
$txtGLN.Font = New-Object System.Drawing.Font("Consolas", 10)
$txtGLN.Enabled = $false
$pGLN.Controls.Add($txtGLN)

$lblGLNCount = New-Object System.Windows.Forms.Label
$lblGLNCount.Text = "0 / 13"
$lblGLNCount.Location = New-Object System.Drawing.Point(282, 42)
$lblGLNCount.Size = New-Object System.Drawing.Size(55, 20)
$lblGLNCount.ForeColor = [System.Drawing.Color]::Gray
$pGLN.Controls.Add($lblGLNCount)

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "Zapisz GLN"
$btnSave.Location = New-Object System.Drawing.Point(345, 37)
$btnSave.Size = New-Object System.Drawing.Size(100, 27)
$btnSave.Enabled = $false
$btnSave.BackColor = [System.Drawing.Color]::FromArgb(0, 140, 70)
$btnSave.ForeColor = [System.Drawing.Color]::White
$btnSave.FlatStyle = "Flat"
$pGLN.Controls.Add($btnSave)

$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Text = "Usun GLN"
$btnDelete.Location = New-Object System.Drawing.Point(455, 37)
$btnDelete.Size = New-Object System.Drawing.Size(100, 27)
$btnDelete.Enabled = $false
$btnDelete.BackColor = [System.Drawing.Color]::FromArgb(180, 30, 30)
$btnDelete.ForeColor = [System.Drawing.Color]::White
$btnDelete.FlatStyle = "Flat"
$pGLN.Controls.Add($btnDelete)

$btnSyncHist = New-Object System.Windows.Forms.Button
$btnSyncHist.Text = "Sync -> Historia"
$btnSyncHist.Location = New-Object System.Drawing.Point(565, 37)
$btnSyncHist.Size = New-Object System.Drawing.Size(120, 27)
$btnSyncHist.Enabled = $false
$btnSyncHist.BackColor = [System.Drawing.Color]::FromArgb(0, 90, 180)
$btnSyncHist.ForeColor = [System.Drawing.Color]::White
$btnSyncHist.FlatStyle = "Flat"
$btnSyncHist.Visible = $false
$pGLN.Controls.Add($btnSyncHist)

$tlp1.Controls.Add($pGLN, 0, 2)

# ════════════════════════════════════════════════════════════
#  TAB 2 – KOPIOWANIE Z POLA WLASNEGO
# ════════════════════════════════════════════════════════════
$tab2 = New-Object System.Windows.Forms.TabPage
$tab2.Text = "  Kopiowanie z pola wlasnego  "
$tab2.Padding = New-Object System.Windows.Forms.Padding(0)
$tabs.Controls.Add($tab2)

$tlp2 = New-Object System.Windows.Forms.TableLayoutPanel
$tlp2.Dock = "Fill"
$tlp2.RowCount = 3
$tlp2.ColumnCount = 1
$tlp2.Padding = New-Object System.Windows.Forms.Padding(0)
$tlp2.Margin = New-Object System.Windows.Forms.Padding(0)
[void]$tlp2.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$tlp2.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 70)))
[void]$tlp2.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$tlp2.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 44)))
$tab2.Controls.Add($tlp2)

$pPole = New-Object System.Windows.Forms.Panel
$pPole.Dock = "Fill"
$pPole.BackColor = [System.Drawing.Color]::FromArgb(245, 248, 255)

$lblPole = New-Object System.Windows.Forms.Label
$lblPole.Text = "Pole wlasne - zrodlo GLN:"
$lblPole.Location = New-Object System.Drawing.Point(10, 12)
$lblPole.AutoSize = $true
$pPole.Controls.Add($lblPole)

$cmbPole = New-Object System.Windows.Forms.ComboBox
$cmbPole.Location = New-Object System.Drawing.Point(190, 9)
$cmbPole.Size = New-Object System.Drawing.Size(280, 23)
$cmbPole.DropDownStyle = "DropDownList"
$pPole.Controls.Add($cmbPole)

$btnPreview = New-Object System.Windows.Forms.Button
$btnPreview.Text = "Wczytaj podglad"
$btnPreview.Location = New-Object System.Drawing.Point(485, 7)
$btnPreview.Size = New-Object System.Drawing.Size(130, 27)
$pPole.Controls.Add($btnPreview)

$lblPoleHint = New-Object System.Windows.Forms.Label
$lblPoleHint.Text = "Lista pokazuje kontrahentow gdzie wybrane pole ma 13 cyfr i GLN jest jeszcze pusty."
$lblPoleHint.Location = New-Object System.Drawing.Point(10, 42)
$lblPoleHint.AutoSize = $true
$lblPoleHint.ForeColor = [System.Drawing.Color]::Gray
$pPole.Controls.Add($lblPoleHint)

$tlp2.Controls.Add($pPole, 0, 0)

$grid2 = New-Object System.Windows.Forms.DataGridView
$grid2.Dock = "Fill"
$grid2.AllowUserToAddRows = $false
$grid2.AllowUserToDeleteRows = $false
$grid2.ReadOnly = $true
$grid2.SelectionMode = "FullRowSelect"
$grid2.MultiSelect = $false
$grid2.AutoSizeColumnsMode = "Fill"
$grid2.RowHeadersVisible = $false
$grid2.BackgroundColor = [System.Drawing.Color]::White
$grid2.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 249, 235)
$tlp2.Controls.Add($grid2, 0, 1)

$pCopyBtn = New-Object System.Windows.Forms.Panel
$pCopyBtn.Dock = "Fill"
$pCopyBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 244, 220)

$btnCopyAll = New-Object System.Windows.Forms.Button
$btnCopyAll.Text = "Kopiuj GLN dla wszystkich na liscie"
$btnCopyAll.Location = New-Object System.Drawing.Point(10, 8)
$btnCopyAll.Size = New-Object System.Drawing.Size(250, 28)
$btnCopyAll.Enabled = $false
$btnCopyAll.BackColor = [System.Drawing.Color]::FromArgb(190, 90, 0)
$btnCopyAll.ForeColor = [System.Drawing.Color]::White
$btnCopyAll.FlatStyle = "Flat"
$pCopyBtn.Controls.Add($btnCopyAll)

$lblCopyHint = New-Object System.Windows.Forms.Label
$lblCopyHint.Text = "Aktualizuje adr__Ewid i adr_Historia. Nadpisuje tylko puste pola GLN."
$lblCopyHint.Location = New-Object System.Drawing.Point(275, 14)
$lblCopyHint.AutoSize = $true
$lblCopyHint.ForeColor = [System.Drawing.Color]::FromArgb(140, 60, 0)
$pCopyBtn.Controls.Add($lblCopyHint)

$tlp2.Controls.Add($pCopyBtn, 0, 2)

# ════════════════════════════════════════════════════════════
#  TAB 3 – CZYSZCZENIE GLN
# ════════════════════════════════════════════════════════════
$tab3 = New-Object System.Windows.Forms.TabPage
$tab3.Text = "  Czyszczenie GLN  "
$tab3.Padding = New-Object System.Windows.Forms.Padding(10)
$tabs.Controls.Add($tab3)

$tlp3 = New-Object System.Windows.Forms.TableLayoutPanel
$tlp3.Dock = "Fill"
$tlp3.RowCount = 2
$tlp3.ColumnCount = 2
$tlp3.Padding = New-Object System.Windows.Forms.Padding(5)
[void]$tlp3.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)))
[void]$tlp3.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)))
[void]$tlp3.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 180)))
[void]$tlp3.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$tab3.Controls.Add($tlp3)

# Lewa karta - adr__Ewid
$gbEwid = New-Object System.Windows.Forms.GroupBox
$gbEwid.Text = "Tabela adr__Ewid (adr_GLN)"
$gbEwid.Dock = "Fill"
$gbEwid.Margin = New-Object System.Windows.Forms.Padding(5)
$gbEwid.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$lblEwidInfo = New-Object System.Windows.Forms.Label
$lblEwidInfo.Text = "Wyczysci pole adr_GLN (ustawi NULL) dla WSZYSTKICH kontrahentow w bazie."
$lblEwidInfo.Location = New-Object System.Drawing.Point(10, 28)
$lblEwidInfo.Size = New-Object System.Drawing.Size(380, 40)
$lblEwidInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$gbEwid.Controls.Add($lblEwidInfo)

$lblEwidCount = New-Object System.Windows.Forms.Label
$lblEwidCount.Text = ""
$lblEwidCount.Location = New-Object System.Drawing.Point(10, 72)
$lblEwidCount.Size = New-Object System.Drawing.Size(380, 20)
$lblEwidCount.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblEwidCount.ForeColor = [System.Drawing.Color]::FromArgb(0, 100, 0)
$gbEwid.Controls.Add($lblEwidCount)

$btnCheckEwid = New-Object System.Windows.Forms.Button
$btnCheckEwid.Text = "Sprawdz ile rekordow ma GLN"
$btnCheckEwid.Location = New-Object System.Drawing.Point(10, 98)
$btnCheckEwid.Size = New-Object System.Drawing.Size(200, 27)
$btnCheckEwid.FlatStyle = "Flat"
$gbEwid.Controls.Add($btnCheckEwid)

$btnClearEwid = New-Object System.Windows.Forms.Button
$btnClearEwid.Text = "Wyczysc adr__Ewid.adr_GLN"
$btnClearEwid.Location = New-Object System.Drawing.Point(10, 133)
$btnClearEwid.Size = New-Object System.Drawing.Size(200, 30)
$btnClearEwid.BackColor = [System.Drawing.Color]::FromArgb(180, 30, 30)
$btnClearEwid.ForeColor = [System.Drawing.Color]::White
$btnClearEwid.FlatStyle = "Flat"
$btnClearEwid.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$gbEwid.Controls.Add($btnClearEwid)

$tlp3.Controls.Add($gbEwid, 0, 0)

# Prawa karta - adr_Historia
$gbHist = New-Object System.Windows.Forms.GroupBox
$gbHist.Text = "Tabela adr_Historia (adrh_GLN)"
$gbHist.Dock = "Fill"
$gbHist.Margin = New-Object System.Windows.Forms.Padding(5)
$gbHist.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$lblHistInfo = New-Object System.Windows.Forms.Label
$lblHistInfo.Text = "Wyczysci pole adrh_GLN (ustawi NULL) dla WSZYSTKICH wpisow historii adresow."
$lblHistInfo.Location = New-Object System.Drawing.Point(10, 28)
$lblHistInfo.Size = New-Object System.Drawing.Size(380, 40)
$lblHistInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$gbHist.Controls.Add($lblHistInfo)

$lblHistCount = New-Object System.Windows.Forms.Label
$lblHistCount.Text = ""
$lblHistCount.Location = New-Object System.Drawing.Point(10, 72)
$lblHistCount.Size = New-Object System.Drawing.Size(380, 20)
$lblHistCount.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblHistCount.ForeColor = [System.Drawing.Color]::FromArgb(0, 100, 0)
$gbHist.Controls.Add($lblHistCount)

$btnCheckHist = New-Object System.Windows.Forms.Button
$btnCheckHist.Text = "Sprawdz ile rekordow ma GLN"
$btnCheckHist.Location = New-Object System.Drawing.Point(10, 98)
$btnCheckHist.Size = New-Object System.Drawing.Size(200, 27)
$btnCheckHist.FlatStyle = "Flat"
$gbHist.Controls.Add($btnCheckHist)

$btnClearHist = New-Object System.Windows.Forms.Button
$btnClearHist.Text = "Wyczysc adr_Historia.adrh_GLN"
$btnClearHist.Location = New-Object System.Drawing.Point(10, 133)
$btnClearHist.Size = New-Object System.Drawing.Size(220, 30)
$btnClearHist.BackColor = [System.Drawing.Color]::FromArgb(180, 30, 30)
$btnClearHist.ForeColor = [System.Drawing.Color]::White
$btnClearHist.FlatStyle = "Flat"
$btnClearHist.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$gbHist.Controls.Add($btnClearHist)

$tlp3.Controls.Add($gbHist, 1, 0)

# Siatka rozbieznosci (wiersz 1, oba kolumny)
$gbDiff = New-Object System.Windows.Forms.GroupBox
$gbDiff.Text = "Kontrahenci z rozbieznoscia GLN miedzy adr__Ewid a adr_Historia"
$gbDiff.Dock = "Fill"
$gbDiff.Margin = New-Object System.Windows.Forms.Padding(5)
$tlp3.Controls.Add($gbDiff, 0, 1)
$tlp3.SetColumnSpan($gbDiff, 2)

$btnCheckDiff = New-Object System.Windows.Forms.Button
$btnCheckDiff.Text = "Znajdz rozbieznosci"
$btnCheckDiff.Location = New-Object System.Drawing.Point(10, 22)
$btnCheckDiff.Size = New-Object System.Drawing.Size(160, 27)
$btnCheckDiff.FlatStyle = "Flat"
$gbDiff.Controls.Add($btnCheckDiff)

$btnSyncEwidToHist = New-Object System.Windows.Forms.Button
$btnSyncEwidToHist.Text = "Sync: Ewid -> Historia (dla zaznaczonych)"
$btnSyncEwidToHist.Location = New-Object System.Drawing.Point(185, 22)
$btnSyncEwidToHist.Size = New-Object System.Drawing.Size(270, 27)
$btnSyncEwidToHist.BackColor = [System.Drawing.Color]::FromArgb(0, 90, 180)
$btnSyncEwidToHist.ForeColor = [System.Drawing.Color]::White
$btnSyncEwidToHist.FlatStyle = "Flat"
$btnSyncEwidToHist.Enabled = $false
$gbDiff.Controls.Add($btnSyncEwidToHist)

$btnSyncHistToEwid = New-Object System.Windows.Forms.Button
$btnSyncHistToEwid.Text = "Sync: Historia -> Ewid (dla zaznaczonych)"
$btnSyncHistToEwid.Location = New-Object System.Drawing.Point(465, 22)
$btnSyncHistToEwid.Size = New-Object System.Drawing.Size(270, 27)
$btnSyncHistToEwid.BackColor = [System.Drawing.Color]::FromArgb(90, 0, 160)
$btnSyncHistToEwid.ForeColor = [System.Drawing.Color]::White
$btnSyncHistToEwid.FlatStyle = "Flat"
$btnSyncHistToEwid.Enabled = $false
$gbDiff.Controls.Add($btnSyncHistToEwid)

$gridDiff = New-Object System.Windows.Forms.DataGridView
$gridDiff.Location = New-Object System.Drawing.Point(10, 58)
$gridDiff.Anchor = "Top,Bottom,Left,Right"
$gridDiff.AllowUserToAddRows = $false
$gridDiff.AllowUserToDeleteRows = $false
$gridDiff.ReadOnly = $true
$gridDiff.SelectionMode = "FullRowSelect"
$gridDiff.MultiSelect = $true
$gridDiff.AutoSizeColumnsMode = "Fill"
$gridDiff.RowHeadersVisible = $false
$gridDiff.BackgroundColor = [System.Drawing.Color]::White
$gbDiff.Controls.Add($gridDiff)

$gbDiff.Add_Resize({
    $gridDiff.Size = New-Object System.Drawing.Size(($gbDiff.Width - 20), ($gbDiff.Height - 70))
})

# ════════════════════════════════════════════════════════════
#  FUNKCJE
# ════════════════════════════════════════════════════════════
function Get-ConnStr {
    param([string]$db = "")
    $srv = $txtServer.Text.Trim()
    $d   = if ($db) { $db } elseif ($cmbDB.SelectedItem) { $cmbDB.SelectedItem.ToString() } else { "master" }
    if ($chkWinAuth.Checked) {
        return "Server=$srv;Database=$d;Integrated Security=True;TrustServerCertificate=True;"
    } else {
        return "Server=$srv;Database=$d;User Id=$($txtLogin.Text.Trim());Password=$($txtPass.Text);TrustServerCertificate=True;"
    }
}

function Run-Query {
    param([string]$cs, [string]$sql, [switch]$NonQuery, [hashtable]$P = @{})
    $conn = New-Object System.Data.SqlClient.SqlConnection($cs)
    try {
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql
        $cmd.CommandTimeout = 30
        foreach ($k in $P.Keys) { $cmd.Parameters.AddWithValue($k, $P[$k]) | Out-Null }
        if ($NonQuery) { return $cmd.ExecuteNonQuery() }
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $adapter.Fill($dt) | Out-Null
        return ,$dt
    } catch {
        $msg = $_.Exception.Message
        if ($msg -match 'Login failed') { [System.Windows.Forms.MessageBox]::Show("Blad logowania.", "Blad", "OK", "Error") }
        elseif ($msg -match 'network-related|server was not found') { [System.Windows.Forms.MessageBox]::Show("Blad polaczenia z serwerem.", "Blad", "OK", "Error") }
        else { [System.Windows.Forms.MessageBox]::Show($msg, "Blad SQL", "OK", "Error") }
        return $null
    } finally { $conn.Close() }
}

function Check-GLNColumn {
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='adr__Ewid' AND COLUMN_NAME='adr_GLN'"
    if ($dt -and [int]$dt.Rows[0]["cnt"] -gt 0) {
        $lblDBStatus.Text = "GLN: kolumna dostepna w bazie"
        $lblDBStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 130, 60)
        return $true
    }
    $lblDBStatus.Text = "UWAGA: brak kolumny adr_GLN - stara wersja InsERT?"
    $lblDBStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 0, 0)
    [System.Windows.Forms.MessageBox]::Show("Kolumna adr_GLN nie istnieje w adr__Ewid.", "Brak GLN", "OK", "Warning")
    return $false
}

function Load-FieldNames {
    $script:poleMap = @{}
    $cmbPole.Items.Clear()
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT khp_Nazwa1,khp_Nazwa2,khp_Nazwa3,khp_Nazwa4,khp_Nazwa5,khp_Nazwa6,khp_Nazwa7,khp_Nazwa8 FROM kh_ParametrG"
    if (-not $dt -or $dt.Rows.Count -eq 0) { return }
    $row = $dt.Rows[0]
    for ($i = 1; $i -le 8; $i++) {
        $n = $row["khp_Nazwa$i"].ToString().Trim()
        if ($n -ne "") {
            $label = "kh_Pole$i  -  $n"
            $cmbPole.Items.Add($label) | Out-Null
            $script:poleMap[$label] = "kh_Pole$i"
        }
    }
    if ($cmbPole.Items.Count -gt 0) { $cmbPole.SelectedIndex = 0 }
}

function Get-SelectedPole {
    if ($cmbPole.SelectedIndex -lt 0 -or -not $cmbPole.SelectedItem) { return $null }
    $label = $cmbPole.SelectedItem.ToString()
    if ($script:poleMap.ContainsKey($label)) { return $script:poleMap[$label] }
    return $null
}

function Apply-RowColors { param($g)
    foreach ($row in $g.Rows) {
        $v = if ($g.Columns["Aktualny GLN"]) { $row.Cells["Aktualny GLN"].Value } else { $null }
        $row.DefaultCellStyle.ForeColor = if ([string]::IsNullOrWhiteSpace($v)) {
            [System.Drawing.Color]::FromArgb(180, 0, 0)
        } else { [System.Drawing.Color]::Black }
    }
}

function Check-Discrepancy {
    # Sprawdz czy historia ma inny GLN niz adr__Ewid dla wybranego kontrahenta
    param([int]$adrId, [string]$ewidGLN)
    if ($adrId -le 0) { return $null }
    $dt = Run-Query -cs (Get-ConnStr) -sql @"
SELECT TOP 1 ISNULL(adrh_GLN,'') AS hist_GLN
FROM adr_Historia
WHERE adrh_IdAdresu = @id
  AND ISNULL(adrh_GLN,'') <> ''
ORDER BY adrh_Id DESC
"@ -P @{"@id" = $adrId}
    if (-not $dt -or $dt.Rows.Count -eq 0) { return $null }
    $histGLN = $dt.Rows[0]["hist_GLN"].ToString().Trim()
    $ewidGLN = $ewidGLN.Trim()
    if ($histGLN -ne "" -and $histGLN -ne $ewidGLN) { return $histGLN }
    return $null
}

$script:poleMap    = @{}
$script:selKhId    = 0
$script:selAdrId   = 0
$script:lastPhrase = ""
$script:lastAll    = $true
$script:histGLN    = ""

# ════════════════════════════════════════════════════════════
#  LOGIKA – POLACZENIE
# ════════════════════════════════════════════════════════════
$btnGetDBs.Add_Click({
    $statusLabel.Text = "Lacze..."; $form.Refresh()
    $sql = @"
IF OBJECT_ID('tempdb..#b') IS NOT NULL DROP TABLE #b
CREATE TABLE #b (n NVARCHAR(128))
DECLARE @s NVARCHAR(MAX),@d NVARCHAR(128)
DECLARE c CURSOR FOR SELECT name FROM sys.databases WHERE state_desc='ONLINE' AND name NOT IN('master','tempdb','model','msdb')
OPEN c; FETCH NEXT FROM c INTO @d
WHILE @@FETCH_STATUS=0 BEGIN
  SET @s='IF EXISTS(SELECT 1 FROM ['+@d+'].sys.tables WHERE name=''ins_ident'') INSERT INTO #b VALUES('''+@d+''')'
  EXEC sp_executesql @s; FETCH NEXT FROM c INTO @d
END
CLOSE c; DEALLOCATE c
SELECT n AS name FROM #b ORDER BY n
DROP TABLE #b
"@
    $dt = Run-Query -cs (Get-ConnStr -db "master") -sql $sql
    if ($dt) {
        $cmbDB.Items.Clear()
        foreach ($r in $dt.Rows) { $cmbDB.Items.Add($r[0].ToString()) | Out-Null }
        $statusLabel.Text = "Pobrano $($cmbDB.Items.Count) baz InsERT"
        if ($cmbDB.Items.Count -gt 0) {
            # Przywroc ostatnio uzywana baze
            $idx = $cmbDB.Items.IndexOf($script:savedDB)
            $cmbDB.SelectedIndex = if ($idx -ge 0) { $idx } else { 0 }
        }
        Save-Config
    } else { $statusLabel.Text = "Blad polaczenia" }
})

$cmbDB.Add_SelectedIndexChanged({
    if (-not $cmbDB.SelectedItem) { return }
    if (Check-GLNColumn) {
        Load-FieldNames
        Do-Search -all $true
        Save-Config
    }
})

# ════════════════════════════════════════════════════════════
#  LOGIKA – TAB 1
# ════════════════════════════════════════════════════════════
function Do-Search {
    param([string]$phrase = "", [bool]$all = $false)
    if (-not $cmbDB.SelectedItem) { [System.Windows.Forms.MessageBox]::Show("Wybierz baze.", "Info", "OK", "Information"); return }
    if (-not $all -and $phrase.Length -lt 2) { [System.Windows.Forms.MessageBox]::Show("Wpisz co najmniej 2 znaki.", "Info", "OK", "Information"); return }
    $script:lastPhrase = $phrase; $script:lastAll = $all
    $statusLabel.Text = "Wczytuje..."; $form.Refresh()
    $fGLN  = if ($chkNoGLN.Checked) { "AND LEN(ISNULL(adr.adr_GLN,''))=0" } else { "" }
    $fText = if ($all -or $phrase -eq "") { "" } else { "AND (adr.adr_Nazwa LIKE @p OR adr.adr_NIP LIKE @p OR adr.adr_Symbol LIKE @p)" }
    $sql = @"
SELECT kh.kh_Id,
       ISNULL(adr.adr_Symbol,'') AS [Symbol],
       ISNULL(adr.adr_Nazwa, '') AS [Nazwa kontrahenta],
       ISNULL(adr.adr_NIP,   '') AS [NIP],
       ISNULL(adr.adr_Adres, '') AS [Adres],
       ISNULL(adr.adr_GLN,   '') AS [Aktualny GLN],
       ISNULL(adr.adr_Id,     0) AS adr_Id
FROM kh__Kontrahent kh
LEFT JOIN adr__Ewid adr ON adr.adr_IdObiektu=kh.kh_Id AND adr.adr_TypAdresu=1
WHERE 1=1 $fText $fGLN
ORDER BY adr.adr_Nazwa
"@
    $p = @{}; if (-not $all -and $phrase -ne "") { $p["@p"] = "%$phrase%" }
    $dt = Run-Query -cs (Get-ConnStr) -sql $sql -P $p
    if ($dt) {
        $lblSelInfo.Text = "Wybierz kontrahenta z listy..."
        $lblWarning.Text = ""
        $txtGLN.Text = ""; $txtGLN.Enabled = $false
        $btnSave.Enabled = $false; $btnDelete.Enabled = $false
        $btnSyncHist.Visible = $false
        $lblGLNCount.Text = "0 / 13"
        $script:selKhId = 0; $script:selAdrId = 0; $script:histGLN = ""
        $grid.DataSource = $dt
        foreach ($c in @("kh_Id","adr_Id")) { if ($grid.Columns[$c]) { $grid.Columns[$c].Visible = $false } }
        Apply-RowColors $grid
        $statusLabel.Text = "Kontrahentow: $($dt.Rows.Count)"
    } else { $statusLabel.Text = "Blad wyszukiwania" }
}

$btnSearch.Add_Click({ Do-Search -phrase $txtSearch.Text.Trim() })
$txtSearch.Add_KeyDown({ if ($_.KeyCode -eq "Return") { Do-Search -phrase $txtSearch.Text.Trim() } })
$btnShowAll.Add_Click({ Do-Search -all $true })

$grid.Add_SelectionChanged({
    if ($grid.SelectedRows.Count -gt 0) {
        $row = $grid.SelectedRows[0]
        try {
            $script:selKhId  = [int]$row.Cells["kh_Id"].Value
            $script:selAdrId = [int]$row.Cells["adr_Id"].Value
            $name    = $row.Cells["Nazwa kontrahenta"].Value
            $nip     = $row.Cells["NIP"].Value
            $cur     = $row.Cells["Aktualny GLN"].Value
            $curTxt  = if ([string]::IsNullOrWhiteSpace($cur)) { "brak" } else { $cur }
            $lblSelInfo.Text = "$name  |  NIP: $nip  |  GLN (Ewid): $curTxt"
            $txtGLN.Text = if ([string]::IsNullOrWhiteSpace($cur)) { "" } else { $cur }
            $txtGLN.Enabled = $true
            $btnSave.Enabled = $true
            $btnDelete.Enabled = -not [string]::IsNullOrWhiteSpace($cur)
            $lblGLNCount.Text = "$($txtGLN.Text.Length) / 13"

            # Sprawdz rozbieznosc z historia
            $script:histGLN = Check-Discrepancy -adrId $script:selAdrId -ewidGLN $cur
            if ($script:histGLN) {
                $lblWarning.Text = "UWAGA: Historia ma inny GLN: $($script:histGLN)  (Ewid: $curTxt)"
                $btnSyncHist.Visible = $true
                $btnSyncHist.Enabled = $true
            } else {
                $lblWarning.Text = ""
                $btnSyncHist.Visible = $false
            }
        } catch {}
    }
})

$txtGLN.Add_KeyPress({
    # IsControl = Backspace, Delete, Ctrl+C, Ctrl+V, Ctrl+A, Ctrl+X itp.
    if ([char]::IsControl($_.KeyChar)) { return }
    if ([char]::IsDigit($_.KeyChar))   { return }
    $_.Handled = $true
})
$script:glnChanging = $false
$txtGLN.Add_TextChanged({
    if (-not $script:glnChanging) {
        # Usun wszystko co nie jest cyfra, obetnij do 13
        $clean = ($txtGLN.Text -replace '[^0-9]','')
        if ($clean.Length -gt 13) { $clean = $clean.Substring(0, 13) }
        if ($clean -ne $txtGLN.Text) {
            $script:glnChanging = $true
            $txtGLN.Text = $clean
            $txtGLN.SelectionStart = $clean.Length
            $script:glnChanging = $false
        }
    }
    $len = $txtGLN.Text.Length; $lblGLNCount.Text = "$len / 13"
    $lblGLNCount.ForeColor = if ($len -eq 13) { [System.Drawing.Color]::FromArgb(0,130,60) } else { [System.Drawing.Color]::FromArgb(160,0,0) }
})

$btnSave.Add_Click({
    if ($script:selKhId -eq 0) { return }
    $gln = $txtGLN.Text.Trim()
    if ($gln -notmatch '^\d{13}$') { [System.Windows.Forms.MessageBox]::Show("GLN musi miec dokladnie 13 cyfr.", "Blad", "OK", "Warning"); return }
    $cs = Get-ConnStr
    $r1 = Run-Query -cs $cs -NonQuery -sql "UPDATE adr__Ewid SET adr_GLN=@gln WHERE adr_IdObiektu=@id AND adr_TypAdresu=1" -P @{"@gln"=$gln;"@id"=$script:selKhId}
    $r2 = 0
    if ($script:selAdrId -gt 0) {
        $r2 = Run-Query -cs $cs -NonQuery -sql "UPDATE adr_Historia SET adrh_GLN=@gln WHERE adrh_IdAdresu=@id AND LEN(ISNULL(adrh_GLN,''))=0" -P @{"@gln"=$gln;"@id"=$script:selAdrId}
    }
    if ($null -ne $r1) {
        [System.Windows.Forms.MessageBox]::Show("Zapisano.`nadr__Ewid: $r1`nadr_Historia: $r2","Gotowe","OK","Information")
        Do-Search -phrase $script:lastPhrase -all $script:lastAll
    }
})

$btnDelete.Add_Click({
    if ($script:selKhId -eq 0) { return }
    $name = $grid.SelectedRows[0].Cells["Nazwa kontrahenta"].Value
    if ([System.Windows.Forms.MessageBox]::Show(
        "Usunac GLN dla kontrahenta:`n$name`n`nSpowoduje to ustawienie NULL w adr__Ewid i adr_Historia.",
        "Potwierdzenie usuniecia", "YesNo", "Warning") -ne "Yes") { return }
    $cs = Get-ConnStr
    $r1 = Run-Query -cs $cs -NonQuery -sql "UPDATE adr__Ewid SET adr_GLN=NULL WHERE adr_IdObiektu=@id AND adr_TypAdresu=1" -P @{"@id"=$script:selKhId}
    $r2 = 0
    if ($script:selAdrId -gt 0) {
        $r2 = Run-Query -cs $cs -NonQuery -sql "UPDATE adr_Historia SET adrh_GLN=NULL WHERE adrh_IdAdresu=@id" -P @{"@id"=$script:selAdrId}
    }
    if ($null -ne $r1) {
        [System.Windows.Forms.MessageBox]::Show("Usunieto GLN.`nadr__Ewid: $r1`nadr_Historia: $r2","Gotowe","OK","Information")
        Do-Search -phrase $script:lastPhrase -all $script:lastAll
    }
})

# Sync historia -> nadpisz wartoscia z Ewid
$btnSyncHist.Add_Click({
    if ($script:selAdrId -le 0) { return }
    $ewidGLN = $grid.SelectedRows[0].Cells["Aktualny GLN"].Value
    $r = Run-Query -cs (Get-ConnStr) -NonQuery -sql "UPDATE adr_Historia SET adrh_GLN=@gln WHERE adrh_IdAdresu=@id" -P @{"@gln"=$ewidGLN;"@id"=$script:selAdrId}
    if ($null -ne $r) {
        [System.Windows.Forms.MessageBox]::Show("Zsynchronizowano historie z Ewid. Rekordow: $r","Gotowe","OK","Information")
        Do-Search -phrase $script:lastPhrase -all $script:lastAll
    }
})

# ════════════════════════════════════════════════════════════
#  LOGIKA – TAB 2
# ════════════════════════════════════════════════════════════
function Do-Preview {
    if (-not $cmbDB.SelectedItem) { [System.Windows.Forms.MessageBox]::Show("Wybierz baze.", "Info", "OK", "Information"); return }
    $pole = Get-SelectedPole
    if (-not $pole) {
        $msg = if ($cmbPole.Items.Count -eq 0) { "Dropdown jest pusty - sprawdz tabele kh_ParametrG." } else { "Zaznacz pole z listy." }
        [System.Windows.Forms.MessageBox]::Show($msg, "Info", "OK", "Information"); return
    }
    $statusLabel.Text = "Podglad: $pole..."; $form.Refresh()
    $sql = @"
SELECT ISNULL(adr.adr_Symbol,'') AS [Symbol],
       ISNULL(adr.adr_Nazwa, '') AS [Nazwa kontrahenta],
       ISNULL(adr.adr_NIP,   '') AS [NIP],
       ISNULL(adr.adr_Adres, '') AS [Adres],
       ISNULL(kh.$pole,      '') AS [Wartosc pola],
       ISNULL(adr.adr_GLN,   '') AS [Aktualny GLN]
FROM kh__Kontrahent kh
LEFT JOIN adr__Ewid adr ON adr.adr_IdObiektu=kh.kh_Id AND adr.adr_TypAdresu=1
WHERE LEN(ISNULL(kh.$pole,''))=13
  AND kh.$pole NOT LIKE '%[^0-9]%'
  AND LEN(ISNULL(adr.adr_GLN,''))=0
ORDER BY adr.adr_Nazwa
"@
    $dt = Run-Query -cs (Get-ConnStr) -sql $sql
    if ($dt) {
        $grid2.DataSource = $dt
        $btnCopyAll.Enabled = ($dt.Rows.Count -gt 0)
        $statusLabel.Text = "Do skopiowania: $($dt.Rows.Count) kontrahentow ($pole)"
    } else { $statusLabel.Text = "Blad podgladu" }
}

$btnPreview.Add_Click({ Do-Preview })

$btnCopyAll.Add_Click({
    $pole = Get-SelectedPole; if (-not $pole) { return }
    $cnt  = $grid2.Rows.Count; if ($cnt -eq 0) { return }
    $label = $cmbPole.SelectedItem.ToString()
    if ([System.Windows.Forms.MessageBox]::Show(
        "Skopiowac GLN z [$label] dla $cnt kontrahentow?`nZaktualizowane: adr__Ewid i adr_Historia.",
        "Potwierdzenie","YesNo","Warning") -ne "Yes") { return }
    $cs = Get-ConnStr
    $r1 = Run-Query -cs $cs -NonQuery -sql @"
UPDATE adr__Ewid SET adr_GLN=kh.$pole
FROM adr__Ewid adr JOIN kh__Kontrahent kh ON adr.adr_IdObiektu=kh.kh_Id AND adr.adr_TypAdresu=1
WHERE LEN(ISNULL(kh.$pole,''))=13 AND kh.$pole NOT LIKE '%[^0-9]%' AND LEN(ISNULL(adr.adr_GLN,''))=0
"@
    $r2 = Run-Query -cs $cs -NonQuery -sql @"
UPDATE adr_Historia SET adrh_GLN=adr.adr_GLN
FROM adr_Historia h JOIN adr__Ewid adr ON h.adrh_IdAdresu=adr.adr_Id AND adr.adr_TypAdresu=1
WHERE LEN(ISNULL(adr.adr_GLN,''))=13 AND LEN(ISNULL(h.adrh_GLN,''))=0
"@
    if ($null -ne $r1) {
        [System.Windows.Forms.MessageBox]::Show("Skopiowano.`nadr__Ewid: $r1`nadr_Historia: $r2","Gotowe","OK","Information")
        Do-Preview
    }
})

# ════════════════════════════════════════════════════════════
#  LOGIKA – TAB 3
# ════════════════════════════════════════════════════════════
$btnCheckEwid.Add_Click({
    if (-not $cmbDB.SelectedItem) { return }
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT COUNT(*) AS cnt FROM adr__Ewid WHERE LEN(ISNULL(adr_GLN,''))>0 AND adr_TypAdresu=1"
    if ($dt) { $lblEwidCount.Text = "Rekordow z GLN: $([int]$dt.Rows[0]['cnt'])" }
})

$btnClearEwid.Add_Click({
    if (-not $cmbDB.SelectedItem) { return }
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT COUNT(*) AS cnt FROM adr__Ewid WHERE LEN(ISNULL(adr_GLN,''))>0 AND adr_TypAdresu=1"
    $cnt = if ($dt) { [int]$dt.Rows[0]["cnt"] } else { 0 }
    if ($cnt -eq 0) { [System.Windows.Forms.MessageBox]::Show("Brak rekordow z GLN w adr__Ewid.","Info","OK","Information"); return }
    if ([System.Windows.Forms.MessageBox]::Show(
        "Czy na pewno chcesz usunac GLN z $cnt rekordow w tabeli adr__Ewid?`n`nOperacja NIEODWRACALNA - ustawia NULL dla wszystkich!",
        "POTWIERDZENIE","YesNo","Warning") -ne "Yes") { return }
    $r = Run-Query -cs (Get-ConnStr) -NonQuery -sql "UPDATE adr__Ewid SET adr_GLN=NULL WHERE adr_TypAdresu=1"
    if ($null -ne $r) {
        [System.Windows.Forms.MessageBox]::Show("Wyczyszczono adr_GLN. Rekordow: $r","Gotowe","OK","Information")
        $lblEwidCount.Text = "Rekordow z GLN: 0"
        Do-Search -all $true
    }
})

$btnCheckHist.Add_Click({
    if (-not $cmbDB.SelectedItem) { return }
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT COUNT(*) AS cnt FROM adr_Historia WHERE LEN(ISNULL(adrh_GLN,''))>0"
    if ($dt) { $lblHistCount.Text = "Rekordow z GLN: $([int]$dt.Rows[0]['cnt'])" }
})

$btnClearHist.Add_Click({
    if (-not $cmbDB.SelectedItem) { return }
    $dt = Run-Query -cs (Get-ConnStr) -sql "SELECT COUNT(*) AS cnt FROM adr_Historia WHERE LEN(ISNULL(adrh_GLN,''))>0"
    $cnt = if ($dt) { [int]$dt.Rows[0]["cnt"] } else { 0 }
    if ($cnt -eq 0) { [System.Windows.Forms.MessageBox]::Show("Brak rekordow z GLN w adr_Historia.","Info","OK","Information"); return }
    if ([System.Windows.Forms.MessageBox]::Show(
        "Czy na pewno chcesz usunac GLN z $cnt rekordow w tabeli adr_Historia?`n`nOperacja NIEODWRACALNA - ustawia NULL dla wszystkich!",
        "POTWIERDZENIE","YesNo","Warning") -ne "Yes") { return }
    $r = Run-Query -cs (Get-ConnStr) -NonQuery -sql "UPDATE adr_Historia SET adrh_GLN=NULL"
    if ($null -ne $r) {
        [System.Windows.Forms.MessageBox]::Show("Wyczyszczono adrh_GLN. Rekordow: $r","Gotowe","OK","Information")
        $lblHistCount.Text = "Rekordow z GLN: 0"
    }
})

$btnCheckDiff.Add_Click({
    if (-not $cmbDB.SelectedItem) { return }
    $statusLabel.Text = "Szukam rozbieznosci..."; $form.Refresh()
    $sql = @"
SELECT ISNULL(adr.adr_Symbol,'')  AS [Symbol],
       ISNULL(adr.adr_Nazwa, '')  AS [Nazwa kontrahenta],
       ISNULL(adr.adr_NIP,   '')  AS [NIP],
       ISNULL(adr.adr_GLN,   '')  AS [GLN w Ewid],
       ISNULL(h.adrh_GLN,    '')  AS [GLN w Historia],
       adr.adr_Id                 AS adr_Id
FROM adr__Ewid adr
JOIN kh__Kontrahent kh ON adr.adr_IdObiektu=kh.kh_Id AND adr.adr_TypAdresu=1
JOIN (
    SELECT adrh_IdAdresu,
           MAX(CASE WHEN adrh_GLN IS NOT NULL THEN adrh_GLN ELSE '' END) AS adrh_GLN
    FROM adr_Historia GROUP BY adrh_IdAdresu
) h ON h.adrh_IdAdresu=adr.adr_Id
WHERE ISNULL(adr.adr_GLN,'') <> ISNULL(h.adrh_GLN,'')
  AND (LEN(ISNULL(adr.adr_GLN,''))>0 OR LEN(ISNULL(h.adrh_GLN,''))>0)
ORDER BY adr.adr_Nazwa
"@
    $dt = Run-Query -cs (Get-ConnStr) -sql $sql
    if ($dt) {
        $gridDiff.DataSource = $dt
        if ($gridDiff.Columns["adr_Id"]) { $gridDiff.Columns["adr_Id"].Visible = $false }
        $btnSyncEwidToHist.Enabled = ($dt.Rows.Count -gt 0)
        $btnSyncHistToEwid.Enabled = ($dt.Rows.Count -gt 0)
        $statusLabel.Text = "Rozbieznosci: $($dt.Rows.Count)"
    }
})

$btnSyncEwidToHist.Add_Click({
    $rows = $gridDiff.SelectedRows
    if ($rows.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Zaznacz wiersze.","Info","OK","Information"); return }
    if ([System.Windows.Forms.MessageBox]::Show(
        "Nadpisac GLN w historii wartoscia z Ewid dla $($rows.Count) zaznaczonych?",
        "Potwierdzenie","YesNo","Warning") -ne "Yes") { return }
    $cs = Get-ConnStr; $total = 0
    foreach ($row in $rows) {
        $adrId  = [int]$row.Cells["adr_Id"].Value
        $ewidGL = $row.Cells["GLN w Ewid"].Value
        $val    = if ([string]::IsNullOrWhiteSpace($ewidGL)) { $null } else { $ewidGL }
        $r = Run-Query -cs $cs -NonQuery -sql "UPDATE adr_Historia SET adrh_GLN=@g WHERE adrh_IdAdresu=@id" -P @{"@g"=$val;"@id"=$adrId}
        if ($null -ne $r) { $total += $r }
    }
    [System.Windows.Forms.MessageBox]::Show("Zsynchronizowano. Rekordow historii: $total","Gotowe","OK","Information")
    $btnCheckDiff.PerformClick()
})

$btnSyncHistToEwid.Add_Click({
    $rows = $gridDiff.SelectedRows
    if ($rows.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Zaznacz wiersze.","Info","OK","Information"); return }
    if ([System.Windows.Forms.MessageBox]::Show(
        "Nadpisac GLN w Ewid wartoscia z historii dla $($rows.Count) zaznaczonych?",
        "Potwierdzenie","YesNo","Warning") -ne "Yes") { return }
    $cs = Get-ConnStr; $total = 0
    foreach ($row in $rows) {
        $adrId  = [int]$row.Cells["adr_Id"].Value
        $histGL = $row.Cells["GLN w Historia"].Value
        $val    = if ([string]::IsNullOrWhiteSpace($histGL)) { $null } else { $histGL }
        # Pobierz kh_Id dla tego adresu
        $dtKh = Run-Query -cs $cs -sql "SELECT adr_IdObiektu FROM adr__Ewid WHERE adr_Id=@id" -P @{"@id"=$adrId}
        if ($dtKh -and $dtKh.Rows.Count -gt 0) {
            $khId = [int]$dtKh.Rows[0]["adr_IdObiektu"]
            $r = Run-Query -cs $cs -NonQuery -sql "UPDATE adr__Ewid SET adr_GLN=@g WHERE adr_IdObiektu=@id AND adr_TypAdresu=1" -P @{"@g"=$val;"@id"=$khId}
            if ($null -ne $r) { $total += $r }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Zsynchronizowano. Rekordow Ewid: $total","Gotowe","OK","Information")
    $btnCheckDiff.PerformClick()
    Do-Search -phrase $script:lastPhrase -all $script:lastAll
})

# ════════════════════════════════════════════════════════════
#  START – wczytaj config i pokaz okno
# ════════════════════════════════════════════════════════════
Load-Config
$form.ShowDialog() | Out-Null
Save-Config
