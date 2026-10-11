import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/preferences/app_preferences.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/streak_repository.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../widgets/cosmic_widgets.dart';
import 'companion_profile.dart';
import 'companion_avatar.dart';

class CompanionScreen extends ConsumerStatefulWidget {
  const CompanionScreen({super.key});

  @override
  ConsumerState<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<CompanionScreen> {
  bool _sparkle = false;

  Future<void> _save(CompanionProfile next) async {
    await saveCompanionProfile(ref, next);
  }

  Future<void> _editName(CompanionProfile companion) async {
    final controller = TextEditingController(text: companion.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eşlikçine bir ad ver'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          decoration: const InputDecoration(labelText: 'Ad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    await _save(companion.copyWith(name: name));
  }

  Future<void> _chooseSpecies(CompanionProfile companion) async {
    final animals = ZodiacSign.values
        .map((sign) => sign.primarySpiritAnimal)
        .toSet()
        .toList();
    final species = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Hayvan türünü seç',
                style: AppTextStyles.h2(
                    Theme.of(context).extension<CosmicTokens>()!),
              ),
            ),
            for (final animal in animals)
              ListTile(
                title: Text(animal),
                trailing: animal == companion.species
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, animal),
              ),
          ],
        ),
      ),
    );
    if (species == null || !mounted) return;
    await _save(companion.copyWith(species: species));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final companion = ref.watch(companionProfileProvider);
    final streak = ref.watch(streakResultProvider).valueOrNull;
    final longestStreak = streak?.longestStreak ?? 0;
    final reduceMotion = ref.watch(reduceMotionProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text('Kişisel Eşlikçim', style: AppTextStyles.h2(tokens)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Semantics(
            label: '${companion.name}, ${companion.species} eşlikçin',
            child: GestureDetector(
              onTap: () {
                if (hapticsEnabled) HapticFeedback.lightImpact();
                setState(() => _sparkle = !_sparkle);
              },
              child: CosmicCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: tokens.accentPrimary.withValues(alpha: _sparkle ? .2 : .08),
                          blurRadius: _sparkle ? 18 : 8,
                        )],
                      ),
                      child: CompanionAvatar(
                        profile: companion,
                        tokens: tokens,
                        size: 148,
                        glow: _sparkle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(companion.name, style: AppTextStyles.h1(tokens)),
                    const SizedBox(height: 4),
                    Text(companion.species, style: AppTextStyles.body(tokens)),
                    const SizedBox(height: 8),
                    Text(
                      _sparkle
                          ? 'Burada, sana eşlik ediyor.'
                          : 'Dokununca küçük bir parıltı belirir.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(tokens),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Eşlikçini tanımla', style: AppTextStyles.title(tokens)),
          const SizedBox(height: 8),
          _SettingsTile(
            title: 'Adı',
            subtitle: companion.name,
            icon: PhosphorIcons.textAa(),
            onTap: () => _editName(companion),
          ),
          _SettingsTile(
            title: 'Hayvan türü',
            subtitle: companion.species,
            icon: PhosphorIcons.pawPrint(),
            onTap: () => _chooseSpecies(companion),
          ),
          const SizedBox(height: 16),
          Text('Görünüm', style: AppTextStyles.title(tokens)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final coat in ['Lavanta', 'Ametist', 'İnci', 'Gümüş'])
                ChoiceChip(
                  label: Text(coat),
                  selected: companion.coat == coat,
                  onSelected: (_) => _save(companion.copyWith(coat: coat)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Göz rengi', style: AppTextStyles.titleSmall(tokens)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in ['Ametist', 'Turkuaz', 'İnci', 'Gümüş'])
                ChoiceChip(
                  label: Text(color),
                  selected: companion.eyeColor == color,
                  onSelected: (_) => _save(companion.copyWith(eyeColor: color)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Kozmetik koleksiyonu', style: AppTextStyles.title(tokens)),
          const SizedBox(height: 4),
          Text(
            'Açılımlar yalnızca görünümü değiştirir. Ulaştığın eşyalar kalıcıdır.',
            style: AppTextStyles.caption(tokens),
          ),
          const SizedBox(height: 8),
          for (final cosmetic in companionCosmetics)
            _CosmeticTile(
              cosmetic: cosmetic,
              unlocked: cosmetic.isUnlocked(longestStreak),
              equipped: companion.equippedItems[cosmetic.slot] == cosmetic.id,
              tokens: tokens,
              onTap: cosmetic.isUnlocked(longestStreak)
                  ? () {
                      final items = Map<String, String>.from(companion.equippedItems);
                      if (items[cosmetic.slot] == cosmetic.id) {
                        items.remove(cosmetic.slot);
                      } else {
                        items[cosmetic.slot] = cosmetic.id;
                      }
                      _save(companion.copyWith(
                        equippedCosmetic: cosmetic.id,
                        equippedItems: items,
                      ));
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Card(
      color: tokens.surface,
      child: ListTile(
        //minTileHeight: 56,
        leading: Icon(icon, color: tokens.accentPrimary),
        title: Text(title, style: AppTextStyles.body(tokens)),
        subtitle: Text(subtitle, style: AppTextStyles.caption(tokens)),
        trailing:
            Icon(PhosphorIcons.caretRight(), color: tokens.onSurfaceMuted),
        onTap: onTap,
      ),
    );
  }
}

class _CosmeticTile extends StatelessWidget {
  const _CosmeticTile({
    required this.cosmetic,
    required this.unlocked,
    required this.equipped,
    required this.tokens,
    required this.onTap,
  });

  final CompanionCosmetic cosmetic;
  final bool unlocked;
  final bool equipped;
  final CosmicTokens tokens;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: tokens.surface,
        child: ListTile(
          //minTileHeight: 56,
          leading: Icon(
            unlocked ? PhosphorIcons.sparkle() : PhosphorIcons.lockKey(),
            color: unlocked ? tokens.accentPrimary : tokens.onSurfaceMuted,
          ),
          title: Text(cosmetic.name, style: AppTextStyles.body(tokens)),
          subtitle: Text(
            '${cosmetic.slot} · ${unlocked ? cosmetic.description : 'Seri: ${cosmetic.milestone} gün'}',
            style: AppTextStyles.caption(tokens),
          ),
          trailing: equipped
              ? Icon(PhosphorIcons.check(), color: tokens.successColor)
              : null,
          enabled: unlocked,
          onTap: onTap,
        ),
      );
}
