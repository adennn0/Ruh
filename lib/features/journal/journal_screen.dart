import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/db/app_database.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/intention_repository.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../domain/models/enums.dart';
import '../../widgets/cosmic_widgets.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key, this.initialTab = 0, this.focusIntentionId});

  final int initialTab;
  final int? focusIntentionId;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = ['Bugün', 'Niyetler', 'Yazılar', 'Favoriler'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        title: Text('Günlük', style: AppTextStyles.title(tokens)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tokens.accentPrimary,
          labelColor: tokens.accentPrimary,
          unselectedLabelColor: tokens.onSurfaceMuted,
          labelStyle: AppTextStyles.labelLarge(tokens),
          unselectedLabelStyle: AppTextStyles.label(tokens),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _TodayTab(),
          _IntentionsTab(focusIntentionId: widget.focusIntentionId),
          const _JournalEntriesTab(),
          const _FavoritesTab(),
        ],
      ),
    );
  }
}

// ── Bugün sekmesi ─────────────────────────────────────────────────────────────
class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final journalRepo = ref.watch(journalRepositoryProvider);

    return FutureBuilder<List<JournalEntryModel>>(
      future: journalRepo.forToday(),
      builder: (context, snap) {
        final entries = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Bugünün Özeti', style: AppTextStyles.h2(tokens)),
            const SizedBox(height: 4),
            Text(
              _todayStr(),
              style: AppTextStyles.caption(tokens)
                  .copyWith(color: tokens.onSurfaceMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickWriteBtn(
                    label: 'Günlük',
                    icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.light),
                    type: JournalType.journal,
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickWriteBtn(
                    label: 'Şükür',
                    icon: PhosphorIcons.heart(PhosphorIconsStyle.light),
                    type: JournalType.gratitude,
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickWriteBtn(
                    label: 'Rüya',
                    icon: PhosphorIcons.moon(PhosphorIconsStyle.light),
                    type: JournalType.dream,
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty)
              const EmptyStateWidget(
                title: 'Bugün henüz yazı yok.',
                subtitle: 'Nasıl hissediyorsun?',
              )
            else ...[
              Text('Bugünkü Yazılar', style: AppTextStyles.titleSmall(tokens)),
              const SizedBox(height: 12),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EntryCard(entry: e, tokens: tokens),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _todayStr() {
    final now = DateTime.now();
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
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

class _QuickWriteBtn extends StatelessWidget {
  const _QuickWriteBtn({
    required this.label,
    required this.icon,
    required this.type,
    required this.tokens,
  });
  final String label;
  final IconData icon;
  final JournalType type;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _WriteSheet(type: type),
        ),
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
              Text(label, style: AppTextStyles.labelSmall(tokens)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Niyetler sekmesi ──────────────────────────────────────────────────────────
class _IntentionsTab extends ConsumerWidget {
  const _IntentionsTab({this.focusIntentionId});
  final int? focusIntentionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final activeAsync = ref.watch(activeIntentionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _IntentionSheet(),
        ),
        backgroundColor: tokens.accentPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Yeni Niyet',
          style: AppTextStyles.button(tokens).copyWith(color: Colors.white),
        ),
      ),
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          message: 'Niyetler yüklenemedi',
          onRetry: () => ref.invalidate(activeIntentionsProvider),
        ),
        data: (intentions) => intentions.isEmpty
            ? const EmptyStateWidget(
                title: 'Henüz niyet oluşturmadın.',
                subtitle: 'Bugün ne yaratmak istiyorsun?',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: intentions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _IntentionCard(
                  intention: intentions[i],
                  tokens: tokens,
                  highlighted: intentions[i].id == focusIntentionId,
                ),
              ),
      ),
    );
  }
}

// ── Yazılar sekmesi ───────────────────────────────────────────────────────────
class _JournalEntriesTab extends ConsumerWidget {
  const _JournalEntriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final entriesAsync = ref.watch(allJournalEntriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _WriteSheet(type: JournalType.journal),
        ),
        backgroundColor: tokens.accentPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          message: 'Yazılar yüklenemedi',
          onRetry: () => ref.invalidate(allJournalEntriesProvider),
        ),
        data: (entries) => entries.isEmpty
            ? const EmptyStateWidget(title: 'Henüz yazı oluşturmadın.')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _EntryCard(entry: entries[i], tokens: tokens),
              ),
      ),
    );
  }
}

// ── Favoriler sekmesi ─────────────────────────────────────────────────────────
class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final favorites = ref.watch(favoritesProvider);
    return favorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyStateWidget(
        title: 'Favoriler yüklenemedi.',
        subtitle: 'Biraz sonra yeniden deneyebilirsin.',
      ),
      data: (items) => items.isEmpty
          ? const EmptyStateWidget(
              title: 'Henüz favori yok.',
              subtitle:
                  'Mesajları ve olumlamaları kalp ile favorilerine ekleyebilirsin.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return CosmicCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.contentType == 'affirmation'
                                  ? 'Günlük olumlama'
                                  : 'Sana özel mesaj',
                              style: AppTextStyles.caption(tokens)
                                  .copyWith(color: tokens.accentPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                                item.cachedText ??
                                    'Bu kayıt için metin saklanmamış.',
                                style: AppTextStyles.body(tokens)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Favorilerden çıkar',
                        onPressed: () => ref.read(favoritesDaoProvider).toggle(
                              item.contentType,
                              item.contentId,
                              item.cachedText,
                            ),
                        icon: Icon(PhosphorIcons.heart(PhosphorIconsStyle.fill),
                            color: tokens.accentSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ── Niyet kartı ───────────────────────────────────────────────────────────────
class _IntentionCard extends ConsumerWidget {
  const _IntentionCard(
      {required this.intention,
      required this.tokens,
      this.highlighted = false});
  final IntentionModel intention;
  final CosmicTokens tokens;
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(intentionRepositoryProvider);

    return CosmicCard(
      borderColor: highlighted ? tokens.accentPrimary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(intention.title,
                        style: AppTextStyles.titleSmall(tokens)),
                    const SizedBox(height: 2),
                    Text(
                      intention.category.displayName,
                      style: AppTextStyles.caption(tokens)
                          .copyWith(color: tokens.accentSecondary),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: tokens.surfaceElevated,
                icon: Icon(Icons.more_vert, color: tokens.onSurfaceMuted),
                onSelected: (value) async {
                  switch (value) {
                    case 'complete':
                      await repo.complete(intention.id);
                      await rebuildNotificationWindow(ref);
                    case 'archive':
                      await repo.archive(intention.id);
                      await rebuildNotificationWindow(ref);
                    case 'delete':
                      if (context.mounted) {
                        await _confirmDelete(context, repo, ref);
                      }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'complete',
                    child:
                        Text('Tamamlandı', style: AppTextStyles.body(tokens)),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text('Arşivle', style: AppTextStyles.body(tokens)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Sil',
                        style: AppTextStyles.body(tokens)
                            .copyWith(color: tokens.errorColor)),
                  ),
                ],
              ),
            ],
          ),
          if (intention.description != null) ...[
            const SizedBox(height: 8),
            Text(
              intention.description!,
              style: AppTextStyles.body(tokens)
                  .copyWith(color: tokens.onSurfaceSubtle),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (intention.actionStep != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.accentPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_forward,
                      size: 14, color: tokens.accentPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(intention.actionStep!,
                        style: AppTextStyles.caption(tokens)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    IntentionRepository repo,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Niyeti sil?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil')),
        ],
      ),
    );
    if (confirm == true) {
      await repo.delete(intention.id);
      await rebuildNotificationWindow(ref);
    }
  }
}

// ── Günlük yazı kartı ─────────────────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.tokens});
  final JournalEntryModel entry;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    final typeIcon = switch (entry.type) {
      JournalType.journal =>
        PhosphorIcons.pencilSimple(PhosphorIconsStyle.light),
      JournalType.gratitude => PhosphorIcons.heart(PhosphorIconsStyle.light),
      JournalType.dream => PhosphorIcons.moon(PhosphorIconsStyle.light),
    };

    return CosmicCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: tokens.accentPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.type.displayName,
                      style: AppTextStyles.caption(tokens)
                          .copyWith(color: tokens.accentSecondary),
                    ),
                    const Spacer(),
                    Text(
                      entry.entryDate,
                      style: AppTextStyles.labelSmall(tokens)
                          .copyWith(color: tokens.onSurfaceMuted),
                    ),
                  ],
                ),
                if (entry.title != null) ...[
                  const SizedBox(height: 2),
                  Text(entry.title!, style: AppTextStyles.titleSmall(tokens)),
                ],
                const SizedBox(height: 4),
                Text(
                  entry.body,
                  style: AppTextStyles.body(tokens)
                      .copyWith(color: tokens.onSurfaceSubtle),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yazı yazma sheet ──────────────────────────────────────────────────────────
class _WriteSheet extends ConsumerStatefulWidget {
  const _WriteSheet({required this.type});
  final JournalType type;

  @override
  ConsumerState<_WriteSheet> createState() => _WriteSheetState();
}

class _WriteSheetState extends ConsumerState<_WriteSheet> {
  final _bodyCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.glassStroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('${widget.type.displayName} Yaz',
                style: AppTextStyles.h2(tokens)),
            const SizedBox(height: 16),
            if (widget.type != JournalType.gratitude) ...[
              TextField(
                controller: _titleCtrl,
                style: TextStyle(color: tokens.onSurface),
                decoration:
                    const InputDecoration(hintText: 'Başlık (isteğe bağlı)'),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.type == JournalType.gratitude) ...[
              Text(
                'Bugün minnettar olduğun 3 şey nedir?',
                style: AppTextStyles.body(tokens)
                    .copyWith(color: tokens.onSurfaceSubtle),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _bodyCtrl,
              style: TextStyle(color: tokens.onSurface),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: switch (widget.type) {
                  JournalType.journal => 'Bugün nasıl hissediyorsun?',
                  JournalType.gratitude => '1. ...\n2. ...\n3. ...',
                  JournalType.dream => 'Rüyanı anlat...',
                },
              ),
            ),
            const SizedBox(height: 16),
            CosmicPrimaryButton(
              label: 'Kaydet',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final repo = ref.read(journalRepositoryProvider);
    await repo.save(
      type: widget.type,
      title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }
}

// ── Niyet ekleme sheet ────────────────────────────────────────────────────────
class _IntentionSheet extends ConsumerStatefulWidget {
  const _IntentionSheet();

  @override
  ConsumerState<_IntentionSheet> createState() => _IntentionSheetState();
}

class _IntentionSheetState extends ConsumerState<_IntentionSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();
  IntentionCategory _category = IntentionCategory.personalGrowth;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.glassStroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Yeni Niyet', style: AppTextStyles.h2(tokens)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                style: TextStyle(color: tokens.onSurface),
                decoration: const InputDecoration(hintText: 'Niyetin nedir?'),
              ),
              const SizedBox(height: 12),
              Text('Kategori', style: AppTextStyles.caption(tokens)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: IntentionCategory.values.map((cat) {
                  final sel = _category == cat;
                  return ChoiceChip(
                    label: Text(cat.displayName),
                    selected: sel,
                    onSelected: (_) => setState(() => _category = cat),
                    selectedColor: tokens.accentPrimary.withValues(alpha: 0.2),
                    labelStyle: AppTextStyles.labelSmall(tokens).copyWith(
                      color: sel ? tokens.accentPrimary : tokens.onSurfaceMuted,
                    ),
                    backgroundColor: tokens.surface,
                    side: BorderSide(
                      color: sel ? tokens.accentPrimary : tokens.glassStroke,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                style: TextStyle(color: tokens.onSurface),
                maxLines: 3,
                decoration:
                    const InputDecoration(hintText: 'Açıklama (isteğe bağlı)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stepCtrl,
                style: TextStyle(color: tokens.onSurface),
                decoration: const InputDecoration(
                  hintText: 'Bu niyet için bugün atabileceğin küçük adım?',
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: AppTextStyles.body(tokens)
                        .copyWith(color: tokens.errorColor),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              CosmicPrimaryButton(
                label: 'Niyet Kur',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Niyet başlığı boş olamaz.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(intentionRepositoryProvider);
    final result = await repo.add(
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _category,
      actionStep: _stepCtrl.text.trim().isEmpty ? null : _stepCtrl.text.trim(),
    );
    if (!mounted) return;
    if (result.success) {
      await rebuildNotificationWindow(ref);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = result.error;
      });
    }
  }
}
