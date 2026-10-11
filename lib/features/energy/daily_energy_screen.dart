import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/energy/personal_energy_flow.dart';
import '../../widgets/cosmic_widgets.dart';

final energyHistoryProvider = StreamProvider<List<DailyEnergyEntryTableData>>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return (db.select(db.dailyEnergyEntryTable)
          ..orderBy([
            (row) => OrderingTerm.asc(row.localDate),
            (row) => OrderingTerm.asc(row.updatedAt),
          ]))
        .watch();
  },
);

class DailyEnergyScreen extends ConsumerStatefulWidget {
  const DailyEnergyScreen({super.key});

  @override
  ConsumerState<DailyEnergyScreen> createState() => _DailyEnergyScreenState();
}

class _DailyEnergyScreenState extends ConsumerState<DailyEnergyScreen> {
  static const _moods = ['Sakin', 'İyi', 'Durgun', 'Gergin', 'Karışık'];
  static const _moneyStates = [
    'Bugün düşünmek istemiyorum',
    'Daha planlı hissettim',
    'Bir harcamayı fark ettim',
    'Küçük bir adım attım',
  ];
  int _energy = 3;
  int _focus = 3;
  String? _mood;
  String? _moneyState;
  final _noteController = TextEditingController();
  bool _saving = false;
  DateTime _historyDate = DateTime.now();
  int _chartMetric = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final history = ref.watch(energyHistoryProvider);
    final profile = ref.watch(userProfileProvider);
    final entitlement = ref.watch(entitlementServiceProvider);
    final flowLimit = entitlement.limitFor(AppFeature.personalEnergyFlow);
    final personalFlow = profile == null
        ? const <PersonalEnergyWindow>[]
        : PersonalEnergyFlow.forDate(
            date: DateTime.now(),
            sign: profile.zodiacSign,
            tone: profile.tone,
            personalSalt: ref.watch(userProfileRepositoryProvider).contentSalt,
          );
    final today = _dateKey(DateTime.now());
    final entriesToday =
        history.asData?.value.where((e) => e.localDate == today).toList();
    final existing =
        entriesToday == null || entriesToday.isEmpty ? null : entriesToday.last;
    if (existing != null && _mood == null) {
      _energy = existing.energy;
      _focus = existing.focus;
      _mood = existing.mood;
      _moneyState = existing.financialAwareness;
      _noteController.text = existing.note ?? '';
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title: Text('Günlük enerji akışı', style: AppTextStyles.title(tokens)),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyStateWidget(
          title: 'Kayıtlar yüklenemedi.',
          subtitle: 'Biraz sonra yeniden deneyebilirsin.',
        ),
        data: (entries) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Bu bir ölçüm değil; gün içindeki kendi gözlemin.',
              style: AppTextStyles.body(tokens)
                  .copyWith(color: tokens.onSurfaceMuted),
            ),
            const SizedBox(height: 20),
            _ScaleInput(
              title: 'Enerjin nasıldı?',
              value: _energy,
              onChanged: (v) => setState(() => _energy = v),
              tokens: tokens,
            ),
            const SizedBox(height: 16),
            _ScaleInput(
              title: 'Odağını nasıl hissettin?',
              value: _focus,
              onChanged: (v) => setState(() => _focus = v),
              tokens: tokens,
            ),
            const SizedBox(height: 20),
            Text('Bugünkü ruh hâlin', style: AppTextStyles.titleSmall(tokens)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods
                  .map((mood) => ChoiceChip(
                        label: Text(mood),
                        selected: _mood == mood,
                        onSelected: (_) => setState(() => _mood = mood),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('Para farkındalığın (isteğe bağlı)',
                style: AppTextStyles.titleSmall(tokens)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _moneyState,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Bir seçenek seç'),
              items: _moneyStates
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _moneyState = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLength: 240,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Kısa not (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving || _mood == null ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Bu gözlemi kaydet'),
            ),
            if (personalFlow.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Bugüne özel kişisel akış', style: AppTextStyles.h2(tokens)),
              const SizedBox(height: 6),
              Text(
                'Burcun, seçtiğin ton ve bugünün tarihine göre cihazında hazırlanır. Sembolik bir planlama önerisidir; ölçüm veya gelecek tahmini değildir.',
                style: AppTextStyles.caption(tokens)
                    .copyWith(color: tokens.onSurfaceMuted),
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < personalFlow.length; index++) ...[
                if (index < flowLimit || flowLimit < 0)
                  _PersonalFlowCard(window: personalFlow[index], tokens: tokens)
                else
                  _LockedFlowCard(
                    title: personalFlow[index].title,
                    time: personalFlow[index].time,
                    tokens: tokens,
                  ),
                const SizedBox(height: 10),
              ],
              if (flowLimit >= 0 && flowLimit < personalFlow.length)
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.premium),
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Premium ile tam akışı gör'),
                ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                    child: Text('Geçmiş kayıtlar',
                        style: AppTextStyles.h2(tokens))),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _historyDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context),
                        child: child!,
                      ),
                    );
                    if (date != null) setState(() => _historyDate = date);
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(_dateKey(_historyDate)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final dateEntries = entries
                  .where((entry) => entry.localDate == _dateKey(_historyDate))
                  .toList();
              if (dateEntries.isEmpty) {
                return const EmptyStateWidget(
                  title: 'Bu tarihte kayıt yok.',
                  subtitle:
                      'Başka bir gün seçebilir veya bugünkü gözlemini ekleyebilirsin.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Enerji')),
                      ButtonSegment(value: 1, label: Text('Odak')),
                    ],
                    selected: {_chartMetric},
                    onSelectionChanged: (selected) =>
                        setState(() => _chartMetric = selected.first),
                  ),
                  const SizedBox(height: 10),
                  _EnergyChart(
                    entries: dateEntries,
                    tokens: tokens,
                    metric: _chartMetric,
                  ),
                  ...dateEntries.reversed.map((entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${entry.updatedAt.hour.toString().padLeft(2, '0')}:${entry.updatedAt.minute.toString().padLeft(2, '0')} · ${entry.mood}',
                          style: AppTextStyles.body(tokens),
                        ),
                        subtitle: Text(
                          'Enerji ${entry.energy}/5 · Odak ${entry.focus}/5${entry.financialAwareness == null ? '' : ' · ${entry.financialAwareness}'}${entry.note == null ? '' : '\n${entry.note}'}',
                          style: AppTextStyles.caption(tokens)
                              .copyWith(color: tokens.onSurfaceMuted),
                        ),
                      )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(appDatabaseProvider);
    await db.into(db.dailyEnergyEntryTable).insert(
          DailyEnergyEntryTableCompanion.insert(
            localDate: _dateKey(DateTime.now()),
            energy: _energy,
            mood: _mood!,
            focus: _focus,
            financialAwareness: Value(_moneyState),
            note: Value(_noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (mounted) {
      setState(() => _saving = false);
      showCosmicSnackbar(context, 'Bugünkü gözlemin kaydedildi.',
          isError: false);
    }
  }
}

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _PersonalFlowCard extends StatelessWidget {
  const _PersonalFlowCard({required this.window, required this.tokens});

  final PersonalEnergyWindow window;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => CosmicCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(window.title,
                      style: AppTextStyles.titleSmall(tokens)),
                ),
                Text(window.time,
                    style: AppTextStyles.label(tokens)
                        .copyWith(color: tokens.accentPrimary)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FlowMetric(
                    label: 'Enerji',
                    value: window.energy,
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _FlowMetric(
                    label: 'Odak',
                    value: window.focus,
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(window.reflection, style: AppTextStyles.body(tokens)),
          ],
        ),
      );
}

class _FlowMetric extends StatelessWidget {
  const _FlowMetric({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final int value;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · $value/5', style: AppTextStyles.caption(tokens)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5,
              minHeight: 6,
              backgroundColor: tokens.heroBg,
              color: tokens.accentPrimary,
            ),
          ),
        ],
      );
}

class _LockedFlowCard extends StatelessWidget {
  const _LockedFlowCard({
    required this.title,
    required this.time,
    required this.tokens,
  });

  final String title;
  final String time;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => CosmicCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: tokens.onSurfaceMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title · $time',
                      style: AppTextStyles.titleSmall(tokens)),
                  const SizedBox(height: 3),
                  Text('Bu aralığın kişisel önerisi Premium’da.',
                      style: AppTextStyles.caption(tokens)
                          .copyWith(color: tokens.onSurfaceMuted)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ScaleInput extends StatelessWidget {
  const _ScaleInput(
      {required this.title,
      required this.value,
      required this.onChanged,
      required this.tokens});
  final String title;
  final int value;
  final ValueChanged<int> onChanged;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall(tokens)),
          Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$value/5',
              onChanged: (v) => onChanged(v.round())),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Düşük', style: AppTextStyles.caption(tokens)),
            Text('$value / 5',
                style: AppTextStyles.label(tokens)
                    .copyWith(color: tokens.accentPrimary)),
            Text('Yüksek', style: AppTextStyles.caption(tokens)),
          ]),
        ],
      );
}

class _EnergyChart extends StatelessWidget {
  const _EnergyChart(
      {required this.entries, required this.tokens, required this.metric});
  final List<DailyEnergyEntryTableData> entries;
  final CosmicTokens tokens;
  final int metric;

  @override
  Widget build(BuildContext context) => Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tokens.glassStroke)),
        child: CustomPaint(
          painter: _ChartPainter(
              values:
                  entries.map((e) => metric == 0 ? e.energy : e.focus).toList(),
              lineColor: tokens.accentPrimary,
              gridColor: tokens.glassStroke),
          child: const SizedBox.expand(),
        ),
      );
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter(
      {required this.values, required this.lineColor, required this.gridColor});
  final List<int> values;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height * (5 - values[i]) / 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height * (5 - values[i]) / 4;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      values != oldDelegate.values ||
      lineColor != oldDelegate.lineColor ||
      gridColor != oldDelegate.gridColor;
}
