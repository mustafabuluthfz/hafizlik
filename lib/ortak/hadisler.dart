/// Günün hadisi. Metinler kaynaklarıyla birlikte verilir.
class Hadis {
  final String metin;
  final String kaynak;

  const Hadis(this.metin, this.kaynak);
}

const List<Hadis> hadisler = [
  Hadis('Ameller niyetlere göredir.', 'Buhârî, Bed\'ü\'l-vahy 1'),
  Hadis('Sizin en hayırlınız, Kur\'an\'ı öğrenen ve öğretendir.', 'Buhârî, Fedâilü\'l-Kur\'an 21'),
  Hadis('Kolaylaştırın, zorlaştırmayın; müjdeleyin, nefret ettirmeyin.', 'Buhârî, İlim 11'),
  Hadis('Temizlik imanın yarısıdır.', 'Müslim, Tahâret 1'),
  Hadis('Güzel söz sadakadır.', 'Buhârî, Cihâd 70'),
  Hadis('Allah katında en sevimli amel, az da olsa devamlı olandır.', 'Buhârî, Rikâk 18'),
];
