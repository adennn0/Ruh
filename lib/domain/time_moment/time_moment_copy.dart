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
    List<String> excludedNotificationBodies = const [],
  }) {
    final seed = stableHashParts(
      [time.label, sign.index, tone.index, personalSalt],
    );
    final kindLabel = switch (time.kind) {
      SpecialTimeKind.mirror => 'Çift saat',
      SpecialTimeKind.palindrome => 'Palindrom saat',
      SpecialTimeKind.both => 'Ayna saat',
    };

    final title = '${time.label} · Saat Anı';
    final meaning = SpecialTimeContent.meaningFor(time);
    final reflectionPool = SpecialTimeContent.messagesFor(time);
    final notificationLead = switch (tone) {
      MessageTone.soft => 'Kendine nazik bir soru:',
      MessageTone.strong => 'Bugün seçebileceğin küçük adım:',
      MessageTone.spiritual => 'Bu sembolik durakta düşünebileceğin:',
      MessageTone.rational => 'Kısa bir düşünme molası:',
    };
    final promptIndexForDate =
        (seed.abs() + _dayOfYear(localDate)) % reflectionPool.length;
    var promptIndex = promptIndexForDate;
    var body = '';
    for (var offset = 0; offset < reflectionPool.length; offset++) {
      final candidateIndex = (promptIndex + offset) % reflectionPool.length;
      final candidate = '$notificationLead ${reflectionPool[candidateIndex]}';
      if (!excludedNotificationBodies.contains(candidate)) {
        promptIndex = candidateIndex;
        body = candidate;
        break;
      }
    }
    if (body.isEmpty) {
      body = '$notificationLead ${reflectionPool[promptIndex]}';
    }
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

  /// Optional, explicitly enabled premium reminder; this is a reflection
  /// prompt, not an astrological claim that a particular hour is better.
  String composeNightNotification({
    required String localDate,
    required ZodiacSign sign,
    required MessageTone tone,
    required String personalSalt,
    List<String> excludedBodies = const [],
  }) =>
      composeReminderNotification(
        title: 'Gece niyet molası',
        localDate: localDate,
        sign: sign,
        tone: tone,
        personalSalt: personalSalt,
        excludedBodies: excludedBodies,
      );

  String composeReminderNotification({
    required String title,
    required String localDate,
    required ZodiacSign sign,
    required MessageTone tone,
    required String personalSalt,
    List<String> excludedBodies = const [],
  }) {
    const prompts = SpecialTimeContent.prompts;
    final seed = stableHashParts([title, sign.index, tone.index, personalSalt]);
    final lead = switch (tone) {
      MessageTone.soft => 'Kendine nazikçe sor:',
      MessageTone.strong => 'Küçük ve net bir adım seç:',
      MessageTone.spiritual => 'Kendine sorabileceğin:',
      MessageTone.rational => 'Kısa bir düşünme sorusu:',
    };
    for (var offset = 0; offset < prompts.length; offset++) {
      final index =
          (_dayOfYear(localDate) + seed.abs() + offset) % prompts.length;
      final candidate = '$title · $lead ${prompts[index]}';
      if (!excludedBodies.contains(candidate)) return candidate;
    }
    return '$title · $lead ${prompts[seed.abs() % prompts.length]}';
  }

  int _dayOfYear(String localDate) {
    final parsed = DateTime.tryParse(localDate);
    if (parsed == null) return 0;
    return parsed.difference(DateTime(parsed.year)).inDays;
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
}
