import 'package:just_audio/just_audio.dart';

import '../hafizlik/quran_veri.dart';
import 'indirme_yoneticisi.dart';
import 'okuyucu.dart';

/// Bir sayfadaki ayetleri sırayla çalar.
class SayfaOynatici {
  final AudioPlayer _oynatici = AudioPlayer();

  /// Şu an çalan ayetin sayfa içi sırası (0'dan başlar).
  Stream<int?> get siraIndeksi => _oynatici.currentIndexStream;

  Stream<PlayerState> get durum => _oynatici.playerStateStream;

  bool get calisiyor => _oynatici.playing;

  Future<void> cal(List<Ayet> ayetler, Okuyucu okuyucu, {int baslangic = 0}) async {
    final kaynaklar = <AudioSource>[];
    for (final a in ayetler) {
      // İndirilmişse cihazdaki dosya, değilse internet adresi kullanılır.
      final yerel = await IndirmeYoneticisi.yerelYol(okuyucu, a.sure, a.numara);
      kaynaklar.add(yerel != null
          ? AudioSource.file(yerel)
          : AudioSource.uri(Uri.parse(ayetSesAdresi(okuyucu, a.sure, a.numara))));
    }
    final liste = ConcatenatingAudioSource(children: kaynaklar);
    await _oynatici.setAudioSource(liste, initialIndex: baslangic);
    await _oynatici.play();
  }

  Future<void> oynatDurdur() => _oynatici.playing ? _oynatici.pause() : _oynatici.play();

  /// Sayfadaki ayetleri bitince baştan alarak tekrar çalar.
  Future<void> tekrarModu(bool acik) =>
      _oynatici.setLoopMode(acik ? LoopMode.all : LoopMode.off);

  Future<void> hizAyarlama(double hiz) => _oynatici.setSpeed(hiz);

  Future<void> sonraki() => _oynatici.seekToNext();

  Future<void> onceki() => _oynatici.seekToPrevious();

  Future<void> durdur() => _oynatici.stop();

  Future<void> kapat() => _oynatici.dispose();
}
