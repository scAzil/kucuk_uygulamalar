# AZiL — Küçük Yardımcı Uygulamalar

Kurulum gerektirmeyen, Windows 10/11 üzerinde **yerel olarak** çalışan küçük yardımcı araçlar. Çoğu salt okunur; veri değiştiren seçeneklerde açık onay istenir. Bunlar kamuya açık, erken sürüm kaynak dosyalarıdır; gerçek Windows cihazında uçtan uca test yapılması önerilir.

## Araçlar

| Araç | Görev | Veri değiştirir mi? | Başlatma |
| --- | --- | --- | --- |
| [Büyük Dosya Bulucu](araclar/buyuk_dosya_bulucu/) | Seçilen klasörde en büyük 50 dosyayı ve CSV raporunu oluşturur. | Hayır | [BASLAT.bat](araclar/buyuk_dosya_bulucu/BASLAT.bat) |
| [SHA-256 Dosya Doğrulayıcı](araclar/sha256_dogrulayici/) | İndirilen dosyanın SHA-256 özetini hesaplar, verilen özetle karşılaştırır. | Yalnızca rapor oluşturur | [BASLAT.bat](araclar/sha256_dogrulayici/BASLAT.bat) |
| [Güvenli Klasör Yedekleme](araclar/guvenli_klasor_yedekleme/) | Ön izleme sonrası Robocopy ile bir klasörü başka klasöre kopyalar. | **Evet: hedefte mevcut dosyaların üzerine yazabilir.** Silme yapmaz. | [BASLAT.bat](araclar/guvenli_klasor_yedekleme/BASLAT.bat) |
| [Sistem Özeti](araclar/sistem_ozeti/) | Windows, RAM, CPU, GPU, yerel disk ve etkin güç planını raporlar. | Hayır | [BASLAT.bat](araclar/sistem_ozeti/BASLAT.bat) |
| [Klasör Karşılaştırma](araclar/klasor_karsilastirma/) | İki klasördeki dosya adı, boyutu ve değişiklik tarihini karşılaştırır; CSV raporu üretir. | Hayır | [BASLAT.bat](araclar/klasor_karsilastirma/BASLAT.bat) |
| [Gelişmiş Ağ Onarım Aracı v2](ag_onarim_gelismis_v2.bat) | Ağ teşhisi, DNS temizleme ve izinli ağ onarım işlemleri. | **Bazı seçenekler evet** | [BAT dosyası](ag_onarim_gelismis_v2.bat) |

## Kurulum ve başlatma

1. Sağ üstteki **Code → Download ZIP** ile tüm depoyu indirip çıkarın veya sadece istediğiniz aracın klasöründeki `.ps1` ve `BASLAT.bat` dosyalarını **aynı klasöre** koyun.
2. Aracın `BASLAT.bat` dosyasına çift tıklayın. Her araç Windows PowerShell 5.1+ ve Windows'un yerleşik komutlarını kullanır; üçüncü taraf paket indirmez.
3. Raporlar `%LOCALAPPDATA%\AZiL\KucukUygulamalar\` altına kaydedilir. Ağ Onarım Aracı v2 raporlarını ayrı olarak `%LOCALAPPDATA%\AgOnarim\` altında tutar.

**Güvenlik:** Başlatıcılar yerel PowerShell dosyasını `-ExecutionPolicy Bypass` ile başlatır; bu yalnızca ilgili işlem için kullanılır, makine genelindeki ilkeyi değiştirmez. Kaynak kodu çalıştırmadan önce inceleyin. Kurumsal bilgisayarda izin verilen çalıştırma politikalarına uyun. Özellikle yönetici yetkili ağ işlemlerini kurum izni olmadan çalıştırmayın.

**Yedekleme:** Önce Robocopy'nin `/L` ön izlemesi çalışır; devam etmek için `YEDEKLE` yazılmalıdır. `/MIR`, `/PURGE`, `/MOV` ve `/MOVE` kullanılmaz. Ancak hedefte aynı isimli dosyalar **değiştirilebilir**. Önemli belgeler için tercihen boş bir hedef klasör seçin ve yedeği doğrulayın.

**Karşılaştırma:** Dosyaların içeriğini eşitlik açısından hash'lemez; boyut ve son değiştirilme tarihini kullanır. Büyük Dosya Bulucu ve Klasör Karşılaştırma erişilemeyen dosyalara rastlarsa rapor eksik olabilir.

**Gizlilik:** Programlar bir sunucuya veri göndermez. Sistem ve dosya yolları gibi bilgiler raporlarda bulunabilir; raporları yayımlamadan önce kontrol edin.

**Test durumu:** Dosyalar yazıldı ve GitHub'a kaydedildi. Gerçek Windows ortamında uçtan uca test edilmediler. Deneysel sürüm olarak değerlendirilmelidir.

Skype Kurumsal takip aracı bu depoya dahil edilmedi.
