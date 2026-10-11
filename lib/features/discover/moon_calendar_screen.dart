import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/astrology/moon_phase_calculator.dart';
import '../../widgets/cosmic_widgets.dart';

/// Astronomik evreden ayrı, sembolik düşünme teması.
const _phaseThemes = {
  MoonPhase.newMoon: (
    'Yeni Ay · Niyet başlat',
    'Yeni bir başlangıç için hangi küçük adımı seçebilirsin?'
  ),
  MoonPhase.waxingCrescent: (
    'Hilal · Tohumu besle',
    'Niyetini destekleyecek küçük ve sürdürülebilir bir adım düşün.'
  ),
  MoonPhase.firstQuarter: (
    'İlk Dördün · Eyleme geç',
    'Karşına çıkan bir engel için deneyebileceğin seçenek ne?'
  ),
  MoonPhase.waxingGibbous: (
    'Büyüyen Ay · İnce ayar',
    'İlerlemeni gözden geçir; gerekiyorsa planını yeniden düzenle.'
  ),
  MoonPhase.fullMoon: (
    'Dolunay · Fark et ve bırak',
    'Nelerin işe yaradığını ve neleri geride bırakmak istediğini düşün.'
  ),
  MoonPhase.waningGibbous: (
    'Küçülen Ay · Paylaş',
    'Öğrendiklerinden birini güvendiğin biriyle paylaşabilirsin.'
  ),
  MoonPhase.lastQuarter: (
    'Son Dördün · Sadeleş',
    'Hangi alışkanlığı veya düşünceyi artık taşımak istemiyorsun?'
  ),
  MoonPhase.waningCrescent: (
    'Küçük Hilal · Dinlen',
    'Kendine kısa bir mola ver; dinlenmek de günlük yaşamın bir parçası.'
  ),
};

class MoonCalendarScreen extends ConsumerWidget {
  const MoonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    const engine = AstrologyEngineImpl();
    final now = DateTime.now();
    final currentPhase = engine.moonPhase(now);
    final phaseTheme = _phaseThemes[currentPhase]!;

    // Ay takvimi: onumuzdeki 30 gun
    final calendarDays = List.generate(30, (i) => now.add(Duration(days: i)));
    final eventsByDate = <String, MoonPhaseEvent>{};
    for (final event in const MoonPhaseCalculator().eventsBetween(
      now,
      now.add(const Duration(days: 30)),
    )) {
      final date = event.localTime;
      eventsByDate['${date.year}-${date.month}-${date.day}'] = event;
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        title: Text('Ay Takvimi', style: AppTextStyles.title(tokens)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Bugunku ay evresi hero karti
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.accentPrimary.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Text(
                          currentPhase.symbol,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bugün',
                            style: AppTextStyles.caption(tokens).copyWith(
                              color: tokens.onSurfaceMuted,
                            ),
                          ),
                          Text(
                            currentPhase.displayName,
                            style: AppTextStyles.h2(tokens),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  phaseTheme.$1,
                  style: AppTextStyles.titleSmall(tokens).copyWith(
                    color: tokens.accentPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phaseTheme.$2,
                  style: AppTextStyles.body(tokens).copyWith(
                    color: tokens.onSurfaceSubtle,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Önemli evre anları cihazının yerel saatinde gösterilir. Yorumlar semboliktir.',
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: tokens.onSurfaceMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 30 gunluk takvim
          Text('Önümüzdeki 30 gün', style: AppTextStyles.h2(tokens)),
          const SizedBox(height: 12),
          ...calendarDays.map((day) {
            final phase = engine.moonPhase(day);
            final isToday = day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;
            return _DayRow(
              day: day,
              phase: phase,
              event: eventsByDate['${day.year}-${day.month}-${day.day}'],
              isToday: isToday,
              tokens: tokens,
            );
          }),

          const SizedBox(height: 20),

          // Evre anlamlari rehberi
          Text('Sembolik düşünme temaları', style: AppTextStyles.h2(tokens)),
          const SizedBox(height: 12),
          ...MoonPhase.values.map((phase) {
            final theme = _phaseThemes[phase];
            if (theme == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CosmicCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase.symbol, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.displayName,
                            style: AppTextStyles.titleSmall(tokens),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.$2,
                            style: AppTextStyles.body(tokens).copyWith(
                              color: tokens.onSurfaceSubtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.phase,
    this.event,
    required this.isToday,
    required this.tokens,
  });

  final DateTime day;
  final MoonPhase phase;
  final MoonPhaseEvent? event;
  final bool isToday;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    const months = [
      '',
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? tokens.accentPrimary.withValues(alpha: 0.12)
            : tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: tokens.accentPrimary, width: 1.5)
            : Border.all(color: tokens.glassStroke),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              weekdays[day.weekday],
              style: AppTextStyles.caption(tokens).copyWith(
                color: isToday ? tokens.accentPrimary : tokens.onSurfaceMuted,
              ),
            ),
          ),
          Text(
            '${day.day} ${months[day.month]}',
            style: AppTextStyles.body(tokens).copyWith(
              fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              color: isToday ? tokens.accentPrimary : tokens.onSurface,
            ),
          ),
          const Spacer(),
          Text(event?.phase.symbol ?? phase.symbol,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              event == null
                  ? phase.displayName
                  : '${event!.phase.displayName} · ${event!.localTime.hour.toString().padLeft(2, '0')}:${event!.localTime.minute.toString().padLeft(2, '0')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTextStyles.caption(tokens).copyWith(
                color: tokens.onSurfaceSubtle,
              ),
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Icon(Icons.circle, size: 6, color: tokens.accentPrimary),
          ],
        ],
      ),
    );
  }
}
