import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/hafizlik/tecvid_ekrani.dart';
import 'package:hafizlik_app/ses/okuyucu.dart';

void main() {
  group('Tecvid ve okuyucu kataloğu', () {
    test('önceki okuyucu tercihlerinin ilk dört sırası korunur', () {
      expect(okuyucular.length, greaterThanOrEqualTo(30));
      expect(okuyucular[0].klasor, 'Alafasy_128kbps');
      expect(okuyucular[1].klasor, 'Husary_128kbps');
      expect(okuyucular[2].klasor, 'Abdul_Basit_Murattal_192kbps');
      expect(okuyucular.any((o) => o.klasor.contains('Ishaq')), isFalse);
    });

    test('ayet adresi seçilen okuyucuya göre oluşturulur', () {
      expect(
        ayetSesAdresi(okuyucular.first, 2, 255),
        'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
      );
    });

    testWidgets('tecvid ekranı konu sayısını ve aramayı sunar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TecvidEkrani()));
      expect(find.text('Tecvid Öğren'), findsOneWidget);
      expect(find.textContaining('konu başlığı'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'İklâb');
      await tester.pump();
      expect(find.text('Tecvid kuralı ara...'), findsNothing);
    });
  });
}
