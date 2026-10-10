import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../widgets/cosmic_widgets.dart';

/// Ay evresine karsilik gelen niyet temasi
const _phaseThemes = {
  MoonPhase.newMoon: (
    'Yeni Ay - Niyet Baslat',
    'Yeni baslangiclar icin guclu bir zaman. Ne yaratmak istiyorsun?'
  ),
  MoonPhase.waxingCrescent: (
    'Hilal - Tohumla',
    'Niyetinin filizlendigi bu donemde sabirla suluyorsun.'
  ),
  MoonPhase.firstQuarter: (
    'Ilk Ceyrek - Eyleme Gec',
    'Engelleri asmak icin enerji yuksek. Bir adim at.'
  ),
  MoonPhase.waxingGibbous: (
    'Buyuyen Ay - Ince Ayar',
    'Ilerlemeyi degerlendirme ve gerekirse yonunu duzeltme zamani.'
  ),
  MoonPhase.fullMoon: (
    'Dolunay - Farkindalik ve Birakma',
    'Neyin meyve verdigini gor. Artik ise yaramayani birakmaya hazir misin?'
  ),
  MoonPhase.waningGibbous: (
    'Azalan Ay - Paylas',
    'Ogrendiklerini, kazandiklarini paylasma vakti.'
  ),
  MoonPhase.lastQuarter: (
    'Son Ceyrek - Serbest Birak',
    'Hangi aliskanlik veya dusuncenin zamani doldu?'
  ),
  MoonPhase.waningCrescent: (
    'Eski Hilal - Dinlen',
    'Yeni dongu icin hazirlan. Dinlenme, buyumenin parcasidir.'
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
                            'Bugun',
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
                  '~ Yaklasik hesaplama; gercek ay evresi +/-1 gun farkli olabilir.',
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
          Text('Onumuzdeki 30 Gun', style: AppTextStyles.h2(tokens)),
          const SizedBox(height: 12),
          ...calendarDays.map((day) {
            final phase = engine.moonPhase(day);
            final isToday = day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;
            return _DayRow(
              day: day,
              phase: phase,
              isToday: isToday,
              tokens: tokens,
            );
          }),

          const SizedBox(height: 20),

          // Evre anlamlari rehberi
          Text('Evre Anlamlari', style: AppTextStyles.h2(tokens)),
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
    required this.isToday,
    required this.tokens,
  });

  final DateTime day;
  final MoonPhase phase;
  final bool isToday;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['', 'Pzt', 'Sal', 'Car', 'Per', 'Cum', 'Cmt', 'Paz'];
    const months = [
      '', 'Oca', 'Sub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Agu', 'Eyl', 'Eki', 'Kas', 'Ara'
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
          Text(phase.symbol, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            phase.displayName,
            style: AppTextStyles.caption(tokens).copyWith(
              color: tokens.onSurfaceSubtle,
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
