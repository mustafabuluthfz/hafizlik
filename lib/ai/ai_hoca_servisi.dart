import '../ders/karsilastirma.dart';

/// Tamamen cihaz üzerinde çalışan, internet/API gerektirmeyen hafızlık analizcisi.
/// Metin karşılaştırması ve çalışma önerileri üretir. Gerçek kıraat, mahreç,
/// hareke ve tecvid değerlendirmesi yaptığı iddia edilmez.
class AiHocaServisi {
  AiHocaServisi._();
  static final AiHocaServisi instance = AiHocaServisi._();

  Future<String> analizEt({
    required int sayfa,
    required String beklenenMetin,
    required String taninanMetin,
  }) async {
    final beklenen = beklenenMetin
        .split(RegExp(r'\s+')).where((e) => normalize(e).isNotEmpty).toList();
    final taninan = taninanMetin
        .split(RegExp(r'\s+')).where((e) => normalize(e).isNotEmpty).toList();

    if (beklenen.isEmpty) throw Exception('Karşılaştırılacak Mushaf metni bulunamadı.');
    if (taninan.isEmpty) throw Exception('Okuma metni bulunamadı. Önce Ders Dinlet bölümünde okuyun.');

    final durumlar = karsilastir(beklenen, taninanMetin, tamamlandi: true);
    final dogru = durumlar.where((e) => e.durum == KelimeDurumuTipi.dogru).length;
    final yanlis = durumlar.where((e) => e.durum == KelimeDurumuTipi.yanlis).length;
    final atlanan = durumlar.where((e) => e.durum == KelimeDurumuTipi.atlandi).length;
    final fazla = fazlaKelimeSayisi(beklenen, taninanMetin);
    final toplam = beklenen.length;
    final oran = ((dogru / toplam) * 100).round();

    final farklar = <String>[];
    for (var i = 0; i < durumlar.length; i++) {
      final d = durumlar[i];
      if (d.durum == KelimeDurumuTipi.yanlis) {
        farklar.add('• ${d.metin} — bu kelimenin yerine farklı bir ifade algılandı.');
      } else if (d.durum == KelimeDurumuTipi.atlandi) {
        farklar.add('• ${d.metin} — atlanmış olabilir.');
      }
      if (farklar.length >= 8) break;
    }

    final oneriler = <String>[];
    if (yanlis > 0 || atlanan > 0 || fazla > 0) {
      oneriler.add('Hata görülen bölümün bir önceki kelimesinden başlayarak kısa parçalar hâlinde tekrar edin.');
      oneriler.add('Her iki veya üç kelimelik parçayı doğru okuyana kadar tekrarlayın; sonra parçaları birleştirin.');
    } else {
      oneriler.add('Metin eşleşmesi iyi görünüyor. Aynı sayfayı biraz ara verdikten sonra yeniden ezberden okuyun.');
    }
    oneriler.add('Son kontrolde Mushaf üzerinden kendinizi veya öğretmeninizi kullanarak okuyuşu doğrulayın.');

    final b = StringBuffer()
      ..writeln('CİHAZ İÇİ HAFIZLIK HOCASI · SAYFA $sayfa')
      ..writeln('Çevrimdışı analiz tamamlandı. Hiçbir metin veya ses internet üzerinden gönderilmedi.')
      ..writeln()
      ..writeln('1) GENEL DEĞERLENDİRME')
      ..writeln('Metin eşleşmesi: %$oran')
      ..writeln('Doğru eşleşen kelime: $dogru / $toplam')
      ..writeln('Farklı algılanan kelime: $yanlis')
      ..writeln('Atlanmış olabilecek kelime: $atlanan')
      ..writeln('Fazladan algılanan kelime: $fazla')
      ..writeln()
      ..writeln('2) TESPİT EDİLEN METİN FARKLARI');
    if (farklar.isEmpty && fazla == 0) {
      b.writeln('Belirgin kelime farkı bulunmadı. Bu sonuç doğru telaffuz veya kıraat kanıtı değildir.');
    } else {
      for (final f in farklar) { b.writeln(f); }
      if (fazla > 0) b.writeln('• Mushaf metninde karşılığı bulunmayan $fazla fazla kelime algılandı.');
    }
    b
      ..writeln()
      ..writeln('3) TEKRAR ÇALIŞMASI');
    for (var i = 0; i < oneriler.length; i++) { b.writeln('${i + 1}. ${oneriler[i]}'); }
    b
      ..writeln()
      ..writeln('4) HAREKE, MAHREÇ VE TECVİD KONTROLÜ')
      ..writeln('Bu cihaz içi metin analizi sesin dalga biçimini veya harflerin gerçek çıkışını incelemiyor. Telefonun konuşma tanıma çıktısı hareke, mahreç ve tecvidi güvenilir biçimde göstermez. Bu nedenle bu alanlarda otomatik hata puanı vermedim. Öğretmen kontrolü gereklidir.')
      ..writeln()
      ..writeln('Not: Konuşma tanıma sistemi kelimeyi yanlış yazmış olabilir. Listelenen farklar kesin kıraat hatası değil, kontrol edilmesi gereken olasılıklardır.');
    return b.toString();
  }
}
