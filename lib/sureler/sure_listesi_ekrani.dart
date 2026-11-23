import 'package:flutter/material.dart';

import '../bulmaca/sureler.dart';
import '../hafizlik/quran_veri.dart';
import '../kuran/kuran_okuma_ekrani.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import '../ortak/ikonlar.dart';

/// 114 surenin listesi. Bir surenin üstüne dokununca Kur'an ekranında ilk sayfasından açılır.
class SureListesiEkrani extends StatefulWidget {
  const SureListesiEkrani({super.key});

  @override
  State<SureListesiEkrani> createState() => _SureListesiEkraniState();
}

class _SureListesiEkraniState extends State<SureListesiEkrani> {
  String _ara = '';

  Future<void> _ac(int no) async {
    final sayfa = await QuranVeri.sureninIlkSayfasi(no);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => KuranOkumaEkrani(baslangicSayfa: sayfa),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final q = _ara.toLowerCase();
    final liste = sureler
        .where((s) =>
            q.isEmpty ||
            s.trAd.toLowerCase().contains(q) ||
            s.okunus.toLowerCase().contains(q) ||
            '${s.no}'.contains(q))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sureler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _ara = v.trim()),
              decoration: InputDecoration(
                hintText: 'Sure adı veya numarası',
                prefixIcon: const Icon(AppIkonlari.arama),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: kAltin.withOpacity(0.4)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: liste.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = liste[i];
                return Card(
                  child: ListTile(
                    onTap: () => _ac(s.no),
                    leading: CircleAvatar(
                      backgroundColor: kYesil.withOpacity(0.12),
                      child: Text('${s.no}',
                          style: const TextStyle(
                              color: kYesil, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(s.trAd,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${s.trAnlam} · ${s.ayetSayisi} ayet'),
                    trailing: Text(
                      s.ad,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                          fontFamily: kMushafFontu, fontSize: 22, color: kYesil),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
