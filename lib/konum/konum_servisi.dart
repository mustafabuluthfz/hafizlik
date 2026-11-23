import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KonumBilgisi {
  final double enlem;
  final double boylam;

  const KonumBilgisi(this.enlem, this.boylam);
}

/// Konumu alır; izin yoksa ya da alınamazsa son kaydedilen konumu döndürür.
class KonumServisi {
  static Future<KonumBilgisi?> al() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return _kayitli(prefs);

      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        return _kayitli(prefs);
      }

      final konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 12),
      );
      await prefs.setDouble('konum_enlem', konum.latitude);
      await prefs.setDouble('konum_boylam', konum.longitude);
      return KonumBilgisi(konum.latitude, konum.longitude);
    } catch (_) {
      return _kayitli(prefs);
    }
  }

  static KonumBilgisi? _kayitli(SharedPreferences prefs) {
    final e = prefs.getDouble('konum_enlem');
    final b = prefs.getDouble('konum_boylam');
    if (e == null || b == null) return null;
    return KonumBilgisi(e, b);
  }
}
