/// Ders dinletme sırasında Mushaf kelimelerinin durumları.
enum KelimeDurumuTipi { bekliyor, dogru, yanlis, atlandi }

class KelimeDurumu {
  final String metin;
  final KelimeDurumuTipi durum;

  const KelimeDurumu(this.metin, this.durum);

  /// Eski ekran/kod uyumluluğu için: doğru olmayan her sonuç hatalıdır.
  bool get hatali => durum != KelimeDurumuTipi.dogru;
}

/// Konuşma tanıma motorları çoğunlukla harekesiz metin döndürür. Bu nedenle
/// kelime karşılaştırmasında harekeler kaldırılır; harf benzerliği/fuzzy eşleşme
/// yapılmaz. Hareke ve tecvid ayrıca öğretmen/denetçi tarafından işaretlenmelidir.
final RegExp _harekeRegex = RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]');
final RegExp _harfDisindakiler = RegExp('[^\u0621-\u063A\u0641-\u064A' + r'\s' + ']');

String normalize(String s) {
  final t = s.replaceAll(_harekeRegex, '').replaceAll(RegExp('[أإآٱ]'), 'ا');
  return t.replaceAll(_harfDisindakiler, ' ').trim();
}

bool _esit(String a, String b) => a == b; // Yakın harf/fuzzy eşleşme hatayı gizlemesin.

/// Beklenen Mushaf kelimelerini konuşma tanımanın döndürdüğü kelimelerle
/// sıralı olarak hizalar. Eşleşen=yeşil, değiştirilen=kırmızı, arada atlanan=
/// turuncu, henüz okunmamış=normal renk. ASR çıktısı hatalı olabileceği için
/// bu sonuçlar kesin kıraat/tecvid değerlendirmesi değildir. Harf farkları
/// toleranssız sayılır; hareke/tecvid ses tanıma metninden güvenilir biçimde
/// ölçülemediği için ayrı hata kaydı olarak tutulur.
List<KelimeDurumu> karsilastir(List<String> sayfaKelimeleri, String okunan, {bool tamamlandi = false}) {
  final norm = sayfaKelimeleri.map(normalize).toList();
  final aktif = [for (var i = 0; i < norm.length; i++) if (norm[i].isNotEmpty) i];
  final beklenen = aktif.map((i) => norm[i]).toList();
  final algilanan = normalize(okunan).split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty).toList();

  final n = beklenen.length, m = algilanan.length;
  final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = 0; i <= n; i++) dp[i][0] = i;
  for (var j = 0; j <= m; j++) dp[0][j] = j;
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      final degisim = _esit(beklenen[i - 1], algilanan[j - 1]) ? 0 : 1;
      final sil = dp[i - 1][j] + 1;
      final ekle = dp[i][j - 1] + 1;
      final degistir = dp[i - 1][j - 1] + degisim;
      dp[i][j] = [sil, ekle, degistir].reduce((a, b) => a < b ? a : b);
    }
  }

  final sonuc = List<KelimeDurumuTipi>.filled(
      sayfaKelimeleri.length, KelimeDurumuTipi.bekliyor);
  var i = n, j = m;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && _esit(beklenen[i - 1], algilanan[j - 1]) &&
        dp[i][j] == dp[i - 1][j - 1]) {
      sonuc[aktif[i - 1]] = KelimeDurumuTipi.dogru;
      i--; j--;
    } else if (i > 0 && j > 0 &&
        dp[i][j] == dp[i - 1][j - 1] + 1) {
      sonuc[aktif[i - 1]] = KelimeDurumuTipi.yanlis;
      i--; j--;
    } else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
      // Tanınan fazladan kelime; Mushaf üzerinde ayrı kelime boyanmaz.
      j--;
    } else if (i > 0) {
      // Sondaki henüz okunmamış kelimeler turuncu değil, beklemede kalır.
      // Yalnızca arkasından başka tanınmış kelime geldiyse atlanmıştır.
      sonuc[aktif[i - 1]] = (j > 0 || tamamlandi)
          ? KelimeDurumuTipi.atlandi
          : KelimeDurumuTipi.bekliyor;
      i--;
    } else {
      j--;
    }
  }

  return [
    for (var k = 0; k < sayfaKelimeleri.length; k++)
      KelimeDurumu(sayfaKelimeleri[k], sonuc[k]),
  ];
}

/// Konuşma tanımanın ürettiği, Mushaf metninde karşılığı bulunmayan fazla
/// kelime sayısı. Fazla kelimeler de hata toplamına eklenir.
int fazlaKelimeSayisi(List<String> sayfaKelimeleri, String okunan) {
  final beklenen = sayfaKelimeleri.map(normalize).where((w) => w.isNotEmpty).toList();
  final algilanan = normalize(okunan).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final n = beklenen.length, m = algilanan.length;
  final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = 0; i <= n; i++) dp[i][0] = i;
  for (var j = 0; j <= m; j++) dp[0][j] = j;
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      final maliyet = beklenen[i - 1] == algilanan[j - 1] ? 0 : 1;
      final sil = dp[i - 1][j] + 1;
      final ekle = dp[i][j - 1] + 1;
      final degistir = dp[i - 1][j - 1] + maliyet;
      dp[i][j] = [sil, ekle, degistir].reduce((a, b) => a < b ? a : b);
    }
  }
  var i = n, j = m, fazla = 0;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && beklenen[i - 1] == algilanan[j - 1] &&
        dp[i][j] == dp[i - 1][j - 1]) {
      i--; j--;
    } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
      i--; j--;
    } else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
      fazla++; j--;
    } else if (i > 0) {
      i--;
    } else {
      j--;
    }
  }
  return fazla;
}


/// Her kelime için Türkçe açıklama. Ses tanıma harf farklarını söyleyebilir,
/// ama harekeyi ve şeddeyi güvenilir ölçemez; bu yüzden onlar ayrıca not edilir.
String kelimeAciklamasi(KelimeDurumu k) {
  switch (k.durum) {
    case KelimeDurumuTipi.dogru:
      return 'Harfleri doğru tanındı.';
    case KelimeDurumuTipi.yanlis:
      return 'Harfleri farklı tanındı. Kelimeyi yavaş okuyup harflere dikkat edin.';
    case KelimeDurumuTipi.atlandi:
      return 'Bu kelime okunmadı ya da atlandı.';
    case KelimeDurumuTipi.bekliyor:
      return 'Henüz okunmadı.';
  }
}

/// Hareke ve şedde hataları için dürüst not. Konuşma tanıma bu işaretleri
/// genelde vermez, bu yüzden uygulama bunları "doğru" ya da "yanlış" diye
/// kesin sınıflandıramaz.
String tecvidNotu(String metin) {
  if (metin.contains('\u0651')) {
    return 'Bu kelimede şedde var. Şedde ve harekeler ses tanımayla ölçülemez; bu kısmı dinleyerek kendiniz kontrol edin.';
  }
  return 'Harekeler ses tanımayla ölçülemez; harekeleri dinleyerek kendiniz kontrol edin.';
}
