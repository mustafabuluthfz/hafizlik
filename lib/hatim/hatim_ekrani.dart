import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/hafizlik_sira.dart';
import '../ortak/tema.dart';
import '../ortak/ikonlar.dart';

/// Hatim planı: seçilen gün sayısına göre her gün kaç sayfa okunacağını hesaplar.
class HatimEkrani extends StatefulWidget {
  const HatimEkrani({super.key});

  @override
  State<HatimEkrani> createState() => _HatimEkraniState();
}

class _HatimEkraniState extends State<HatimEkrani> {
  static const List<int> _secenekler = [15, 20, 30, 40, 60];

  bool _yukleniyor = true;
  DateTime? _baslangic;
  int _gun = 30;
  int _tamamlananHatim = 0;
  List<int> _tamamlananGunler = [];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final bas = prefs.getString('hatim_bas');
    if (!mounted) return;
    setState(() {
      _baslangic = bas == null ? null : DateTime.tryParse(bas);
      _gun = prefs.getInt('hatim_gun') ?? 30;
      _tamamlananHatim = prefs.getInt('hatim_sayi') ?? 0;
      _tamamlananGunler = (jsonDecode(prefs.getString('hatim_tamam') ?? '[]') as List).cast<int>();
      _yukleniyor = false;
    });
  }

  int get _sayfaSayisi => HafizlikSira.toplamSayfa;
  int get _gunlukSayfa => (_sayfaSayisi / _gun).ceil();

  /// Bugünün gün numarası (0'dan başlar).
  int get _bugunIndeks {
    if (_baslangic == null) return 0;
    final b = _baslangic!;
    final n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day)
        .difference(DateTime.utc(b.year, b.month, b.day))
        .inDays;
  }

  (int, int) _aralik(int indeks) {
    final bas = indeks * _gunlukSayfa + 1;
    final ham = (indeks + 1) * _gunlukSayfa;
    final son = ham > _sayfaSayisi ? _sayfaSayisi : ham;
    return (bas, son);
  }

  Future<void> _baslat() async {
    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now();
    await prefs.setString('hatim_bas', DateTime(bugun.year, bugun.month, bugun.day).toIso8601String());
    await prefs.setString('hatim_tamam', '[]');
    await _yukle();
  }

  Future<void> _gunSec(int gun) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hatim_gun', gun);
    setState(() => _gun = gun);
  }

  Future<void> _bugunuDegistir() async {
    final i = _bugunIndeks;
    final liste = [..._tamamlananGunler];
    if (liste.contains(i)) {
      liste.remove(i);
    } else {
      liste.add(i);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hatim_tamam', jsonEncode(liste));
    setState(() => _tamamlananGunler = liste);
  }

  Future<void> _yeniHatim() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hatim_sayi', _tamamlananHatim + 1);
    await _baslat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hatim Planı')),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hedef süre',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final g in _secenekler)
                              ChoiceChip(
                                label: Text('$g gün'),
                                selected: _gun == g,
                                onSelected: (_) => _gunSec(g),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Günlük okuma: $_gunlukSayfa sayfa',
                            style: const TextStyle(fontSize: 15)),
                        Text('Tamamlanan hatim: $_tamamlananHatim',
                            style: TextStyle(color: Colors.brown.shade700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_baslangic == null)
                  FilledButton.icon(
                    onPressed: _baslat,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Hatmi başlat'),
                  )
                else if (_bugunIndeks >= _gun)
                  _Tamam(onYeni: _yeniHatim)
                else
                  _Bugun(
                    gunNo: _bugunIndeks + 1,
                    gun: _gun,
                    aralik: _aralik(_bugunIndeks),
                    tamam: _tamamlananGunler.contains(_bugunIndeks),
                    onDegistir: _bugunuDegistir,
                  ),
                const SizedBox(height: 16),
                if (_baslangic != null) ...[
                  Text('Hatim takvimi',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: kMetin)),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _gun; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          _tamamlananGunler.contains(i)
                              ? AppIkonlari.tamam
                              : (i == _bugunIndeks
                                  ? Icons.radio_button_checked_rounded
                                  : AppIkonlari.tamamDegil),
                          color: _tamamlananGunler.contains(i) ? kYesil : kAltin,
                        ),
                        title: Text('${i + 1}. gün'),
                        trailing: Text(() {
                          final (a, b) = _aralik(i);
                          return 'Sayfa $a–$b';
                        }()),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _Bugun extends StatelessWidget {
  final int gunNo;
  final int gun;
  final (int, int) aralik;
  final bool tamam;
  final VoidCallback onDegistir;

  const _Bugun({
    required this.gunNo,
    required this.gun,
    required this.aralik,
    required this.tamam,
    required this.onDegistir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Bugün · $gunNo / $gun. gün',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Sayfa ${aralik.$1} – ${aralik.$2}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kYesil)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onDegistir,
              style: FilledButton.styleFrom(
                backgroundColor: tamam ? kAltin : null,
              ),
              icon: Icon(tamam ? AppIkonlari.tamam : AppIkonlari.tamamDegil),
              label: Text(tamam ? 'Bugünkü bölüm tamam' : 'Bugünkü bölümü tamamladım'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tamam extends StatelessWidget {
  final VoidCallback onYeni;

  const _Tamam({required this.onYeni});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.emoji_events_rounded, size: 48, color: kAltin),
            const SizedBox(height: 8),
            const Text('Hatim tamamlandı. Allah kabul etsin!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onYeni, child: const Text('Yeni hatim başlat')),
          ],
        ),
      ),
    );
  }
}
