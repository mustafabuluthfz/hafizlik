import 'package:shared_preferences/shared_preferences.dart';

String _saat(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Ana ekran widget’ı için bugünkü vakitleri ve sıradaki vakti yazar.
/// Android tarafı bu anahtarları "FlutterSharedPreferences" dosyasından okur.
Future<void> vakitWidgetVerisiYaz(Map<String, DateTime> vakitler) async {
  if (vakitler.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  final simdi = DateTime.now();

  String? sonrakiAd;
  DateTime? sonrakiZaman;
  for (final e in vakitler.entries) {
    if (e.value.isAfter(simdi)) {
      sonrakiAd = e.key;
      sonrakiZaman = e.value;
      break;
    }
  }
  if (sonrakiAd == null) {
    // Yatsıdan sonra: sıradaki vakit yarının imsakı.
    final ilk = vakitler.entries.first;
    sonrakiAd = ilk.key;
    sonrakiZaman = ilk.value.add(const Duration(days: 1));
  }

  final satirlar = vakitler.entries.map((e) => '${e.key} ${_saat(e.value)}').join('|');
  await prefs.setString('widget_satirlar', satirlar);
  await prefs.setString('widget_sonraki_ad', sonrakiAd);
  await prefs.setString('widget_sonraki_saat', _saat(sonrakiZaman!));
}
