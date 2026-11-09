# AZiL Güvenli Klasör Yedekleme | Windows PowerShell 5.1+
# AZiL - Guvenli Klasor Yedekleme v1.0
# Robocopy once /L ile onizleme yapar; /MIR, /PURGE, /MOVE, /MOV ve /B kullanmaz.
$ErrorActionPreference = 'Stop'
function Normalize-Directory([string]$p) {
    $full = [IO.Path]::GetFullPath($p)
    $root = [IO.Path]::GetPathRoot($full)
    if ($full.Length -gt $root.Length) { return $full.TrimEnd([char]'\') }
    return $root
}
Write-Host 'AZiL | Guvenli Klasor Yedekleme' -ForegroundColor Cyan
$sourceText = (Read-Host 'Kaynak klasorun tam yolu').Trim().Trim('"')
$targetText = (Read-Host 'Yedek hedef klasorun tam yolu').Trim().Trim('"')
if ([string]::IsNullOrWhiteSpace($sourceText) -or [string]::IsNullOrWhiteSpace($targetText)) { throw 'Yollar bos olamaz.' }
if (-not (Test-Path -LiteralPath $sourceText -PathType Container)) { throw 'Kaynak klasor yok.' }
$source = Normalize-Directory ((Resolve-Path -LiteralPath $sourceText).ProviderPath)
$target = Normalize-Directory $targetText
$cmp = [StringComparison]::OrdinalIgnoreCase
if ($source.Equals($target, $cmp)) { throw 'Kaynak ile hedef ayni olamaz.' }
if ($source.StartsWith($target.TrimEnd([char]'\') + '\', $cmp) -or
    $target.StartsWith($source.TrimEnd([char]'\') + '\', $cmp)) { throw 'Kaynak ve hedef ic ice olamaz.' }
if ($source.Equals([IO.Path]::GetPathRoot($source), $cmp) -or
    $target.Equals([IO.Path]::GetPathRoot($target), $cmp)) { throw 'Surucu kokunu kaynak veya hedef olarak secmeyin.' }
if (Test-Path -LiteralPath $target) {
    $item = Get-Item -LiteralPath $target -Force
    if (-not $item.PSIsContainer) { throw 'Hedef bir klasor olmali.' }
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Hedef bir baglanti (reparse point) olamaz.' }
}
$base = Join-Path $env:LOCALAPPDATA 'AZiL\KucukUygulamalar\Yedekleme'
New-Item -ItemType Directory -Path $base -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$preview = Join-Path $base ('onizleme_' + $stamp + '.txt')
$report = Join-Path $base ('yedekleme_' + $stamp + '.txt')
$opts = @('/E','/XJ','/R:1','/W:1','/COPY:DAT','/DCOPY:DAT','/NP','/TEE')
Write-Host "ONIZLEME: $source -> $target"
& robocopy.exe $source $target @opts '/L' ('/LOG:' + $preview)
$previewExit = $LASTEXITCODE
if ($previewExit -ge 8) { throw "Onizleme hatasi: Robocopy kodu $previewExit" }
Write-Host 'Hedefteki farkli dosyalarin uzerine yazilabilir. Kaynaktan veya hedeften silme yapilmaz.' -ForegroundColor Yellow
$confirm = Read-Host 'Gercek kopyalama icin BUYUK harfle YEDEKLE yazin'
if ($confirm -cne 'YEDEKLE') { Write-Host ('Iptal edildi. Onizleme: ' + $preview); exit 0 }
& robocopy.exe $source $target @opts ('/LOG:' + $report)
$copyExit = $LASTEXITCODE
Write-Host ('Onizleme: ' + $preview)
Write-Host ('Kopyalama raporu: ' + $report)
if ($copyExit -ge 8) { Write-Host ('Robocopy hata kodu: ' + $copyExit) -ForegroundColor Red; exit $copyExit }
Write-Host ('Tamamlandi. Robocopy kodu: ' + $copyExit) -ForegroundColor Green
