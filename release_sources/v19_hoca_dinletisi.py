from pathlib import Path
import re

def edit(path, pairs):
    p = Path(path)
    s = p.read_text(encoding='utf-8')
    for a, b in pairs:
        if s.count(a) != 1:
            raise RuntimeError(f'{path}: expected one match: {a[:120]}')
        s = s.replace(a, b, 1)
    p.write_text(s, encoding='utf-8')

p = Path('lib/main.dart')
s = p.read_text(encoding='utf-8')
s = s.replace("import 'hafizlik/hoca_dinletisi_ekrani.dart';\n", '')
s, n = re.subn(r"  _Bolum\('Hoca Dinletisi',[^\n]*\n[^\n]*HocaDinletisiEkrani\(\)\),\n", '', s)
assert n == 1, 'Hoca Dinletisi menu entry missing'
s = s.replace("'Hafızlık Yap', 'Günün sayfası'", "'Hafızlık Yap', 'Günün sayfası ve hoca dinletisi'")
p.write_text(s, encoding='utf-8')

edit('lib/hafizlik/hafizlik_sayfa_ekrani.dart', [
    ("title: const Text('Bugünkü Sayfa'),", "title: const Text('Hafızlık Yap'),"),
    ('seciliAyet: _seciliAyet, secimKimligi: _secimKimligi),',
     '''seciliAyet: _seciliAyet, secimKimligi: _secimKimligi,
                  hocaDinletisi: true,
                  onAktifAyet: (ayet) {
                    if (!mounted || _seciliAyet == ayet) return;
                    setState(() => _seciliAyet = ayet);
                  }),'''),
])

# Use a single audio player for tap-to-listen, whole page and teacher repeats.
edit('lib/ses/ses_cubugu.dart', [
    ("import 'okuyucu.dart';", "import 'okuyucu.dart';\nimport 'hoca_dinleti_paneli.dart';"),
    ('  final int secimKimligi;', '''  final int secimKimligi;
  final bool hocaDinletisi;
  final ValueChanged<Ayet?>? onAktifAyet;'''),
    ('this.secimKimligi = 0});', 'this.secimKimligi = 0, this.hocaDinletisi = false, this.onAktifAyet});'),
    ('  Future<void> _islem = Future<void>.value();', '''  Future<void> _islem = Future<void>.value();
  HocaDinletiSecimi? _hocaSecimi;
  List<Ayet> _calmaListesi = [];
  StreamSubscription<int?>? _ayetAboneligi;'''),
    ('    _hazirla();', '''    _hazirla();
    if (widget.hocaDinletisi) {
      _ayetAboneligi = _oynatici.siraIndeksi.listen((i) {
        if (!mounted || !_yuklendi || i == null || i < 0 || i >= _calmaListesi.length) return;
        widget.onAktifAyet?.call(_calmaListesi[i]);
      });
    }'''),
    ('    _istekKimligi++;\n    _oynatici.kapat();', '    _istekKimligi++;\n    _ayetAboneligi?.cancel();\n    _oynatici.kapat();'),
    ('  Future<void> _baslat(Ayet? ayet) {', '''  Future<void> _hocaPaneliniAc() async {
    final secim = await showModalBottomSheet<HocaDinletiSecimi>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HocaDinletiPaneli(
        sayfaAyetleri: _ayetler,
        okuyucu: okuyucular.indexOf(_okuyucu),
        onceki: _hocaSecimi,
      ),
    );
    if (!mounted || secim == null) return;
    _okuyucu = okuyucular[secim.okuyucu];
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    unawaited(prefs.setInt('okuyucu_dizin', secim.okuyucu).then<void>((_) {}));
    await _baslat(null, hoca: secim);
  }

  Future<void> _hocaDurdur() {
    final kimlik = ++_istekKimligi;
    setState(() {
      _yuklendi = false;
      _hazirlaniyor = false;
      _hocaSecimi = null;
      _tekAyetModu = null;
      _calmaListesi = [];
      _hata = null;
    });
    widget.onAktifAyet?.call(null);
    _islem = _islem.then((_) async {
      if (!_guncel(kimlik)) return;
      try { await _oynatici.durdur(); } catch (_) {}
    });
    return _islem;
  }

  Future<void> _baslat(Ayet? ayet, {HocaDinletiSecimi? hoca}) {'''),
    ('      _tekAyetModu = ayet;\n      _hazirlaniyor = true;', '''      _tekAyetModu = ayet;
      _hocaSecimi = hoca;
      _calmaListesi = hoca != null ? hoca.calmaListesi :
          (ayet == null ? _ayetler : [ayet]);
      _hazirlaniyor = true;'''),
    ('await _oynatici.hazirla(ayet == null ? _ayetler : [ayet], _okuyucu);',
     'await _oynatici.hazirla(_calmaListesi, _okuyucu);'),
    ('await _oynatici.tekrarModu(_tekrarAcik);',
     'await _oynatici.tekrarModu(_hocaSecimi == null && _tekrarAcik);'),
    ('setState(() { _yuklendi = true; _hazirlaniyor = false; });',
     '''setState(() { _yuklendi = true; _hazirlaniyor = false; });
        if (_calmaListesi.isNotEmpty) widget.onAktifAyet?.call(_calmaListesi.first);'''),
    ('await _baslat(_tekAyetModu);', 'await _baslat(_tekAyetModu, hoca: _hocaSecimi);'),
    ('      _okuyucu = okuyucular[secilen];', '      _okuyucu = okuyucular[secilen];\n      if (_hocaSecimi != null) _hocaSecimi = _hocaSecimi!.okuyucuyla(secilen);'),
    ('              if (_ayetler.isNotEmpty) Align(', '''              if (widget.hocaDinletisi && _ayetler.isNotEmpty)
                Row(children: [
                  Expanded(child: TextButton.icon(
                    onPressed: _hocaPaneliniAc,
                    icon: const Icon(Icons.repeat_rounded, size: 20),
                    label: const Text('Hoca Dinletisi'),
                  )),
                  if (_hocaSecimi != null)
                    IconButton(
                      tooltip: 'Hoca dinletisini durdur',
                      onPressed: _hocaDurdur,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                ]),
              if (_ayetler.isNotEmpty) Align('''),
    ("final etiket = _hazirlaniyor ? 'Ses hazırlanıyor…' : _tekAyetModu != null", '''final hoca = _hocaSecimi;
                      final konum = (sira ?? 0).clamp(0, _calmaListesi.isEmpty ? 0 : _calmaListesi.length - 1).toInt();
                      final hocaEtiketi = hoca != null && _calmaListesi.isNotEmpty
                          ? '${_calmaListesi[konum].sure}:${_calmaListesi[konum].numara} · Tekrar ${konum % hoca.tekrar + 1}/${hoca.tekrar}'
                          : '';
                      final etiket = _hazirlaniyor ? 'Ses hazırlanıyor…' :
                          hoca != null ? (durumSnap.data?.processingState == ProcessingState.completed
                              ? 'Tekrar tamamlandı' : hocaEtiketi) : _tekAyetModu != null'''),
    ('enabled: !_hazirlaniyor,', 'enabled: !_hazirlaniyor,'),
    ("if (secim == 'tekrar') {", "if (secim == 'tekrar' && _hocaSecimi == null) {"),
    ("PopupMenuItem(value: 'tekrar', child:", "if (_hocaSecimi == null) PopupMenuItem(value: 'tekrar', child:"),
])

# Cache the file lookup for each distinct verse within a repeated playlist.
edit('lib/ses/sayfa_oynatici.dart', [
    ('    final kaynaklar = <AudioSource>[];', '    final kaynaklar = <AudioSource>[];\n    final yerelYollar = <String, String?>{};'),
    ('      final yerel = await IndirmeYoneticisi.yerelYol(okuyucu, a.sure, a.numara);',
     '''      final anahtar = '${a.sure}:${a.numara}';
      if (!yerelYollar.containsKey(anahtar)) {
        yerelYollar[anahtar] = await IndirmeYoneticisi.yerelYol(okuyucu, a.sure, a.numara);
      }
      final yerel = yerelYollar[anahtar];'''),
])

Path('lib/ses/hoca_dinleti_paneli.dart').write_text('''import 'package:flutter/material.dart';
import '../bulmaca/sureler.dart';
import '../hafizlik/quran_veri.dart';
import 'okuyucu.dart';

/// Repeat each verse before moving to the next, including page-boundary surahs.
class HocaDinletiSecimi {
  final List<Ayet> ayetler;
  final int tekrar;
  final int okuyucu;
  final int? sure;
  const HocaDinletiSecimi(this.ayetler, this.tekrar, this.okuyucu, {this.sure});

  List<Ayet> get calmaListesi => [
    for (final ayet in ayetler)
      for (var i = 0; i < tekrar; i++) ayet,
  ];

  HocaDinletiSecimi okuyucuyla(int yeni) =>
      HocaDinletiSecimi(ayetler, tekrar, yeni, sure: sure);
}

class HocaDinletiPaneli extends StatefulWidget {
  final List<Ayet> sayfaAyetleri;
  final int okuyucu;
  final HocaDinletiSecimi? onceki;
  const HocaDinletiPaneli({super.key, required this.sayfaAyetleri,
    required this.okuyucu, this.onceki});

  @override
  State<HocaDinletiPaneli> createState() => _HocaDinletiPaneliState();
}

class _HocaDinletiPaneliState extends State<HocaDinletiPaneli> {
  late List<Ayet> _ayetler;
  late int _okuyucu, _tekrar, _ilk, _son;
  int? _sure;
  bool _yukleniyor = false;
  String? _hata;
  int _istek = 0;

  @override
  void initState() {
    super.initState();
    _ayetler = widget.sayfaAyetleri;
    _okuyucu = widget.okuyucu.clamp(0, okuyucular.length - 1).toInt();
    _tekrar = widget.onceki?.tekrar ?? 3;
    _ilk = 0;
    _son = _ayetler.length - 1;
  }

  Future<void> _kapsamSec(int no) async {
    final kimlik = ++_istek;
    if (no == 0) {
      setState(() {
        _sure = null; _ayetler = widget.sayfaAyetleri;
        _ilk = 0; _son = _ayetler.length - 1; _yukleniyor = false; _hata = null;
      });
      return;
    }
    setState(() { _sure = no; _yukleniyor = true; _hata = null; });
    try {
      final tum = await QuranVeri.tumAyetler();
      if (!mounted || kimlik != _istek) return;
      final liste = tum.where((a) => a.sure == no).toList()
        ..sort((a, b) => a.numara.compareTo(b.numara));
      setState(() {
        _ayetler = liste; _ilk = 0; _son = liste.length - 1; _yukleniyor = false;
        if (liste.isEmpty) _hata = 'Sûrenin ayetleri bulunamadı.';
      });
    } catch (_) {
      if (mounted && kimlik == _istek) setState(() {
        _ayetler = []; _ilk = 0; _son = -1; _yukleniyor = false;
        _hata = 'Ayetler yüklenemedi.';
      });
    }
  }

  String _ayetAdi(Ayet a) => '${sureler[a.sure - 1].trAd} · ${a.numara}. ayet';

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .75),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Text('Hoca Dinletisi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text('Her ayet seçtiğiniz sayıda okunur, ardından sıradaki ayete geçilir.'),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _sure ?? 0, isExpanded: true,
              decoration: const InputDecoration(labelText: 'Çalışma alanı'),
              items: [
                const DropdownMenuItem(value: 0, child: Text('Bugünkü sayfa')),
                for (final s in sureler) DropdownMenuItem(value: s.no,
                  child: Text('${s.no}. ${s.trAd}', overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) { if (v != null) _kapsamSec(v); },
            ),
            const SizedBox(height: 10),
            if (_yukleniyor) const LinearProgressIndicator(),
            if (!_yukleniyor && _ayetler.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                key: ValueKey('ilk-${_sure ?? 0}'),
                value: _ilk, isExpanded: true,
                decoration: const InputDecoration(labelText: 'Başlangıç ayeti'),
                items: [for (var i = 0; i < _ayetler.length; i++)
                  DropdownMenuItem(value: i, child: Text(_ayetAdi(_ayetler[i]), overflow: TextOverflow.ellipsis))],
                onChanged: (v) { if (v != null) setState(() { _ilk = v; if (_son < v) _son = v; }); },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                key: ValueKey('son-${_sure ?? 0}-$_ilk'),
                value: _son, isExpanded: true,
                decoration: const InputDecoration(labelText: 'Bitiş ayeti'),
                items: [for (var i = _ilk; i < _ayetler.length; i++)
                  DropdownMenuItem(value: i, child: Text(_ayetAdi(_ayetler[i]), overflow: TextOverflow.ellipsis))],
                onChanged: (v) { if (v != null) setState(() => _son = v); },
              ),
              const SizedBox(height: 10),
            ],
            DropdownButtonFormField<int>(
              value: _tekrar,
              decoration: const InputDecoration(labelText: 'Her ayetin tekrar sayısı'),
              items: [for (final n in [1, 2, 3, 5, 10])
                DropdownMenuItem(value: n, child: Text('$n kez'))],
              onChanged: (v) { if (v != null) setState(() => _tekrar = v); },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _okuyucu, isExpanded: true,
              decoration: const InputDecoration(labelText: 'Okuyucu'),
              items: [for (var i = 0; i < okuyucular.length; i++)
                DropdownMenuItem(value: i, child: Text(okuyucular[i].tamEtiket, overflow: TextOverflow.ellipsis))],
              onChanged: (v) { if (v != null) setState(() => _okuyucu = v); },
            ),
            if (_hata != null) Padding(padding: const EdgeInsets.all(8), child: Text(_hata!)),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _yukleniyor || _ayetler.isEmpty ? null : () =>
                Navigator.pop(context, HocaDinletiSecimi(
                  _ayetler.sublist(_ilk, _son + 1), _tekrar, _okuyucu, sure: _sure)),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Dinletiyi başlat'),
            ),
            const SizedBox(height: 8),
            const Text('İndirilmiş ayetler çevrimdışı, diğer ayetler internet üzerinden oynatılır.', style: TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    ),
  );
}
''', encoding='utf-8')

Path('test/v19_hoca_dinletisi_test.dart').write_text('''import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/hafizlik/quran_veri.dart';
import 'package:hafizlik_app/ses/hoca_dinleti_paneli.dart';

void main() {
  const ilk = Ayet(sure: 1, numara: 7, metin: '', sayfa: 1);
  const son = Ayet(sure: 2, numara: 1, metin: '', sayfa: 1);
  test('Her ayet ayrı ayrı tekrar edilir, sûre sınırı korunur', () {
    final secim = HocaDinletiSecimi([ilk, son], 3, 0);
    expect(secim.calmaListesi, [ilk, ilk, ilk, son, son, son]);
    expect(secim.okuyucuyla(2).okuyucu, 2);
  });
  test('Hoca dinletisi yalnızca hafızlık ekranına entegre edilir', () {
    final main = File('lib/main.dart').readAsStringSync();
    final hafizlik = File('lib/hafizlik/hafizlik_sayfa_ekrani.dart').readAsStringSync();
    expect(main, isNot(contains("  _Bolum('Hoca Dinletisi'")));
    expect(hafizlik, contains('hocaDinletisi: true'));
  });
  testWidgets('Panel bugünkü sayfayı varsayılan seçer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: HocaDinletiPaneli(sayfaAyetleri: [ilk, son], okuyucu: 0),
    )));
    expect(find.text('Bugünkü sayfa'), findsOneWidget);
    expect(find.text('Dinletiyi başlat'), findsOneWidget);
  });
}
''', encoding='utf-8')

print('V19: Hoca Dinletisi, Hafızlık Yap ekranına entegre edildi.')
