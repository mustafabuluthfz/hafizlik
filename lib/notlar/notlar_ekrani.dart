import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/hafizlik_sira.dart';
import '../ortak/tema.dart';

/// Sayfa notları: her sayfaya kısa bir not (hatırlatma, tekrar notu vb.).
class NotlarEkrani extends StatefulWidget {
  const NotlarEkrani({super.key});

  @override
  State<NotlarEkrani> createState() => _NotlarEkraniState();
}

class _NotlarEkraniState extends State<NotlarEkrani> {
  static const String _anahtar = 'sayfa_notlari';
  Map<int, String> _notlar = {};

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
      _notlar = kayit == null
          ? {}
          : (jsonDecode(kayit) as Map<String, dynamic>)
              .map((k, v) => MapEntry(int.parse(k), v as String));
    });
  }

  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _anahtar, jsonEncode(_notlar.map((k, v) => MapEntry('$k', v))));
  }

  Future<void> _duzenle({int? sayfa, String? metin}) async {
    final sayfaKontrol = TextEditingController(text: sayfa?.toString() ?? '');
    final metinKontrol = TextEditingController(text: metin ?? '');
    final sonuc = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(sayfa == null ? 'Yeni not' : 'Notu düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sayfaKontrol,
              keyboardType: TextInputType.number,
              enabled: sayfa == null,
              decoration: const InputDecoration(labelText: 'Sayfa (1-604)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: metinKontrol,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notunuz'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Kaydet')),
        ],
      ),
    );
    if (sonuc != true) return;
    final hedefSayfa = sayfa ?? int.tryParse(sayfaKontrol.text.trim());
    final not = metinKontrol.text.trim();
    if (hedefSayfa == null || hedefSayfa < 1 || hedefSayfa > HafizlikSira.toplamSayfa) return;
    setState(() {
      if (not.isEmpty) {
        _notlar.remove(hedefSayfa);
      } else {
        _notlar[hedefSayfa] = not;
      }
    });
    await _kaydet();
  }

  @override
  Widget build(BuildContext context) {
    final sirali = _notlar.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Notlarım')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _duzenle(),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Not ekle'),
      ),
      body: sirali.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Henüz not yok. Sayfalara tekrar hatırlatmaları, zor kelimeler veya kendi notlarınızı ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: sirali.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = sirali[i];
                return Card(
                  child: ListTile(
                    onTap: () => _duzenle(sayfa: s, metin: _notlar[s]),
                    leading: CircleAvatar(
                      backgroundColor: kAltinAcik.withOpacity(0.5),
                      child: Text('$s',
                          style: const TextStyle(fontSize: 12, color: kYesil)),
                    ),
                    title: Text('Sayfa $s · ${HafizlikSira.cuzOf(s)}. cüz'),
                    subtitle: Text(_notlar[s]!, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        setState(() => _notlar.remove(s));
                        await _kaydet();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
