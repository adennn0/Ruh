import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:share_plus/share_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/theme.dart';
import '../../core/entitlement/entitlement.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../widgets/cosmic_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final String _version = '1.0.0 (Geliştirme)';

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
                ContentSourceBadge(
                    label: profile.zodiacSign.name.toUpperCase()),
                const SizedBox(height: 24),

                // Bilgilerim
                buildSectionTitle('Bilgilerim'),
                buildListTile(
                  title: 'Doğum Bilgileri',
                  icon: PhosphorIcons.calendar(),
                  subtitle:
                      '${profile.birthDate.day}/${profile.birthDate.month}/${profile.birthDate.year}',
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Hitap Adı',
                  icon: PhosphorIcons.user(),
                  subtitle: profile.displayName ?? 'Kozmik Yolcu',
                  onTap: () {},
                ),

                // Kozmik Kimliğim
                buildSectionTitle('Kozmik Kimliğim'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CosmicChip(label: 'Burç: ${profile.zodiacSign.name}'),
                      const CosmicChip(label: 'Element: Ateş'),
                      const CosmicChip(label: 'Gezegen: Mars'),
                      const CosmicChip(label: 'Taş: Yakut'),
                    ],
                  ),
                ),

                buildSectionTitle('Tercihler'),
                buildListTile(
                  title: 'Mesaj Tonu',
                  icon: PhosphorIcons.chatCircle(),
                  subtitle: profile.tone.displayName,
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Tema',
                  icon: PhosphorIcons.palette(),
                  subtitle: profile.themeId,
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Işık Serisi',
                  icon: PhosphorIcons.fire(),
                  subtitle: '7 Günlük Seri',
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Kedim',
                  icon: PhosphorIcons.cat(),
                  isSoon: true,
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
                  value: true,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  title: Text('Niyetlerimi bilsin',
                      style: AppTextStyles.body(tokens)),
                  value: true,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) {},
                ),
                buildListTile(
                  title: 'Sohbet geçmişini sil',
                  icon: PhosphorIcons.trash(),
                  onTap: () {},
                ),

                buildSectionTitle('Hesap ve Güvenlik'),
                buildListTile(
                  title: 'Premium',
                  icon: PhosphorIcons.star(),
                  trailing: const PremiumBadge(compact: true),
                  isSoon: true,
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
                  value: false,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  title: Text('Titreşim', style: AppTextStyles.body(tokens)),
                  value: true,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  title: Text('Widget gizli mod',
                      style: AppTextStyles.body(tokens)),
                  value: false,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (val) {},
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
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Kullanım Koşulları',
                  icon: PhosphorIcons.fileText(),
                  onTap: () {},
                ),
                buildListTile(
                  title: 'Geri bildirim gönder',
                  icon: PhosphorIcons.envelopeSimple(),
                  onTap: () {},
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
