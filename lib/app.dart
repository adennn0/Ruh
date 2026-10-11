import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'core/preferences/app_preferences.dart';
import 'data/repositories/user_profile_repository.dart';
import 'domain/services/notification_scheduler.dart';

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
