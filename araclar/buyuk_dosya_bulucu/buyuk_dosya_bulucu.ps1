# AZiL Büyük Dosya Bulucu | Windows PowerShell 5.1+
# AZiL - Buyuk Dosya Bulucu v1.0 (salt okunur)
$ErrorActionPreference = 'Stop'
Write-Host 'AZiL | Buyuk Dosya Bulucu' -ForegroundColor Cyan
$inputPath = Read-Host 'Taranacak klasor (bos = Belgeler)'
if ([string]::IsNullOrWhiteSpace($inputPath)) { $inputPath = [Environment]::GetFolderPath('MyDocuments') }
$inputPath = $inputPath.Trim().Trim('"')
if (-not (Test-Path -LiteralPath $inputPath -PathType Container)) { Write-Host 'Klasor bulunamadi.' -ForegroundColor Red; exit 1 }
$folder = (Resolve-Path -LiteralPath $inputPath).ProviderPath
$base = Join-Path $env:LOCALAPPDATA 'AZiL\KucukUygulamalar\BuyukDosyalar'
New-Item -ItemType Directory -Path $base -Force | Out-Null
$report = Join-Path $base ('buyuk_dosyalar_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.csv')
Write-Host 'Taraniyor; buyuk klasorlerde zaman alabilir. Dosyalar degistirilmez.'
$scanErrors = @()
$top = @(Get-ChildItem -LiteralPath $folder -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable +scanErrors |
    Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 } |
    Sort-Object Length -Descending |
    Select-Object -First 50)
$rows = @($top | ForEach-Object {
    [pscustomobject]@{
        'Boyut_MB' = [math]::Round($_.Length / 1MB, 2)
        'Boyut_Bayt' = $_.Length
        'Degistirme_Tarihi' = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
        'Tam_Yol' = $_.FullName
    }
})
if ($rows.Count) {
    $rows | Export-Csv -LiteralPath $report -Delimiter ';' -Encoding UTF8 -NoTypeInformation
    $rows | Select-Object -First 15 Boyut_MB, Tam_Yol | Format-Table -AutoSize -Wrap
    Write-Host ('Rapor: ' + $report) -ForegroundColor Green
} else { Write-Host 'Okunabilir dosya bulunamadi.' }
if ($scanErrors.Count) { Write-Warning ("Erisilemeyen bazi yollar olabilir; hata sayisi: {0}" -f $scanErrors.Count) }
Write-Host 'Dosya silinmedi, tasinmadi veya degistirilmedi.'
