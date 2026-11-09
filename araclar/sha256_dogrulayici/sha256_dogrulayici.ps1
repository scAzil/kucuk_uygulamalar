# AZiL SHA-256 Dosya Doğrulayıcı | Windows PowerShell 5.1+
# AZiL - SHA256 Dosya Dogrulayici v1.0
$ErrorActionPreference = 'Stop'
Write-Host 'AZiL | SHA-256 Dosya Dogrulayici' -ForegroundColor Cyan
$inputPath = (Read-Host 'Dogrulanacak dosyanin tam yolu').Trim().Trim('"')
if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) { Write-Host 'Dosya bulunamadi.' -ForegroundColor Red; exit 1 }
$file = (Resolve-Path -LiteralPath $inputPath).ProviderPath
$actual = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
Write-Host ('SHA-256: ' + $actual) -ForegroundColor Green
$expected = (Read-Host 'Karsilastirilacak SHA-256 (yoksa bos)').Trim().Replace(' ','').ToUpperInvariant()
$status = 'Hesaplandi; beklenen ozet verilmedi.'
if ($expected.Length -gt 0) {
    if ($expected -notmatch '^[0-9A-F]{64}$') { Write-Host 'Beklenen ozet 64 hexadecimal karakter olmali.' -ForegroundColor Yellow; exit 2 }
    if ($actual -ceq $expected) {
        $status = 'ESLESIYOR'
        Write-Host $status -ForegroundColor Green
    } else {
        $status = 'ESLESMIYOR'
        Write-Host $status -ForegroundColor Red
    }
}
$base = Join-Path $env:LOCALAPPDATA 'AZiL\KucukUygulamalar\SHA256'
New-Item -ItemType Directory -Path $base -Force | Out-Null
$report = Join-Path $base ('sha256_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.txt')
@('AZiL SHA-256 Raporu', 'Dosya: ' + $file, 'Gercek SHA-256: ' + $actual,
  'Beklenen SHA-256: ' + $expected, 'Sonuc: ' + $status) |
  Out-File -LiteralPath $report -Encoding UTF8
Write-Host ('Rapor: ' + $report)
if ($status -eq 'ESLESMIYOR') { exit 3 }
