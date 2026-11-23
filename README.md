# Hafızlık Uygulaması

Flutter ile yazılmış Android/iOS uygulaması. Uygulama; Kur'an okuma, hafızlık takibi, ders dinletme, hatim planı, namaz vakitleri, kıble, zikir, dualar, Esmaü'l Hüsna, notlar ve ses kütüphanesi bölümlerini içerir.

## Hafızlık bölümü nasıl çalışır?

- İlk açılışta bir başlangıç tarihi kaydedilir.
- Her takvim gününde bir sonraki sayfa gösterilir.
- Sayfa sırası: önce her cüzün son sayfaları, sonra sondan 2., sondan 3. sayfalar...
- Mushaf sayfa metinleri uygulama içindeki `assets/quran/sayfalar.json` dosyasından okunur.

## GitHub üzerinden APK indirme (bilgisayar kurmadan)

1. GitHub'da yeni bir depo açın ve bu klasörün içeriğini yükleyin.
2. Depo sayfasında **Actions** sekmesine girin.
3. "Android derle" iş akışı otomatik başlar (ya da **Run workflow** ile elle başlatın).
4. İş bittiğinde sayfanın altındaki **Artifacts** bölümünden `hafizlik-android` dosyasını indirin.
   İçinde `app-release.apk` (doğrudan telefona kurulabilir) ve `app-release.aab` (Play Store için) bulunur.

## Bilgisayarda çalıştırma

```bash
flutter create --platforms=android,ios --project-name hafizlik_app .
flutter pub get
flutter run
```

## Yayınlamadan önce yapılacaklar

1. **Paket adını değiştirin:** `--org com.hafizlik.app` değerini kendi alan adınıza göre düzenleyin.
2. **Yayın imzası:** Şu an release derlemesi debug anahtarıyla imzalanır. Play Store için kendi
   upload keystore'unuzu oluşturup GitHub Secrets üzerinden bağlamanız gerekir.
3. **Hesaplar:** Google Play Console (tek seferlik ücret) ve iOS için Apple Developer Program (yıllık ücret) hesabı gerekir.
4. **Gizlilik politikası:** Mağaza için bir gizlilik politikası sayfası hazırlayıp bağlamanız gerekir.
5. **İçerik ve lisans:** Kullanılan Kur'an metni ve API'nin kullanım koşullarını kontrol edin.

## Kur'an metni hakkında

- Mushaf metni `assets/quran/sayfalar.json` dosyasında, uygulamanın içinde gelir. İnternet gerekmez.
- Metin, `quran-json` paketindeki Tanzil metinlerinden alınmıştır. Tanzil metinleri Creative Commons (BY 3.0) lisansı altındadır. Yayından önce lisans koşullarını ve gerekli atıfı kontrol edin.
- Sayfa-ayet eşlemesi `quran-meta` paketinden (Hafs, Medine mushafı, 604 sayfa) alınmıştır. Bu paketin lisansını da kontrol edin.
- Veri dosyası şu şekildedir: `{"1": [[sure, ayet, metin], ...], "2": [...], ...}`.


## Ders Dinletme

- Ders Dinlet, cihazın konuşma tanıma servisini kullanarak Arapça tilaveti algılar ve ekrandaki Mushaf sayfasıyla kelime düzeyinde karşılaştırır. Bu özellik yapay zekâ ile tecvid/mahreç değerlendirmesi yapmaz.
- İlk kullanımda Android mikrofon izni verilmelidir.
- Telefonda Arapça konuşma tanıma desteği bulunmalıdır. Bazı cihazlarda bu hizmet internet bağlantısı gerektirir.
- Android proje klasörü ilk derlemede GitHub Actions iş akışı tarafından oluşturulur. İş akışı mikrofon, internet ve konum izinlerini manifest dosyasına ekler.
- Cihazın dil listesi boş dönse bile uygulama `ar-SA` diliyle dinlemeyi başlatmayı dener. Dil desteği yoksa telefonun konuşma tanıma hizmeti hata bildirir. Konuşma tanıma hizmeti ve Arapça dil desteği telefona göre değişir; internet gerekebilir.
- Tanıma oturumu Android tarafından kapatılırsa uygulama artan bekleme aralıklarıyla sınırlı sayıda yeniden başlatmayı dener. Kalıcı izin veya servis hatalarında kullanıcıya açıklayıcı uyarı gösterir.
- Sonuç ekranında eşleşen kelime sayısı ve yaklaşık eşleşme yüzdesi gösterilir. Bu oran yalnızca konuşma tanıma metniyle karşılaştırmadır; tecvid, mahreç veya kıraat değerlendirmesi değildir.
- Ses tanıma doğruluğu telefonun mikrofonuna, ortam gürültüsüne ve konuşma tanıma sağlayıcısına bağlıdır. Bu özellik tecvid veya hafızlık icazet değerlendirmesi yerine geçmez.

## Ezber Programı ve Öğrenci Takibi

- Günlük, haftalık ve aylık sayfa hedefleri belirlenebilir.
- Günlük ezber sayfası, ezber/tekrar/dinletme/sınav görevleri ve çalışma süresi kaydedilir.
- Birden fazla öğrenci için ad, son ezberlenen sayfa, günlük hedef ve öğretmen notu tutulabilir.
- Bu kayıtlar `shared_preferences` aracılığıyla yalnızca cihazda saklanır; bulut eşitlemesi veya kullanıcı hesabı bulunmaz. Uygulama verileri silinirse bu yerel kayıtlar da silinebilir.

## Sınırlar ve doğrulama

- Bulmaca bölümü ayet temelli soru/cevap çalışması sağlar.
- Ders Dinlet'in eşleşme yüzdesi, konuşma tanıma metninin Mushaf metniyle kelime karşılaştırmasıdır; kıraat, tecvid, mahreç veya hafızlık yeterlilik kararı değildir.
- Bu kaynak paketi Flutter SDK bulunan bir ortamda `flutter pub get`, `flutter analyze` ve `flutter test` komutlarıyla doğrulanmalıdır. Gerçek mikrofon testi Arapça konuşma tanıma desteği olan Android cihazda yapılmalıdır.


## Sınavlar, raporlar ve yedekleme (1.2.0)

- Hafızlık sekmesindeki **Sınav ve Raporlar** ekranından 10 soruluk çevrimdışı ayet numarası sınavı başlatılabilir.
- Sınavlar kişisel çalışma olarak veya kayıtlı öğrenci adına kaydedilebilir. Öğrenci raporunda sınav adedi ve son sınav yüzdesi gösterilir.
- **Yedek oluştur ve paylaş** seçeneği uygulamanın SharedPreferences kayıtlarını JSON metnine dönüştürür; metin panoya kopyalanabilir.
- Diğer cihazda **Yedeği içe aktar** ile bu metin içe alınabilir. İçe aktarma aynı anahtarlardaki mevcut değerlerin üzerine yazar. Aktarmadan önce mevcut verilerin yedeğini almak önerilir.
- Bu aktarım gerçek zamanlı bulut senkronizasyonu değildir. Öğretmen ve öğrenci kayıtlarını eşitlemek için kullanıcıların yedek metnini güvenli bir kanal üzerinden manuel paylaşması gerekir. Bu sürümde çevrim içi hesap, sunucu veya otomatik eşitleme yoktur.

## Telaffuz değerlendirmesi hakkında önemli sınır

Ders Dinlet, cihazın konuşma tanıma hizmetinden gelen metni Mushaf metniyle karşılaştırır. Bu mekanizma ses dalgasını, mahreçleri, tecvid kurallarını veya kıraat doğruluğunu uzman seviyesinde değerlendirmez. Gerçek yapay zekâ destekli telaffuz/tecvid değerlendirmesi için güvenilir ve doğrulanmış bir ses modeli, sunucu/API altyapısı, veri güvenliği tasarımı ve uzmanlarca hazırlanmış değerlendirme ölçütleri gerekir. Bu sürüm böyle bir değerlendirme iddiasında bulunmaz.


## 1.4.0 – Canlı Ders Dinletme geri bildirimi

- 1.5.0 sürümünden itibaren Mushaf sayfası dinleme sırasında gizlenir; dinleme bitince sonuç ekranında yeniden açılır.
- Konuşma tanıma sonucuna göre kelimeler anlık olarak yeşil (eşleşti), kırmızı (farklı algılandı), turuncu (aradan atlandı) ve normal (henüz okunmadı) gösterilir.
- Henüz sıra gelmemiş kelimeler yanlış/atlandı olarak işaretlenmez.
- Ders ekranında renk açıklaması ve konuşma tanımanın kıraat/tecvid değerlendirmesi olmadığına dair bilgilendirme bulunur.
- Kelime hizalama testleri doğru, yanlış, atlanan ve henüz okunmayan durumları kapsayacak şekilde genişletildi.

**Sınırlama:** Ders Dinlet, Android/telefon konuşma tanıma servisinin Arapça metin çıktısını karşılaştırır. Tanıma servisi Arapça Kur'an tilavetine özel olmayabilir; bu nedenle yanlış pozitif/negatif sonuçlar oluşabilir. Renkler kesin tecvid, mahreç veya kıraat hükmü değildir.

## 1.3.0 – Ezber Atölyesi ve dinleme kontrolleri

Bu sürümde, Hıfz-ı Kelâm uygulamasının herkese açık mağaza açıklamasında belirtilen çalışma fikirlerinden uygulamamızın mevcut veri ve mimarisine uygun olanlar bağımsız biçimde uyarlandı. Başka uygulamanın kaynak kodu, görselleri veya özel arayüzü kopyalanmadı.

- **Ezber Atölyesi:** Sayfa bazlı çalışma ekranı eklendi.
- **Metin modları:** Normal metin, soluk metin ve ezberden çalışma; kelimeleri %25, %50, %75 veya tamamen gizleme. Gizlenen kelimeler Mushaf görünümünde dokunularak açılabilir.
- **Ezber listem:** Çalışılacak Mushaf sayfalarını cihazda saklama ve tek dokunuşla açma.
- **Sayfa başlangıcı/bitişi kontrolü:** Sayfanın ilk ve son ayetini önce gizli tutup sonra kontrol etme.
- **Dinleme:** Ses çubuğuna sayfa tekrarını açıp kapatma ve 0,75×–1,50× hız seçimi eklendi.
- **Gizlilik:** Ezber sayfa listesi cihazdaki SharedPreferences alanında tutulur; hesap veya sunucu gerektirmez.

**Kapsam notu:** Bu sürüm yapay zekâ ile harf/hareke, mahreç veya tecvid doğrulaması yapmaz. Ders Dinlet bölümünün mevcut konuşma tanıma yaklaşımı ayrı bir özelliktir; insan öğretmenin değerlendirmesinin yerine geçmez. Sesli dinleme için mevcut ses kaynağı ve internet bağlantısı gerekir; çevrimdışı ses için ilgili kayıtların önceden indirilmiş olması gerekir.

## 1.6.0 – İlk çevrimiçi deneme (1.7.0 sürümünde kaldırıldı)

Bu sürümde denenmiş olan harici API bağlantısı, kullanıcı isteği doğrultusunda 1.7.0 sürümünden tamamen çıkarıldı. Güncel sürüm API anahtarı, model seçimi, hesap veya harici yapay zekâ servisi kullanmaz.


## 1.5.0 – Ezber modu ve hata kaydı

- Ders Dinlet başlatıldığında Mushaf metni ekrandan gizlenir; öğrenci ezberden okur. Dinleme tamamlanınca metin ve karşılaştırma sonuçları görünür.
- Kelime farkı, atlanan ve fazla tanınan kelimeler ayrı hata türleri olarak raporlanır. Hareke ve tecvid hataları, mevcut ses tanıma motoru bunları güvenilir biçimde ayırt edemediği için öğretmen/denetçi tarafından manuel eklenir.


## Sürüm 1.7.0 – Çevrimdışı Hafızlık Hocası

- OpenAI/API anahtarı/model bağlantısı kaldırıldı.
- Hafızlık değerlendirmesi cihaz üzerinde, Mushaf metni ile konuşma tanıma metninin karşılaştırılmasıyla yapılır.
- Okuma metni bu analiz için internet üzerinden gönderilmez.
- Sistem yanlış/atlanmış/fazla algılanan kelimeleri sayar ve tekrar çalışması önerileri üretir.
- Bu sürüm gerçek bir yerel büyük dil modeli veya Kur'an tilaveti ses modeli içermez. Mahreç, hareke ve tecvid hatalarını otomatik teşhis ettiğini iddia etmez; bu konularda öğretmen kontrolü gerekir.
- Ders Dinlet'in konuşma tanıma kısmı Android'in mevcut konuşma tanıma hizmetine bağlı olabilir; tamamen çevrimdışı ses tanıma için ayrıca lisansı uygun, Arapça/Kur'an tilavetine özel model dosyalarının uygulamaya gömülmesi gerekir.

## Sürüm 1.8.0 – Hafızlık ve Kur'an çalışma araçları

Bu sürümde mevcut 604 sayfa / 6.236 ayetlik yerel Kur'an metni kullanılarak şu bölümler eklendi:

- **Kısa Sureler:** Namazlarda sık okunan kısa sureleri metinden inceleme ve seçili okuyucudan dinleme.
- **Tecvid Öğren:** İzhâr, idğâm, iklâb, ihfâ, mîm-i sâkin, kalkale ve med gibi temel konular için açıklama ve örnekler.
- **Hıfzımı Test Et:** Bir ayetin ardından gelen ayeti dört seçenek arasından bulma; doğru/yanlış sayacı ve yeni soru akışı.
- **Sesli Ayet Bul:** Arapça birkaç kelimeyi sesli söyleyerek yerel Kur'an metninde olası ayet eşleşmelerini arama.
- **Ayarlar:** Sistem/açık/koyu tema, sekiz Mushaf kâğıdı rengi, Arapça yazı boyutu ve varsayılan okuyucu seçimi.

### Çevrimdışı çalışma sınırları

Kur'an metni, tecvid açıklamaları, ezber testi ve görünüm tercihleri cihazda çalışır. Sesli ayet arama, Android'in konuşma tanıma hizmetini ve cihazda Arapça tanıma desteğini kullanır; bazı telefonlarda Arapça dil paketi veya internet gerekebilir. Kârî sesleri ağdan çalınır; Ses Kütüphanesi'nden indirilen kayıtlar çevrimdışı kullanılabilir. Bu uygulama harici OpenAI/API veya başka bir yapay zekâ servisi kullanmaz. Sesli arama eşleşmeleri olası sonuçtur; kıraat/tecvid doğrulaması değildir.


## Tecvid ve okuyucu kataloğu (1.9.0)

- Tecvid bölümü nûn-i sâkin/tenvin, mîm-i sâkin, idğâm türleri, ğunne, med çeşitleri, kalkale, tefhim-terkik, râ ve lâm hükümleri, mahreçler, harf sıfatları, vakıf ve ibtidâ başlıklarında 58 öğretim maddesi içerir. Arama ve konu filtresi bulunur. Açıklamalar temel öğretim içindir; farklı rivayet/tariklerdeki uygulamalar uzman hocadan teyit edilmelidir.
- Ayet okuyucu listesi 4'ten 37 seçeneğe çıkarıldı. Sesler EveryAyah üzerinde barındırılan ayet dosyalarından çevrimiçi akışla oynatılır; uygulama kayıtları APK içine koymaz. İnternet bağlantısı gerekir. Bazı uzak dosyalar geçici olarak erişilemeyebilir.
- EveryAyah'ın yayımladığı okuyucu/klasör kataloğu: https://www.everyayah.com/recitations_pages.html ve https://everyayah.com/data/ . Okuyucu adı ve kayıtları ilgili kaynak sahiplerine aittir. Bu ekleme ücretsiz çevrimiçi dinleme bağlantısı sağlar; sesleri yeniden dağıtma veya APK içine gömme izni vermez. Bu nedenle çevrimdışı indirme seçeneği izin doğrulanana kadar kapalıdır.
- Mevcut sürümde 1-4 arasındaki eski okuyucu tercih sırası korunmuştur; kayıtlı ayarların farklı okuyucuya kayması önlenmiştir.


## 2.0.0 sürümündeki yeni hafızlık araçları

- **Tecvid sınavı:** Tecvid Öğren ekranının üst kısmındaki sınav simgesinden 10 soruluk, kural açıklaması ve örnek üzerinden ilerleyen çevrimdışı sınav açılır.
- **Hoca Dinletisi:** Hafızlık sekmesinden sure ve ayet aralığı seçilir; her ayet 1, 2, 3, 5 veya 10 kez tekrar ettirilebilir. Okuyucu seçimi uygulamanın genel okuyucu tercihiyle eşitlenir. Ses akışı EveryAyah üzerinden internet bağlantısıyla yapılır.
- **Gelişmiş Hıfzımı Test Et:** Hıfzımı Test Et ekranındaki ayarlar simgesinden sayfa başı, sayfa ortası, sayfa sonu veya rastgele ayet modunda devam sınavı başlatılır.

Bu sınavlar ezber ve teorik bilgi çalışmasına yardımcı olur; gerçek kıraat, mahreç ve tecvid tashihinin yerini ehil öğretmenin dinleyerek değerlendirmesi almaz.


## Uygulama simgesi

Android ana ekran simgesi ve uygulama açılış ekranı aynı yeşil `assets/icon/icon.png` görselini temel alır. Uyarlanabilir Android simgesinde aynı logonun şeffaf ön planı (`assets/icon/foreground.png`) ve `#2E7D32` yeşil arka planı kullanılır. Simge dosyaları derleme sırasında `flutter_launcher_icons` ve `flutter_native_splash` ile üretilir.
