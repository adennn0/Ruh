import '../astrology/astrology_engine.dart';
import '../models/enums.dart';
import '../../core/stable_hash.dart';
import 'special_times.dart';
import 'special_time_content.dart';

class TimeMomentCopy {
  const TimeMomentCopy({
    required this.title,
    required this.notificationBody,
    required this.fullMessage,
    required this.kindLabel,
  });

  final String title;
  final String notificationBody;
  final String fullMessage;
  final String kindLabel;
}

/// Saat Anı metinleri: burç + ton + tarih + saat + kişisel tuz.
/// Kilit ekranı gövdesine niyet başlığı yazılmaz.
class TimeMomentCopyEngine {
  const TimeMomentCopyEngine();

  TimeMomentCopy compose({
    required SpecialTime time,
    required String localDate,
    required ZodiacSign sign,
    required MessageTone tone,
    required String personalSalt,
    String? intentionTitle,
  }) {
    final seed = stableHashParts(
      [localDate, time.label, sign.index, tone.index, personalSalt],
    );
    final kindLabel = switch (time.kind) {
      SpecialTimeKind.mirror => 'Çift saat',
      SpecialTimeKind.palindrome => 'Palindrom saat',
      SpecialTimeKind.both => 'Ayna saat',
    };

    final title = '${time.label} · Saat Anı';
    final bodyPool = _bodiesFor(tone);
    final meaning = SpecialTimeContent.meaningFor(time);
    final reflectionPool = SpecialTimeContent.messagesFor(time);
    final body = bodyPool[seed.abs() % bodyPool.length]
        .replaceAll('{time}', time.label)
        .replaceAll('{sign}', sign.displayName)
        .replaceAll('{theme}', sign.energyTheme.toLowerCase());

    final promptIndex = seed.abs() % reflectionPool.length;
    final reflection = reflectionPool[promptIndex];
    final opening = _openingFor(tone, time.label, meaning.category);
    var full = '$opening\n\n$reflection';

    if (intentionTitle != null && intentionTitle.trim().isNotEmpty) {
      final safe = intentionTitle.trim();
      full += '\n\n${_intentionLine(tone, safe)}';
    }

    full +=
        '\n\nBu saat sembolik bir durak. İsteklerin gerçekleşeceğinin garantisi değil; seçtiğin yönde küçük bir adım için hatırlatıcı.';

    return TimeMomentCopy(
      title: title,
      notificationBody: body,
      fullMessage: full,
      kindLabel: kindLabel,
    );
  }

  String _openingFor(MessageTone tone, String time, String category) =>
      switch (tone) {
        MessageTone.soft =>
          '$time anı, $category üzerine kendine nazikçe alan açabileceğin sembolik bir durak.',
        MessageTone.strong =>
          '$time. $category konusunda bugün seçebileceğin net ve küçük bir adım belirle.',
        MessageTone.spiritual =>
          '$time tekrarını, $category üzerine düşünmek için kişisel ve sembolik bir hatırlatıcı olarak kullanabilirsin.',
        MessageTone.rational =>
          '$time bir saat örüntüsüdür; ona vereceğin anlam kişiseldir. Bugünkü tema: $category.',
      };

  String pickIntentionTitle(
      List<String> titles, String localDate, String timeLabel) {
    if (titles.isEmpty) return '';
    final i = stableHashParts([localDate, timeLabel]) % titles.length;
    return titles[i];
  }

  String _intentionLine(MessageTone tone, String title) {
    return switch (tone) {
      MessageTone.soft => 'Bugün "$title" niyetine nazikçe yer açabilirsin.',
      MessageTone.strong => '"$title" için bu anda tek net adımın ne?',
      MessageTone.spiritual =>
        '"$title" niyetini bu anda içinden geçir; sonra somut bir jestle bağla.',
      MessageTone.rational =>
        '"$title" niyetin için ölçülebilir küçük adımın nedir?',
    };
  }

  List<String> _bodiesFor(MessageTone tone) => switch (tone) {
        MessageTone.soft => [
            '{time}: bir an dur, nefes al. {sign} ritminle kendine yumuşak bir yer aç.',
            'Bu çift/palindrom saat bir hatırlatıcı: bugün kendine nazik kal.',
            '{time} geldi. Omuzlarını indir; küçük bir niyet yeterli.',
          ],
        MessageTone.strong => [
            '{time}. Dur. Niyetini söyle, sonra bir adım at.',
            '{sign}: bu anda net ol. Tek bir somut hareket.',
            '{time} — hatırlatıcı. Odaklan, seç, ilerle.',
          ],
        MessageTone.spiritual => [
            '{time}: ayna saat. {theme} temasıyla bu ana yerleş.',
            'Bazı insanlar {time} anını bir durak olarak görür. Nefes al.',
            '{sign} enerjisiyle {time} — iç sesine kısa bir kulak ver.',
          ],
        MessageTone.rational => [
            '{time} tekrarlayan bir desen. Bu bir hatırlatıcı, kehanet değil.',
            'Kısa mola: bugünkü niyetin için tek somut adımı seç.',
            '{sign} gününde {time}. Düşün, seç, kaydet.',
          ],
      };
}
