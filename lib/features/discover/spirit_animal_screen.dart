import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../core/entitlement/entitlement_service.dart';

class SpiritAnimalScreen extends ConsumerWidget {
  const SpiritAnimalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final profile = ref.watch(userProfileProvider);
    final entitlementService = ref.watch(entitlementServiceProvider);
    final hasPremiumContent =
        entitlementService.isFeatureAvailable(AppFeature.deepAnimalReading);
    final astrologyEngine = ref.watch(astrologyEngineProvider);

    if (profile == null) {
      return Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(backgroundColor: tokens.background, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sign = profile.zodiacSign;
    final period = profile.spiritAnimalPeriod;
    final animalName = astrologyEngine.spiritAnimalName(sign, period);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        title: Text('Ruh Hayvanın', style: AppTextStyles.h2(tokens)),
        iconTheme: IconThemeData(color: tokens.onBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!profile.birthTimeKnown)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.glassStroke),
                ),
                child: Text(
                  'Doğum saati bilinmediği için ana ruh hayvanı formu (Gün) gösterilmektedir.',
                  style: AppTextStyles.caption(tokens)
                      .copyWith(color: tokens.onSurfaceSubtle),
                ),
              ),
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
                      animalName,
                      style: AppTextStyles.h1(tokens)
                          .copyWith(color: const Color(0xFFFFFFFF)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asset: animals/${sign.name}_${period.name}.webp',
                      style: AppTextStyles.labelSmall(tokens)
                          .copyWith(color: const Color(0xB3FFFFFF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              animalName,
              style: AppTextStyles.displayMedium(tokens),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getAnimalDescription(sign, period),
              style: AppTextStyles.bodyLarge(tokens),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bugünün Hayvan Mesajı',
                      style: AppTextStyles.titleSmall(tokens)),
                  const SizedBox(height: 8),
                  Text(
                    _getDailyMessage(sign),
                    style: AppTextStyles.body(tokens)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CosmicSecondaryButton(
              label: 'Paylaş',
              icon: const Icon(Icons.share, size: 20),
              onPressed: () {
                showCosmicSnackbar(context, 'Paylaşma menüsü açılıyor...');
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Sembolik ve eğlence amaçlıdır.',
              style: AppTextStyles.caption(tokens),
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
                        Text('Derin Okuma ve Ritüel',
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
                label: 'Derin Okuma ve Ritüel Önerileri',
                sublabel: 'Ruh hayvanınla derin bir bağ kur',
                onPreview: () => context.push('/premium'),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _getAnimalDescription(ZodiacSign sign, SpiritAnimalTimePeriod period) {
    final baseTrait = switch (sign) {
      ZodiacSign.aries =>
        'Şahin, keskin görüşün ve hedefe kilitlenmenin sembolüdür.',
      ZodiacSign.taurus =>
        'Ayı, güçlü köklerin ve sarsılmaz dayanıklılığın temsilcisidir.',
      ZodiacSign.gemini =>
        'Kelebek, değişimin ve zihinsel çevikliğin zarif dansıdır.',
      ZodiacSign.cancer =>
        'Kaplumbağa, korunmanın ve bilgece yavaşlamanın sembolüdür.',
      ZodiacSign.leo => 'Aslan, cesaretin ve liderliğin parlayan ruhudur.',
      ZodiacSign.virgo =>
        'Baykuş, derin bilgeliğin ve detayları görme yeteneğinin ustasıdır.',
      ZodiacSign.libra =>
        'Kuğu, içsel zarafetin ve uyumlu bağların temsilcisidir.',
      ZodiacSign.scorpio =>
        'Yılan, kabuk değiştirmenin ve derin dönüşümün sembolüdür.',
      ZodiacSign.sagittarius =>
        'At, özgürlüğün ve yeni ufuklara koşmanın ruhudur.',
      ZodiacSign.capricorn =>
        'Dağ Keçisi, zirveye ulaşma azminin ve dengenin sembolüdür.',
      ZodiacSign.aquarius =>
        'Kuzgun, vizyoner bakış açısının ve zekanın temsilcisidir.',
      ZodiacSign.pisces =>
        'Yunus, empatinin ve duygu denizlerinde neşeyle yüzmenin sembolüdür.',
    };

    final periodTrait = switch (period) {
      SpiritAnimalTimePeriod.dawn =>
        'Şafak vakti doğan bu ruh, sana her gün yeni bir başlangıç yapma hevesi ve taze bir umut enerjisi verir.',
      SpiritAnimalTimePeriod.day =>
        'Gün ışığında parlayan bu ruh, yeteneklerini dışa vurma ve cesurca harekete geçme gücünü taşır.',
      SpiritAnimalTimePeriod.evening =>
        'Akşamın kızıllığında beliren bu ruh, günün deneyimlerini bilgeliğe dönüştürme ve dengede kalma yeteneği sunar.',
      SpiritAnimalTimePeriod.night =>
        'Gece karanlığında süzülen bu ruh, sezgilerinin derinliklerine inme ve rüyalarının rehberliğini anlama yetisi katar.',
    };

    return '$baseTrait $periodTrait';
  }

  String _getDailyMessage(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return 'İçindeki ateşi yak; bugün bir adım at.';
      case ZodiacSign.taurus:
        return 'Köklerine güven; sabrın seni hedefe taşıyacak.';
      case ZodiacSign.gemini:
        return 'Merakını serbest bırak; bugün yeni bir şey öğren.';
      case ZodiacSign.cancer:
        return 'Sezgilerin doğru söylüyor; kalbini dinle.';
      case ZodiacSign.leo:
        return 'Işığını saklama; bugün sahnede olma sırası sende.';
      case ZodiacSign.virgo:
        return 'Detaylardaki güzelliği fark et; her şey yerli yerinde.';
      case ZodiacSign.libra:
        return 'Dengeyi bul; içsel uyumun dışına yansıyacak.';
      case ZodiacSign.scorpio:
        return 'Eskiyi bırak; yeninin doğmasına izin ver.';
      case ZodiacSign.sagittarius:
        return 'Ufkunu genişlet; sınırlarını aşmanın tam zamanı.';
      case ZodiacSign.capricorn:
        return 'Zirve yolculuğun devam ediyor; kararlılığını koru.';
      case ZodiacSign.aquarius:
        return 'Farklı düşün; senin vizyonuna ihtiyaç var.';
      case ZodiacSign.pisces:
        return 'Akışa teslim ol; evren seni doğru yere götürüyor.';
    }
  }
}
