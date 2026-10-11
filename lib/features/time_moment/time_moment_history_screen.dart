import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;

import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../widgets/cosmic_widgets.dart';

final timeMomentHistoryProvider = StreamProvider<List<TimeMomentTableData>>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return (db.select(db.timeMomentTable)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .watch();
  },
);

class TimeMomentHistoryScreen extends ConsumerWidget {
  const TimeMomentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final records = ref.watch(timeMomentHistoryProvider);
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title: Text('Saat Anı geçmişi', style: AppTextStyles.title(tokens)),
      ),
      body: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyStateWidget(
          title: 'Geçmiş yüklenemedi.',
          subtitle: 'Biraz sonra yeniden deneyebilirsin.',
        ),
        data: (items) => items.isEmpty
            ? const EmptyStateWidget(
                title: 'Henüz kaydedilmiş bir an yok.',
                subtitle:
                    'Özel bir saatte niyetini kaydettiğinde burada görünür.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _MomentCard(
                  moment: items[index],
                  tokens: tokens,
                  onEdit: () => _edit(context, ref, items[index]),
                  onDelete: () => _delete(context, ref, items[index]),
                ),
              ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    TimeMomentTableData moment,
  ) async {
    final controller = TextEditingController(text: moment.intentionText ?? '');
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${moment.timeLabel} niyetini düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Niyetin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (updated == null) return;
    final value = updated.trim();
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.timeMomentTable)
          ..where((row) => row.id.equals(moment.id)))
        .write(TimeMomentTableCompanion(
      intentionText: Value(value.isEmpty ? null : value),
    ));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    TimeMomentTableData moment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kaydı sil?'),
        content: const Text('Bu Saat Anı kaydı kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await (ref
            .read(appDatabaseProvider)
            .delete(ref.read(appDatabaseProvider).timeMomentTable)
          ..where((row) => row.id.equals(moment.id)))
        .go();
    if (context.mounted) {
      showCosmicSnackbar(context, 'Kayıt silindi.', isError: false);
    }
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({
    required this.moment,
    required this.tokens,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeMomentTableData moment;
  final CosmicTokens tokens;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tokens.glassStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(moment.timeLabel, style: AppTextStyles.titleSmall(tokens)),
                const SizedBox(width: 12),
                Text(moment.date,
                    style: AppTextStyles.caption(tokens)
                        .copyWith(color: tokens.onSurfaceMuted)),
                const Spacer(),
                IconButton(
                    tooltip: 'Düzenle',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined)),
                IconButton(
                    tooltip: 'Sil',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline)),
              ],
            ),
            Text(
              moment.intentionText?.isNotEmpty == true
                  ? moment.intentionText!
                  : 'Bu an için bir niyet yazılmadı.',
              style: AppTextStyles.body(tokens).copyWith(
                  color: moment.intentionText?.isNotEmpty == true
                      ? tokens.onBackground
                      : tokens.onSurfaceMuted),
            ),
          ],
        ),
      );
}
