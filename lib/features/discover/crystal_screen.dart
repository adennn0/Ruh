import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../core/entitlement/entitlement_service.dart';

class CrystalScreen extends ConsumerWidget {
  const CrystalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final entitlementService = ref.watch(entitlementServiceProvider);
    final hasPremiumContent =
        entitlementService.isFeatureAvailable(AppFeature.moonRisingStone);

    if (profile == null) {
      return Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(backgroundColor: tokens.background, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sign = profile.zodiacSign;
    final crystalName = sign.primaryStone;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        title: Text('Doğal Taşın', style: AppTextStyles.h2(tokens)),
        iconTheme: IconThemeData(color: tokens.onBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area placeholder
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: tokens.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crystalName,
                      style: AppTextStyles.h1(tokens)
                          .copyWith(color: const Color(0xFFFFFFFF)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asset: gems/${sign.name}.webp',
                      style: AppTextStyles.labelSmall(tokens)
                          .copyWith(color: const Color(0xB3FFFFFF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              crystalName,
              style: AppTextStyles.displayMedium(tokens),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getCrystalDescription(sign),
              style: AppTextStyles.bodyLarge(tokens),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nasıl Kullanılır?',
                      style: AppTextStyles.titleSmall(tokens)),
                  const SizedBox(height: 8),
                  Text(
                    _getUsageSuggestion(sign),
                    style: AppTextStyles.body(tokens),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CosmicPrimaryButton(
              label: 'Bu taşı niyetime bağla',
              onPressed: () {
                // TODO: Navigate to Journal -> Niyetler tab
                showCosmicSnackbar(context, 'Niyetlere yönlendiriliyor...');
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Sembolik ve eğlence amaçlıdır. Tıbbi veya tedavi edici bir özelliği yoktur.',
              style: AppTextStyles.caption(tokens)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasPremiumContent)
              CosmicCard(
                borderColor: tokens.premiumBadge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PremiumBadge(compact: true),
                        const SizedBox(width: 8),
                        Text('Ay ve Yükselen Taşları',
                            style: AppTextStyles.titleSmall(tokens)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Premium özellik (Aktif)',
                        style: AppTextStyles.body(tokens)),
                  ],
                ),
              )
            else
              LockedPremiumCard(
                label: 'Ay ve Yükselen Taşları',
                sublabel: 'Diğer burçlarının taşlarını keşfet',
                onPreview: () => context.push('/premium'),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _getCrystalDescription(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return 'Kırmızı Yaspis, cesaretin ve içsel ateşin sembolüdür. Yeni başlangıçlarda sana güç ve kararlılık enerjisi taşır.';
      case ZodiacSign.taurus:
        return 'Gül Kuvars, koşulsuz sevginin ve şefkatin taşıdır. Kalbini güzelliklere ve içsel huzura açmanı temsil eder.';
      case ZodiacSign.gemini:
        return 'Akik, denge ve uyumun sembolüdür. Zihinsel odaklanmayı artırdığına ve iletişimi güçlendirdiğine inanılır.';
      case ZodiacSign.cancer:
        return 'Ay Taşı, sezgilerin ve içsel bilgeliğin yansımasıdır. Duygusal dalgalanmalarda sakin kalmayı sembolize eder.';
      case ZodiacSign.leo:
        return 'Kaplan Gözü, özgüvenin ve kişisel gücün taşıdır. Karşılaştığın zorlukları cesaretle aşmanı temsil eder.';
      case ZodiacSign.virgo:
        return 'Yeşil Aventurin, şansın ve büyümenin sembolüdür. Doğanın sakinleştirici enerjisini ruhuna taşır.';
      case ZodiacSign.libra:
        return 'Opal, umut ve uyumun ışıldayan taşıdır. Hayatındaki dengeyi bulmanı ve ilhamı çekmeni sembolize eder.';
      case ZodiacSign.scorpio:
        return 'Obsidyen, korunmanın ve derin dönüşümün taşıdır. İçindeki gizli gücü açığa çıkarmanı temsil eder.';
      case ZodiacSign.sagittarius:
        return 'Turkuaz, maceranın ve bilgeliğin sembolüdür. Evrensel bağları ve açık fikirli olmayı temsil eder.';
      case ZodiacSign.capricorn:
        return 'Oniks, dayanıklılığın ve odaklanmanın taşıdır. Hedeflerine yürürken güçlü kalmanı sembolize eder.';
      case ZodiacSign.aquarius:
        return 'Ametist, ruhsal farkındalığın ve içsel vizyonun taşıdır. Zihnini sakinleştirip büyük resmi görmeni temsil eder.';
      case ZodiacSign.pisces:
        return 'Akuamarin, okyanusların huzurunu ruhuna taşır. Derin empatinin ve akışta kalmanın sembolüdür.';
    }
  }

  String _getUsageSuggestion(ZodiacSign sign) {
    return 'Bu taşı niyetlerine odaklanırken elinde tutabilir veya göz önünde bulundurarak ilham alabilirsin.';
  }
}
