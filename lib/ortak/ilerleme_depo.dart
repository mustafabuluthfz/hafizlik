import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/hafizlik_sira.dart';
import 'ikonlar.dart';

/// Okunan günlerin kaydı, seri hesabı ve rozet koşulları.
class IlerlemeDepo {
  static const String _gunlerAnahtari = 'tamamlanan_gunler';
  static const String _bulmacaEnIyiAnahtari = 'bulmaca_en_iyi_seri';
  static const String _bulmacaDogruAnahtari = 'bulmaca_dogru_toplam';
  static const String _kuranAcildiAnahtari = 'kuran_acildi';

  static String gunAnahtari(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  /// Okunmuş günlerin kümesi (yyyy-MM-dd).
  static Future<Set<String>> gunler() async {
    final prefs = await SharedPreferences.getInstance();
    final kayit = prefs.getString(_gunlerAnahtari);
    if (kayit == null) return {};
    return (jsonDecode(kayit) as List).cast<String>().toSet();
  }

  static Future<void> gunuIsaretle(DateTime t, bool okundu) async {
    final gunler = await IlerlemeDepo.gunler();
    final k = gunAnahtari(t);
    if (okundu) {
      gunler.add(k);
    } else {
      gunler.remove(k);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gunlerAnahtari, jsonEncode(gunler.toList()..sort()));
  }

  /// Başlangıç gününden [gun] gününe düşen sayfa.
  static int sayfaGununde(DateTime baslangic, DateTime gun) =>
      HafizlikSiraYardimci.sayfa(baslangic, gun);

  /// Bugün okunmamışsa seri dünden geriye sayılır.
  static int seri(Set<String> gunler, DateTime bugun) {
    var gun = DateTime(bugun.year, bugun.month, bugun.day);
    if (!gunler.contains(gunAnahtari(gun))) {
      gun = DateTime(gun.year, gun.month, gun.day - 1);
    }
    var sayac = 0;
    while (gunler.contains(gunAnahtari(gun))) {
      sayac++;
      gun = DateTime(gun.year, gun.month, gun.day - 1);
    }
    return sayac;
  }

  /// Bulmacada bir cevap verildiğinde en iyi seri ve toplam doğru sayısını günceller.
  static Future<void> bulmacaCevap({required bool dogru, required int seri}) async {
    final prefs = await SharedPreferences.getInstance();
    if (dogru) {
      await prefs.setInt(_bulmacaDogruAnahtari, (prefs.getInt(_bulmacaDogruAnahtari) ?? 0) + 1);
    }
    final enIyi = prefs.getInt(_bulmacaEnIyiAnahtari) ?? 0;
    if (seri > enIyi) await prefs.setInt(_bulmacaEnIyiAnahtari, seri);
  }

  static Future<void> kuranAcildi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kuranAcildiAnahtari, true);
  }

  /// Rozetler: her biri bir koşula bağlı. Sıra, ekranda gösterilme sırasıdır.
  static Future<List<Rozet>> rozetler({DateTime? bugun}) async {
    final gunler = await IlerlemeDepo.gunler();
    final prefs = await SharedPreferences.getInstance();
    final seri = IlerlemeDepo.seri(gunler, bugun ?? DateTime.now());
    final toplam = gunler.length;
    final bEnIyi = prefs.getInt(_bulmacaEnIyiAnahtari) ?? 0;
    final bDogru = prefs.getInt(_bulmacaDogruAnahtari) ?? 0;
    final kuran = prefs.getBool(_kuranAcildiAnahtari) ?? false;

    return [
      Rozet('İlk adım', 'İlk sayfanı okudun', Icons.flag_rounded, toplam >= 1),
      Rozet('Üç gün', '3 gün üst üste okudun', Icons.looks_3_rounded, seri >= 3),
      Rozet('Haftalık istikrar', '7 gün üst üste okudun',
          AppIkonlari.seri, seri >= 7),
      Rozet('İki hafta', '14 gün üst üste okudun', Icons.whatshot_rounded, seri >= 14),
      Rozet('Bir tur', '30 günlük turu tamamladın',
          Icons.workspace_premium_rounded, toplam >= 30),
      Rozet('Ayın sonu', '30 gün üst üste okudun', AppIkonlari.hatim,
          seri >= 30),
      Rozet('Altmış gün', '60 gün okudun', Icons.military_tech_rounded, toplam >= 60),
      Rozet('Yüz gün', '100 gün okudun', Icons.emoji_events_rounded, toplam >= 100),
      Rozet('Bulmaca ustası', 'Bulmacada 10 doğru üst üste',
          Icons.psychology_rounded, bEnIyi >= 10),
      Rozet('Keskin zihin', 'Bulmacada 100 doğru cevap',
          Icons.bolt_rounded, bDogru >= 100),
      Rozet('Mushaf gezgini', 'Kur\'an okuma bölümünü açtın',
          AppIkonlari.sayfa, kuran),
    ];
  }
}

class Rozet {
  final String ad;
  final String aciklama;
  final IconData ikon;
  final bool kazanildi;

  const Rozet(this.ad, this.aciklama, this.ikon, this.kazanildi);
}

class HafizlikSiraYardimci {
  static int sayfa(DateTime b, DateTime g) => HafizlikSira.pageForDay(b, g);
}

/// Kur'an okuma: son kalınan sayfa ve yer imleri.
class OkumaKaydi {
  static const String _sonSayfa = 'son_sayfa';
  static const String _yerImleri = 'yer_imleri';

  static Future<int?> sonSayfa() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sonSayfa);
  }

  static Future<void> sonSayfaKaydet(int sayfa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sonSayfa, sayfa);
  }

  static Future<List<int>> yerImleri() async {
    final prefs = await SharedPreferences.getInstance();
    final kayit = prefs.getString(_yerImleri);
    if (kayit == null) return [];
    return (jsonDecode(kayit) as List).cast<int>();
  }

  /// Yer imi varsa kaldırır, yoksa ekler. Yeni durumu döndürür (true = eklendi).
  static Future<bool> yerImiDegistir(int sayfa) async {
    final liste = await yerImleri();
    final eklendi = !liste.contains(sayfa);
    if (eklendi) {
      liste.add(sayfa);
    } else {
      liste.remove(sayfa);
    }
    liste.sort();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_yerImleri, jsonEncode(liste));
    return eklendi;
  }
}
