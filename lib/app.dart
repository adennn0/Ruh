import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'data/repositories/user_profile_repository.dart';

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
    final themeIdStr = profile?.themeId ?? 'amethystAurora';
    final themeId = AppThemeId.values.firstWhere(
      (t) => t.name == themeIdStr,
      orElse: () => AppThemeId.amethystAurora,
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
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.5),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
