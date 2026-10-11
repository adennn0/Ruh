import 'special_times.dart';

class SpecialTimeMeaning {
  const SpecialTimeMeaning(this.category, this.meaning);
  final String category;
  final String meaning;
}

/// These are opt-in symbolic reflection prompts, not numerological facts.
class SpecialTimeContent {
  SpecialTimeContent._();

  static const meanings = <String, SpecialTimeMeaning>{
    '00:00': SpecialTimeMeaning('Yeni başlangıç', 'bir döngüyü kapatıp yeni bir başlangıca yer açma'),
    '01:01': SpecialTimeMeaning('Öz farkındalık', 'kendi ihtiyacını fark etme'),
    '02:02': SpecialTimeMeaning('İlişkiler', 'karşılıklı dinleme ve anlayış'),
    '03:03': SpecialTimeMeaning('Yaratıcılık', 'merakını küçük bir üretime dönüştürme'),
    '04:04': SpecialTimeMeaning('Düzen', 'güven veren bir temel kurma'),
    '05:05': SpecialTimeMeaning('Değişim', 'değişen koşullara esneklikle uyum sağlama'),
    '06:06': SpecialTimeMeaning('Öz şefkat', 'bakım verirken kendi ihtiyaçlarını da gözetme'),
    '07:07': SpecialTimeMeaning('Sabır', 'acele etmeden bir sonraki adımı seçme'),
    '08:08': SpecialTimeMeaning('Finansal farkındalık', 'kaynaklarını bilinçli ve gerçekçi kullanma'),
    '09:09': SpecialTimeMeaning('Tamamlama', 'bitirmek istediğin bir işi kapatma'),
    '10:10': SpecialTimeMeaning('Yeni yön', 'hedefinle uyumlu bir başlangıç yapma'),
    '11:11': SpecialTimeMeaning('Odak', 'dikkatini seçtiğin niyete geri getirme'),
    '12:12': SpecialTimeMeaning('İş birliği', 'yardım isteme ve destek sunma dengesi'),
    '13:13': SpecialTimeMeaning('Dönüşüm', 'işe yaramayan bir yöntemi yeniden değerlendirme'),
    '14:14': SpecialTimeMeaning('Disiplin', 'küçük bir alışkanlığı sürdürülebilir kılma'),
    '15:15': SpecialTimeMeaning('İletişim', 'söylemek istediğini açık ve nazik ifade etme'),
    '16:16': SpecialTimeMeaning('Yeniden değerlendirme', 'kararını yeni bilgiler ışığında gözden geçirme'),
    '17:17': SpecialTimeMeaning('Güven', 'kontrol edebildiğin adıma emek verme'),
    '18:18': SpecialTimeMeaning('Şükran', 'günün içindeki somut bir desteği fark etme'),
    '19:19': SpecialTimeMeaning('İfade', 'önem verdiğin bir düşünceyi görünür kılma'),
    '20:20': SpecialTimeMeaning('Sınırlar', 'zamanını ve enerjini koruyan bir sınır belirleme'),
    '21:21': SpecialTimeMeaning('Öğrenme', 'yaşadığından çıkarabileceğin bir dersi seçme'),
    '22:22': SpecialTimeMeaning('Dayanışma', 'tek başına taşımak zorunda olmadığın bir konuyu paylaşma'),
    '23:23': SpecialTimeMeaning('Dinlenme', 'günü kapatıp dinlenmeye geçiş yapma'),
    '01:10': SpecialTimeMeaning('Eylem ve düşünme', 'harekete geçmeden önce niyetini netleştirme'),
    '02:20': SpecialTimeMeaning('Karşılıklılık', 'ilişkide hem verme hem alma alanı açma'),
    '03:30': SpecialTimeMeaning('Yaratıcı ifade', 'aklındaki fikri küçük bir taslağa dökme'),
    '04:40': SpecialTimeMeaning('Sağlam zemin', 'planını gerçekçi bir parçaya bölme'),
    '05:50': SpecialTimeMeaning('Esneklik', 'plan değiştiğinde seçeneklerini yeniden görme'),
    '10:01': SpecialTimeMeaning('Başlangıca dönüş', 'yeni adımını asıl amacınla karşılaştırma'),
    '12:21': SpecialTimeMeaning('Denge', 'başkalarına ayırdığın zamanla kendi zamanını dengeleme'),
    '13:31': SpecialTimeMeaning('Uyum', 'değişimi küçük ve yönetilebilir parçalara ayırma'),
    '14:41': SpecialTimeMeaning('Tutarlılık', 'hedefin için tekrar edebileceğin basit bir rutin kurma'),
    '15:51': SpecialTimeMeaning('Esnek ilerleme', 'planını koşullara göre güncellerken yönünü koruma'),
    '20:02': SpecialTimeMeaning('Sınır ve yakınlık', 'yakınlık ihtiyacını ve sınırını birlikte ifade etme'),
    '21:12': SpecialTimeMeaning('Bilinçli seçim', 'önemli bir konuya ayıracağın zamanı seçme'),
    '23:32': SpecialTimeMeaning('Dinlenme ve sınır', 'günün sorumluluklarıyla dinlenme zamanını ayırma'),
  };

  static const prompts = <String>[
    'Bugün bununla ilgili tamamlayabileceğin en küçük adım ne?',
    'Bu konuda kontrol edebildiğin tek şey hangisi?',
    'İhtiyacını tek bir açık cümleyle nasıl anlatırsın?',
    'Bu hedefi on dakikalık hangi işe bölebilirsin?',
    'Bugün hangi gereksiz yükü bırakabilirsin?',
    'Birinden destek istemek işini nasıl kolaylaştırır?',
    'Kendine bugün nasıl daha anlayışlı davranabilirsin?',
    'Bu seçimin hangi kişisel değerinle uyumlu?',
    'Şimdi dikkatini dağıtan neyi bir süre erteleyebilirsin?',
    'Bu akşam kendine ayırabileceğin gerçekçi mola ne?',
    'Yarın işini kolaylaştıracak neyi şimdiden hazırlayabilirsin?',
    'Bu konudaki varsayımını hangi bilgiyle kontrol edebilirsin?',
    'Hangi sınırını sakin ve net biçimde paylaşman gerekiyor?',
    'İlerlemeni fark etmek için hangi küçük işarete bakarsın?',
    'Bu hedef hâlâ senin için anlamlı mı; neden?',
    'Daha sade bir plan yapsan ilk adım ne olurdu?',
    'Bugün hangi konuşmayı ertelemek yerine başlatabilirsin?',
    'Bir işi bitirmek için hangi ölçüt yeterli olur?',
    'Bugün sana yardımcı olan somut bir şeyi fark et.',
    'Yapamayacağın bir şeye nazikçe nasıl hayır diyebilirsin?',
    'Bir sonraki adım için hangi kaynağa gerçekten ihtiyacın var?',
    'Kendini yormadan sürdürebileceğin tempo nedir?',
    'Bu konuda yeni bir bakış açısı kimden gelebilir?',
    'Bugün küçük bir ilerleme sayacağın şey ne?',
    'Gerginliğini azaltmak için şimdi neyi yavaşlatabilirsin?',
    'Yarım kalan işi yeniden başlatmayı kolaylaştıracak ilk hareket ne?',
    'Bu düşünceye kanıt olan ve olmayan şeyler neler?',
    'Günün sonunda kendine hangi konuda teşekkür edebilirsin?',
    'Bu niyeti somutlaştıran bir davranış hangisi?',
    'Şimdi durup bedeninde fark ettiğin bir şeyi adlandır.',
  ];

  static SpecialTimeMeaning meaningFor(SpecialTime time) =>
      meanings[time.label] ?? const SpecialTimeMeaning('Farkındalık', 'bu anı kendi değerlerinle ilişkilendirme');

  static List<String> messagesFor(SpecialTime time) {
    final meaning = meaningFor(time);
    return prompts.map((prompt) =>
      '${time.label} için sembolik tema: ${meaning.meaning}. $prompt'
    ).toList(growable: false);
  }
}
