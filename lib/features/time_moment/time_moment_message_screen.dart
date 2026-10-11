import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/intention_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/time_moment/special_times.dart';
import '../../domain/time_moment/time_moment_copy.dart';
import '../../widgets/cosmic_widgets.dart';

class TimeMomentMessageScreen extends ConsumerWidget {
  const TimeMomentMessageScreen({
    super.key,
    required this.localDate,
    required this.timeLabel,
  });

  final String localDate;
  final String timeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final special = SpecialTimes.parse(timeLabel);
    final salt = ref.watch(userProfileRepositoryProvider).contentSalt;
    final intentions = ref.watch(activeIntentionsProvider).valueOrNull ?? [];

    String headline;
    String body;
    String kind = 'Hatırlatıcı';

    if (special != null && profile != null) {
      const copyEngine = TimeMomentCopyEngine();
      final intention = copyEngine.pickIntentionTitle(
        intentions.map((i) => i.title).toList(),
        localDate,
        special.label,
      );
      final copy = copyEngine.compose(
        time: special,
        localDate: localDate.isEmpty ? _todayKey() : localDate,
        sign: profile.zodiacSign,
        tone: profile.tone,
        personalSalt: salt,
        intentionTitle: intention.isEmpty ? null : intention,
      );
      headline = copy.title;
      body = copy.fullMessage;
      kind = copy.kindLabel;
    } else {
      headline = _genericHeadline(timeLabel);
      body = _genericBody(timeLabel, profile);
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(kind, style: AppTextStyles.titleSmall(tokens)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                timeLabel.length == 5 ? timeLabel : headline,
                textAlign: TextAlign.center,
                style: AppTextStyles.heroTitle(tokens),
              ),
              const SizedBox(height: 8),
              if (profile != null)
                Text(
                  '${profile.zodiacSign.displayName} · ${profile.tone.displayName}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(tokens),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: CosmicCard(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Text(body, style: AppTextStyles.bodyLarge(tokens)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CosmicPrimaryButton(
                label: 'Bu anda niyetimi söyle',
                onPressed: () => context.push(
                  Uri(
                    path: AppRoutes.timeMoment,
                    queryParameters: {
                      if (localDate.isNotEmpty) 'date': localDate,
                      if (special != null) 'time': special.label,
                    },
                  ).toString(),
                ),
              ),
              const SizedBox(height: 8),
              CosmicGhostButton(
                label: 'Nefes molası',
                onPressed: () => context.push(AppRoutes.breath),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _genericHeadline(String label) {
    return switch (label) {
      'niyet' => 'Niyet hatırlatıcısı',
      'aksam' => 'Akşam duruşu',
      'mesaj' => 'Günün mesajı',
      _ => 'Bir an dur',
    };
  }

  String _genericBody(String label, UserProfile? profile) {
    final tone = profile?.tone ?? MessageTone.spiritual;
    final sign = profile?.zodiacSign.displayName ?? 'senin';
    return switch (label) {
      'niyet' =>
        'Aktif niyetlerinden biri için bugün atabileceğin küçük adım nedir? $sign ritminle, ${tone.displayName.toLowerCase()} bir cümle yeter.',
      'aksam' =>
        'Günü yargılamadan kapat. Ne işe yaradı, yarın hangi küçük jesti denersin?',
      'mesaj' =>
        'Bugünkü mesajın Ana Sayfa’da. Burcuna ve seçtiğin tona göre yazıldı; herkese aynı metin gitmez.',
      _ => 'Bu bir hatırlatıcı. Niyetini söyle, nefes al, küçük bir adım seç.',
    };
  }
}
