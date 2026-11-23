import 'dart:math' as math;

/// Namaz vakitleri ve kıble yönü. İnternet gerektirmez.
/// Yöntem: Diyanet İşleri Başkanlığı'na yakın (İmsak -18°, Yatsı -17°, İkindi Hanefi).
class VakitHesap {
  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;

  static double _norm360(double v) {
    var x = v % 360;
    if (x < 0) x += 360;
    return x;
  }

  /// Gregoryen takvimden Julian günü (0 UT).
  static double _julianGun(DateTime d) {
    var y = d.year;
    var m = d.month;
    final gun = d.day.toDouble();
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + a ~/ 4;
    return (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        gun +
        b -
        1524.5;
  }

  /// Güneş [yukseklik] derece iken saat açısı (saat cinsinden). Olay yoksa null.
  static double? _saatAcisi(double enlem, double sapma, double yukseklik) {
    final cosH = (math.sin(_rad(yukseklik)) -
            math.sin(_rad(enlem)) * math.sin(sapma)) /
        (math.cos(_rad(enlem)) * math.cos(sapma));
    if (cosH < -1 || cosH > 1) return null;
    return _deg(math.acos(cosH)) / 15.0;
  }

  /// Bir günün vakitleri. [saatDilimi]: UTC'ye göre saat farkı (ör. Türkiye 3).
  static Map<String, DateTime> gunVakitleri(
    DateTime gun,
    double enlem,
    double boylam,
    double saatDilimi,
  ) {
    final jd = _julianGun(gun) + 0.5;
    final n = jd - 2451545.0;

    final l = _norm360(280.460 + 0.9856474 * n);
    final g = _rad(_norm360(357.528 + 0.9856003 * n));
    final lambda = _rad(l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g));
    final eps = _rad(23.439 - 0.0000004 * n);
    final sapma = math.asin(math.sin(eps) * math.sin(lambda));
    final ra = _deg(math.atan2(math.cos(eps) * math.sin(lambda), math.cos(lambda)));

    var e = l - ra;
    if (e > 180) e -= 360;
    if (e < -180) e += 360;
    final denklemDakika = 4 * e;

    // Öğle (yerel saat, saat cinsinden)
    final ogle = 12 + saatDilimi - boylam / 15 - denklemDakika / 60;

    // İkindi (Hanefi: gölge oranı 2)
    final fark = (_rad(enlem) - sapma).abs();
    final ikindiYuksekligi = _deg(math.atan(1 / (2 + math.tan(fark))));

    final imsakAcisi = _saatAcisi(enlem, sapma, -18);
    final gunesAcisi = _saatAcisi(enlem, sapma, -0.833);
    final ikindiAcisi = _saatAcisi(enlem, sapma, ikindiYuksekligi);
    final yatsiAcisi = _saatAcisi(enlem, sapma, -17);
    if (imsakAcisi == null ||
        gunesAcisi == null ||
        ikindiAcisi == null ||
        yatsiAcisi == null) {
      return {};
    }

    DateTime zaman(double saat) => DateTime(gun.year, gun.month, gun.day)
        .add(Duration(seconds: (saat * 3600).round()));

    return {
      'İmsak': zaman(ogle - imsakAcisi),
      'Güneş': zaman(ogle - gunesAcisi),
      'Öğle': zaman(ogle),
      'İkindi': zaman(ogle + ikindiAcisi),
      'Akşam': zaman(ogle + gunesAcisi),
      'Yatsı': zaman(ogle + yatsiAcisi),
    };
  }

  /// Verilen konumdan kâbe'ye (21.4225°K, 39.8262°D) kuzeyden saat yönünde açı.
  static double kibleAcisi(double enlem, double boylam) {
    final lat1 = _rad(enlem);
    final lat2 = _rad(21.4225);
    final dLon = _rad(39.8262 - boylam);
    final y = math.sin(dLon);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLon);
    return _norm360(_deg(math.atan2(y, x)));
  }
}
