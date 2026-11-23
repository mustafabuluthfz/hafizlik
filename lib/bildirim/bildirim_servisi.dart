import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Namaz vakti ve günlük okuma hatırlatması bildirimleri.
/// Zamanlar mutlak an olarak verilir; cihaz saat dilimi gerekmez.
class BildirimServisi {
  static final FlutterLocalNotificationsPlugin _eklenti =
      FlutterLocalNotificationsPlugin();

  static const String _namazKanal = 'namaz_vakitleri';
  static const String _hatirlatmaKanal = 'okuma_hatirlatma';

  static Future<void> baslat() async {
    tzdata.initializeTimeZones();
    const ayar = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _eklenti.initialize(ayar);
  }

  static Future<bool> izinIste() async {
    final android = _eklenti.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.requestNotificationsPermission()) ?? false;
  }

  /// Önceki bildirimleri temizler, 7 günlük yeni plan kurar.
  static Future<void> planla({
    required List<MapEntry<String, DateTime>> namazVakitleri,
    TimeOfDay? hatirlatma,
  }) async {
    await _eklenti.cancelAll();
    final simdi = DateTime.now();

    var id = 1000;
    for (final v in namazVakitleri) {
      if (v.value.isAfter(simdi)) {
        await _zamanla(id, 'Namaz vakti', '${v.key} vakti girdi', v.value,
            _namazKanal, 'Namaz vakitleri');
      }
      id++;
    }

    if (hatirlatma != null) {
      for (var g = 0; g < 7; g++) {
        final zaman = DateTime(simdi.year, simdi.month, simdi.day + g,
            hatirlatma.hour, hatirlatma.minute);
        if (zaman.isAfter(simdi)) {
          await _zamanla(
              5000 + g,
              'Hafızlık hatırlatması',
              'Bugünkü sayfanızı okumayı unutmayın',
              zaman,
              _hatirlatmaKanal,
              'Okuma hatırlatması');
        }
      }
    }
  }

  static Future<void> _zamanla(int id, String baslik, String govde,
      DateTime zaman, String kanal, String kanalAdi) async {
    await _eklenti.zonedSchedule(
      id,
      baslik,
      govde,
      tz.TZDateTime.from(zaman, tz.UTC),
      NotificationDetails(
        android: AndroidNotificationDetails(
          kanal,
          kanalAdi,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
