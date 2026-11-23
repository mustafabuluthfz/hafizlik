import 'package:flutter/material.dart';

/// Tasarım sistemi: renkler, boşluklar, köşe yuvarlaklıkları ve yazı stilleri.
/// Tüm ekranlar bu değerleri kullanır; tek yerden değiştirilebilir.

// Marka renkleri
const Color kYesil = Color(0xFF0E4D43);
const Color kYesilAcik = Color(0xFF1F7A68);
const Color kAltin = Color(0xFFB8912F);
const Color kAltinAcik = Color(0xFFF1E6C4);
const Color kZemin = Color(0xFFF6F5F1);
const Color kMetin = Color(0xFF17201C);
const Color kIkincilMetin = Color(0xFF5F6B66);
const Color kKoyuZemin = Color(0xFF0B1210);
const Color kKoyuKart = Color(0xFF15201C);

// Boşluklar (8'in katları)
const double kBosluk4 = 4;
const double kBosluk8 = 8;
const double kBosluk12 = 12;
const double kBosluk16 = 16;
const double kBosluk20 = 20;
const double kBosluk24 = 24;
const double kBosluk32 = 32;

// Köşe yuvarlaklıkları
const double kYaricap12 = 12;
const double kYaricap16 = 16;
const double kYaricap20 = 20;

/// Kullanıcının seçtiği görünüm (açık, koyu, sistem). Uygulama açılışında yüklenir.
final ValueNotifier<ThemeMode> kTemaModu = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Mushaf kâğıdı rengi ve Arapça yazı boyutu kullanıcı tercihleri.
final ValueNotifier<Color> kMushafKagitRengi = ValueNotifier<Color>(const Color(0xFFFBF6E9));
final ValueNotifier<double> kMushafYaziBoyutu = ValueNotifier<double>(26);

const List<Color> kKagitPaleti = [
  Color(0xFFFBF6E9), Color(0xFFF3E8D0), Color(0xFFF5F0DC), Color(0xFFE8F0E5),
  Color(0xFFE7EEF5), Color(0xFFF0E6E8), Color(0xFFFFFFFF), Color(0xFF202820),
];
const List<String> kKagitAdlari = ['Klasik', 'Sepya', 'Krem', 'Açık yeşil', 'Açık mavi', 'Gül', 'Beyaz', 'Koyu'];

ThemeData kTemaAcik() => _tema(Brightness.light);
ThemeData kTemaKoyu() => _tema(Brightness.dark);

ThemeData _tema(Brightness parlaklik) {
  final koyu = parlaklik == Brightness.dark;
  final zemin = koyu ? kKoyuZemin : kZemin;
  final kart = koyu ? kKoyuKart : Colors.white;
  final semalar = ColorScheme.fromSeed(
    seedColor: kYesil,
    brightness: parlaklik,
    primary: koyu ? const Color(0xFF81C784) : kYesil,
    onPrimary: koyu ? kKoyuZemin : Colors.white,
    secondary: kAltin,
    surface: kart,
  );

  final yazi = ThemeData(brightness: parlaklik).textTheme.apply(
        bodyColor: koyu ? const Color(0xFFE6EAE4) : kMetin,
        displayColor: koyu ? const Color(0xFFE6EAE4) : kMetin,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: parlaklik,
    colorScheme: semalar,
    scaffoldBackgroundColor: zemin,
    textTheme: yazi.copyWith(
      titleLarge: yazi.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2),
      titleMedium: yazi.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: yazi.bodyMedium?.copyWith(height: 1.4),
      labelLarge: yazi.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: koyu ? kKoyuZemin : kYesil,
      foregroundColor: koyu ? const Color(0xFFE6EAE4) : Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: kart,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kYaricap20),
        side: BorderSide(
          color: koyu ? Colors.white10 : const Color(0xFFE6E0CF),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: kBosluk16, vertical: kBosluk4),
    ),
    dividerTheme: DividerThemeData(
      color: koyu ? Colors.white12 : const Color(0xFFE6E0CF),
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kYaricap12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: kAltin),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kYaricap12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kart,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kYaricap12),
        borderSide: BorderSide(color: kAltin.withOpacity(0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kYaricap12),
        borderSide: BorderSide(color: kAltin.withOpacity(0.35)),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: kAltin.withOpacity(0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kYaricap20)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kYaricap12)),
    ),
  );
}
