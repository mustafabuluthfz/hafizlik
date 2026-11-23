import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../bulmaca/sureler.dart';
import 'okuyucu.dart';

/// İndirme iptal edildiğinde fırlatılır.
class IptalEdildi implements Exception {
  const IptalEdildi();
}

/// Ayet ses dosyalarını cihaza indirir, yerel yolları verir ve silme işlerini yapar.
/// Dosyalar ses/<klasör>/<sure>/<ayet>.mp3 biçiminde saklanır.
class IndirmeYoneticisi {
  static const int _enAzBoyut = 1024; // bundan küçük yanıtlar hatalı kabul edilir

  static Future<Directory> _kok() async {
    final belge = await getApplicationDocumentsDirectory();
    final kok = Directory('${belge.path}/ses');
    if (!await kok.exists()) await kok.create(recursive: true);
    return kok;
  }

  static Future<Directory> _sureKlasoru(Okuyucu okuyucu, int sure) async {
    final kok = await _kok();
    final klasor = Directory(
        '${kok.path}/${okuyucu.klasor}/${sure.toString().padLeft(3, '0')}');
    if (!await klasor.exists()) await klasor.create(recursive: true);
    return klasor;
  }

  static String _dosyaAdi(int ayet) => '${ayet.toString().padLeft(3, '0')}.mp3';

  /// Ayetin yerel dosyası varsa yolunu, yoksa null döndürür.
  static Future<String?> yerelYol(Okuyucu okuyucu, int sure, int ayet) async {
    final klasor = await _sureKlasoru(okuyucu, sure);
    final dosya = File('${klasor.path}/${_dosyaAdi(ayet)}');
    if (await dosya.exists() && await dosya.length() > _enAzBoyut) {
      return dosya.path;
    }
    return null;
  }

  /// Surenin tüm ayetleri eksiksiz indirilmiş mi?
  static Future<bool> sureIndirildiMi(Okuyucu okuyucu, int sure) async {
    final ayetSayisi = sureler[sure - 1].ayetSayisi;
    for (var a = 1; a <= ayetSayisi; a++) {
      if (await yerelYol(okuyucu, sure, a) == null) return false;
    }
    return true;
  }

  /// Bir sureyi ayet ayet indirir. Her ayet 3 kez denenir, yanıt doğrulanır.
  static Future<void> sureIndir(
    Okuyucu okuyucu,
    int sure, {
    required void Function(double oran) ilerleme,
    required bool Function() iptalMi,
  }) async {
    if (!okuyucu.indirmeIzniVar) {
      throw StateError('Bu okuyucu için indirme izni tanımlı değil.');
    }
    final ayetSayisi = sureler[sure - 1].ayetSayisi;
    final klasor = await _sureKlasoru(okuyucu, sure);
    final istemci = http.Client();
    try {
      for (var a = 1; a <= ayetSayisi; a++) {
        if (iptalMi()) throw const IptalEdildi();
        final hedef = File('${klasor.path}/${_dosyaAdi(a)}');
        if (await hedef.exists() && await hedef.length() > _enAzBoyut) {
          ilerleme(a / ayetSayisi);
          continue;
        }
        final adres = Uri.parse(ayetSesAdresi(okuyucu, sure, a));
        var basarili = false;
        for (var deneme = 1; deneme <= 3 && !basarili; deneme++) {
          try {
            final yanit = await istemci.get(adres).timeout(const Duration(seconds: 30));
            if (yanit.statusCode == 200 && yanit.bodyBytes.length > _enAzBoyut) {
              final gecici = File('${hedef.path}.part');
              await gecici.writeAsBytes(yanit.bodyBytes, flush: true);
              await gecici.rename(hedef.path);
              basarili = true;
            }
          } catch (_) {
            await Future<void>.delayed(Duration(seconds: deneme));
          }
        }
        if (!basarili) {
          throw Exception('Sure $sure, ayet $a indirilemedi. Bağlantıyı kontrol edin.');
        }
        ilerleme(a / ayetSayisi);
      }
    } finally {
      istemci.close();
    }
  }

  static Future<void> sureSil(Okuyucu okuyucu, int sure) async {
    final klasor = await _sureKlasoru(okuyucu, sure);
    if (await klasor.exists()) await klasor.delete(recursive: true);
  }

  /// Tüm indirilenlerin toplam boyutu (bayt).
  static Future<int> toplamBoyut() async {
    final kok = await _kok();
    var toplam = 0;
    await for (final varlik in kok.list(recursive: true)) {
      if (varlik is File) toplam += await varlik.length();
    }
    return toplam;
  }
}
