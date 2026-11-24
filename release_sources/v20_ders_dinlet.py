from pathlib import Path

def edit(path, pairs):
    p = Path(path)
    s = p.read_text(encoding='utf-8')
    for a, b in pairs:
        if s.count(a) != 1:
            raise RuntimeError(f'{path}: expected one match: {a[:120]}')
        s = s.replace(a, b, 1)
    p.write_text(s, encoding='utf-8')

# The 31-token ASR alphabet does not encode short vowels. Never infer vowel
# correctness from consonant spelling. Word boundaries, however, can be repaired.
edit('lib/ders/karsilastirma.dart', [
    ("    .replaceAll('▁', ' ')", "    .replaceAll('▁', ' ')\n    .replaceAll(RegExp('[\\u200C-\\u200F\\u202A-\\u202E\\u2066-\\u2069\\uFEFF]'), '')"),
    ('''      maliyet[i][j] = enIyiMaliyet;''', '''      // CTC may emit an extra space inside a word, or miss the space
      // between two words. Repair only exact concatenated letter matches.
      if (j >= 2 && beklenen[i - 1] == algilanan[j - 2] + algilanan[j - 1]) {
        final c = maliyet[i - 1][j - 2] + 1;
        final d = dogru[i - 1][j - 2] + 1;
        if (c < enIyiMaliyet || (c == enIyiMaliyet && d > enIyiDogru)) {
          enIyiMaliyet = c; enIyiDogru = d; enIyiHareket = 4;
        }
      }
      if (i >= 2 && beklenen[i - 2] + beklenen[i - 1] == algilanan[j - 1]) {
        final c = maliyet[i - 2][j - 1] + 1;
        final d = dogru[i - 2][j - 1] + 2;
        if (c < enIyiMaliyet || (c == enIyiMaliyet && d > enIyiDogru)) {
          enIyiMaliyet = c; enIyiDogru = d; enIyiHareket = 5;
        }
      }
      maliyet[i][j] = enIyiMaliyet;'''),
    ('''    } else if (h == 2 && i > 0) {''', '''    } else if (h == 4 && i > 0 && j >= 2) {
      durum[yerler[i - 1]] = KelimeDurumuTipi.dogru;
      i--; j -= 2;
    } else if (h == 5 && i >= 2 && j > 0) {
      durum[yerler[i - 1]] = KelimeDurumuTipi.dogru;
      durum[yerler[i - 2]] = KelimeDurumuTipi.dogru;
      i -= 2; j--;
    } else if (h == 2 && i > 0) {'''),
    ("return 'Bu konumdaki harfler farklı algılandı. Ses tanıma hatalı olabilir.';",
     "return 'Harfler farklı algılandı. Bu bir okuma hatası olabilir veya ses tanımadan kaynaklanabilir; kesin hata değildir.';"),
    ("return 'Bu kelime atlandı ya da model tarafından algılanamadı.';",
     "return 'Model bu kelimeyi algılayamadı. Okumayı dinlemeden atlandığı kesinleştirilemez.';"),
])

# Longer pauses and utterances reduce cuts within a word / prolonged vowel.
edit('lib/ders/yerel_kuran_tanima.dart', [
    ('static const _onBuffer = 4800; // 300 ms, kelime başını korur', 'static const _onBuffer = 8000; // 500 ms, kelime başını korur'),
    ('static const _enUzunParca = 16000 * 9; // Tek parçada en fazla 9 saniye', 'static const _enUzunParca = 16000 * 24; // Uzun tilavetleri daha az böl'),
    ('static const _duraklama = 16000 * 0.72;', 'static const _duraklama = 16000 * 1.15;'),
    ('''    final previous = _samples.length > _onBuffer
        ? _samples.sublist(_samples.length - _onBuffer) : List<double>.from(_samples);''',
     '''    // After a normal pause the previous buffer is silent. At the hard
    // length cap do not re-decode speech already sent to the model.
    final previous = _sessizOrnekler >= _onBuffer
        ? _samples.sublist(_samples.length - _onBuffer)
        : <double>[];'''),
])

# Show ASR discrepancies as review candidates, not confirmed reading errors.
# Keep the existing matching enum/API for the remaining app.
edit('lib/ders/ders_ekrani.dart', [
    ("label: Text(_dinliyor ? 'Dinlemeyi bitir' : 'Okumayı dinle'),",
     "label: Text(_dinliyor ? 'Dersi bitir' : 'Ders Dinlet'),"),
    ("title: Text(_sayfa == null ? 'Ders Dinlet' : 'Ders · Sayfa $_sayfa'),",
     "title: Text(_sayfa == null ? 'Ders Dinlet' : 'Ders Dinlet · Sayfa $_sayfa'),"),
    ("'Doğru: $dogruSayisi  ·  Kelime hatası: ${yanlisSayisi + atlananSayisi + fazlaSayisi}  ·  Hareke: $_harekeHatalari  ·  Tecvid: $_tecvidHatalari'",
     "'Eşleşen: $dogruSayisi · Kontrol: ${yanlisSayisi + atlananSayisi} · Ek algılama: $fazlaSayisi'"),
    ("_RenkAciklama(renk: Colors.green, yazi: 'Doğru'),", "_RenkAciklama(renk: Colors.green, yazi: 'Harfler eşleşti'),"),
    ("_RenkAciklama(renk: Colors.red, yazi: 'Farklı algılandı'),", "_RenkAciklama(renk: Colors.orange, yazi: 'Farklı algılandı'),"),
    ("_RenkAciklama(renk: Colors.orange, yazi: 'Atlandı'),", "_RenkAciklama(renk: Colors.brown, yazi: 'Algılanmadı'),"),
    ("KelimeDurumuTipi.yanlis => Colors.red.shade700,", "KelimeDurumuTipi.yanlis => Colors.orange.shade900,"),
    ("KelimeDurumuTipi.atlandi => Colors.orange.shade800,", "KelimeDurumuTipi.atlandi => Colors.brown.shade700,"),
    ("'Kelime kontrolü sayfanın başından sırasıyla ilerler. Sondaki tekrarlar baştaki okumayla eşleştirilmez. Hareke ve tecvid otomatik değerlendirilmez.'",
     "'Harf eşleşmeleri gösterilir; farklı algılanan kelimeler kesin okuma hatası değildir. Hareke ve tecvid bu ses modeliyle ölçülemez.'"),
    ("'Elle işaretlenen hata · Hareke: $_harekeHatalari · Tecvid: $_tecvidHatalari'",
     "'Hareke: otomatik ölçülemez · Elle not: $_harekeHatalari · Tecvid notu: $_tecvidHatalari'"),
    ('''    if (!mounted || metin.trim().isEmpty) return;
    setState(() {''',
     '''    if (!mounted || (!_dinliyor && !_analizSuruyor) || metin.trim().isEmpty) return;
    setState(() {'''),
    ('''        if (!_dinliyor && !_analizSuruyor && _sonuc != null && _kesin.trim().isNotEmpty)
          Padding(''',
     '''        if (!_dinliyor && !_analizSuruyor && _sonuc != null && _kesin.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Modelin algıladığı metni incele'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (ctx) => SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .65),
                    child: SingleChildScrollView(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Ses tanıma çıktısı', style: Theme.of(ctx).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('Bu metin modelin tahminidir, kesin transkript değildir. Hareke bilgisi içermez.'),
                        const SizedBox(height: 12),
                        SelectableText(_kesin, textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: kMushafFontu, fontSize: 24, height: 1.8)),
                      ],
                    )),
                  ),
                )),
              ),
            ),
          ),
        if (!_dinliyor && !_analizSuruyor && _sonuc != null && _kesin.trim().isNotEmpty)
          Padding('''),
])

# Avoid presenting the offline AI summary as a definitive verdict, too.
p = Path('lib/ai/ai_hoca_servisi.dart')
s = p.read_text(encoding='utf-8')
# Keep calculation logic; only clarify any definitive labels in human-readable strings.
s = s.replace('Kelime hatası:', 'Kontrol edilmesi gereken kelime:').replace('Atlanan kelimeler:', 'Algılanmayan kelimeler:').replace('Yanlış okunan kelimeler:', 'Farklı algılanan kelimeler:')
p.write_text(s, encoding='utf-8')

Path('test/v20_ders_dinlet_test.dart').write_text('''import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/ders/karsilastirma.dart';

void main() {
  test('Yanlış kelime boşluğu gerçek harf eşleşmesini bozmaz', () {
    final split = karsilastir(['الرحمن', 'الرحيم'], 'ال رحمن الرحيم');
    expect(split.every((k) => k.durum == KelimeDurumuTipi.dogru), isTrue);
    final joined = karsilastir(['بسم', 'الله', 'الرحمن'], 'بسمالله الرحمن');
    expect(joined.every((k) => k.durum == KelimeDurumuTipi.dogru), isTrue);
    expect(fazlaKelimeSayisi(['بسم', 'الله'], 'بسمالله'), 0);
  });
  test('Farklı harf sırf benzerlik nedeniyle doğru sayılmaz', () {
    expect(karsilastir(['كتب'], 'كذب').single.durum, KelimeDurumuTipi.yanlis);
  });
  test('Okunmayan son kelimeler hata sayılmaz', () {
    final r = karsilastir(['بسم', 'الله', 'الرحمن'], 'بسمالله', tamamlandi: true);
    expect(r.last.durum, KelimeDurumuTipi.bekliyor);
  });
  test('Hareke hakkında modelin taşımadığı bilgi varsayılmaz', () {
    final r = karsilastir(['كَتَبَ'], 'كتب').single;
    expect(kelimeAciklamasi(r), contains('hareke doğruluğu ölçülmedi'));
  });
}
''', encoding='utf-8')

print('V20: Ders Dinlet hizalama, ses bölütleme ve değerlendirme düzeltmeleri hazır.')
