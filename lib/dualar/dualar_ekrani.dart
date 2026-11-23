import 'package:flutter/material.dart';

import '../hafizlik/quran_veri.dart';
import 'ek_dualar.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';

/// Kur'an'dan seçilmiş dualar. Metinler veri dosyasından alınır.
class Dua {
  final String ad;
  final int sure;
  final int baslangic;
  final int bitis;
  final String anlam;

  const Dua(this.ad, this.sure, this.baslangic, this.bitis, this.anlam);
}

const List<Dua> dualar = [
  Dua('Ayetel Kürsî', 2, 255, 255,
      'Allah, kendisinden başka ilah olmayan, diri ve her şeyi ayakta tutandır.'),
  Dua('Âmentü\'r-Rasûl', 2, 285, 286,
      'Peygamber ve müminler Rablerinden indirilene iman etti. Allah kimseye gücünün yetmediğini yüklemez.'),
  Dua('Dünya ve ahiret duası', 2, 201, 201,
      'Rabbimiz, bize dünyada da ahirette de iyilik ver ve bizi ateş azabından koru.'),
  Dua('İlim duası', 20, 114, 114,
      'Rabbim, ilmimi artır.'),
  Dua('Mağfiret duası', 14, 41, 41,
      'Rabbimiz, beni, ana babamı ve müminleri hesap günü bağışla.'),
];

class DualarEkrani extends StatefulWidget {
  const DualarEkrani({super.key});

  @override
  State<DualarEkrani> createState() => _DualarEkraniState();
}

class _DualarEkraniState extends State<DualarEkrani> {
  late final Future<Map<String, String>> _metinler = _metinleriYukle();

  /// "sure:ayet" anahtarıyla ayet metinleri.
  static Future<Map<String, String>> _metinleriYukle() async {
    final tum = await QuranVeri.tumAyetler();
    final harita = <String, String>{};
    for (final a in tum) {
      harita['${a.sure}:${a.numara}'] = a.metin;
    }
    return harita;
  }

  String _metin(Map<String, String> harita, Dua d) {
    final parcalar = <String>[];
    for (var a = d.baslangic; a <= d.bitis; a++) {
      parcalar.add(harita['${d.sure}:$a'] ?? '');
    }
    return parcalar.join(' ');
  }

  Widget _ekDuaKarti(EkDua d) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.favorite_rounded, color: kAltin),
              const SizedBox(width: 6),
              Expanded(
                child: Text(d.ad, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Text(d.kaynak, style: TextStyle(color: Colors.brown.shade600, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Text(d.arapca,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: kMushafFontu, fontSize: 22, height: 2, color: kYesil)),
            const SizedBox(height: 10),
            Text(d.turkce,
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.brown.shade700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dualar')),
      body: FutureBuilder<Map<String, String>>(
        future: _metinler,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final harita = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dualar.length + ekDualar.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i >= dualar.length) return _ekDuaKarti(ekDualar[i - dualar.length]);
              final d = dualar[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: kAltin),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(d.ad,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                          Text(
                            d.baslangic == d.bitis
                                ? '${d.sure}:${d.baslangic}'
                                : '${d.sure}:${d.baslangic}-${d.bitis}',
                            style: TextStyle(color: Colors.brown.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _metin(harita, d),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: kMushafFontu,
                          fontSize: 22,
                          height: 2,
                          color: kYesil,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        d.anlam,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.brown.shade700),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
