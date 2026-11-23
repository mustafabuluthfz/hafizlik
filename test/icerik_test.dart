import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/hafizlik/cezeri_meal.dart';
import 'package:hafizlik_app/hafizlik/cezeri_mukaddime.dart';
import 'package:hafizlik_app/hafizlik/tecvid_ilkeleri_ekrani.dart';
import 'package:hafizlik_app/dualar/ek_dualar.dart';

void main() {
  test('her beyitin meali var ve sayılar eşleşir', () {
    expect(cezeriMealler.length, cezeriBablar.length);
    for (var i = 0; i < cezeriBablar.length; i++) {
      expect(cezeriMealler[i].length, cezeriBablar[i].beyitler.length);
    }
  });

  test('tecvid ilkeleri ve ek dualar boş değil', () {
    expect(tecvidIlkeleri, isNotEmpty);
    expect(ekDualar, isNotEmpty);
    for (final d in ekDualar) {
      expect(d.arapca.trim(), isNotEmpty);
      expect(d.turkce.trim(), isNotEmpty);
    }
  });
}
