import 'package:flutter/material.dart';

import '../ortak/islimi_desen.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';

/// Uygulama açılışı: koyu yeşil zeminde altın desen, simge, ayet ve mealin
/// zarif biçimde belirmesi. Dokunulursa animasyon atlanır.
class AcilisEkrani extends StatefulWidget {
  final Widget sonraki;

  const AcilisEkrani({super.key, required this.sonraki});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani>
    with SingleTickerProviderStateMixin {
  static const String _ayet =
      'قُلۡ هَلۡ يَسۡتَوِي ٱلَّذِينَ يَعۡلَمُونَ وَٱلَّذِينَ لَا يَعۡلَمُونَ';
  static const String _meal = 'De ki: Bilenlerle bilmeyenler bir olur mu?';
  static const String _kaynak = 'Zümer Suresi · 39/9';

  late final AnimationController _kontrol;
  final List<String> _kelimeler = _ayet.split(' ');
  bool _gecildi = false;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();
    _kontrol.addStatusListener((durum) {
      if (durum == AnimationStatus.completed) _sonrakineGec();
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  void _sonrakineGec() {
    if (_gecildi || !mounted) return;
    _gecildi = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => widget.sonraki,
        transitionsBuilder: (_, animasyon, __, sayfa) =>
            FadeTransition(opacity: animasyon, child: sayfa),
      ),
    );
  }

  /// 0..1 arası, [bas]-[bit] zaman diliminde ilerleme.
  double _aralik(double bas, double bit) {
    final t = (_kontrol.value - bas) / (bit - bas);
    return t < 0 ? 0 : (t > 1 ? 1 : t);
  }

  @override
  Widget build(BuildContext context) {
    final n = _kelimeler.length;
    final simgeOlcek = 0.55 + 0.45 * Curves.easeOutBack.transform(_aralik(0.0, 0.14));
    final cikis = 1 - _aralik(0.92, 1.0);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _sonrakineGec,
        child: AnimatedBuilder(
          animation: _kontrol,
          builder: (context, _) {
            return Opacity(
              opacity: cikis,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0E3B16), kYesil, kYesilAcik],
                  ),
                ),
                child: Stack(
                  children: [
                    // Altın desen yavaşça belirir
                    Positioned.fill(
                      child: Opacity(
                        opacity: _aralik(0.0, 0.25) * 0.9,
                        child: const CustomPaint(
                          painter: IslimiDesen(renk: kAltin, hucre: 90),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Simge: büyüyerek ve parlayarak gelir
                            Opacity(
                              opacity: _aralik(0.0, 0.12),
                              child: Transform.scale(
                                scale: simgeOlcek,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kAltin.withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Image.asset(
                                      'assets/icon/icon.png',
                                      width: 96,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Ayet kelime kelime, altın renkte
                            Text.rich(
                              TextSpan(
                                children: [
                                  for (var i = 0; i < n; i++)
                                    TextSpan(
                                      text: '${_kelimeler[i]} ',
                                      style: TextStyle(
                                        color: kAltinAcik.withOpacity(
                                          _aralik(
                                            0.12 + i * (0.45 / n),
                                            0.12 + i * (0.45 / n) + 0.05,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: kMushafFontu,
                                fontSize: 32,
                                height: 2.1,
                                shadows: [
                                  Shadow(color: Colors.black38, blurRadius: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Altın ayraç çizgisi genişleyerek açılır
                            Container(
                              width: 140 * _aralik(0.6, 0.72),
                              height: 1.5,
                              color: kAltin,
                            ),
                            const SizedBox(height: 18),
                            Opacity(
                              opacity: _aralik(0.7, 0.84),
                              child: const Text(
                                _meal,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: kZemin,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Opacity(
                              opacity: _aralik(0.84, 0.94),
                              child: const Text(
                                _kaynak,
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                  color: kAltinAcik,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 28,
                      child: Opacity(
                        opacity: _aralik(0.35, 0.5) * (1 - _aralik(0.8, 0.9)),
                        child: const Text(
                          'Geçmek için dokunun',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kAltinAcik, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
