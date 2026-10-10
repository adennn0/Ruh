import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/router/app_router.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/astrology/astrology_engine.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        title: Text('Keşfet', style: AppTextStyles.title(tokens)),
      ),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        children: [
          _DiscoverCard(
            label: 'Uyumluluk',
            subtitle: 'Burçlar arası dinamikler',
            icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.light),
            gradient: [tokens.accentPrimary, tokens.accentSecondary],
            onTap: () => context.push(AppRoutes.compatibility),
            tokens: tokens,
          ),
          _DiscoverCard(
            label: 'Doğal Taşım',
            subtitle: profile != null ? profile.zodiacSign.displayName : '',
            icon: PhosphorIcons.diamond(PhosphorIconsStyle.light),
            gradient: [tokens.accentSecondary, tokens.accentPrimary],
            onTap: () => context.push(AppRoutes.crystal),
            tokens: tokens,
          ),
          _DiscoverCard(
            label: 'Ruh Hayvanım',
            subtitle: 'Burcun ve doğum saatin',
            icon: PhosphorIcons.horse(PhosphorIconsStyle.light),
            gradient: [
              tokens.accentPrimary,
              tokens.accentSecondary.withValues(alpha: 0.7),
            ],
            onTap: () => context.push(AppRoutes.spiritAnimal),
            tokens: tokens,
          ),
          _DiscoverCard(
            label: 'Ay Takvimi',
            subtitle: _moonPhaseName(tokens),
            icon: PhosphorIcons.moon(PhosphorIconsStyle.light),
            gradient: [
              tokens.accentSecondary,
              tokens.accentPrimary.withValues(alpha: 0.6),
            ],
            onTap: () => context.push(AppRoutes.moonCalendar),
            tokens: tokens,
          ),
          _DiscoverCard(
            label: 'Saat Anı',
            subtitle: 'Bilinçli an deneyimi',
            icon: PhosphorIcons.clockCountdown(PhosphorIconsStyle.light),
            gradient: [
              tokens.accentPrimary.withValues(alpha: 0.8),
              tokens.accentSecondary,
            ],
            onTap: () => context.push(AppRoutes.timeMoment),
            tokens: tokens,
          ),
          _DiscoverCard(
            label: 'Nefes Molası',
            subtitle: 'Yönlendirmeli nefes',
            icon: PhosphorIcons.wind(PhosphorIconsStyle.light),
            gradient: [
              tokens.accentSecondary.withValues(alpha: 0.8),
              tokens.accentPrimary,
            ],
            onTap: () => context.push(AppRoutes.breath),
            tokens: tokens,
          ),
        ],
      ),
    );
  }

  String _moonPhaseName(CosmicTokens tokens) {
    const engine = AstrologyEngineImpl();
    final phase = engine.moonPhase(DateTime.now());
    return phase.displayName;
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.tokens,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.titleSmall(tokens).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
