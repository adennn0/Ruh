import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/router/app_router.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/repositories/streak_repository.dart';
import '../../data/local_content/local_content_service.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/models/content_models.dart';
import '../../platform/widget/home_widget_adapter.dart';
import '../companion/companion_profile.dart';
import '../companion/companion_avatar.dart';
import 'greeting.dart';
import '../../widgets/cosmic_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleClockRefresh();
  }

  void _scheduleClockRefresh() {
    _clockTimer?.cancel();
    final now = DateTime.now();
    final untilNextMinute = const Duration(minutes: 1) -
        Duration(seconds: now.second, milliseconds: now.millisecond);
    _clockTimer = Timer(untilNextMinute, () {
      if (!mounted) return;
      setState(() {});
      _scheduleClockRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final streakAsync = ref.watch(streakResultProvider);
    final contentAsync = ref.watch(todayContentProvider);
    final widgetPrivacyMode = ref.watch(widgetPrivacyModeProvider);
    final showStreakOnWidget = ref.watch(showStreakOnWidgetProvider);

    final now = DateTime.now();
    final greeting = greetingFor(now, profile?.displayName);

    final todayContent = contentAsync.valueOrNull;
    if (profile != null && todayContent != null) {
      final privateMode = widgetPrivacyMode;
      final streakCount = streakAsync.valueOrNull?.currentStreak;
      String toHex(Color color) =>
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          ref.read(homeWidgetAdapterProvider).updateSnapshot(
                WidgetSnapshot(
                  localDate:
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
                  headline: privateMode
                      ? 'Bugün kendine nazik davran.'
                      : todayContent.affirmation,
                  body: privateMode
                      ? 'Küçük bir nefes arası iyi gelebilir.'
                      : todayContent.message,
                  moonPhaseLabel:
                      const AstrologyEngineImpl().moonPhase(now).displayName,
                  streakCount:
                      !privateMode && showStreakOnWidget ? streakCount : null,
                  themeId: profile.themeId,
                  accentColors: [
                    toHex(tokens.surface),
                    toHex(tokens.onSurface),
                    toHex(tokens.accentPrimary),
                    toHex(tokens.accentSecondary),
                  ],
                  privacyMode: privateMode,
                  contentSource: privateMode ? 'local' : todayContent.source,
                ),
              ),
        );
      });
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: tokens.background,
            elevation: 0,
            title: Text('Ruhun Parlıyor', style: AppTextStyles.title(tokens)),
            actions: [
              IconButton(
                icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.light),
                    color: tokens.onSurfaceSubtle),
                onPressed: () => context.push(AppRoutes.notificationSettings),
                tooltip: 'Bildirimler',
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 1. Karşılama ──────────────────────────────────────────
                _GreetingSection(
                  greeting: greeting,
                  date: now,
                  tokens: tokens,
                  streakAsync: streakAsync,
                  profile: profile,
                ),
                const SizedBox(height: 24),

                // ── 2. Hero mesaj kartı ───────────────────────────────────
                _HeroMessageCard(
                  tokens: tokens,
                  contentAsync: contentAsync,
                  profile: profile,
                ),
                const SizedBox(height: 16),

                // ── 3. Saat Anı kartı ─────────────────────────────────────
                _TimeMomentCard(tokens: tokens),
                const SizedBox(height: 16),

                // ── 4. Günlük olumlama ────────────────────────────────────
                _DailyAffirmationCard(
                  tokens: tokens,
                  contentAsync: contentAsync,
                ),
                const SizedBox(height: 16),

                // ── 5. Kişisel eşlikçi ────────────────────────────────────
                const _CompanionCard(),
                const SizedBox(height: 16),

                // ── 6. Hızlı eylemler ─────────────────────────────────────
                _QuickActionsRow(tokens: tokens),
                const SizedBox(height: 24),

                // ── 7. Keşfet önizlemesi ──────────────────────────────────
                _DiscoverPreview(tokens: tokens, profile: profile),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionCard extends ConsumerWidget {
  const _CompanionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final companion = ref.watch(companionProfileProvider);
    return Semantics(
      button: true,
      label: 'Kişisel eşlikçin ${companion.name}, ${companion.species}',
      child: CosmicCard(
        onTap: () => context.push(AppRoutes.companion),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CompanionAvatar(
              profile: companion,
              tokens: tokens,
              size: 52,
              glow: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companion.name, style: AppTextStyles.titleSmall(tokens)),
                  Text(
                    '${companion.species} · Kişisel eşlikçin',
                    style: AppTextStyles.caption(tokens),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), color: tokens.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

// ── Karşılama bölümü ──────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.greeting,
    required this.date,
    required this.tokens,
    required this.streakAsync,
    required this.profile,
  });

  final String greeting;
  final DateTime date;
  final CosmicTokens tokens;
  final AsyncValue<StreakResult> streakAsync;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    const engine = AstrologyEngineImpl();
    final moonPhase =
        profile != null ? engine.moonPhase(date) : MoonPhase.newMoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTextStyles.h1(tokens)),
        const SizedBox(height: 6),
        Text(
          _formatDate(date),
          style: AppTextStyles.body(tokens).copyWith(
            color: tokens.onSurfaceSubtle,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Ay evresi çipi
            _Chip(
              icon: PhosphorIcons.moon(PhosphorIconsStyle.fill),
              label: moonPhase.displayName,
              tokens: tokens,
            ),
            const SizedBox(width: 8),
            // Işık Serisi çipi
            streakAsync.when(
              data: (streak) => streak.currentStreak > 0
                  ? _Chip(
                      icon: PhosphorIcons.flame(PhosphorIconsStyle.fill),
                      label: '${streak.currentStreak} gün',
                      tokens: tokens,
                      color: const Color(0xFFFF6B35),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    const days = [
      '',
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.tokens,
    this.color,
  });
  final IconData icon;
  final String label;
  final CosmicTokens tokens;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? tokens.accentPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall(tokens).copyWith(color: c),
          ),
        ],
      ),
    );
  }
}

// ── Hero mesaj kartı ──────────────────────────────────────────────────────────
class _HeroMessageCard extends ConsumerWidget {
  const _HeroMessageCard({
    required this.tokens,
    required this.contentAsync,
    required this.profile,
  });

  final CosmicTokens tokens;
  final AsyncValue<TodayContent?> contentAsync;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return contentAsync.when(
      loading: () => const ShimmerBox(height: 180, borderRadius: 20),
      error: (e, _) => ErrorStateWidget(
        message: 'İçerik yüklenemedi',
        onRetry: () => ref.invalidate(todayContentProvider),
      ),
      data: (content) => _buildCard(context, content),
    );
  }

  Widget _buildCard(BuildContext context, TodayContent? content) {
    final message =
        content?.message ?? 'Bugün de yolculuğuna devam ediyorsun. 🌟';
    final source = content?.source ?? 'local';
    final contentId = content?.contentKey ?? _todayContentKey();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.accentPrimary.withValues(alpha: 0.18),
            tokens.accentSecondary.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.accentPrimary.withValues(alpha: 0.25)),
        boxShadow: tokens.primaryGlow(radius: 20, opacity: 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bugünün Sana Özel Mesajı',
                style: AppTextStyles.caption(tokens).copyWith(
                  color: tokens.accentPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (source == 'demo' || source == 'local')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.glassOverlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    source == 'demo' ? 'Demo' : 'Yerel',
                    style: AppTextStyles.labelSmall(tokens).copyWith(
                      color: tokens.onSurfaceMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (profile != null)
            Text(
              profile!.zodiacSign.displayName,
              style: AppTextStyles.labelSmall(tokens).copyWith(
                color: tokens.accentSecondary,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTextStyles.body(tokens).copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _FavoriteButton(
                contentType: 'message',
                contentId: contentId,
                text: message,
                tokens: tokens,
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.copy(PhosphorIconsStyle.light),
                tooltip: 'Kopyala',
                tokens: tokens,
                onPressed: () => _copyContent(context, message),
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                tooltip: 'Paylaş',
                tokens: tokens,
                onPressed: () => Share.share(message),
              ),
              const Spacer(),
              TextButton(
                onPressed: content == null
                    ? null
                    : () =>
                        context.push(AppRoutes.dailyMessage, extra: content),
                child: Text(
                  'Tamamını oku →',
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: tokens.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  const _ActionIconBtn({
    required this.icon,
    required this.tooltip,
    required this.tokens,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final CosmicTokens tokens;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tokens.glassOverlay,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Icon(icon, size: 16, color: tokens.onSurfaceSubtle),
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({
    required this.contentType,
    required this.contentId,
    required this.text,
    required this.tokens,
  });

  final String contentType;
  final String contentId;
  final String text;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (contentType: contentType, contentId: contentId);
    final favorite = ref.watch(favoriteStatusProvider(key));
    return _ActionIconBtn(
      icon: favorite.valueOrNull == true
          ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
          : PhosphorIcons.heart(PhosphorIconsStyle.light),
      tooltip: favorite.valueOrNull == true ? 'Favorilerden çıkar' : 'Favorile',
      tokens: tokens,
      onPressed: () async {
        final wasFavorite = await ref
            .read(favoritesDaoProvider)
            .isFavorite(contentType, contentId);
        await ref
            .read(favoritesDaoProvider)
            .toggle(contentType, contentId, text);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasFavorite ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi',
            ),
          ),
        );
      },
    );
  }
}

String _todayContentKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Future<void> _copyContent(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Panoya kopyalandı')),
  );
}

// ── Saat Anı kartı ────────────────────────────────────────────────────────────
class _TimeMomentCard extends StatelessWidget {
  const _TimeMomentCard({required this.tokens});
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push(AppRoutes.timeMoment),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tokens.heroBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.access_time_rounded,
                        color: tokens.accentPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saat Anı', style: AppTextStyles.titleSmall(tokens)),
                        Text(
                          'Çift ve palindrom saatlerde kısa bir durak',
                          style: AppTextStyles.caption(tokens).copyWith(
                            color: tokens.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: tokens.onSurfaceMuted),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/time-moment/history'),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Kaydettiğim niyetler'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Günlük olumlama ───────────────────────────────────────────────────────────
class _DailyAffirmationCard extends ConsumerWidget {
  const _DailyAffirmationCard({
    required this.tokens,
    required this.contentAsync,
  });
  final CosmicTokens tokens;
  final AsyncValue<TodayContent?> contentAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affirmation = contentAsync.whenData((c) => c?.affirmation).value ??
        'Bugün iyi hissetmeyi seçiyorum.';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük Olumlama',
            style: AppTextStyles.caption(tokens).copyWith(
              color: tokens.accentSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$affirmation"',
            style: AppTextStyles.body(tokens).copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _FavoriteButton(
                contentType: 'affirmation',
                contentId:
                    contentAsync.valueOrNull?.contentKey ?? _todayContentKey(),
                text: affirmation,
                tokens: tokens,
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.copy(PhosphorIconsStyle.light),
                tooltip: 'Kopyala',
                tokens: tokens,
                onPressed: () => _copyContent(context, affirmation),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hızlı eylemler ────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.tokens});
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        PhosphorIcons.target(PhosphorIconsStyle.light),
        'Niyet\nOluştur',
        () {
          context.go(AppRoutes.journal, extra: {'openIntentionSheet': true});
        }
      ),
      (
        PhosphorIcons.pencilSimple(PhosphorIconsStyle.light),
        'Günlük\nYaz',
        () {
          context.go(AppRoutes.journal);
        }
      ),
      (
        PhosphorIcons.wind(PhosphorIconsStyle.light),
        'Nefes\nMolası',
        () {
          context.push(AppRoutes.breath);
        }
      ),
      (
        PhosphorIcons.clock(PhosphorIconsStyle.light),
        'Saat\nAnı',
        () {
          context.push(AppRoutes.timeMoment);
        }
      ),
    ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _QuickActionBtn(
                  icon: a.$1,
                  label: a.$2,
                  tokens: tokens,
                  onPressed: a.$3,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.tokens,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final CosmicTokens tokens;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Column(
            children: [
              Icon(icon, color: tokens.accentPrimary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall(tokens),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Keşfet önizlemesi ─────────────────────────────────────────────────────────
class _DiscoverPreview extends StatelessWidget {
  const _DiscoverPreview({required this.tokens, required this.profile});
  final CosmicTokens tokens;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        PhosphorIcons.heartbeat(PhosphorIconsStyle.light),
        'Uyumluluk',
        AppRoutes.compatibility
      ),
      (
        PhosphorIcons.diamond(PhosphorIconsStyle.light),
        'Doğal Taşım',
        AppRoutes.crystal
      ),
      (
        PhosphorIcons.horse(PhosphorIconsStyle.light),
        'Ruh Hayvanım',
        AppRoutes.spiritAnimal
      ),
      (
        PhosphorIcons.moon(PhosphorIconsStyle.light),
        'Ay Takvimi',
        AppRoutes.moonCalendar
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keşfet', style: AppTextStyles.h2(tokens)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _DiscoverCard(
              icon: items[i].$1,
              label: items[i].$2,
              onTap: () => context.push(items[i].$3),
              tokens: tokens,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tokens,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tokens.accentPrimary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelSmall(tokens),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TodayContent model + provider ─────────────────────────────────────────────
class TodayContent {
  const TodayContent({
    required this.message,
    required this.affirmation,
    this.reflectionPrompt,
    required this.source,
    this.contentKey,
  });
  final String message;
  final String affirmation;
  final String? reflectionPrompt;
  final String source;
  final String? contentKey;
}

final todayContentProvider = FutureProvider<TodayContent?>((ref) async {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return null;

  final now = DateTime.now();
  final localDate =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final contentService = ref.watch(aiContentServiceProvider);
  final dailyDao = ref.watch(dailyContentDaoProvider);
  try {
    final saved = await dailyDao.forDate(localDate);
    if (saved != null) {
      return TodayContent(
        message: saved.message,
        affirmation: saved.affirmation,
        reflectionPrompt: saved.reflectionPrompt,
        source: saved.source,
        contentKey: saved.contentKey,
      );
    }
    final recentKeys = await dailyDao.recentContentKeys(7);
    final result = await contentService.generateDailyMessage(
      sign: profile.zodiacSign,
      tone: profile.tone,
      localDate: localDate,
      recentContentKeys: recentKeys,
      personalSalt: ref.read(userProfileRepositoryProvider).contentSalt,
    );
    if (result is ServiceSuccess<DailyContentResult>) {
      final data = result.data;
      await dailyDao.upsert(DailyContentTableCompanion.insert(
        localDate: localDate,
        message: data.message,
        affirmation: data.affirmation,
        reflectionPrompt: Value(data.reflectionPrompt),
        source: Value(data.source.name),
        contentKey: Value(data.contentKey),
      ));
      return TodayContent(
        message: data.message,
        affirmation: data.affirmation,
        reflectionPrompt: data.reflectionPrompt,
        source: data.source.name,
        contentKey: data.contentKey,
      );
    }
    return null;
  } catch (_) {
    return null;
  }
});
