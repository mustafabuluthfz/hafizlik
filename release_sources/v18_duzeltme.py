from pathlib import Path

def edit(path, replacements):
    p = Path(path)
    data = p.read_text(encoding='utf-8')
    for old, new in replacements:
        if data.count(old) != 1:
            raise RuntimeError(f'{path}: expected exactly one match: {old[:100]}')
        data = data.replace(old, new, 1)
    p.write_text(data, encoding='utf-8')

edit('lib/hafizlik/hafizlik_sayfa_ekrani.dart', [
    ('  int _seri = 0;', '  int _seri = 0;\n  Ayet? _seciliAyet;\n  int _secimKimligi = 0;'),
    ('        _sayfa = sayfa;', '        if (_sayfa != sayfa) _seciliAyet = null;\n        _sayfa = sayfa;'),
    ("SesCubugu(key: ValueKey('ses-$_sayfa'), sayfaNo: _sayfa!),",
     "SesCubugu(key: ValueKey('ses-$_sayfa'), sayfaNo: _sayfa!,\n                  seciliAyet: _seciliAyet, secimKimligi: _secimKimligi),"),
    ('        Expanded(\n          child: LayoutBuilder(',
     """        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            _gizliSeviye == 0
                ? 'Dinlemek için ayete dokunun.'
                : 'Dinlemek için ayet numarasına dokunun.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: LayoutBuilder("""),
    ('                  gizliSeviye: _gizliSeviye,',
     """                  gizliSeviye: _gizliSeviye,
                  vurgulananAyet: _seciliAyet,
                  onAyetSecildi: (ayet) => setState(() {
                    _seciliAyet = ayet;
                    _secimKimligi++;
                  }),"""),
])

edit('lib/ortak/mushaf.dart', [
    ('        style: TextStyle(color: koyuKagit ? Colors.amber.shade200',
     '        recognizer: widget.onAyetSecildi != null ? _ayetTanik(a) : null,\n        style: TextStyle(color: koyuKagit ? Colors.amber.shade200'),
])

# Preserve the keyed page subtrees and paint only the moving fold per frame.
edit('lib/kuran/kitap_sayfa_cevirici.dart', [
    ('duration: const Duration(milliseconds: 760)', 'duration: const Duration(milliseconds: 340)'),
    ('    if (fark.abs() != 1) {',
     '    if (fark.abs() != 1 || _cevirme.isAnimating || MediaQuery.disableAnimationsOf(context)) {'),
    ('''    if (_dokunanlar.isNotEmpty || _baslangic == null || _son == null ||
        _cevirme.isAnimating) return;
    final fark = _son! - _baslangic!;
    _baslangic = null;
    _son = null;''',
     '''    if (_dokunanlar.isNotEmpty) return;
    final baslangic = _baslangic;
    final son = _son;
    _baslangic = null;
    _son = null;
    if (baslangic == null || son == null || _cevirme.isAnimating) return;
    final fark = son - baslangic;'''),
    ('''      child: ClipRect(
        child: AnimatedBuilder(
          animation: _cevirme,
          builder: (context, _) {
            if (_eski == null || !_cevirme.isAnimating) {
              return widget.sayfaOlustur(widget.sayfa);
            }
            final ilerleme = Curves.easeInOutCubic.transform(_cevirme.value);
            final soldan = _yon > 0;
            return LayoutBuilder(builder: (context, kisitlar) {
              final boyut = Size(kisitlar.maxWidth, kisitlar.maxHeight);
              return Stack(fit: StackFit.expand, children: [
                // Yeni sayfa, kıvrılan eski yaprağın altında sabittir.
                widget.sayfaOlustur(widget.sayfa),
                IgnorePointer(
                  child: ClipPath(
                    clipper: _KalanSayfaKirpici(ilerleme, soldan),
                    child: widget.sayfaOlustur(_eski!),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: boyut,
                    painter: _KivrimBoyacisi(ilerleme, soldan),
                  ),
                ),
              ]);
            });
          },
        ),
      ),''',
     '''      child: ClipRect(
        child: Stack(fit: StackFit.expand, children: [
          _sayfaKatmani(widget.sayfa, eski: false),
          if (_eski != null) _sayfaKatmani(_eski!, eski: true),
          if (_eski != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _cevirme,
                  builder: (context, _) => CustomPaint(
                    painter: _KivrimBoyacisi(
                      Curves.easeInOutCubic.transform(_cevirme.value), _yon > 0),
                  ),
                ),
              ),
            ),
        ]),
      ),'''),
    ('''  @override
  Widget build(BuildContext context) {
    return Listener(''',
     '''  Widget _sayfaKatmani(int sayfa, {required bool eski}) {
    return KeyedSubtree(
      key: ValueKey(sayfa),
      child: IgnorePointer(
        ignoring: eski,
        child: AnimatedBuilder(
          animation: _cevirme,
          child: RepaintBoundary(child: widget.sayfaOlustur(sayfa)),
          builder: (context, child) => ClipPath(
            clipBehavior: eski ? Clip.antiAlias : Clip.none,
            clipper: eski ? _KalanSayfaKirpici(
              Curves.easeInOutCubic.transform(_cevirme.value), _yon > 0) : null,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener('''),
    ('    canvas.drawShadow(kirim, const Color(0xFF47341C), 12, false);',
     '    // The fold gradient supplies shading without a dynamic shadow pass.'),
])

# play() completes after playback; separate loading so pause/repeat work immediately.
edit('lib/ses/sayfa_oynatici.dart', [
    ('''  Future<void> cal(List<Ayet> ayetler, Okuyucu okuyucu, {int baslangic = 0}) async {
    final kaynaklar''',
     '''  Future<void> cal(List<Ayet> ayetler, Okuyucu okuyucu, {int baslangic = 0}) async {
    await hazirla(ayetler, okuyucu, baslangic: baslangic);
    await oynat();
  }

  Future<void> hazirla(List<Ayet> ayetler, Okuyucu okuyucu, {int baslangic = 0}) async {
    final kaynaklar'''),
    ('''    await _oynatici.setAudioSource(liste, initialIndex: baslangic);
    await _oynatici.play();
  }

  Future<void> oynatDurdur() => _oynatici.playing ? _oynatici.pause() : _oynatici.play();''',
     '''    await _oynatici.setAudioSource(liste, initialIndex: baslangic);
  }

  Future<void> oynat() => _oynatici.play();

  Future<void> oynatDurdur() async {
    if (_oynatici.processingState == ProcessingState.completed) {
      await _oynatici.seek(Duration.zero, index: 0);
      await _oynatici.play();
    } else if (_oynatici.playing) {
      await _oynatici.pause();
    } else {
      await _oynatici.play();
    }
  }'''),
])

p = Path('lib/ses/ses_cubugu.dart')
data = p.read_text(encoding='utf-8')
start = data.index('  Future<void> _tekAyetCal(Ayet ayet) async {')
end = data.index('  Future<void> _okuyucuSec() async {', start)
data = data[:start] + '''  Future<void> _tekAyetCal(Ayet ayet) => _baslat(ayet);

  Future<void> _tamSayfaCal() => _baslat(null);

  bool _guncel(int kimlik) => mounted && kimlik == _istekKimligi;

  Future<void> _baslat(Ayet? ayet) {
    if (!mounted || !_hazirMi || _ayetler.isEmpty) return Future<void>.value();
    final kimlik = ++_istekKimligi;
    setState(() {
      _tekAyetModu = ayet;
      _hazirlaniyor = true;
      _yuklendi = false;
      _hata = null;
    });
    _islem = _islem.then((_) async {
      if (!_guncel(kimlik)) return;
      try {
        await _oynatici.durdur();
        if (!_guncel(kimlik)) return;
        await _oynatici.hazirla(ayet == null ? _ayetler : [ayet], _okuyucu);
        if (!_guncel(kimlik)) return;
        await _oynatici.hizAyarlama(_hiz);
        if (!_guncel(kimlik)) return;
        await _oynatici.tekrarModu(_tekrarAcik);
        if (!_guncel(kimlik)) return;
        setState(() { _yuklendi = true; _hazirlaniyor = false; });
        unawaited(_oynatici.oynat().catchError((Object hata) {
          if (_guncel(kimlik)) setState(() {
            _yuklendi = false;
            _hata = 'Ses çalınamadı. Bağlantıyı ve okuyucuyu kontrol edin.';
          });
        }));
      } catch (_) {
        if (_guncel(kimlik)) setState(() {
          _hazirlaniyor = false;
          _yuklendi = false;
          _hata = 'Ses çalınamadı. Bağlantıyı ve okuyucuyu kontrol edin.';
        });
      }
    });
    return _islem;
  }

  Future<void> _calVeyaDevamEt() async {
    if (!mounted || _hazirlaniyor) return;
    setState(() => _hata = null);
    if (!_yuklendi) {
      await _baslat(_tekAyetModu);
      return;
    }
    final kimlik = _istekKimligi;
    try {
      await _oynatici.oynatDurdur();
    } catch (_) {
      if (_guncel(kimlik)) setState(() {
        _yuklendi = false;
        _hata = 'Ses çalınamadı. Bağlantıyı ve okuyucuyu kontrol edin.';
      });
    }
  }

''' + data[end:]
p.write_text(data, encoding='utf-8')
edit(str(p), [
    ("import 'package:flutter/material.dart';", "import 'dart:async';\nimport 'package:flutter/material.dart';"),
    ('  double _hiz = 1.0;', '''  double _hiz = 1.0;
  bool _hazirMi = false;
  bool _hazirlaniyor = false;
  int _istekKimligi = 0;
  Future<void> _islem = Future<void>.value();'''),
    ('''      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tekAyetCal(widget.seciliAyet!);
      });''',
     '''      final kimlik = widget.secimKimligi;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _hazirMi && widget.secimKimligi == kimlik &&
            widget.seciliAyet != null) {
          _tekAyetCal(widget.seciliAyet!);
        }
      });'''),
    ('    _oynatici.kapat();', '    _istekKimligi++;\n    _oynatici.kapat();'),
    ('      _ayetler = ayetler;', '      _ayetler = ayetler;\n      _hazirMi = true;'),
    ('    if (secilen == null) return;', '    if (secilen == null || !mounted || _hazirlaniyor) return;'),
    ('''    await _oynatici.durdur();
    _yuklendi = false;
    _tekAyetModu = null;
    setState(() => _okuyucu = okuyucular[secilen]);''',
     '''    if (!mounted) return;
    final kimlik = ++_istekKimligi;
    await _oynatici.durdur();
    if (!_guncel(kimlik)) return;
    setState(() {
      _yuklendi = false;
      _okuyucu = okuyucular[secilen];
    });'''),
    ('onPressed: _tamSayfaCal,', 'onPressed: _hazirlaniyor ? null : _tamSayfaCal,'),
    ('final calisiyor = durumSnap.data?.playing ?? false;', '''final calisiyor = (durumSnap.data?.playing ?? false) &&
                      durumSnap.data?.processingState != ProcessingState.completed;'''),
    ('final etiket = _tekAyetModu != null', "final etiket = _hazirlaniyor ? 'Ses hazırlanıyor…' : _tekAyetModu != null"),
    ('onPressed: _yuklendi ? _oynatici.onceki : null,', 'onPressed: _yuklendi && _tekAyetModu == null && !_hazirlaniyor ? _oynatici.onceki : null,'),
    ('onPressed: _yuklendi ? _oynatici.sonraki : null,', 'onPressed: _yuklendi && _tekAyetModu == null && !_hazirlaniyor ? _oynatici.sonraki : null,'),
    ('onPressed: _ayetler.isEmpty ? null : _calVeyaDevamEt,', 'onPressed: _ayetler.isEmpty || _hazirlaniyor ? null : _calVeyaDevamEt,'),
    ('onPressed: _okuyucuSec,', 'onPressed: _hazirlaniyor ? null : _okuyucuSec,'),
    ("tooltip: 'Dinleme ayarları',", "tooltip: 'Dinleme ayarları',\n                            enabled: !_hazirlaniyor,"),
])

print('V18: kitap geçişi ve hafızlık ayet dinletisi hazır.')
