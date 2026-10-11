import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/bond_repository.dart';
import '../../widgets/cosmic_widgets.dart';

final bondProfilesProvider = StreamProvider<List<BondProfileTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.bondProfileTable)
        ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
      .watch();
});

final bondMomentsProvider =
    StreamProvider.family<List<BondMomentTableData>, int>((ref, bondId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.bondMomentTable)
        ..where((row) => row.bondId.equals(bondId))
        ..orderBy([(row) => OrderingTerm.desc(row.occurredOn)]))
      .watch();
});

class BondsScreen extends ConsumerWidget {
  const BondsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profiles = ref.watch(bondProfilesProvider);
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title: Text('Bağlı Ruhlar', style: AppTextStyles.title(tokens)),
        actions: [
          IconButton(
            tooltip: 'Kişi ekle',
            onPressed: () => _editBond(context, ref),
            icon: Icon(Icons.add, color: tokens.accentPrimary),
          ),
        ],
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyStateWidget(
          title: 'Bağların yüklenemedi.',
          subtitle: 'Biraz sonra yeniden deneyebilirsin.',
        ),
        data: (items) => items.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const EmptyStateWidget(
                    title: 'Önem verdiğin bağlara yer aç.',
                    subtitle:
                        'Bir kişi ekleyerek ilişkin üzerine notlar ve ortak anılar tutabilirsin. Bu bilgiler cihazında kalır.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _editBond(context, ref),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('İlk kişiyi ekle'),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bond = items[index];
                  return CosmicCard(
                    onTap: () => context.push('/bonds/${bond.id}'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              tokens.accentPrimary.withValues(alpha: .14),
                          child: Icon(Icons.favorite_outline,
                              color: tokens.accentPrimary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bond.name,
                                  style: AppTextStyles.titleSmall(tokens)),
                              const SizedBox(height: 4),
                              Text(bond.relationCategory,
                                  style: AppTextStyles.caption(tokens)
                                      .copyWith(color: tokens.onSurfaceMuted)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: tokens.onSurfaceMuted),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _editBond(BuildContext context, WidgetRef ref,
      {BondProfileTableData? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final note = TextEditingController(text: existing?.privateNote ?? '');
    final intention = TextEditingController(text: existing?.intention ?? '');
    const categories = ['Partner', 'Aile', 'Arkadaş', 'Diğer'];
    var category = categories.contains(existing?.relationCategory)
        ? existing!.relationCategory
        : categories.first;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).extension<CosmicTokens>()!.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(existing == null ? 'Bağlı ruh ekle' : 'Bağı düzenle',
                  style: AppTextStyles.h2(
                      Theme.of(context).extension<CosmicTokens>()!)),
              const SizedBox(height: 12),
              TextField(
                  controller: name,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(labelText: 'İsim veya takma ad')),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'İlişki'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setSheetState(() => category = value ?? category),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: intention,
                  maxLength: 240,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Bu bağa dair niyet (isteğe bağlı)')),
              TextField(
                  controller: note,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Özel not (isteğe bağlı)')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final value = name.text.trim();
                  if (value.isEmpty) return;
                  final db = ref.read(appDatabaseProvider);
                  final changes = BondProfileTableCompanion(
                    name: Value(value),
                    relationCategory: Value(category),
                    intention: Value(intention.text.trim().isEmpty
                        ? null
                        : intention.text.trim()),
                    privateNote: Value(
                        note.text.trim().isEmpty ? null : note.text.trim()),
                  );
                  if (existing == null) {
                    await db.into(db.bondProfileTable).insert(changes);
                  } else {
                    await (db.update(db.bondProfileTable)
                          ..where((row) => row.id.equals(existing.id)))
                        .write(changes);
                  }
                  if (sheetContext.mounted) Navigator.pop(sheetContext, true);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
    name.dispose();
    note.dispose();
    intention.dispose();
    if (result == true) ref.invalidate(bondProfilesProvider);
  }
}

class BondDetailScreen extends ConsumerWidget {
  const BondDetailScreen({super.key, required this.bondId});
  final int bondId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final db = ref.watch(appDatabaseProvider);
    final matches = ref
        .watch(bondProfilesProvider)
        .valueOrNull
        ?.where((p) => p.id == bondId)
        .toList();
    final profile = matches == null || matches.isEmpty ? null : matches.first;
    final moments = ref.watch(bondMomentsProvider(bondId));
    if (profile == null) {
      return Scaffold(
          backgroundColor: tokens.background,
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    const prompts = [
      'Bu ilişkide kendimi ne zaman en çok duyulmuş hissediyorum?',
      'Bugün bu bağa iyi gelecek küçük ve gerçekçi bir adım ne olabilir?',
      'İhtiyacımı açık ve nazik biçimde nasıl ifade edebilirim?',
    ];
    final prompt = prompts[(DateTime.now().day + bondId) % prompts.length];
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title: Text(profile.name, style: AppTextStyles.title(tokens)),
        actions: [
          IconButton(
            tooltip: 'Bağı düzenle',
            onPressed: () =>
                const BondsScreen()._editBond(context, ref, existing: profile),
            icon: Icon(Icons.edit_outlined, color: tokens.accentPrimary),
          ),
          IconButton(
            tooltip: 'Profili sil',
            onPressed: () async {
              final yes = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text('Bağ profilini sil?'),
                        content: const Text(
                            'Bu profile ait ortak anılar da silinir.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Vazgeç')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sil'))
                        ],
                      ));
              if (yes == true) {
                await deleteBondProfile(db, bondId);
                if (context.mounted) context.pop();
              }
            },
            icon: Icon(Icons.delete_outline, color: tokens.errorColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMoment(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ortak anı'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(profile.relationCategory,
              style: AppTextStyles.caption(tokens)
                  .copyWith(color: tokens.accentPrimary)),
          if (profile.intention?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text('Bu bağa dair niyet', style: AppTextStyles.titleSmall(tokens)),
            Text(profile.intention!, style: AppTextStyles.body(tokens)),
          ],
          if (profile.privateNote?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text('Özel notun', style: AppTextStyles.titleSmall(tokens)),
            Text(profile.privateNote!, style: AppTextStyles.body(tokens)),
          ],
          const SizedBox(height: 24),
          CosmicCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Üzerine düşün', style: AppTextStyles.titleSmall(tokens)),
                const SizedBox(height: 8),
                Text(prompt, style: AppTextStyles.body(tokens)),
                const SizedBox(height: 8),
                Text(
                    'Bu soru bir değerlendirme aracıdır; ilişkin hakkında kesin bir yargı vermez.',
                    style: AppTextStyles.caption(tokens)
                        .copyWith(color: tokens.onSurfaceMuted)),
              ])),
          const SizedBox(height: 24),
          Text('Birlikte yaşanan anlar', style: AppTextStyles.h2(tokens)),
          const SizedBox(height: 8),
          moments.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Anılar yüklenemedi.'),
            data: (items) => items.isEmpty
                ? const EmptyStateWidget(
                    title: 'Henüz ortak anı eklenmedi.',
                    subtitle: 'Hatırlamak istediğin bir günü kaydet.')
                : Column(
                    children: items
                        .map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title,
                                  style: AppTextStyles.titleSmall(tokens)),
                              subtitle: Text(
                                  '${item.occurredOn}${item.note == null ? '' : ' · ${item.note}'}',
                                  style: AppTextStyles.caption(tokens)),
                              trailing: IconButton(
                                tooltip: 'Anıyı sil',
                                icon: Icon(Icons.delete_outline,
                                    color: tokens.onSurfaceMuted),
                                onPressed: () async => (db
                                        .delete(db.bondMomentTable)
                                      ..where((row) => row.id.equals(item.id)))
                                    .go(),
                              ),
                            ))
                        .toList()),
          ),
        ],
      ),
    );
  }

  Future<void> _addMoment(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final note = TextEditingController();
    final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Ortak anı ekle'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: title,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Başlık')),
                TextField(
                    controller: note,
                    maxLength: 300,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Not (isteğe bağlı)')),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Vazgeç')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Kaydet'))
              ],
            ));
    if (saved == true && title.text.trim().isNotEmpty) {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final db = ref.read(appDatabaseProvider);
      await db.into(db.bondMomentTable).insert(BondMomentTableCompanion.insert(
            bondId: bondId,
            title: title.text.trim(),
            note: Value(note.text.trim().isEmpty ? null : note.text.trim()),
            occurredOn: date,
          ));
    }
    title.dispose();
    note.dispose();
  }
}
