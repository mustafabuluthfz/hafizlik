/// Ücretsiz çevrimiçi ayet okuyucuları.
/// Sesler EveryAyah veri sunucusundan akış olarak alınır. Uygulama ses kayıtlarını
/// kendi sunucusunda barındırmaz. İnternet bağlantısı gerekir.
class Okuyucu {
  final String ad;
  final String klasor;

  /// Ses dosyasını uygulama içinde çevrimdışı saklama izni ayrıca doğrulanmalıdır.
  /// Kullanıcının isteğiyle indirme varsayılan olarak açıktır. Yayın öncesi
  /// EveryAyah kullanım koşullarının doğrulanması gerekir.
  final bool indirmeIzniVar;

  const Okuyucu(this.ad, this.klasor, {this.indirmeIzniVar = true});
}

/// EveryAyah ayet dosyası klasörleri. Ücretsiz dinleme/akış içindir;
/// dosyaların yeniden dağıtım veya çevrimdışı paketleme izni anlamına gelmez.
const List<Okuyucu> okuyucular = [
  // İlk dört sırayı eski sürümlerle uyum için koru; kayıtlı okuyucu tercihi değişmesin.
  Okuyucu('Mişârî Râşid el-Âfâsî', 'Alafasy_128kbps'),
  Okuyucu('Mahmûd Halîl el-Husarî (Murattal)', 'Husary_128kbps'),
  Okuyucu('Abdülbâsıt Abdüssamed (Murattal)', 'Abdul_Basit_Murattal_192kbps'),
  Okuyucu('Mahmûd Halîl el-Husarî (Mücavved)', 'Husary_128kbps_Mujawwad'),
  Okuyucu('Mahmûd Halîl el-Husarî (Muallim)', 'Husary_Muallim_128kbps'),
  Okuyucu('Muhammed Sıddîk el-Minşâvî (Murattal)', 'Minshawy_Murattal_128kbps'),
  Okuyucu('Muhammed Sıddîk el-Minşâvî (Mücavved)', 'Minshawy_Mujawwad_192kbps'),
  Okuyucu('Abdurrahman es-Südeys', 'Abdurrahmaan_As-Sudais_64kbps'),
  Okuyucu('Suud eş-Şureym', 'Saood_ash-Shuraym_128kbps'),
  Okuyucu('Sa‘d el-Ğâmidî', 'Ghamadi_40kbps'),
  Okuyucu('Mâhir el-Muaykılî', 'Maher_AlMuaiqly_64kbps'),
  Okuyucu('Hânî er-Rifâî', 'Hani_Rifai_192kbps'),
  Okuyucu('Yâsir ed-Devserî', 'Yasser_Ad-Dussary_128kbps'),
  Okuyucu('Ebû Bekir eş-Şâtırî', 'Abu_Bakr_Ash-Shaatree_128kbps'),
  Okuyucu('Nâsır el-Katâmî', 'Nasser_Alqatami_128kbps'),
  Okuyucu('Ali el-Huzeyfî', 'Hudhaify_128kbps'),
  Okuyucu('İbrahim el-Ahdar', 'Ibrahim_Akhdar_32kbps'),
  Okuyucu('Muhammed Eyyûb', 'Muhammad_Ayyoub_128kbps'),
  Okuyucu('Muhammed Cibrîl', 'Muhammad_Jibreel_128kbps'),
  Okuyucu('Muhammed et-Tablâvî', 'Mohammad_al_Tablaway_128kbps'),
  Okuyucu('Salâh Abdürrahman Buhâtır', 'Salaah_AbdulRahman_Bukhatir_128kbps'),
  Okuyucu('Abdullah Avad el-Cühenî', 'Abdullaah_3awwaad_Al-Juhaynee_128kbps'),
  Okuyucu('Salâh el-Budeyr', 'Salah_Al_Budair_128kbps'),
  Okuyucu('Abdullah Matrûd', 'Abdullah_Matroud_128kbps'),
  Okuyucu('Ahmed en-Neînâ', 'Ahmed_Neana_128kbps'),
  Okuyucu('Ali Câbir', 'Ali_Jaber_64kbps'),
  Okuyucu('Fâris Abbâd', 'Fares_Abbad_64kbps'),
  Okuyucu('Parhizgâr', 'Parhizgar_48kbps'),
  Okuyucu('Sehl Yâsîn', 'Sahl_Yassin_128kbps'),
  Okuyucu('Mahmûd Ali el-Bennâ', 'mahmoud_ali_al_banna_32kbps'),
  Okuyucu('Akram el-Alakîmî', 'Akram_AlAlaqimy_128kbps'),
  Okuyucu('Abdullah Basfar', 'Abdullah_Basfar_64kbps'),
  Okuyucu('Ali Haccâc es-Süveysî', 'Ali_Hajjaj_AlSuesy_128kbps'),
  Okuyucu('Ayman Süveyd', 'Ayman_Sowaid_64kbps'),
  Okuyucu('Ahmed el-Acemî', 'ahmed_ibn_ali_al_ajamy_128kbps'),
  Okuyucu('Hâlid el-Kahtânî', 'Khaalid_Abdullaah_al-Qahtaanee_192kbps'),
];

/// Bir ayetin ses dosyası adresi: klasör/SSSAAA.mp3.
String ayetSesAdresi(Okuyucu okuyucu, int sure, int ayet) {
  final s = sure.toString().padLeft(3, '0');
  final a = ayet.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/${okuyucu.klasor}/$s$a.mp3';
}
