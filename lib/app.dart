import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'core/preferences/app_preferences.dart';
import 'core/entitlement/entitlement.dart';
import 'data/repositories/intention_repository.dart';
import 'data/repositories/user_profile_repository.dart';
import 'domain/services/notification_scheduler.dart';
import 'features/profile/notification_settings.dart';
import 'features/profile/notification_settings_screen.dart';
import 'platform/notifications/notifications_adapter.dart';

/// Uygulama kök widget'ı.
/// Tema, yerelleştirme ve router burada bağlanır.
/// Tema seçimi kullanıcı profilinden okunur; Aşama 3'te tam ayarlar eklenecek.
class RuhunParliyorApp extends ConsumerWidget {
  const RuhunParliyorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Kullanıcı profili varsa onun tema tercihini kullan
    final profile = ref.watch(userProfileProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final themeIdStr = profile?.themeId ?? 'pearlMoon';
    final themeId = AppThemeId.values.firstWhere(
      (t) => t.name == themeIdStr,
      orElse: () => AppThemeId.pearlMoon,
    );
    final theme = AppThemes.getTheme(themeId);

    return MaterialApp.router(
      title: 'Ruhun Parlıyor',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        // Yazı ölçeği: 0.8–1.5 arası (erişilebilirlik)
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations: mediaQuery.disableAnimations || reduceMotion,
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.5),
            ),
          ),
          child: NotificationBootstrap(child: child!),
        );
      },
    );
  }
}

/// Bildirim izni varsa 7 günlük Saat Anı penceresini kurar; tıklamayı açar.
class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _boot();
    });
  }

  Future<void> _boot() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.attachTapHandler();
    await rebuildNotificationWindow(ref);
    await _maybeRequestNotificationPermission(scheduler);
  }

  Future<void> _maybeRequestNotificationPermission(
    NotificationScheduler scheduler,
  ) async {
    final repository = ref.read(userProfileRepositoryProvider);
    final profile = ref.read(userProfileProvider);
    if (!repository.onboardingDone || profile == null) return;

    final adapter = ref.read(notificationsAdapterProvider);
    if (await adapter.hasPermission()) return;
    if (!mounted) return;

    final settings = ref.read(notificationSettingsProvider);
    final hasAnyReminder = settings.timeMoment ||
        settings.intentionReminder ||
        settings.eveningReview ||
        settings.dailyMessage ||
        settings.pastIntentionReminder ||
        settings.nightReminder;
    if (!hasAnyReminder) return;

    final preferences = ref.read(sharedPreferencesProvider);
    if (preferences.getBool('notification_permission_prompt_seen') == true) {
      return;
    }

    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Saat Anı bildirimlerini açalım mı?'),
        content: const Text(
          'Çift ve palindrom saatlerde kişisel bir durak hatırlatması al. '
          'Niyet metnin kilit ekranında gösterilmez. Bildirim izni istediğinde '
          'hatırlatmaları dilediğin zaman ayarlardan kapatabilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Şimdi değil'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bildirimleri aç'),
          ),
        ],
      ),
    );

    await preferences.setBool('notification_permission_prompt_seen', true);
    if (shouldEnable != true || !mounted) return;

    final intentions =
        await ref.read(intentionRepositoryProvider).watchActive().first;
    final granted = await scheduler.enableAndRebuild(
      profile: profile,
      settings: settings,
      entitlement: ref.read(entitlementServiceProvider),
      personalSalt: repository.contentSalt,
      intentionTitles: intentions.map((item) => item.title).toList(),
      intentions: intentions,
    );
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bildirim izni verilmedi. İstersen Bildirim Ayarları’ndan daha sonra açabilirsin.',
          ),
        ),
      );
      return;
    }
    ref.invalidate(notificationAvailabilityProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      rebuildNotificationWindow(ref);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
