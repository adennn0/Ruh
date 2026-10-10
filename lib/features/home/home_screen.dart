import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/repositories/streak_repository.dart';
import '../../data/local_content/local_content_service.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/models/content_models.dart';
import '../../widgets/cosmic_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final streakAsync = ref.watch(streakResultProvider);
    final contentAsync = ref.watch(todayContentProvider);

    final now = DateTime.now();
    final greeting = _greeting(now.hour, profile?.displayName);

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
                onPressed: () {},
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

                // ── 5. Hızlı eylemler ─────────────────────────────────────
                _QuickActionsRow(tokens: tokens),
                const SizedBox(height: 24),

                // ── 6. Keşfet önizlemesi ──────────────────────────────────
                _DiscoverPreview(tokens: tokens, profile: profile),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour, String? name) {
    final prefix = hour < 12
        ? 'Günaydın'
        : hour < 18
            ? 'İyi günler'
            : 'İyi akşamlar';
    return name != null && name.isNotEmpty ? '$prefix, $name ✨' : '$prefix ✨';
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
              _ActionIconBtn(
                icon: PhosphorIcons.heart(PhosphorIconsStyle.light),
                tooltip: 'Favorile',
                tokens: tokens,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.copy(PhosphorIconsStyle.light),
                tooltip: 'Kopyala',
                tokens: tokens,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                tooltip: 'Paylaş',
                tokens: tokens,
                onPressed: () {},
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
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
          width: 36,
          height: 36,
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

// ── Saat Anı kartı ────────────────────────────────────────────────────────────
class _TimeMomentCard extends StatelessWidget {
  const _TimeMomentCard({required this.tokens});
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: InkWell(
        onTap: () => context.push(AppRoutes.timeMoment),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: tokens.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saat Anı', style: AppTextStyles.titleSmall(tokens)),
                  Text(
                    '11:11 · 22:22 gibi saatlerde bir an dur',
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
              _ActionIconBtn(
                icon: PhosphorIcons.heart(PhosphorIconsStyle.light),
                tooltip: 'Favorile',
                tokens: tokens,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _ActionIconBtn(
                icon: PhosphorIcons.copy(PhosphorIconsStyle.light),
                tooltip: 'Kopyala',
                tokens: tokens,
                onPressed: () {},
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
      (PhosphorIcons.target(PhosphorIconsStyle.light), 'Niyet\nOluştur', () {
        context.go(AppRoutes.journal, extra: {'openIntentionSheet': true});
      }),
      (PhosphorIcons.pencilSimple(PhosphorIconsStyle.light), 'Günlük\nYaz', () {
        context.go(AppRoutes.journal);
      }),
      (PhosphorIcons.wind(PhosphorIconsStyle.light), 'Nefes\nMolası', () {
        context.push(AppRoutes.breath);
      }),
      (PhosphorIcons.clock(PhosphorIconsStyle.light), 'Saat\nAnı', () {
        context.push(AppRoutes.timeMoment);
      }),
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
      (PhosphorIcons.heartbeat(PhosphorIconsStyle.light), 'Uyumluluk'),
      (PhosphorIcons.diamond(PhosphorIconsStyle.light), 'Doğal Taşım'),
      (PhosphorIcons.horse(PhosphorIconsStyle.light), 'Ruh Hayvanım'),
      (PhosphorIcons.moon(PhosphorIconsStyle.light), 'Ay Takvimi'),
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
    required this.tokens,
  });
  final IconData icon;
  final String label;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  });
  final String message;
  final String affirmation;
  final String? reflectionPrompt;
  final String source;
}

final todayContentProvider = FutureProvider<TodayContent?>((ref) async {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return null;

  final now = DateTime.now();
  final localDate =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final contentService = ref.watch(aiContentServiceProvider);
  try {
    final result = await contentService.generateDailyMessage(
      sign: profile.zodiacSign,
      tone: profile.tone,
      localDate: localDate,
      recentContentKeys: [],
    );
    if (result is ServiceSuccess<DailyContentResult>) {
      final data = result.data;
      return TodayContent(
        message: data.message,
        affirmation: data.affirmation,
        reflectionPrompt: data.reflectionPrompt,
        source: data.source.name,
      );
    }
    return null;
  } catch (_) {
    return null;
  }
});
