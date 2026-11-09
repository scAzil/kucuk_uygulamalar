# AZiL — Küçük Uygulamalar

Windows üzerinde kullanılabilen küçük, bağımsız yardımcı araçların deposu. Büyük masaüstü yazılımlarımız kendi depolarında yayımlanır.

## Ağ Onarım Aracı v2

**Dosya:** [ag_onarim_gelismis_v2.bat](./ag_onarim_gelismis_v2.bat)

Windows 10/11 için menülü ağ teşhis ve onarım yardımcısıdır. Kaynak kodu açıkça incelenebilir ve ek kurulum gerektirmeyen `.bat` biçimindedir.

- Ağ bilgilerini kaydeder; IP, rota, adaptör ve proxy yapılandırma raporları üretir.
- DNS önbelleğini temizleyebilir.
- Winsock ve TCP/IP sıfırlama komutlarını **açık onayla ve yönetici yetkisiyle** çalıştırabilir.
- DHCP IP yenileme, bağlantı testleri ve isteğe bağlı yeniden başlatma seçenekleri içerir.
- Oturum raporlarını `%LOCALAPPDATA%\AgOnarim\` altında tutar.

**Uyarı:** 3 (kapsamlı onarım), 4 (DHCP yenileme) ve 7 (yeniden başlatma) seçenekleri aktif bağlantıları etkileyebilir. VPN, kurumsal ağ veya statik IP kullanan cihazlarda yetkili ağ yöneticisinin onayı olmadan çalıştırmayın. Raporlar IP/adaptör ve yapılandırma bilgileri içerebilir; herkese açık paylaşmadan önce inceleyin. Dosyanın gerçek Windows üzerinde uçtan uca testi ayrıca yapılmalıdır.

### Kullanım

1. BAT dosyasını indirin.
2. Kendi Windows bilgisayarınızda dosya içeriğini kontrol ederek açın.
3. Önce **1 — Ağ bilgilerini kaydet** veya **5 — Bağlantı testleri** seçeneğini kullanın.
4. Onarım işlemlerini yalnızca ne yapacaklarını biliyorsanız uygulayın.

Bu depo Skype Kurumsal tanılama dosyalarını içermez.
