import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../konum/konum_servisi.dart';
import '../namaz/vakit_hesap.dart';
import '../ortak/tema.dart';

class KibleEkrani extends StatefulWidget {
  const KibleEkrani({super.key});

  @override
  State<KibleEkrani> createState() => _KibleEkraniState();
}

class _KibleEkraniState extends State<KibleEkrani> {
  bool _yukleniyor = true;
  double? _kible;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final konum = await KonumServisi.al();
    if (!mounted) return;
    setState(() {
      if (konum == null) {
        _hata = 'Kıble için konum gerekli. Konum iznini verin.';
      } else {
        _kible = VakitHesap.kibleAcisi(konum.enlem, konum.boylam);
      }
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kıble')),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_hata!)))
              : _pusula(),
    );
  }

  Widget _pusula() {
    final akis = FlutterCompass.events;
    if (akis == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Bu cihazda pusula sensörü bulunamadı.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: akis,
      builder: (context, snap) {
        // Cihazın kuzeyden saat yönünde sapması (derece).
        final yon = snap.data?.heading;
        final kible = _kible!;
        final fark = yon == null ? null : ((kible - yon + 540) % 360) - 180;
        final hizali = fark != null && fark.abs() < 5;

        // Kadran, cihaz yönünün tersine döner: K her zaman gerçek kuzeyi gösterir.
        final kadranAcisi = yon == null ? 0.0 : -yon * math.pi / 180;
        // Kıble işareti kadran üzerinde kendi açısına (kuzeyden kible) yerleşir.
        final kibleAcisi = kible * math.pi / 180;

        const etiket = TextStyle(fontWeight: FontWeight.w800, color: kYesil);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: kadranAcisi,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: kAltin, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: kYesil.withOpacity(0.12),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text('K', style: etiket),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('G', style: etiket),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text('B', style: etiket),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: Text('D', style: etiket),
                            ),
                          ),
                          Transform.rotate(
                            angle: kibleAcisi,
                            child: const Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 44),
                                child: Icon(Icons.location_on_rounded,
                                    size: 34, color: Colors.redAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sabit işaret: telefonun üst kenarının baktığı yön.
                    Positioned(
                      top: 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 44,
                        color: hizali ? kYesil : Colors.brown.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Kıble yönü: ${kible.toStringAsFixed(1)}°',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                fark == null
                    ? 'Pusula bekleniyor…'
                    : (hizali
                        ? 'Kıbleye yöneldiniz'
                        : 'Kıbleye ${fark.abs().toStringAsFixed(0)}° ${fark > 0 ? 'sağa' : 'sola'} dönün'),
                style: TextStyle(
                  color: hizali ? kYesil : Colors.brown.shade700,
                  fontWeight: hizali ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Telefonu düz tutun ve pusulayı kalibre edin. Kırmızı işaret kıble yönünü gösterir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.brown.shade500),
              ),
            ],
          ),
        );
      },
    );
  }
}
