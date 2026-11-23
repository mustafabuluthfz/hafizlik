import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bildirim/bildirim_servisi.dart';
import 'karsilama/karsilama_ekrani.dart';
import 'kible/kible_ekrani.dart';
import 'namaz/namaz_ekrani.dart';

import 'acilis/acilis_ekrani.dart';
import 'dualar/dualar_ekrani.dart';
import 'notlar/notlar_ekrani.dart';
import 'ses/ses_kutuphanesi_ekrani.dart';
import 'sureler/sure_listesi_ekrani.dart';
import 'ayarlar/ayarlar_ekrani.dart';
import 'esma/esmaul_husna_ekrani.dart';
import 'hatim/hatim_ekrani.dart';
import 'zikir/zikirmatik_ekrani.dart';
import 'bulmaca/bulmaca_ekrani.dart';
import 'ders/ders_ekrani.dart';
import 'hafizlik/bugunku_sayfa.dart';
import 'hafizlik/calisma_programi_ekrani.dart';
import 'hafizlik/egitim_araclari_ekrani.dart';
import 'hafizlik/ezber_atolyesi_ekrani.dart';
import 'hafizlik/hafizlik_sayfa_ekrani.dart';
import 'hafizlik/hafizlik_sira.dart';
import 'hafizlik/quran_veri.dart';
import 'ilerleme/ilerleme_ekrani.dart';
import 'kuran/kuran_okuma_ekrani.dart';
import 'kuran/sesli_ayet_bul_ekrani.dart';
import 'hafizlik/kisa_sureler_ekrani.dart';
import 'hafizlik/tecvid_ekrani.dart';
import 'hafizlik/hifzimi_test_et_ekrani.dart';
import 'hafizlik/hoca_dinletisi_ekrani.dart';
import 'ortak/ilerleme_depo.dart';
import 'ortak/islimi_desen.dart';
import 'ortak/mushaf.dart';
import 'namaz/vakit_hesap.dart';
import 'ortak/bilesenler.dart';
import 'ortak/hadisler.dart';
import 'ortak/tema.dart';
import 'ortak/uygulama.dart';
import 'ortak/ikonlar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final kayitliTema = prefs.getInt('tema') ?? 0;
  kMushafKagitRengi.value = Color(prefs.getInt('mushaf_kagit') ?? 0xFFFBF6E9);
  kMushafYaziBoyutu.value = prefs.getDouble('mushaf_yazi_boyutu') ?? 26;
  kTemaModu.value = ThemeMode.values[(kayitliTema < 0 || kayitliTema > 2) ? 0 : kayitliTema];
  await BildirimServisi.baslat();
  final karsilamaTamam = await KarsilamaEkrani.tamamlandiMi();
  runApp(HafizlikApp(ilkAcilis: !karsilamaTamam));
}

class HafizlikApp extends StatelessWidget {
  final bool ilkAcilis;

  const HafizlikApp({super.key, this.ilkAcilis = false});

  bool get _ilkAcilis => ilkAcilis;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: kTemaModu,
      builder: (context, mod, _) => MaterialApp(
        title: 'Hafızlık',
        debugShowCheckedModeBanner: false,
        theme: kTemaAcik(),
        darkTheme: kTemaKoyu(),
        themeMode: mod,
        home: AcilisEkrani(sonraki: _ilkAcilis ? const KarsilamaEkrani(sonraki: AnaIskelet()) : const AnaIskelet()),
      ),
    );
  }
}

/// Bölümler mantıksal sekmelere ayrılmıştır.
final List<_Bolum> _hizliErisim = [
  _Bolum('Hafızlık Yap', 'Günün sayfası', AppIkonlari.sayfa,
      const Color(0xFF2E7D32), (c) => const HafizlikSayfaEkrani()),
  _Bolum("Kur'an Oku", 'Cüz, sure, sayfa', AppIkonlari.kuran,
      const Color(0xFF00695C), (c) => const KuranOkumaEkrani()),
  _Bolum('Namaz Vakitleri', 'Konumunuza göre', AppIkonlari.namaz,
      const Color(0xFFAD1457), (c) => const NamazEkrani()),
  _Bolum('Zikirmatik', 'Tesbih sayacı', AppIkonlari.zikir,
      const Color(0xFF6A1B9A), (c) => const ZikirmatikEkrani()),
];

final List<_Bolum> _kuranSekmesi = [
  _Bolum("Kur'an Oku", 'Cüz, sure, sayfa', AppIkonlari.kuran,
      const Color(0xFF00695C), (c) => const KuranOkumaEkrani()),
  _Bolum('Sesli Ayet Bul', 'Okuyarak ayeti bul', Icons.manage_search_rounded,
      const Color(0xFF00838F), (c) => const SesliAyetBulEkrani()),
  _Bolum('Sureler', '114 sure', AppIkonlari.sureler,
      const Color(0xFF5D4037), (c) => const SureListesiEkrani()),
  _Bolum('Dualar', 'Kur\'an\'dan dualar', AppIkonlari.dualar,
      const Color(0xFF1565C0), (c) => const DualarEkrani()),
  _Bolum('Esmaül Hüsna', '99 isim ve anlamı', AppIkonlari.esma,
      const Color(0xFF00838F), (c) => const EsmaulHusnaEkrani()),
  _Bolum('Notlarım', 'Sayfa notları', AppIkonlari.notlar,
      const Color(0xFF827717), (c) => const NotlarEkrani()),
  _Bolum('Ses kütüphanesi', 'İndir, dinle, yönet', Icons.download_for_offline_rounded,
      const Color(0xFF00897B), (c) => const SesKutuphanesiEkrani()),
];

final List<_Bolum> _hafizSekmesi = [
  _Bolum('Hafızlık Yap', 'Günün sayfası', AppIkonlari.sayfa,
      const Color(0xFF2E7D32), (c) => const HafizlikSayfaEkrani()),
  _Bolum('Bulmaca', 'Ayet soruları', AppIkonlari.bulmaca,
      const Color(0xFF3949AB), (c) => const BulmacaEkrani()),
  _Bolum('Ders Dinlet', 'Ezberini takip et', AppIkonlari.ders,
      const Color(0xFFB8860B), (c) => const DersEkrani()),
  _Bolum('Hoca Dinletisi', 'Ayetleri seçtiğin sayıda tekrar et', Icons.repeat_rounded,
      const Color(0xFF00897B), (c) => const HocaDinletisiEkrani()),
  _Bolum('Kısa Sureler', 'Namaz surelerini öğren', Icons.menu_book_rounded,
      const Color(0xFF5D4037), (c) => const KisaSurelerEkrani()),
  _Bolum('Tecvid Öğren', 'Kuralları örnekleriyle öğren', Icons.school_rounded,
      const Color(0xFF00695C), (c) => const TecvidEkrani()),
  _Bolum('Hıfzımı Test Et', 'Ayet devamı ve ezber sınavı', Icons.quiz_rounded,
      const Color(0xFF3949AB), (c) => const HifzimiTestEtEkrani()),
  _Bolum('Ezber Atölyesi', 'Gizle, tekrar et, kendini sına', Icons.auto_stories_rounded,
      const Color(0xFF7B1FA2), (c) => const EzberAtolyesiEkrani()),
  _Bolum('Hatim Planı', 'Günlük sayfa planı', AppIkonlari.hatim,
      const Color(0xFFEF6C00), (c) => const HatimEkrani()),
  _Bolum('İlerlemem', 'Seri, rozet, harita', AppIkonlari.ilerleme,
      const Color(0xFF00897B), (c) => const IlerlemeEkrani()),
  _Bolum('Ezber Programı', 'Hedefler ve öğrenci takibi', Icons.school_rounded,
      const Color(0xFF455A64), (c) => const CalismaProgramiEkrani()),
  _Bolum('Sınav ve Raporlar', 'Başarı ölçümü ve yedekleme', Icons.assessment_rounded,
      const Color(0xFF00695C), (c) => const EgitimAraclariEkrani()),
];

final List<_Bolum> _araclarSekmesi = [
  _Bolum('Namaz Vakitleri', 'Konumunuza göre', AppIkonlari.namaz,
      const Color(0xFFAD1457), (c) => const NamazEkrani()),
  _Bolum('Kıble', 'Kıble yönünü bulun', AppIkonlari.kible,
      const Color(0xFF37474F), (c) => const KibleEkrani()),
  _Bolum('Zikirmatik', 'Tesbih sayacı', AppIkonlari.zikir,
      const Color(0xFF6A1B9A), (c) => const ZikirmatikEkrani()),
  _Bolum('Ayarlar', 'Görünüm ve veriler', AppIkonlari.ayarlar,
      const Color(0xFF546E7A), (c) => const AyarlarEkrani()),
];

/// Alt gezinme çubuğu ile dört ana sekme.
class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _sekme = 0;

  Future<void> _cikisOnayi(BuildContext context) async {
    final cik = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Uygulamadan çıkılsın mı?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Çık')),
        ],
      ),
    );
    if (cik == true) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_sekme != 0) {
          setState(() => _sekme = 0);
          return;
        }
        _cikisOnayi(context);
      },
      child: _govde(context),
    );
  }

  Widget _govde(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _sekme,
        children: [
          const AnaEkran(),
          SekmeSayfasi(baslik: "Kur'an", bolumler: _kuranSekmesi),
          SekmeSayfasi(baslik: 'Hafızlık', bolumler: _hafizSekmesi),
          SekmeSayfasi(baslik: 'Araçlar', bolumler: _araclarSekmesi),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sekme,
        onDestinationSelected: (i) => setState(() => _sekme = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(AppIkonlari.ana),
              selectedIcon: Icon(AppIkonlari.ana),
              label: 'Ana'),
          NavigationDestination(
              icon: Icon(AppIkonlari.kuranOutline),
              selectedIcon: Icon(AppIkonlari.kuran),
              label: "Kur'an"),
          NavigationDestination(
              icon: Icon(AppIkonlari.hafizlikOutline),
              selectedIcon: Icon(AppIkonlari.hafizlik),
              label: 'Hafızlık'),
          NavigationDestination(
              icon: Icon(AppIkonlari.araclarOutline),
              selectedIcon: Icon(AppIkonlari.araclar),
              label: 'Araçlar'),
        ],
      ),
    );
  }
}

/// Bir sekmenin içeriği: başlık ve iki sütunlu kart ızgarası.
class SekmeSayfasi extends StatelessWidget {
  final String baslik;
  final List<_Bolum> bolumler;

  const SekmeSayfasi({super.key, required this.baslik, required this.bolumler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: GridView.count(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
        children: [
          for (final b in bolumler)
            _KartTile(
              bolum: b,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: b.hedef)),
            ),
        ],
      ),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _seri = 0;
  int _bugunSayfa = 0;
  int _okunanGun = 0;
  bool _bugunOkundu = false;
  late Future<Ayet?> _gununAyeti;
  late Future<(String, DateTime)?> _sonrakiVakit;

  @override
  void initState() {
    super.initState();
    _gununAyeti = _gunAyetiGetir();
    _sonrakiVakit = _sonrakiVakitGetir();
    _seriYukle();
  }

  Future<void> _seriYukle() async {
    final gunler = await IlerlemeDepo.gunler();
    final bugun = DateTime.now();
    final sayfa = await bugunkuSayfaNo();
    if (!mounted) return;
    setState(() {
      _seri = IlerlemeDepo.seri(gunler, bugun);
      _bugunSayfa = sayfa;
      _okunanGun = gunler.length;
      _bugunOkundu = gunler.contains(IlerlemeDepo.gunAnahtari(bugun));
    });
  }

  Future<Ayet?> _gunAyetiGetir() async {
    final sayfa = await bugunkuSayfaNo();
    final ayetler = await QuranVeri.sayfa(sayfa);
    return ayetler.isEmpty ? null : ayetler.first;
  }

  /// Kayıtlı konumdan bir sonraki namaz vaktini hesaplar (konum izni istemez).
  Future<(String, DateTime)?> _sonrakiVakitGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final enlem = prefs.getDouble('konum_enlem');
    final boylam = prefs.getDouble('konum_boylam');
    if (enlem == null || boylam == null) return null;
    final simdi = DateTime.now();
    final saatDilimi = simdi.timeZoneOffset.inMinutes / 60.0;
    final bugun = VakitHesap.gunVakitleri(simdi, enlem, boylam, saatDilimi);
    for (final e in bugun.entries) {
      if (e.value.isAfter(simdi)) return (e.key, e.value);
    }
    final yarin = VakitHesap.gunVakitleri(
        simdi.add(const Duration(days: 1)), enlem, boylam, saatDilimi);
    if (yarin.isEmpty) return null;
    final ilk = yarin.entries.first;
    return (ilk.key, ilk.value);
  }

  /// Bölüme git, dönünce özeti tazele.
  Future<void> _ac(WidgetBuilder hedef) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: hedef));
    _seriYukle();
    _sonrakiVakit = _sonrakiVakitGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SelamBasligi(seri: _seri),
            const SizedBox(height: kBosluk16),
            _BugunKarti(
              sayfa: _bugunSayfa,
              okundu: _bugunOkundu,
              onOkut: () => _ac((_) => const HafizlikSayfaEkrani()),
            ),
            const SizedBox(height: kBosluk12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<(String, DateTime)?>(
                      future: _sonrakiVakit,
                      builder: (context, snap) => _NamazKarti(
                        vakit: snap.data,
                        onTap: () => _ac((_) => const NamazEkrani()),
                      ),
                    ),
                  ),
                  const SizedBox(width: kBosluk12),
                  Expanded(
                    child: _SeriKarti(seri: _seri, okunanGun: _okunanGun),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kBosluk24),
            const BolumBasligi('Günün ayeti'),
            FutureBuilder<Ayet?>(
              future: _gununAyeti,
              builder: (context, snap) => snap.hasData && snap.data != null
                  ? _GununAyetiKarti(ayet: snap.data!)
                  : const SizedBox(height: 90),
            ),
            const SizedBox(height: kBosluk16),
            const BolumBasligi('Günün hadisi'),
            _HadisKarti(hadis: _bugununHadisi()),
            const SizedBox(height: kBosluk24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _ac((_) => const IlerlemeEkrani()),
                    icon: const Icon(AppIkonlari.ilerleme),
                    label: const Text('İlerlemem'),
                  ),
                ),
                const SizedBox(width: kBosluk12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(kMagazaAdresi),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(AppIkonlari.degerlendir),
                    label: const Text('Değerlendir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Hadis _bugununHadisi() {
    final gun = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return hadisler[gun % hadisler.length];
  }
}

const List<String> _aylar = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];
const List<String> _gunler = [
  'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
];

/// Selamlama ve tarih: sade, koyu yeşil başlık.
class _SelamBasligi extends StatelessWidget {
  final int seri;

  const _SelamBasligi({required this.seri});

  String get _selamlama {
    final saat = DateTime.now().hour;
    if (saat < 5) return 'Hayırlı geceler';
    if (saat < 12) return 'Hayırlı sabahlar';
    if (saat < 17) return 'Hayırlı öğleler';
    if (saat < 21) return 'Hayırlı akşamlar';
    return 'Hayırlı geceler';
  }

  String get _tarih {
    final n = DateTime.now();
    return '${n.day} ${_aylar[n.month - 1]} ${n.year}, ${_gunler[n.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kBosluk20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kYaricap20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kYesil, kYesilAcik],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: IslimiDesen(hucre: 56)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: kMushafFontu, fontSize: 22, color: kAltinAcik),
              ),
              const SizedBox(height: kBosluk12),
              Text(_selamlama,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: kBosluk4),
              Text(_tarih, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bugünkü sayfa: ana eylem.
class _BugunKarti extends StatelessWidget {
  final int sayfa;
  final bool okundu;
  final VoidCallback onOkut;

  const _BugunKarti({required this.sayfa, required this.okundu, required this.onOkut});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(kBosluk16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kAltinAcik.withOpacity(0.5),
              borderRadius: BorderRadius.circular(kYaricap12),
            ),
            alignment: Alignment.center,
            child: Text(sayfa == 0 ? '-' : '$sayfa',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kYesil)),
          ),
          const SizedBox(width: kBosluk16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bugünkü sayfa', style: t.titleMedium),
                const SizedBox(height: 2),
                Text(
                  okundu
                      ? 'Bugün okundu. Maşallah!'
                      : (sayfa == 0 ? 'Yükleniyor' : '${HafizlikSira.cuzOf(sayfa)}. cüz'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          if (!okundu)
            FilledButton(
              onPressed: onOkut,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text('Oku'),
            )
          else
            const Icon(AppIkonlari.tamam, color: kYesil, size: 28),
        ],
      ),
    );
  }
}

/// Sonraki namaz vakti kartı.
class _NamazKarti extends StatelessWidget {
  final (String, DateTime)? vakit;
  final VoidCallback onTap;

  const _NamazKarti({required this.vakit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final v = vakit;
    final saat = v == null
        ? null
        : '${v.$2.hour.toString().padLeft(2, '0')}:${v.$2.minute.toString().padLeft(2, '0')}';
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(AppIkonlari.namaz, color: Color(0xFFAD1457), size: 18),
            const SizedBox(width: kBosluk4),
            Text('Sonraki vakit',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ]),
          const SizedBox(height: kBosluk8),
          Text(v == null ? 'Konum ekleyin' : v.$1,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(saat ?? 'Namaz Vakitleri\'nden konum seçin',
              style: const TextStyle(fontSize: 13, color: kIkincilMetin)),
        ],
      ),
    );
  }
}

/// Seri ve okunan gün kartı.
class _SeriKarti extends StatelessWidget {
  final int seri;
  final int okunanGun;

  const _SeriKarti({required this.seri, required this.okunanGun});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(AppIkonlari.seri, color: kAltin, size: 18),
            const SizedBox(width: kBosluk4),
            Text('Seri',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ]),
          const SizedBox(height: kBosluk8),
          Text('$seri gün', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text('$okunanGun okunan gün',
              style: const TextStyle(fontSize: 13, color: kIkincilMetin)),
        ],
      ),
    );
  }
}

/// Günün hadisi kartı.
class _HadisKarti extends StatelessWidget {
  final Hadis hadis;

  const _HadisKarti({required this.hadis});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(kBosluk20),
      child: Column(
        children: [
          Text(
            '“${hadis.metin}”',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: kBosluk12),
          Text(hadis.kaynak, style: const TextStyle(fontSize: 12, color: kIkincilMetin)),
        ],
      ),
    );
  }
}

/// Üst alan: yeşil zemin, İslami desen, besmele ve seri rozeti.
class _Ust extends StatelessWidget {
  final int seri;

  const _Ust({required this.seri});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kYesil, kYesilAcik],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: IslimiDesen())),
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: kMushafFontu,
                            fontSize: 30,
                            color: kAltinAcik,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(width: 60, height: 1.5, color: kAltin),
                        const SizedBox(height: 10),
                        const Text(
                          'Hafızlık',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (seri > 0)
                    Positioned(
                      right: 16,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kAltin.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(AppIkonlari.seri,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('$seri gün',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Günün ayeti: bugünkü sayfanın ilk ayeti.
class _GununAyetiKarti extends StatelessWidget {
  final Ayet ayet;

  const _GununAyetiKarti({required this.ayet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: kKagitRengi,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAltin.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIkonlari.esma, size: 16, color: kAltin),
              const SizedBox(width: 6),
              Text(
                'Günün ayeti · Sure ${ayet.sure}, Ayet ${ayet.numara}',
                style: TextStyle(fontSize: 12, color: Colors.brown.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ayet.metin,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: kMushafFontu,
              fontSize: 20,
              height: 1.8,
              color: kYesil,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bolum {
  final String baslik;
  final String altyazi;
  final IconData ikon;
  final Color renk;
  final WidgetBuilder hedef;

  const _Bolum(this.baslik, this.altyazi, this.ikon, this.renk, this.hedef);
}

class _KartTile extends StatelessWidget {
  final _Bolum bolum;
  final VoidCallback onTap;

  const _KartTile({required this.bolum, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final renk = bolum.renk;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [renk.withOpacity(0.18), Theme.of(context).cardColor],
        ),
        border: Border.all(color: renk.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: renk.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [renk, renk.withOpacity(0.75)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: renk.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(bolum.ikon, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  bolum.baslik,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kMetin,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bolum.altyazi,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: renk.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ana ekranın özet kartı: selamlama, bugünkü sayfa, seri ve hızlı başlat.
class _OzetKarti extends StatelessWidget {
  final int seri;
  final int bugunSayfa;
  final int okunanGun;
  final bool bugunOkundu;
  final VoidCallback onOkut;

  const _OzetKarti({
    required this.seri,
    required this.bugunSayfa,
    required this.okunanGun,
    required this.bugunOkundu,
    required this.onOkut,
  });

  String get _selamlama {
    final saat = DateTime.now().hour;
    if (saat < 5) return 'Hayırlı geceler';
    if (saat < 12) return 'Hayırlı sabahlar';
    if (saat < 17) return 'Hayırlı öğleler';
    if (saat < 21) return 'Hayırlı akşamlar';
    return 'Hayırlı geceler';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAltin.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: kYesil.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selamlama,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: kMetin)),
          const SizedBox(height: 4),
          Text(
            bugunOkundu
                ? 'Bugünkü sayfayı okudunuz. Maşallah!'
                : (bugunSayfa == 0
                    ? 'Bugünkü sayfanız yükleniyor…'
                    : 'Bugünkü sayfanız: $bugunSayfa. sayfa, ${HafizlikSira.cuzOf(bugunSayfa)}. cüz'),
            style: TextStyle(color: Colors.brown.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Rozet(
                  ikon: AppIkonlari.seri,
                  metin: '$seri gün seri',
                  renk: kAltin),
              const SizedBox(width: 8),
              _Rozet(
                  ikon: AppIkonlari.tamam,
                  metin: '$okunanGun okunan gün',
                  renk: kYesil),
              const Spacer(),
              if (!bugunOkundu)
                FilledButton(
                  onPressed: onOkut,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Oku'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  final IconData ikon;
  final String metin;
  final Color renk;

  const _Rozet({required this.ikon, required this.metin, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: renk),
          const SizedBox(width: 4),
          Text(metin, style: TextStyle(fontSize: 12, color: renk, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
