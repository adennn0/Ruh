import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../astrology/astrology_engine.dart';

final compatibilityEngineProvider = Provider<CompatibilityEngine>((ref) {
  return CompatibilityEngine();
});

class CompatibilityResult {
  final ZodiacSign sign1;
  final ZodiacSign sign2;
  final int score;
  final String label;
  final String shortText;

  const CompatibilityResult({
    required this.sign1,
    required this.sign2,
    required this.score,
    required this.label,
    required this.shortText,
  });
}

class CompatibilityEngine {
  CompatibilityResult calculate(ZodiacSign sign1, ZodiacSign sign2) {
    int score = 0;

    if (sign1 == sign2) {
      score = 78;
    } else {
      // Element relationship
      final el1 = sign1.element;
      final el2 = sign2.element;

      if (el1 == el2) {
        score = 80;
      } else if ((el1 == ZodiacElement.fire && el2 == ZodiacElement.air) ||
          (el1 == ZodiacElement.air && el2 == ZodiacElement.fire) ||
          (el1 == ZodiacElement.earth && el2 == ZodiacElement.water) ||
          (el1 == ZodiacElement.water && el2 == ZodiacElement.earth)) {
        score = 88;
      } else if ((el1 == ZodiacElement.fire && el2 == ZodiacElement.earth) ||
          (el1 == ZodiacElement.earth && el2 == ZodiacElement.fire) ||
          (el1 == ZodiacElement.air && el2 == ZodiacElement.water) ||
          (el1 == ZodiacElement.water && el2 == ZodiacElement.air)) {
        score = 60;
      } else if ((el1 == ZodiacElement.earth && el2 == ZodiacElement.air) ||
          (el1 == ZodiacElement.air && el2 == ZodiacElement.earth)) {
        score = 55;
      } else if ((el1 == ZodiacElement.fire && el2 == ZodiacElement.water) ||
          (el1 == ZodiacElement.water && el2 == ZodiacElement.fire)) {
        score = 52;
      }

      // Modality adjustment
      final mod1 = sign1.modality;
      final mod2 = sign2.modality;

      if (mod1 == mod2) {
        if (mod1 == ZodiacModality.cardinal || mod1 == ZodiacModality.fixed) {
          score -= 3;
        }
      } else if ((mod1 == ZodiacModality.cardinal && mod2 == ZodiacModality.fixed) ||
          (mod1 == ZodiacModality.fixed && mod2 == ZodiacModality.cardinal)) {
        score += 2;
      } else if ((mod1 == ZodiacModality.fixed && mod2 == ZodiacModality.mutable) ||
          (mod1 == ZodiacModality.mutable && mod2 == ZodiacModality.fixed)) {
        score += 3;
      } else if ((mod1 == ZodiacModality.cardinal && mod2 == ZodiacModality.mutable) ||
          (mod1 == ZodiacModality.mutable && mod2 == ZodiacModality.cardinal)) {
        score += 4;
      }
    }

    // Clamp 40-95
    if (score < 40) score = 40;
    if (score > 95) score = 95;

    return CompatibilityResult(
      sign1: sign1,
      sign2: sign2,
      score: score,
      label: compatibilityLabel(score),
      shortText: _getShortText(sign1, sign2),
    );
  }

  String compatibilityLabel(int score) {
    if (score >= 85) return 'Yüksek akış';
    if (score >= 70) return 'Uyumlu ritim';
    if (score >= 55) return 'Öğretici denge';
    return 'Dönüştürücü bağ';
  }

  String _getShortText(ZodiacSign sign1, ZodiacSign sign2) {
    final key = _pairKey(sign1, sign2);
    return _commentaries[key] ?? 'İki farklı enerjinin eşsiz dansı. Karşılıklı anlayışla derinleşen bir bağ.';
  }

  String _pairKey(ZodiacSign sign1, ZodiacSign sign2) {
    // Sort to ensure aries-leo is same as leo-aries
    if (sign1.index < sign2.index) {
      return '${sign1.name}_${sign2.name}';
    }
    return '${sign2.name}_${sign1.name}';
  }

  static const Map<String, String> _commentaries = {
    // Aries
    'aries_aries': 'İki ateşin güçlü buluşması. Enerjiniz çok yüksek, ortak hedeflerde büyük bir ivme yakalayabilirsiniz.',
    'aries_taurus': 'Ateşin hızı ve toprağın sabrı birleşiyor. Birbirinizin ritmine ayak uydurduğunuzda dengeli bir büyüme sağlanır.',
    'aries_gemini': 'Fikirler ve eylemler arasında hızlı bir alışveriş var. İletişimi canlı tutarak harika bir sinerji yaratabilirsiniz.',
    'aries_cancer': 'Cesaret ve duygusal derinliğin karşılaşması. Birbirinizin sınırlarına saygı duyarak güven inşa edebilirsiniz.',
    'aries_leo': 'Ortak tutku ve yaratıcılık! Parlak bir yaşam enerjisine sahip, birbirini motive eden güçlü bir bağ.',
    'aries_virgo': 'Hareket ve düzenin öğretici dengesi. Farklı bakış açılarınız, detayları tamamlama konusunda harika işleyebilir.',
    'aries_libra': 'Ben ve biz ekseninde birbirinizi tamamlarsınız. Karşıt enerjilerin güçlü bir uyuma dönüşme potansiyeli çok yüksek.',
    'aries_scorpio': 'Derin bir dönüşüm ve ortak irade. Yüzleşmeler size güç verir, dürüstlükle derinleşen bir bağ oluşturursunuz.',
    'aries_sagittarius': 'Ortak macera ve keşif arzusu. Birbirinizin sınırlarını genişleten, coşkulu ve yenilikçi bir birliktelik.',
    'aries_capricorn': 'Farklı hızlardaki iki güçlü irade. Ortak bir amaç belirlendiğinde aşamayacağınız hiçbir engel yoktur.',
    'aries_aquarius': 'Bireysellik ve toplumsal vizyon bir arada. Yenilikleri birlikte denemek bu bağın taze kalmasını sağlar.',
    'aries_pisces': 'Dışa dönüklük ve içsel bilgeliğin buluşması. Empati sayesinde farklı dünyaları şefkatle birleştirebilirsiniz.',
    
    // Taurus
    'taurus_taurus': 'Toprağın huzuru ve kararlılığı. Güvenli, sadık ve adımları sağlam atılan, uzun soluklu bir yaşam yolculuğu.',
    'taurus_gemini': 'Sabır ve zihinsel çevikliğin buluşması. Farklı hızlarınızı anladığınızda ufuk açıcı bir dinamik oluşur.',
    'taurus_cancer': 'Duygusal güven ve pratikliğin tatlı uyumu. Ev hissi veren, köklenen ve birbirini besleyen bir dinamik.',
    'taurus_leo': 'İstikrar ve parlamanın birleşimi. Birbirinizin güçlü yönlerini onaylayarak sağlam bir güven inşa edebilirsiniz.',
    'taurus_virgo': 'Toprağın pratik ve destekleyici gücü. Düzen ve sabırla örülü, karşılıklı emeğe dayanan sakin bir bağ.',
    'taurus_libra': 'Venüs’ün iki farklı yüzü. Güzellik, estetik ve uyum arayışı ortak; huzuru paylaşmaktan keyif alırsınız.',
    'taurus_scorpio': 'Maddi dünya ve ruhsal derinliğin kutupsal çekimi. Sırları paylaştıkça sarsılmaz bir güven yaratırsınız.',
    'taurus_sagittarius': 'Köklenme ve özgürlük arayışı. Farklı ufuklara saygı duydukça birbirinizin vizyonunu geliştirirsiniz.',
    'taurus_capricorn': 'Sabır ve disiplinin kusursuz inşası. Pratik hedefleri birlikte gerçekleştirerek sağlam yapılar kurarsınız.',
    'taurus_aquarius': 'Gelenek ve yeniliğin karşılaşması. Esneklik gösterildikçe birbirinize farklı ufuklar kazandırabilirsiniz.',
    'taurus_pisces': 'Pratiklik ve hayal gücünün yaratıcı uyumu. Somut adımlarla ruhsal idealleri birbirine bağlarsınız.',

    // Gemini
    'gemini_gemini': 'Bitmek bilmeyen bir merak ve iletişim. Zihinsel uyarım sayesinde her gün yeni bir keşifle doludur.',
    'gemini_cancer': 'Zihin ve duygunun etkileşimi. Düşünceleri şefkatle ifade ettiğinizde birbirinize güvenli bir alan sağlarsınız.',
    'gemini_leo': 'Sosyallik ve yaratıcı ifadenin uyumu. Eğlenceli, neşeli ve karşılıklı takdirle beslenen sıcak bir dinamik.',
    'gemini_virgo': 'Merkür’ün iki farklı çalışma şekli. Detaylar ve büyük resim arasında köprü kurarak birbirinizi tamamlarsınız.',
    'gemini_libra': 'Hava elementinin entelektüel uyumu. Fikirlerin özgürce uçuştuğu, paylaşımın ve sohbetin ön planda olduğu bir bağ.',
    'gemini_scorpio': 'Yüzeysellikten derinliğe uzanan öğretici bir bağ. Gizem ve merak birbirini besleyerek iletişimi derinleştirir.',
    'gemini_sagittarius': 'Bilgi ve bilgelik arayışı. Hem öğretmen hem öğrenci olarak birbirinizin hayatına renk katarsınız.',
    'gemini_capricorn': 'Hafiflik ve ciddiyetin birleşimi. Pratik zekayı disiplinle harmanladığınızda ortak başarı yakalarsınız.',
    'gemini_aquarius': 'Orijinal fikirlerin ve ortak ideallerin dansı. Toplumsal vizyon ve yenilikçilik bağınızı güçlendirir.',
    'gemini_pisces': 'Mantık ve sezginin buluşması. Birbirinizin iletişim dilini anladığınızda çok zengin bir iç dünya paylaşırsınız.',

    // Cancer
    'cancer_cancer': 'Duygusal bir yuva ve şefkat alanı. Birbirinizi sezgilerinizle anlar, sarmalayıcı bir güven inşa edersiniz.',
    'cancer_leo': 'Su ve ateşin öğretici dansı. Duyarlılıkla coşkuyu dengeleyerek birbirinize şefkat dolu bir sahne sunabilirsiniz.',
    'cancer_virgo': 'Bakım ve pratik desteğin buluşması. Karşılıklı empatiyle günlük yaşamı son derece huzurlu hale getirirsiniz.',
    'cancer_libra': 'İçsel güven ile sosyal uyumun birleşimi. Farklı ihtiyaçlarınızı dengeli bir iletişimle çözdüğünüzde bağınız güçlenir.',
    'cancer_scorpio': 'Derin suların güçlü şifası. Sezgisel anlayışınız çok yüksek, kelimelere dökmeden birbirinizi anlarsınız.',
    'cancer_sagittarius': 'Evcimenlik ve göçebe ruh. Farklı ihtiyaçlarınızı anladığınızda birbirinize hem kök hem kanat olabilirsiniz.',
    'cancer_capricorn': 'Aile ve kariyer, iç dünya ve dış başarı. Karşıtlıklarınızı birleştirdiğinizde eksiksiz bir bütün olursunuz.',
    'cancer_aquarius': 'Duygusal derinlik ve zihinsel vizyon. Bağımsızlık ve aidiyet ihtiyacını dengelediğinizde ufkunuz açılır.',
    'cancer_pisces': 'Şefkat, rüyalar ve koşulsuz sevgi. İki su burcu olarak adeta tek bir duygusal frekansta titreşirsiniz.',

    // Leo
    'leo_leo': 'İki güneşin parıltısı. Yaratıcılık, coşku ve onayla dolu; birbirinizin ışığını büyüttüğünüz görkemli bir bağ.',
    'leo_virgo': 'Liderlik ve hizmetin dengesi. Sahnede parlamakla kulisi yönetmek arasındaki işbirliği sizi harika bir takım yapar.',
    'leo_libra': 'Güzellik, zarafet ve çekicilik. Sosyal yaşamda parlayan, birbirini her anlamda yükselten sıcak bir uyum.',
    'leo_scorpio': 'Yoğun tutkular ve kararlılık. Güven temelinde yükseldiğinde, hiçbir zorluğun yıkamayacağı güçlü bir irade.',
    'leo_sagittarius': 'Ateş elementinin macera dolu sinerjisi. Neşe, keşif ve ortak vizyonlarla beslenen çok canlı bir birliktelik.',
    'leo_capricorn': 'Görkem ve disiplinin buluşması. Ortak başarı hedeflerinde birbirinize saygı duyarak büyük adımlar atabilirsiniz.',
    'leo_aquarius': 'Kişisel parıltı ve kolektif vizyon. Farklı ideallerinizi paylaştıkça çok geniş bir bakış açısı kazanırsınız.',
    'leo_pisces': 'Coşku ve empatinin yaratıcı birleşimi. Sanatsal ve ruhsal bir vizyonla birbirinizi derinden besleyebilirsiniz.',

    // Virgo
    'virgo_virgo': 'Düzen, hizmet ve analitik zekanın zirvesi. Pratik yaşamda kusursuz işleyen, birbirini destekleyen bir sistem.',
    'virgo_libra': 'Detaylar ve estetik denge. İletişimde nezaketi koruduğunuzda birbirinize hem düzen hem huzur getirirsiniz.',
    'virgo_scorpio': 'Pratik çözüm ve stratejik derinlik. Karşılıklı sadakat ve güvenle inşa edilen, sessiz ama güçlü bir bağ.',
    'virgo_sagittarius': 'Detaylar ve büyük resmin öğretici dengesi. Farklı açılardan baktığınızda hayatı çok boyutlu algılarsınız.',
    'virgo_capricorn': 'Toprak elementinin çalışkan uyumu. Disiplin ve pratiklik sayesinde hayatın her alanında ortak başarı.',
    'virgo_aquarius': 'Mantık ve yeniliğin buluşması. Sistem kurma becerisiyle vizyonu birleştirdiğinizde harika fikirler doğar.',
    'virgo_pisces': 'Mantık ve teslimiyetin birbirini tamamlaması. Gerçekliği sezgiyle, hayalleri pratiklikle beslersiniz.',

    // Libra
    'libra_libra': 'Uyum, estetik ve paylaşımın zarif dansı. Denge arayışınız ortak, çatışmadan uzak, huzurlu bir ilişki.',
    'libra_scorpio': 'Hafiflik ve derinliğin karşılaşması. Sınırları aşmayı öğrendikçe birbirinize güvenmeyi derinden hissedersiniz.',
    'libra_sagittarius': 'Sosyal etkileşim ve özgürlük. İletişimi keyifli, macera ruhu yüksek, birbirini boğmayan rahat bir enerji.',
    'libra_capricorn': 'Sosyal uyum ve ciddi hedefler. Farklı ritimlerinizi esneklikle birleştirdiğinizde ortak yapılar kurarsınız.',
    'libra_aquarius': 'Hava elementinin zihinsel canlılığı. Fikirdaşlık, sosyallik ve ortak vizyonla her daim ferah bir iletişim.',
    'libra_pisces': 'Estetik ve empatinin sanatsal birleşimi. Şefkat ve nezaketle dolu, ruhsal frekansı yüksek bir beraberlik.',

    // Scorpio
    'scorpio_scorpio': 'Derin suların yoğunluğu. Tutku, sadakat ve sarsılmaz bir bağ; dönüşüme açık oldukça birlikte güçlenirsiniz.',
    'scorpio_sagittarius': 'Gizem ve şeffaflık. Farklı yaklaşımlarınızı kabullendikçe hayatın felsefi boyutunu birlikte keşfedersiniz.',
    'scorpio_capricorn': 'Strateji, kararlılık ve sağlamlık. Birbirine son derece güvenen, yıkılmaz bir ittifak kurma potansiyeli.',
    'scorpio_aquarius': 'Yoğunluk ve objektiflik. Duygusal ihtiyaçları zihinsel esneklikle dengeleyerek derin bir farkındalık yaratırsınız.',
    'scorpio_pisces': 'Sezgisel derinliğin kusursuz uyumu. Sözlere gerek kalmadan birbirinizi anlar, ruhsal bir bütünleşme yaşarsınız.',

    // Sagittarius
    'sagittarius_sagittarius': 'Keşif, macera ve felsefenin buluşması. Birlikte sınırları aştığınız, bol neşeli ve özgür bir yolculuk.',
    'sagittarius_capricorn': 'Vizyon ve yapının öğretici dengesi. Hayalleri somutlaştırmak için birbirinizin ritmine ihtiyaç duyarsınız.',
    'sagittarius_aquarius': 'Yenilik, özgürlük ve yüksek idealler. Birlikte geleceğe umutla baktığınız vizyoner bir birliktelik.',
    'sagittarius_pisces': 'Arayış ve kabullenişin buluşması. Hem evreni hem de iç dünyanızı şefkatle genişlettiğiniz bir dinamik.',

    // Capricorn
    'capricorn_capricorn': 'Disiplin, sorumluluk ve büyük hedefler. Sarsılmaz bir güvenle ortak amaçlara birlikte yürüyüş.',
    'capricorn_aquarius': 'Gelenek ve devrimin sentezi. Yapılandırma gücüyle orijinal fikirleri harmanlayarak kalıcı eserler bırakırsınız.',
    'capricorn_pisces': 'Katı gerçeklik ve suyun esnekliği. Güvenli bir liman arayan sulara kök, kuru topraklara can suyu olursunuz.',

    // Aquarius
    'aquarius_aquarius': 'Orijinal zihinlerin buluşması. Geleneklerden uzak, entelektüel uyarımın dorukta olduğu özgür bir bağ.',
    'aquarius_pisces': 'Kolektif vizyon ve ruhsal birlik. Mantık ve sezgiyi dengeleyerek insanlığa ilham verecek enerjiler yaratırsınız.',

    // Pisces
    'pisces_pisces': 'İki engin okyanusun birleşimi. Empati, rüyalar ve sezgilerle dolu, tamamen ruhsal ve şefkatli bir bütünlük.',
  };
}
