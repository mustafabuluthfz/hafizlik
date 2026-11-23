import 'package:shared_preferences/shared_preferences.dart';

import 'hafizlik_sira.dart';

/// Bugünkü hafızlık sayfasının numarası (ilk açılış tarihi kayıtlıdır).
Future<int> bugunkuSayfaNo() async {
  final prefs = await SharedPreferences.getInstance();
  final kayit = prefs.getString('baslangic_tarihi');
  final bugun = DateTime.now();

  DateTime baslangic;
  if (kayit == null) {
    baslangic = DateTime(bugun.year, bugun.month, bugun.day);
    await prefs.setString('baslangic_tarihi', baslangic.toIso8601String());
  } else {
    baslangic = DateTime.parse(kayit);
  }
  return HafizlikSira.pageForDay(baslangic, bugun);
}
