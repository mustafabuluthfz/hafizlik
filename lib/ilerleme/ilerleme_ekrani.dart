import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/bugunku_sayfa.dart';
import '../hafizlik/hafizlik_sira.dart';
import '../ortak/ilerleme_depo.dart';
import '../hafizlik/quran_veri.dart';
import '../kuran/kuran_okuma_ekrani.dart';
import '../ortak/tema.dart';
import '../ortak/ikonlar.dart';

/// İlerlemem: seri, okunan gün sayısı, tur, halka grafik ve rozetler.
class IlerlemeEkrani extends StatefulWidget {
  const IlerlemeEkrani({super.key});

  @override
  State<IlerlemeEkrani> createState() => _IlerlemeEkraniState();
}

class _IlerlemeEkraniState extends State<IlerlemeEkrani> {
  bool _yukleniyor = true;
  int _gun = 0; // başlangıçtan bugüne kaç gün (bugün dahil)
  int _sayfa = 0;
  DateTime? _baslangic;
  int _okunanGun = 0;
  int _seri = 0;
  List<Rozet> _rozetler = [];
  List<MapEntry<DateTime, int>> _tekrar = [];
  Set<int> _okunanSayfalar = {};
  int _okunanAyet = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final sayfa = await bugunkuSayfaNo();
    final prefs = await SharedPreferences.getInstance();
    final kayit = prefs.getString('baslangic_tarihi');
    final bugun = DateTime.now();
    final b = (kayit == null ? null : DateTime.tryParse(kayit)) ??
        DateTime(bugun.year, bugun.month, bugun.day);
    final fark = DateTime.utc(bugun.year, bugun.month, bugun.day)
        .difference(DateTime.utc(b.year, b.month, b.day))
        .inDays;
    final gunler = await IlerlemeDepo.gunler();
    final seri = IlerlemeDepo.seri(gunler, bugun);
    final rozetler = await IlerlemeDepo.rozetler(bugun: bugun);

    // Okunan günlerin sayfaları → sayfa ve ayet sayıları
    final okunan = <int>{};
    for (final k in gunler) {
      final t = DateTime.tryParse(k);
      if (t != null) okunan.add(IlerlemeDepo.sayfaGununde(b, t));
    }
    final tumAyetler = await QuranVeri.tumAyetler();
    final ayetSayisi = tumAyetler.where((a) => okunan.contains(a.sayfa)).length;

    // Son okunan 10 günün sayfaları (tekrar için)
    final tekrar = <MapEntry<DateTime, int>>[];
    for (final k in (gunler.toList()..sort()).reversed.take(10)) {
      final t = DateTime.tryParse(k);
      if (t == null) continue;
      tekrar.add(MapEntry(t, IlerlemeDepo.sayfaGununde(b, t)));
    }

    if (!mounted) return;
    setState(() {
      _baslangic = b;
      _gun = fark + 1;
      _sayfa = sayfa;
      _okunanGun = gunler.length;
      _seri = seri;
      _rozetler = rozetler;
      _tekrar = tekrar;
      _okunanSayfalar = okunan;
      _okunanAyet = ayetSayisi;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dongu = HafizlikSira.dongu;
    final gunIci = _gun <= 0 ? 0 : ((_gun - 1) % dongu) + 1;
    final tamamlananTur = _gun <= 0 ? 0 : (_gun - 1) ~/ dongu;
    final oran = gunIci / dongu;
    final kazanilan = _rozetler.where((r) => r.kazanildi).length;

    return Scaffold(
      appBar: AppBar(title: const Text('İlerlemem')),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: oran,
                                  strokeWidth: 12,
                                  backgroundColor: kAltinAcik.withOpacity(0.5),
                                  color: kYesil,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('%${(oran * 100).floor()}',
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: kYesil)),
                                  const Text('bu tur',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _gun <= 0
                              ? 'Henüz başlamadınız'
                              : '$gunIci / $dongu gün bu turda',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Istatistik(
                        ikon: AppIkonlari.seri,
                        baslik: 'Seri',
                        deger: '$_seri gün',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Istatistik(
                        ikon: AppIkonlari.tamam,
                        baslik: 'Okunan gün',
                        deger: '$_okunanGun',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Istatistik(
                        ikon: Icons.loop_rounded,
                        baslik: 'Tamamlanan tur',
                        deger: '$tamamlananTur',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Istatistik(
                        ikon: AppIkonlari.sayfa,
                        baslik: 'Bugünkü sayfa',
                        deger: _sayfa == 0 ? '-' : '$_sayfa',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Rozetler · $kazanilan / ${_rozetler.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: kMetin)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [for (final r in _rozetler) _RozetKarti(rozet: r)],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Istatistik(
                        ikon: AppIkonlari.sureler,
                        baslik: 'Okunan ayet',
                        deger: '$_okunanAyet',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Istatistik(
                        ikon: Icons.pie_chart_rounded,
                        baslik: 'Kur\'an yüzdesi',
                        deger:
                            '%${(_okunanSayfalar.length * 100 / HafizlikSira.toplamSayfa).toStringAsFixed(1)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Cüz haritası',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: kMetin)),
                const SizedBox(height: 8),
                _CuzHaritasi(okunanSayfalar: _okunanSayfalar),
                const SizedBox(height: 22),
                Text('Tekrar et · son okuduğunuz sayfalar',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: kMetin)),
                const SizedBox(height: 8),
                if (_tekrar.isEmpty)
                  Text('Henüz okunmuş gün yok.',
                      style: TextStyle(color: Colors.brown.shade600)),
                for (final e in _tekrar)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.replay_rounded, color: kYesil),
                      title: Text('Sayfa ${e.value} · ${HafizlikSira.cuzOf(e.value)}. Cüz'),
                      subtitle: Text('${e.key.day}.${e.key.month}.${e.key.year}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              KuranOkumaEkrani(baslangicSayfa: e.value))),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(
                  'Her gün bir sayfa okursunuz. $dongu günlük tur tamamlanınca '
                  'yeni tur başlar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.brown.shade700, fontSize: 13),
                ),
              ],
            ),
    );
  }
}

class _Istatistik extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;

  const _Istatistik({required this.ikon, required this.baslik, required this.deger});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(ikon, color: kYesil),
            const SizedBox(height: 8),
            Text(deger,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: kMetin)),
            const SizedBox(height: 2),
            Text(baslik, style: TextStyle(fontSize: 12, color: Colors.brown.shade600)),
          ],
        ),
      ),
    );
  }
}

class _RozetKarti extends StatelessWidget {
  final Rozet rozet;

  const _RozetKarti({required this.rozet});

  @override
  Widget build(BuildContext context) {
    final acik = rozet.kazanildi;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: acik ? kAltinAcik.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: acik ? kAltin : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(rozet.ikon, color: acik ? kYesil : Colors.grey, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rozet.ad,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: acik ? kMetin : Colors.grey.shade600)),
                Text(acik ? rozet.aciklama : 'Kilitli',
                    style: TextStyle(fontSize: 11, color: Colors.brown.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 30 cüzün her biri, okunan sayfa oranına göre koyulukta gösterilir.
class _CuzHaritasi extends StatelessWidget {
  final Set<int> okunanSayfalar;

  const _CuzHaritasi({required this.okunanSayfalar});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 6,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: [
        for (var c = 1; c <= 30; c++) _cuzKutusu(c),
      ],
    );
  }

  Widget _cuzKutusu(int c) {
    final bas = HafizlikSira.cuzBaslangici(c);
    final son = c == 30 ? HafizlikSira.toplamSayfa : HafizlikSira.cuzBaslangici(c + 1) - 1;
    final toplam = son - bas + 1;
    var okunan = 0;
    for (var p = bas; p <= son; p++) {
      if (okunanSayfalar.contains(p)) okunan++;
    }
    final oran = okunan / toplam;
    return Container(
      decoration: BoxDecoration(
        color: kYesil.withOpacity(0.08 + 0.92 * oran),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAltin.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$c',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: oran > 0.5 ? Colors.white : kMetin,
        ),
      ),
    );
  }
}
