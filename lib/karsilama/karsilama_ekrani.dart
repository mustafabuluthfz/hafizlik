import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bildirim/bildirim_servisi.dart';
import '../konum/konum_servisi.dart';
import '../ortak/ikonlar.dart';
import '../ortak/tema.dart';

/// İlk açılışta bir kez gösterilen karşılama akışı: tanıtım ve izinler.
class KarsilamaEkrani extends StatefulWidget {
  final Widget sonraki;

  const KarsilamaEkrani({super.key, required this.sonraki});

  /// Karşılama daha önce tamamlandı mı?
  static Future<bool> tamamlandiMi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('karsilama_tamam') ?? false;
  }

  @override
  State<KarsilamaEkrani> createState() => _KarsilamaEkraniState();
}

class _KarsilamaEkraniState extends State<KarsilamaEkrani> {
  final PageController _kontrol = PageController();
  int _sayfa = 0;
  bool _izinIsteniyor = false;

  static const List<_Sayfa> _sayfalar = [
    _Sayfa(
      ikon: AppIkonlari.kuran,
      baslik: 'Hoş geldiniz',
      metin: 'Kur\'an\'ı günlük okuma, ezber takibi ve ibadet araçlarıyla yanınızda taşıyın.',
    ),
    _Sayfa(
      ikon: AppIkonlari.hafizlik,
      baslik: 'Hafızlık planınız',
      metin: 'Her gün bir sayfa. Seri, rozet ve ilerleme haritasıyla motivasyonunuzu koruyun.',
    ),
    _Sayfa(
      ikon: AppIkonlari.namaz,
      baslik: 'Vakitler ve hatırlatma',
      metin: 'Namaz vakitlerini ve kıble yönünü konumunuza göre görün. Hatırlatmalar isteğe bağlıdır.',
    ),
  ];

  bool get _sonSayfa => _sayfa == _sayfalar.length;

  Future<void> _izinleriIste() async {
    setState(() => _izinIsteniyor = true);
    await KonumServisi.al();
    await BildirimServisi.izinIste();
    if (mounted) setState(() => _izinIsteniyor = false);
  }

  Future<void> _bitir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('karsilama_tamam', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => widget.sonraki,
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(kBosluk8),
                child: TextButton(onPressed: _bitir, child: const Text('Atla')),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _kontrol,
                onPageChanged: (i) => setState(() => _sayfa = i),
                children: [
                  for (final s in _sayfalar) _TanitimSayfasi(sayfa: s),
                  _IzinSayfasi(
                    yukleniyor: _izinIsteniyor,
                    onIzin: _izinleriIste,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i <= _sayfalar.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _sayfa ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _sayfa ? kYesil : tema.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: kBosluk24),
            Padding(
              padding: const EdgeInsets.fromLTRB(kBosluk24, 0, kBosluk24, kBosluk24),
              child: FilledButton(
                onPressed: _sonSayfa
                    ? _bitir
                    : () => _kontrol.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        ),
                child: Text(_sonSayfa ? 'Başlayalım' : 'İleri'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sayfa {
  final IconData ikon;
  final String baslik;
  final String metin;

  const _Sayfa({required this.ikon, required this.baslik, required this.metin});
}

class _TanitimSayfasi extends StatelessWidget {
  final _Sayfa sayfa;

  const _TanitimSayfasi({required this.sayfa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kBosluk32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kYesil, kYesilAcik],
              ),
              boxShadow: [
                BoxShadow(color: kYesil.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            child: Icon(sayfa.ikon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: kBosluk32),
          Text(sayfa.baslik,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: kBosluk12),
          Text(sayfa.metin,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.5)),
        ],
      ),
    );
  }
}

class _IzinSayfasi extends StatelessWidget {
  final bool yukleniyor;
  final VoidCallback onIzin;

  const _IzinSayfasi({required this.yukleniyor, required this.onIzin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kBosluk32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(AppIkonlari.bilgi, size: 56, color: kAltin),
          const SizedBox(height: kBosluk24),
          Text('İzinler', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: kBosluk12),
          const Text(
            'Namaz vakitleri ve kıble için konum, hatırlatmalar için bildirim izni istenir. '
            'Bunları şimdi veya daha sonra Ayarlar\'dan verebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: kBosluk24),
          OutlinedButton.icon(
            onPressed: yukleniyor ? null : onIzin,
            icon: yukleniyor
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(AppIkonlari.konum),
            label: const Text('İzinleri ver'),
          ),
        ],
      ),
    );
  }
}
