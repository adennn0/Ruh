import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/theme.dart';
import '../../core/entitlement/entitlement.dart';
import '../../core/preferences/app_preferences.dart';
import '../../data/repositories/streak_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../features/home/home_screen.dart';
import '../companion/companion_profile.dart';
import '../../widgets/cosmic_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final String _version = '1.0.0 (Geliştirme)';

  Future<void> _saveProfile(UserProfile profile) async {
    await ref.read(userProfileRepositoryProvider).saveProfile(profile);
    ref.read(userProfileProvider.notifier).state = profile;
    ref.invalidate(todayContentProvider);
    await rebuildNotificationWindow(ref);
  }

  Future<void> _editDisplayName(UserProfile profile) async {
    final controller = TextEditingController(text: profile.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hitap Adı'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration:
              const InputDecoration(labelText: 'Sana nasıl hitap edelim?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    await ref.read(userProfileRepositoryProvider).saveDisplayName(name);
    final updated = ref.read(userProfileRepositoryProvider).loadProfile();
    if (updated == null) return;
    ref.read(userProfileProvider.notifier).state = updated;
  }

  Future<void> _editBirthDate(UserProfile profile) async {
    final date = await showDatePicker(
      context: context,
      initialDate: profile.birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum tarihini seç',
    );
    if (date == null) return;
    await _saveProfile(profile.copyWith(birthDate: date));
  }

  Future<void> _selectTone(UserProfile profile) async {
    final tone = await showModalBottomSheet<MessageTone>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tone in MessageTone.values)
              ListTile(
                title: Text(tone.displayName),
                subtitle: Text(tone.subtitle),
                trailing: tone == profile.tone ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, tone),
              ),
          ],
        ),
      ),
    );
    if (tone == null) return;
    await _saveProfile(profile.copyWith(tone: tone));
  }

  Future<void> _selectTheme(UserProfile profile, bool isPremium) async {
    final theme = await showModalBottomSheet<AppThemeId>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).extension<CosmicTokens>()!.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .82,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<CosmicTokens>()!
                      .onSurfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Görünümünü seç',
                    style: AppTextStyles.h2(
                      Theme.of(context).extension<CosmicTokens>()!,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppThemeId.values.length,
                  itemBuilder: (context, index) {
                    final theme = AppThemeId.values[index];
                    return ListTile(
                      minTileHeight: 64,
                      title: Text(theme.displayName),
                      subtitle: Text(theme.description),
                      trailing: theme.name == profile.themeId
                          ? const Icon(Icons.check)
                          : theme.isPremium
                              ? const PremiumBadge(compact: true)
                              : null,
                      onTap: theme.isPremium && !isPremium
                          ? null
                          : () => Navigator.pop(context, theme),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (theme == null) return;
    await _saveProfile(profile.copyWith(themeId: theme.name));
  }

  void _showStreak(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final streak = ref.read(streakResultProvider).valueOrNull;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Işık Serin', style: AppTextStyles.h2(tokens)),
        content: Text(
          streak == null
              ? 'Seri bilgisi şu anda yüklenemedi.'
              : 'Mevcut seri: ${streak.currentStreak} gün\n'
                  'En uzun seri: ${streak.longestStreak} gün\n'
                  'Toplam ışık günü: ${streak.totalDays}',
          style: AppTextStyles.body(tokens),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteChatHistory() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sohbet geçmişi silinsin mi?'),
        content: const Text(
            'Bu işlem kayıtlı sohbet mesajlarını kalıcı olarak siler.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sil')),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await ref
        .read(appDatabaseProvider)
        .delete(ref.read(appDatabaseProvider).chatMessageTable)
        .go();
    if (mounted) showCosmicSnackbar(context, 'Sohbet geçmişi silindi.');
  }

  void _showAboutDialog(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat'))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _exportData(WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    final data = {
      'displayName': profile.displayName,
      'birthDate': profile.birthDate.toIso8601String(),
      'birthHour': profile.birthHour,
      'birthMinute': profile.birthMinute,
      'tone': profile.tone.name,
      'themeId': profile.themeId,
      'companion': ref.read(companionProfileProvider).toJson(),
    };

    final jsonStr = jsonEncode(data);
    await Share.share(jsonStr, subject: 'Ruhun Parlıyor - Verilerim');
  }

  void _deleteAllData(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surface,
        title: Text('Tüm Verilerimi Sil', style: AppTextStyles.h2(tokens)),
        content: Text('Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
            style: AppTextStyles.body(tokens)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: AppTextStyles.button(tokens)
                    .copyWith(color: tokens.onSurface)),
          ),
          CosmicDestructiveButton(
            label: 'Sil',
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userProfileRepositoryProvider).clearAll();
              if (context.mounted) {
                // Return to onboarding or exit depending on router
                SystemNavigator.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final birthDataSharing = ref.watch(birthDataSharingProvider);
    final intentionSharing = ref.watch(intentionSharingProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final widgetPrivacyMode = ref.watch(widgetPrivacyModeProvider);
    final showStreakOnWidget = ref.watch(showStreakOnWidgetProvider);
    final companion = ref.watch(companionProfileProvider);
    final profile = ref.watch(userProfileProvider);
    final isPremium = ref.watch(isPremiumProvider);

    if (profile == null) {
      return Scaffold(
        backgroundColor: tokens.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(title,
            style: AppTextStyles.labelLarge(tokens)
                .copyWith(color: tokens.accentPrimary)),
      );
    }

    Widget buildListTile({
      required String title,
      IconData? icon,
      Widget? trailing,
      VoidCallback? onTap,
      bool isSoon = false,
      String? subtitle,
    }) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: icon != null
            ? Icon(icon,
                color: isSoon ? tokens.onSurfaceMuted : tokens.onBackground)
            : null,
        title: Text(
          title,
          style: AppTextStyles.bodyLarge(tokens).copyWith(
              color: isSoon ? tokens.onSurfaceMuted : tokens.onBackground),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.caption(tokens))
            : null,
        trailing: trailing ??
            (isSoon
                ? const ContentSourceBadge(label: 'Yakında')
                : const Icon(Icons.chevron_right, color: Colors.grey)),
        onTap: isSoon ? null : onTap,
        enabled: !isSoon,
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text('Profil', style: AppTextStyles.h2(tokens)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: tokens.surfaceElevated,
                  child: Icon(PhosphorIcons.cat(PhosphorIconsStyle.fill),
                      size: 40, color: tokens.accentPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.displayName ?? 'Kozmik Yolcu',
                  style: AppTextStyles.h1(tokens),
                ),
                const SizedBox(height: 8),
                ContentSourceBadge(label: profile.zodiacSign.displayName),
                const SizedBox(height: 24),

                // Bilgilerim
                buildSectionTitle('Bilgilerim'),
                buildListTile(
                  title: 'Doğum Bilgileri',
                  icon: PhosphorIcons.calendar(),
                  subtitle:
                      '${profile.birthDate.day}/${profile.birthDate.month}/${profile.birthDate.year}',
                  onTap: () => _editBirthDate(profile),
                ),
                buildListTile(
                  title: 'Hitap Adı',
                  icon: PhosphorIcons.user(),
                  subtitle: profile.displayName ?? 'Kozmik Yolcu',
                  onTap: () => _editDisplayName(profile),
                ),

                // Kozmik Kimliğim
                buildSectionTitle('Kozmik Kimliğim'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CosmicChip(
                          label: 'Burç: ${profile.zodiacSign.displayName}'),
                      CosmicChip(
                        label:
                            'Element: ${profile.zodiacSign.element.displayName}',
                      ),
                      CosmicChip(
                        label: 'Gezegen: ${profile.zodiacSign.rulingPlanet}',
                      ),
                      CosmicChip(
                        label: 'Taş: ${profile.zodiacSign.primaryStone}',
                      ),
                    ],
                  ),
                ),

                buildSectionTitle('Tercihler'),
                buildListTile(
                  title: 'Mesaj Tonu',
                  icon: PhosphorIcons.chatCircle(),
                  subtitle: profile.tone.displayName,
                  onTap: () => _selectTone(profile),
                ),
                buildListTile(
                  title: 'Tema',
                  icon: PhosphorIcons.palette(),
                  subtitle: profile.themeId,
                  onTap: () => _selectTheme(profile, isPremium),
                ),
                buildListTile(
                  title: 'Işık Serisi',
                  icon: PhosphorIcons.fire(),
                  subtitle: 'Seri ve toplam gün bilgisi',
                  onTap: () => _showStreak(context, ref),
                ),
                buildListTile(
                  title: 'Kişisel Ruh Hayvanım',
                  icon: PhosphorIcons.compass(),
                  subtitle: profile.zodiacSign.primarySpiritAnimal,
                  onTap: () => context.push('/discover/spirit-animal'),
                ),
                buildListTile(
                  title: 'Eşlikçim',
                  icon: PhosphorIcons.pawPrint(),
                  subtitle: '${companion.name} · ${companion.species}',
                  onTap: () => context.push('/companion'),
                ),
                buildListTile(
                  title: 'Bildirimler',
                  icon: PhosphorIcons.bell(),
                  onTap: () => context.push('/profile/notifications'),
                ),

                buildSectionTitle('Rehber Ayarları'),
                SwitchListTile(
                  title: Text('Doğum verimi kullanmasına izin ver',
                      style: AppTextStyles.body(tokens)),
                  value: birthDataSharing,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'ai_use_birth_data', val),
                ),
                SwitchListTile(
                  title: Text('Niyetlerimi bilsin',
                      style: AppTextStyles.body(tokens)),
                  value: intentionSharing,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'ai_know_intentions', val),
                ),
                buildListTile(
                  title: 'Sohbet geçmişini sil',
                  icon: PhosphorIcons.trash(),
                  onTap: _confirmDeleteChatHistory,
                ),

                buildSectionTitle('Hesap ve Güvenlik'),
                buildListTile(
                  title: 'Premium',
                  icon: PhosphorIcons.star(),
                  trailing: const PremiumBadge(compact: true),
                  onTap: () => context.push('/premium'),
                ),
                buildListTile(
                  title: 'Uygulama Kilidi',
                  icon: PhosphorIcons.lock(),
                  isSoon: true,
                ),

                buildSectionTitle('Gizlilik ve Veri'),
                SwitchListTile(
                  title:
                      Text('Hareketi azalt', style: AppTextStyles.body(tokens)),
                  value: reduceMotion,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'reduce_motion', val),
                ),
                SwitchListTile(
                  title: Text('Titreşim', style: AppTextStyles.body(tokens)),
                  value: hapticsEnabled,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'haptics_enabled', val),
                ),
                SwitchListTile(
                  title: Text('Widget gizli mod',
                      style: AppTextStyles.body(tokens)),
                  subtitle: Text(
                    'Açıkken genel bir olumlama gösterilir.',
                    style: AppTextStyles.caption(tokens),
                  ),
                  value: widgetPrivacyMode,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'widget_privacy_mode', val),
                ),
                SwitchListTile(
                  title: Text('Widget’ta Işık Serisini göster',
                      style: AppTextStyles.body(tokens)),
                  value: showStreakOnWidget,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) =>
                      saveBooleanPreference(ref, 'widget_show_streak', val),
                ),
                buildListTile(
                  title: 'Widget ekleme yönergesi',
                  icon: PhosphorIcons.squaresFour(),
                  onTap: () => _showAboutDialog(
                    'Ana ekrana widget ekle',
                    'Telefonunun ana ekranında boş bir alana basılı tut. Widget’lar menüsünü açıp “Ruhun Parlıyor”u bul ve küçük ya da geniş boyutu ana ekrana sürükle. Widget içeriği uygulama açıldığında yenilenir; Android pil ve arka plan sınırları nedeniyle anlık güncelleme garanti edilmez.',
                  ),
                ),
                buildListTile(
                  title: 'Verilerimi Dışa Aktar',
                  icon: PhosphorIcons.export(),
                  onTap: () => _exportData(ref),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(PhosphorIcons.warningCircle(),
                      color: tokens.errorColor),
                  title: Text('Tüm Verilerimi Sil',
                      style: AppTextStyles.bodyLarge(tokens)
                          .copyWith(color: tokens.errorColor)),
                  onTap: () => _deleteAllData(context, ref),
                ),

                buildSectionTitle('Hakkında'),
                buildListTile(
                  title: 'Gizlilik ve KVKK',
                  icon: PhosphorIcons.shieldCheck(),
                  onTap: () => _showAboutDialog(
                    'Gizlilik ve KVKK',
                    'Ruhun Parlıyor’daki günlük içerikler ve astrolojik değerler kişisel rehberlik amacı taşır; kesinlik veya sağlık vaadi sunmaz. Hesap verilerini bu ekrandaki dışa aktarma ve veri silme kontrolleriyle yönetebilirsin.',
                  ),
                ),
                buildListTile(
                  title: 'Kullanım Koşulları',
                  icon: PhosphorIcons.fileText(),
                  onTap: () => _showAboutDialog(
                    'Kullanım Koşulları',
                    'Uygulama geliştirme aşamasındadır. İçerikler kişisel farkındalık ve eğlence amaçlıdır; profesyonel danışmanlık yerine geçmez.',
                  ),
                ),
                buildListTile(
                  title: 'Geri bildirim gönder',
                  icon: PhosphorIcons.envelopeSimple(),
                  onTap: () =>
                      Share.share('Ruhun Parlıyor için geri bildirimim:'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Versiyon $_version',
                      style: AppTextStyles.caption(tokens)),
                ),

                // Debug Section
                if (kDebugMode) // In actual code use kDebugMode, but hardcoding for view
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle('Debug / Geliştirici'),
                      SwitchListTile(
                        title: Text('Premium Aktif',
                            style: AppTextStyles.body(tokens)),
                        value: isPremium,
                        activeTrackColor: tokens.accentPrimary,
                        onChanged: (val) {
                          ref
                              .read(entitlementServiceProvider)
                              .toggleDebugPremium();
                        },
                      ),
                      buildListTile(
                        title: 'Onboarding Sıfırla',
                        icon: PhosphorIcons.arrowCounterClockwise(),
                        onTap: () async {
                          await ref
                              .read(userProfileRepositoryProvider)
                              .clearAll();
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
