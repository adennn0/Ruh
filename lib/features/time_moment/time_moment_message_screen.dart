import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/intention_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/time_moment/special_times.dart';
import '../../domain/time_moment/time_moment_copy.dart';
import '../../widgets/cosmic_widgets.dart';

class TimeMomentMessageScreen extends ConsumerStatefulWidget {
  const TimeMomentMessageScreen({
    super.key,
    required this.localDate,
    required this.timeLabel,
  });

  final String localDate;
  final String timeLabel;

  @override
  ConsumerState<TimeMomentMessageScreen> createState() =>
      _TimeMomentMessageScreenState();
}

class _TimeMomentMessageScreenState
    extends ConsumerState<TimeMomentMessageScreen> {
  bool _acknowledged = false;

  String get _acknowledgementKey =>
      'time_moment_ack_${widget.localDate}_${widget.timeLabel}';

  @override
  void initState() {
    super.initState();
    _loadAcknowledgement();
  }

  Future<void> _loadAcknowledgement() async {
    final value =
        ref.read(sharedPreferencesProvider).getBool(_acknowledgementKey);
    if (mounted) setState(() => _acknowledged = value ?? false);
  }

  Future<void> _acknowledgeMoment() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_acknowledgementKey, true);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _acknowledged = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu an için kendine alan açtın.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final special = SpecialTimes.parse(widget.timeLabel);
    final scheduledNightTime = widget.timeLabel.startsWith('gece@')
        ? widget.timeLabel.substring('gece@'.length)
        : null;
    final salt = ref.watch(userProfileRepositoryProvider).contentSalt;
    final intentions = ref.watch(activeIntentionsProvider).valueOrNull ?? [];

    String headline;
    String body;
    String kind = 'Hatırlatıcı';

    if (special != null && profile != null) {
      const copyEngine = TimeMomentCopyEngine();
      final intention = copyEngine.pickIntentionTitle(
        intentions.map((i) => i.title).toList(),
        widget.localDate,
        special.label,
      );
      final copy = copyEngine.compose(
        time: special,
        localDate: widget.localDate.isEmpty ? _todayKey() : widget.localDate,
        sign: profile.zodiacSign,
        tone: profile.tone,
        personalSalt: salt,
        intentionTitle: intention.isEmpty ? null : intention,
      );
      headline = copy.title;
      body = copy.fullMessage;
      kind = copy.kindLabel;
    } else {
      final genericType =
          scheduledNightTime == null ? widget.timeLabel : 'gece';
      headline = _genericHeadline(genericType);
      body = _genericBody(
        genericType,
        profile,
        widget.localDate.isEmpty ? _todayKey() : widget.localDate,
        salt,
      );
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
                special != null ? widget.timeLabel : headline,
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
                label: 'Bu ana niyet ekle',
                onPressed: () => context.push(
                  Uri(
                    path: AppRoutes.timeMoment,
                    queryParameters: {
                      if (widget.localDate.isNotEmpty) 'date': widget.localDate,
                      if (special != null) 'time': special.label,
                      if (scheduledNightTime != null)
                        'time': scheduledNightTime,
                    },
                  ).toString(),
                ),
              ),
              const SizedBox(height: 8),
              CosmicSecondaryButton(
                label: _acknowledged
                    ? 'Bu ana alan açtın ✓'
                    : 'Bu ana alan açıyorum',
                onPressed: _acknowledged ? null : _acknowledgeMoment,
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
      'gece' => 'Gece niyet molası',
      _ => 'Bir an dur',
    };
  }

  String _genericBody(
    String label,
    UserProfile? profile,
    String date,
    String personalSalt,
  ) {
    if (profile != null) {
      const copyEngine = TimeMomentCopyEngine();
      final reminderTitle = switch (label) {
        'niyet' => 'Niyet hatırlatıcısı',
        'aksam' => 'Akşam duruşu',
        'mesaj' => 'Günün mesajı hazır',
        _ => null,
      };
      if (label == 'gece') {
        return copyEngine.composeNightNotification(
          localDate: date,
          sign: profile.zodiacSign,
          tone: profile.tone,
          personalSalt: personalSalt,
        );
      }
      if (reminderTitle != null) {
        return copyEngine.composeReminderNotification(
          title: reminderTitle,
          localDate: date,
          sign: profile.zodiacSign,
          tone: profile.tone,
          personalSalt: personalSalt,
        );
      }
    }
    final tone = profile?.tone ?? MessageTone.spiritual;
    final sign = profile?.zodiacSign.displayName ?? 'senin';
    return switch (label) {
      'niyet' =>
        'Aktif niyetlerinden biri için bugün atabileceğin küçük adım nedir? $sign ritminle, ${tone.displayName.toLowerCase()} bir cümle yeter.',
      'aksam' =>
        'Günü yargılamadan kapat. Ne işe yaradı, yarın hangi küçük jesti denersin?',
      'mesaj' =>
        'Bugünkü mesajın Ana Sayfa’da. Burcuna ve seçtiğin tona göre yazıldı; herkese aynı metin gitmez.',
      'gece' =>
        'Gece hatırlatıcısı isteğe bağlı bir düşünme molasıdır; burcun için en iyi zamanı gösterdiği iddiasını taşımaz. Şimdi ya da yarın için seçebileceğin küçük bir adım ne?',
      _ => 'Bu bir hatırlatıcı. Niyetini söyle, nefes al, küçük bir adım seç.',
    };
  }
}
