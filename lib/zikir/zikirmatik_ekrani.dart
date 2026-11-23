import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ortak/mushaf.dart';
import '../ortak/tema.dart';

class Zikir {
  final String ad;
  final String arapca;
  final int hedef; // 0 = serbest

  const Zikir(this.ad, this.arapca, this.hedef);
}

const List<Zikir> zikirler = [
  Zikir('Sübhanallah', 'سُبْحَانَ اللَّهِ', 33),
  Zikir('Elhamdülillah', 'الْحَمْدُ لِلَّهِ', 33),
  Zikir('Allahu Ekber', 'اللَّهُ أَكْبَرُ', 34),
  Zikir('La ilahe illallah', 'لَا إِلَٰهَ إِلَّا اللَّهُ', 100),
  Zikir('Estağfirullah', 'أَسْتَغْفِرُ اللَّهَ', 100),
  Zikir('Salavat', 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 100),
  Zikir('Serbest', '', 0),
];

class ZikirmatikEkrani extends StatefulWidget {
  const ZikirmatikEkrani({super.key});

  @override
  State<ZikirmatikEkrani> createState() => _ZikirmatikEkraniState();
}

class _ZikirmatikEkraniState extends State<ZikirmatikEkrani> {
  static const String _anahtar = 'zikir_sayac';
  int _secili = 0;
  Map<String, int> _sayaclar = {};

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayit = prefs.getString(_anahtar);
    if (!mounted) return;
    setState(() {
      _sayaclar = kayit == null
          ? {}
          : (jsonDecode(kayit) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as int));
    });
  }

  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anahtar, jsonEncode(_sayaclar));
  }

  Zikir get _zikir => zikirler[_secili];
  int get _sayi => _sayaclar[_zikir.ad] ?? 0;

  Future<void> _artir() async {
    final yeni = _sayi + 1;
    setState(() => _sayaclar[_zikir.ad] = yeni);
    await _kaydet();
    if (_zikir.hedef > 0 && yeni % _zikir.hedef == 0) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_zikir.ad} · $yeni tamamlandı'),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _sifirla() async {
    setState(() => _sayaclar[_zikir.ad] = 0);
    await _kaydet();
  }

  @override
  Widget build(BuildContext context) {
    final hedef = _zikir.hedef;
    final oran = hedef == 0 ? 0.0 : (_sayi % hedef) / hedef;

    return Scaffold(
      appBar: AppBar(title: const Text('Zikirmatik')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _secili,
              decoration: const InputDecoration(
                labelText: 'Zikir',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var i = 0; i < zikirler.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(zikirler[i].hedef == 0
                        ? zikirler[i].ad
                        : '${zikirler[i].ad} (${zikirler[i].hedef})'),
                  ),
              ],
              onChanged: (v) => setState(() => _secili = v ?? 0),
            ),
            const SizedBox(height: 16),
            if (_zikir.arapca.isNotEmpty)
              Text(
                _zikir.arapca,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kMushafFontu,
                  fontSize: 30,
                  color: kYesil,
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: _artir,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: hedef == 0 ? 1 : oran,
                        strokeWidth: 14,
                        backgroundColor: kAltinAcik.withOpacity(0.5),
                        color: kAltin,
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kYesil, kYesilAcik],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kYesil.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$_sayi',
                              style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          if (hedef > 0)
                            Text('hedef $hedef',
                                style: const TextStyle(color: kAltinAcik)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Daireye dokunarak sayın'),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _sifirla,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Sayacı sıfırla'),
            ),
          ],
        ),
      ),
    );
  }
}
