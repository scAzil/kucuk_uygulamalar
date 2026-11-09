@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
color 0B
title Gelismis Ag Onarim Araci - Windows 10 / 11

REM Kod ASCII uyumludur; yorumlar ve mesajlarda ozel Turkce karakter yoktur.
REM Bu dosya Wi-Fi profillerini silmez, adaptorlere disable/enable uygulamaz,
REM DNS/proxy adreslerini degistirmez ve gizli verileri internete gondermez.

set "BASE=%LOCALAPPDATA%\AgOnarim"
if not exist "%BASE%" mkdir "%BASE%" >nul 2>&1
if not exist "%BASE%" (
    echo HATA: Rapor klasoru olusturulamadi: "%BASE%"
    pause
    exit /b 1
)
set "STAMP="
for /f %%A in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss" 2^>nul') do if not defined STAMP set "STAMP=%%A"
if not defined STAMP set "STAMP=oturum_%RANDOM%_%RANDOM%"
set "ROOT=%BASE%\%STAMP%_%RANDOM%"
mkdir "%ROOT%" >nul 2>&1
if not exist "%ROOT%" (
    echo HATA: Oturum klasoru olusturulamadi.
    pause
    exit /b 1
)

:MENU
cls
echo ================================================================
echo             GELISMIS AG ONARIM ARACI - WINDOWS 10/11
echo ================================================================
echo.
echo Raporlar: "%ROOT%"
echo.
echo  1 - Ag bilgilerini kaydet + yedek al      [Sadece okuma]
echo  2 - Guvenli onarim: DNS onbellegini temizle
echo  3 - Kapsamli onarim: Winsock + TCP/IP reset [Yonetici gerekir]
echo  4 - DHCP IP adresini birak / yenile         [Baglanti kesilebilir]
echo  5 - Baglanti ve DNS testleri
 echo  6 - Rapor klasorunu ac
 echo  7 - Bilgisayari yeniden baslat [Onayli, 60 saniye]
 echo  0 - Cikis
 echo.
echo NOT: Wi-Fi parolalari ve profilleri bu aracta silinmez.
echo NOT: 3 ve 4, statik IP / VPN kullaniminda baglantiyi etkileyebilir.
echo.
choice /c 12345670 /n /m "Secim (1-7, 0): "
if errorlevel 8 goto END
if errorlevel 7 goto RESTART_CONFIRM
if errorlevel 6 goto OPEN_FOLDER
if errorlevel 5 goto TEST
if errorlevel 4 goto DHCP
if errorlevel 3 goto FULL_RESET
if errorlevel 2 goto DNS_ONLY
if errorlevel 1 goto DIAG
goto MENU

:DIAG
cls
echo [1] Ag durumu kaydediliyor...
call :SNAPSHOT "ONCE"
call :BACKUP
echo.
echo Kayitlar hazir. Dosyalar: "%ROOT%"
goto PAUSE_AND_MENU

:DNS_ONLY
cls
echo [2] Guvenli onarim: yalnizca DNS onbellegi temizlenecek.
call :SNAPSHOT "DNS_ONCE"
call :BACKUP
ipconfig /flushdns > "%ROOT%\dns_temizleme.txt" 2>&1
set "DNS_RESULT=%ERRORLEVEL%"
type "%ROOT%\dns_temizleme.txt"
if "%DNS_RESULT%"=="0" (echo DNS onbellegi temizleme komutu tamamlandi.) else (echo UYARI: Komut hata dondu. Raporu inceleyin.)
call :SNAPSHOT "DNS_SONRA"
goto PAUSE_AND_MENU

:FULL_RESET
cls
echo [3] KAPSAMLI ONARIM
 echo.
echo Bu islem Winsock ve TCP/IP yiginini sifirlar.
echo Ozel IP, DNS, statik ag veya VPN baglantilarini etkileyebilir.
echo WARP / FortiClient gibi araclar icin yeniden ayar gerekebilir.
echo Islem sonunda bilgisayari yeniden baslatman gerekir.
echo.
call :CHECK_ADMIN
if not "%IS_ADMIN%"=="1" (
    echo YONETICI YETKISI YOK. Dosyaya sag tiklayip
    echo "Yonetici olarak calistir" secenegini kullanin.
    goto PAUSE_AND_MENU
)
choice /c EH /n /m "Devam edilsin mi? [E=Evet H=Hayir]: "
if errorlevel 2 goto MENU
call :SNAPSHOT "RESET_ONCE"
call :BACKUP
 echo.
echo Winsock sifirlaniyor...
netsh winsock reset > "%ROOT%\kapsamli_reset_sonuc.txt" 2>&1
set "WINSOCK_RESULT=%ERRORLEVEL%"
echo TCP/IP sifirlaniyor...
netsh int ip reset "%ROOT%\tcpip_reset_ayrinti.txt" >> "%ROOT%\kapsamli_reset_sonuc.txt" 2>&1
set "TCPIP_RESULT=%ERRORLEVEL%"
echo DNS onbellegi temizleniyor...
ipconfig /flushdns >> "%ROOT%\kapsamli_reset_sonuc.txt" 2>&1
set "FLUSH_RESULT=%ERRORLEVEL%"
 echo.>> "%ROOT%\kapsamli_reset_sonuc.txt"
 echo Winsock kodu: %WINSOCK_RESULT% >> "%ROOT%\kapsamli_reset_sonuc.txt"
 echo TCPIP kodu: %TCPIP_RESULT% >> "%ROOT%\kapsamli_reset_sonuc.txt"
 echo DNS kodu: %FLUSH_RESULT% >> "%ROOT%\kapsamli_reset_sonuc.txt"
echo.
type "%ROOT%\kapsamli_reset_sonuc.txt"
if not "%WINSOCK_RESULT%"=="0" echo UYARI: Winsock reset hata raporladi.
if not "%TCPIP_RESULT%"=="0" echo UYARI: TCP/IP reset hata raporladi.
if not "%FLUSH_RESULT%"=="0" echo UYARI: DNS temizligi hata raporladi.
echo.
echo ONEMLI: Yeniden baslatmadan once gerekli ag ayarlarini kontrol edin.
echo Islem sonrasini de kaydediyorum. Degisikliklerin bir kismi
 echo ancak yeniden baslatma sonrasi etkin olur.
call :SNAPSHOT "RESET_SONRA_ONYENIDENBASLATMA"
echo.
echo Ag sifirlama islemleri bitti. Tamamlanmalari icin yeniden baslat.
goto RESTART_CONFIRM

:DHCP
cls
echo [4] DHCP IP YENILEME
 echo.
echo DHCP ile adres alan adaptorlere uygulanir.
echo Internet / VPN / uzak masaustu oturumunu gecici olarak kesebilir.
echo Statik IP yapilandirmalarina dokunmak istemiyorsan iptal et.
echo.
choice /c EH /n /m "Devam edilsin mi? [E=Evet H=Hayir]: "
if errorlevel 2 goto MENU
call :SNAPSHOT "DHCP_ONCE"
call :BACKUP
echo Mevcut DHCP adresleri birakiliyor...
ipconfig /release > "%ROOT%\dhcp_yenileme.txt" 2>&1
echo IP adresi yenileniyor...
ipconfig /renew >> "%ROOT%\dhcp_yenileme.txt" 2>&1
set "RENEW_RESULT=%ERRORLEVEL%"
type "%ROOT%\dhcp_yenileme.txt"
if not "%RENEW_RESULT%"=="0" echo UYARI: IP yenileme hata raporladi. Ag durumunu inceleyin.
call :SNAPSHOT "DHCP_SONRA"
goto PAUSE_AND_MENU

:TEST
cls
echo [5] BAGLANTI TESTLERI
 echo.
echo Bu testler dis ag baglantisi ve DNS cozumlemesini inceler.
echo Ping engellenmis olabilir; basarisiz ping kesin ariza demek degildir.
(
    echo === TEST ZAMANI ===
    date /t
    time /t
    echo.
    echo === IP ADRESI ===
    ipconfig
    echo.
    echo === IP PING 1.1.1.1 ===
    ping -n 3 -w 1500 1.1.1.1
    echo.
    echo === DNS sorgusu: example.com ===
    nslookup example.com
    echo.
    echo === Alan adi ping: example.com ===
    ping -n 3 -w 1500 example.com
    echo.
    echo === PROXY ===
    netsh winhttp show proxy
) > "%ROOT%\baglanti_testi.txt" 2>&1
type "%ROOT%\baglanti_testi.txt"
goto PAUSE_AND_MENU

:OPEN_FOLDER
start "" "%ROOT%"
goto MENU

REM Yeniden baslatma tamamen istege baglidir; onay almadan islem yapilmaz.
:RESTART_CONFIRM
echo.
echo [7] BILGISAYARI YENIDEN BASLAT
echo Kaydedilmemis belgelerinizi kaydedin, calismalarinizi kapatin.
echo Onaydan sonra 60 saniyelik geri sayim baslar.
echo Geri sayimi iptal etmek icin CMD: shutdown /a
echo.
choice /c EH /n /m "60 saniye sonra yeniden baslatilsin mi? [E=Evet H=Hayir]: "
if errorlevel 2 goto PAUSE_AND_MENU
shutdown.exe /r /t 60 /c "Ag onarimi sonrasi kullanici onayli yeniden baslatma"
if errorlevel 1 (
    echo HATA: Yeniden baslatma zamanlanamadi. Yetki veya Windows durumunu kontrol et.
) else (
    echo Yeniden baslatma planlandi: 60 saniye.
    echo Iptal etmek icin: shutdown /a
)
goto PAUSE_AND_MENU

:CHECK_ADMIN
set "IS_ADMIN=0"
fltmc >nul 2>&1
if not errorlevel 1 set "IS_ADMIN=1"
exit /b

:SNAPSHOT
set "TAG=%~1"
(
    echo ================================================================
    echo AG DURUM RAPORU: %TAG%
    echo ================================================================
    date /t
    time /t
    echo.
    echo === IPCONFIG /ALL ===
    ipconfig /all
    echo.
    echo === AG ARAYUZLERI ===
    netsh interface show interface
    echo.
    echo === IPv4 ARAYUZ AYARLARI ===
    netsh interface ipv4 show config
    echo.
    echo === IPv6 ARAYUZLERI ===
    netsh interface ipv6 show interfaces
    echo.
    echo === ROUTE PRINT ===
    route print
    echo.
    echo === WINHTTP PROXY ===
    netsh winhttp show proxy
    echo.
    echo === WLAN ARAYUZLERI (parola gostermez) ===
    netsh wlan show interfaces
    echo.
    echo === ADAPTOR DURUMLARI (PowerShell) ===
    powershell.exe -NoProfile -Command "Get-NetAdapter -ErrorAction SilentlyContinue" 2>nul
) > "%ROOT%\%TAG%_ag_durumu.txt" 2>&1
echo Ag raporu kaydedildi: %TAG%_ag_durumu.txt
exit /b

:BACKUP
REM Bunlar ag yapilandirmasi kayitlaridir; tek tikla geri yukleme degildir.
REM Reg dosyalarini rastgele iceri almak yerine bir uzmana danisin.
netsh interface ip dump > "%ROOT%\yedek_ipv4_netsh.txt" 2>&1
netsh interface ipv6 dump > "%ROOT%\yedek_ipv6_netsh.txt" 2>&1
reg.exe export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "%ROOT%\yedek_tcpip_registry.reg" /y > "%ROOT%\yedek_registry_sonuc.txt" 2>&1
reg.exe export "HKLM\SYSTEM\CurrentControlSet\Services\WinSock2" "%ROOT%\yedek_winsock_registry.reg" /y >> "%ROOT%\yedek_registry_sonuc.txt" 2>&1
(
  echo Ag durum raporlari ve yapilandirma dokumleri otomatik kaydedildi.
  echo Yedek dosyalari OTOMATIK geri yuklenmez.
  echo .reg dosyalarini bilincsizce ice aktarmayin.
  echo Bu raporlar IP / ag ayrintilari icerebilir; paylasirken dikkat edin.
  echo Wi-Fi sifreleri bu arac tarafindan disari aktarilmadi.
) > "%ROOT%\BENI_OKU.txt"
echo Yapilandirma kayitlari klasore kaydedildi.
exit /b

:PAUSE_AND_MENU
echo.
 echo Ayrintilar: "%ROOT%"
pause
goto MENU

:END
endlocal
exit /b 0
