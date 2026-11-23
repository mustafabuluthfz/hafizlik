# Değişiklik Notları

## Bu sürümde yapılanlar
- **Kelime karşılaştırma hatası düzeltildi**: Düzenli ifadelerdeki hata Arapça harfleri silip kelime karşılaştırmasını bozuyordu. Artık harfler doğru korunuyor (`lib/ders/karsilastirma.dart`).
- **Ders Dinlet açıklamaları**: Kelimeye dokununca Türkçe açıklama gösterilir. Harekе ve şedde ses tanımayla güvenilir ölçülemediği için bunlar için dürüst bir not verilir.
- **Sesli Ayet Bul**: Aynı düzenli ifade hatası düzeltildi. Yüzde eşiği (%30–%100) ayarlanabilir, eşiği geçen tüm ayetler yüzdeleriyle listelenir.
- **Kıble ekranı**: Pusula kadranı cihaz yönüne göre döner, K her zaman gerçek kuzeyi gösterir, kırmızı işaret kıble yönünü gösterir. Eski ikon 45° yanlış duruyordu.
- **Ses kütüphanesi**: İndirme varsayılan olarak açıldı (`indirmeIzniVar = true`).
- **Testler**: `test/normalize_regresyon_test.dart` eklendi.

## Henüz yapılmayanlar
- **İshak Danış sesi**: Klasör adı (`Ishaq_Danish_128kbps`) doğrulanamadı. EveryAyah'taki gerçek klasör adı kontrol edilip `lib/ses/okuyucu.dart` içinde değiştirilmeli.
- **Dua listesi ve "Âmentü'r-Rasûl" adı**: Hangi kaynağın (Arapça metin ve meal) kullanılacağı belirlenmeli.
- **Tecvid bölümü**: Cezerî'nin Tecvid kitabının bölüm listesi ve metni gerekli; Arapça örneklerle yeniden yazılacak.
- **Namaz bildirimi ve ana ekran widget'ı**: Android yerel kodu ve `home_widget` paketi gerektirir.
- **Tasarım yenileme**: Tema ve ekranların ayrıca düzenlenmesi gerekiyor.

## Lisans uyarısı
Ses indirme özelliği EveryAyah verilerini kullanır. Yayınlamadan önce kullanım koşullarının doğrulanması gerekir.

## Sürüm 2 değişiklikleri
- **İshak Danış kaldırıldı** (`lib/ses/okuyucu.dart`).
- **Cezerî Mukaddime eklendi**: Tecvid Öğren ekranından açılır. Arapça beyitler ve Türkçe açıklamalar `lib/hafizlik/cezeri_mukaddime.dart` içinde. Harekeler ve Türkçe açıklamalar hocanızla teyit edilmelidir. Kapsam: PDF’in okunabilen bölümleri (giriş, hemzetü’l-vasl, vakıf, maktû-mevsûl, nûn ve tenvin, med, mahreçler, râlar, lâm). Ta’at, sıfatlar ve tecvid bölümlerinin tamamı sonraki turda eklenecek.
- **Ana ekran widget’ı**: Vakitler `lib/namaz/vakit_widget_veri.dart` ile kaydedilir. Android dosyaları `android_overlay/` içinde, CI adımı (`tools/android_overlay.py`) bunları derlemede projeye ekler. Widget her 30 dakikada bir ya da uygulama açıldığında yenilenir.
- **Tasarım**: Renk paleti derin yeşil-turkuaz ve sıcak altın tonlarına çekildi; kartlar daha yuvarlak.

## Açık kalanlar
- Namaz bildirimleri mevcut haliyle korunuyor; widget dışında bildirim içeriği yeniden tasarlanmadı.
- Tecvid kurallarının tamamı Cezerî ile hizalanmadı.
- Dua listesi ve Âmentü adı için kaynak bekleniyor.


## Sürüm 3 değişiklikleri
- **Cezerî beyitleri**: Her beyitin altına Türkçe meal eklendi (`lib/hafizlik/cezeri_meal.dart`), açıklama ayrı gösteriliyor.
- **Tecvid ilkeleri**: Tecvid Öğren ekranına eklendi. Her ilke için Arapça ifade, Türkçe açıklama ve örnek var (`lib/hafizlik/tecvid_ilkeleri_ekrani.dart`).
- **Ek dualar**: Dualar ekranına 12 dua eklendi (Kur’an ayetleri ve sahih hadisler, `lib/dualar/ek_dualar.dart`).
- **Diyanet Elif-Ba**: Kitabın metni bu sürümde kullanılmadı. Sayfalar paylaşılırsa oradan dua eklenebilir.
- **Mealler ve açıklamalar**: Öğretim amaçlıdır; hocayla teyit edilmelidir.
