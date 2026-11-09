# AZiL Sistem Özeti | Windows PowerShell 5.1+
# AZiL - Sistem Ozeti v1.0 (sadece okuma)
$ErrorActionPreference = 'Continue'
Write-Host 'AZiL | Sistem Ozeti' -ForegroundColor Cyan
$base = Join-Path $env:LOCALAPPDATA 'AZiL\KucukUygulamalar\SistemOzeti'
New-Item -ItemType Directory -Path $base -Force | Out-Null
$report = Join-Path $base ('sistem_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.txt')
$rows = New-Object 'System.Collections.Generic.List[string]'
[void]$rows.Add('AZiL SISTEM OZETI')
[void]$rows.Add('Tarih: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
[void]$rows.Add('Bilgisayar: ' + $env:COMPUTERNAME)
try {
  $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
  [void]$rows.Add('Windows: ' + $os.Caption)
  [void]$rows.Add('Surum: ' + $os.Version + ' | Derleme: ' + $os.BuildNumber)
  [void]$rows.Add(('RAM toplam (GB): {0:N2}' -f ($os.TotalVisibleMemorySize / 1MB)))
  [void]$rows.Add(('Son baslatma: ' + $os.LastBootUpTime))
} catch { [void]$rows.Add('Isletim sistemi bilgisi alinamadi: ' + $_.Exception.Message) }
try {
  foreach ($cpu in @(Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop)) {
    [void]$rows.Add('CPU: ' + $cpu.Name)
    [void]$rows.Add('Cekirdek: ' + $cpu.NumberOfCores + ' | Izlek: ' + $cpu.NumberOfLogicalProcessors)
  }
} catch { [void]$rows.Add('CPU bilgisi alinamadi.') }
try {
  foreach ($gpu in @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop)) {
    [void]$rows.Add('GPU: ' + $gpu.Name)
  }
} catch { [void]$rows.Add('GPU bilgisi alinamadi.') }
try {
  [void]$rows.Add('--- Yerel Diskler ---')
  foreach ($disk in @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)) {
    [void]$rows.Add(('{0} | Toplam {1:N2} GB | Bos {2:N2} GB' -f $disk.DeviceID, ($disk.Size/1GB), ($disk.FreeSpace/1GB)))
  }
} catch { [void]$rows.Add('Disk bilgisi alinamadi.') }
[void]$rows.Add('--- Guc Bilgisi ---')
try {
  $power = (& powercfg.exe /getactivescheme 2>&1 | Out-String).Trim()
  [void]$rows.Add($power)
} catch { [void]$rows.Add('Guc plani okunamadi.') }
$rows | Out-File -LiteralPath $report -Encoding UTF8
$rows | ForEach-Object { Write-Host $_ }
Write-Host ('Rapor: ' + $report) -ForegroundColor Green
Write-Warning 'Rapor bilgisayar adi ve donanim bilgisini icerir; paylasmadan once kontrol edin.'
