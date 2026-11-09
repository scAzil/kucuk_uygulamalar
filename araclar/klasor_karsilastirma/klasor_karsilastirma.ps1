# AZiL Klasör Karşılaştırma | Windows PowerShell 5.1+
# AZiL - Klasor Karsilastirma v1.0 (sadece okuma)
$ErrorActionPreference = 'Stop'
Write-Host 'AZiL | Klasor Karsilastirma' -ForegroundColor Cyan
$leftText = (Read-Host 'Birinci klasor yolu').Trim().Trim('"')
$rightText = (Read-Host 'Ikinci klasor yolu').Trim().Trim('"')
if (-not (Test-Path -LiteralPath $leftText -PathType Container)) { throw 'Birinci klasor bulunamadi.' }
if (-not (Test-Path -LiteralPath $rightText -PathType Container)) { throw 'Ikinci klasor bulunamadi.' }
$left = (Resolve-Path -LiteralPath $leftText).ProviderPath.TrimEnd([char]'\')
$right = (Resolve-Path -LiteralPath $rightText).ProviderPath.TrimEnd([char]'\')
if ($left -eq $right) { throw 'Farkli iki klasor secin.' }
$errors1 = @(); $errors2 = @()
$leftFiles = @(Get-ChildItem -LiteralPath $left -File -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable +errors1 |
  Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 })
$rightFiles = @(Get-ChildItem -LiteralPath $right -File -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable +errors2 |
  Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 })
$a = @{}; $b = @{}
foreach ($f in $leftFiles) { $a[$f.FullName.Substring($left.Length).TrimStart([char]'\')] = $f }
foreach ($f in $rightFiles) { $b[$f.FullName.Substring($right.Length).TrimStart([char]'\')] = $f }
$changes = New-Object 'System.Collections.Generic.List[object]'
foreach ($key in @(($a.Keys + $b.Keys) | Sort-Object -Unique)) {
  $x = $a[$key]; $y = $b[$key]
  $status = ''
  if ($null -eq $x) { $status = 'Yalnizca_ikinci_klasorde' }
  elseif ($null -eq $y) { $status = 'Yalnizca_birinci_klasorde' }
  elseif ($x.Length -ne $y.Length -or [math]::Abs(($x.LastWriteTimeUtc - $y.LastWriteTimeUtc).TotalSeconds) -gt 2) { $status = 'Boyut_veya_tarih_farkli' }
  if ($status) {
    [void]$changes.Add([pscustomobject]@{
      'Durum' = $status
      'Goreli_Yol' = $key
      'Ilk_Boyut_Bayt' = $(if($x){$x.Length}else{''})
      'Ikinci_Boyut_Bayt' = $(if($y){$y.Length}else{''})
    })
  }
}
$base = Join-Path $env:LOCALAPPDATA 'AZiL\KucukUygulamalar\KlasorKarsilastirma'
New-Item -ItemType Directory -Path $base -Force | Out-Null
$report = Join-Path $base ('farklar_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.csv')
if ($changes.Count) {
    $changes | Export-Csv -LiteralPath $report -NoTypeInformation -Delimiter ';' -Encoding UTF8
    $changes | Select-Object -First 20 | Format-Table -AutoSize -Wrap
    Write-Host ('CSV raporu: ' + $report) -ForegroundColor Green
} else { Write-Host 'Boyut ve tarih bilgilerine gore fark bulunamadi.' -ForegroundColor Green }
Write-Host 'Bu islem dosya silmez, kopyalamaz veya degistirmez.'
Write-Host 'Not: Icerik SHA-256 ile karsilastirilmadi; ayni boyut/tarih ayni icerik garantisi degildir.'
if ($errors1.Count + $errors2.Count -gt 0) { Write-Warning 'Erisilemeyen bazi dosyalar olabilir; rapor eksik olabilir.' }
