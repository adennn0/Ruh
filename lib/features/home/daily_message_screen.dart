import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/theme/theme.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/limits.dart';
import '../../data/db/app_database.dart';
import '../../data/local_content/local_content_service.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/content_models.dart';
import '../../widgets/cosmic_widgets.dart';
import 'home_screen.dart' show TodayContent, todayContentProvider;

class DailyMessageScreen extends ConsumerStatefulWidget {
  const DailyMessageScreen({super.key, this.initialContent});

  final TodayContent? initialContent;

  @override
  ConsumerState<DailyMessageScreen> createState() => _DailyMessageScreenState();
}

class _DailyMessageScreenState extends ConsumerState<DailyMessageScreen> {
  TodayContent? _refreshedContent;
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final content = _refreshedContent ??
        widget.initialContent ??
        ref.watch(todayContentProvider).valueOrNull;
    if (content == null) {
      return Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(title: const Text('Günün mesajı')),
        body: const Center(child: Text('Günün mesajı şu anda yüklenemedi.')),
      );
    }

    final contentId = content.contentKey ?? _todayContentKey();
    final isFavorite = ref
            .watch(favoriteStatusProvider(
              (contentType: 'message', contentId: contentId),
            ))
            .valueOrNull ??
        false;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title: Text('Günün mesajı', style: AppTextStyles.title(tokens)),
        actions: [
          IconButton(
            tooltip: 'Yeni mesaj',
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
            onPressed: () => ref.read(favoritesDaoProvider).toggle(
                  'message',
                  contentId,
                  content.message,
                ),
            icon: Icon(
              isFavorite
                  ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                  : PhosphorIcons.heart(PhosphorIconsStyle.light),
              color: tokens.accentSecondary,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BUGÜN · ${_todayDate()}',
                    style: AppTextStyles.label(tokens)
                        .copyWith(color: tokens.accentPrimary)),
                const SizedBox(height: 12),
                Text(content.message,
                    style:
                        AppTextStyles.bodyLarge(tokens).copyWith(height: 1.7)),
                const SizedBox(height: 18),
                Text('Burcuna ve seçtiğin tona göre hazırlanmış yerel içerik.',
                    style: AppTextStyles.caption(tokens)),
                const SizedBox(height: 8),
                Text(
                    'Kaynak: ${content.source == 'ai' ? 'Yapay zekâ' : content.source == 'demo' ? 'Demo' : 'Yerel içerik'}',
                    style: AppTextStyles.caption(tokens)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: content.message));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mesaj kopyalandı.')));
              }
            },
            icon: Icon(PhosphorIcons.copy()),
            label: const Text('Mesajı kopyala'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;
    final entitlement = ref.read(entitlementServiceProvider);
    final limit = entitlement.limitFor(AppFeature.messageRefresh);
    final dao = ref.read(dailyContentDaoProvider);
    final dateKey = _todayContentKey();
    final saved = await dao.forDate(dateKey);
    final used = saved?.regenCount ?? 0;
    if (limit >= 0 && used >= limit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bugünkü yeni mesaj hakkını kullandın.')),
        );
      }
      return;
    }
    setState(() => _refreshing = true);
    try {
      final service = ref.read(aiContentServiceProvider);
      final result = await service.generateDailyMessage(
        sign: profile.zodiacSign,
        tone: profile.tone,
        localDate: dateKey,
        recentContentKeys:
            await dao.recentContentKeys(AppLimits.contentNoRepeatDays),
        personalSalt: ref.read(userProfileRepositoryProvider).contentSalt,
      );
      if (result is! ServiceSuccess<DailyContentResult>) {
        throw StateError('Yeni içerik üretilemedi.');
      }
      final data = result.data;
      await dao.upsert(DailyContentTableCompanion.insert(
        localDate: dateKey,
        message: data.message,
        affirmation: data.affirmation,
        reflectionPrompt: Value(data.reflectionPrompt),
        source: Value(data.source.name),
        contentKey: Value(data.contentKey),
        regenCount: Value(used + 1),
      ));
      if (!mounted) return;
      setState(() {
        _refreshedContent = TodayContent(
          message: data.message,
          affirmation: data.affirmation,
          reflectionPrompt: data.reflectionPrompt,
          source: data.source.name,
          contentKey: data.contentKey,
        );
        _refreshing = false;
      });
      ref.invalidate(todayContentProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _refreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Yeni mesaj yüklenemedi. Tekrar deneyebilirsin.')),
      );
    }
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
  }

  String _todayContentKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
