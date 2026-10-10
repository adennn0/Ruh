import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';

/// Uygulama kök widget'ı.
/// Tema, yerelleştirme ve router burada bağlanır.
class RuhunParliyorApp extends ConsumerWidget {
  const RuhunParliyorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Tema seçimi Aşama 3'te settings'ten okunacak; şimdilik varsayılan
    const themeId = AppThemeId.amethystAurora;
    final theme = AppThemes.getTheme(themeId);

    return MaterialApp.router(
      title: 'Ruhun Parlıyor',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Koyu tema şimdilik aynı (Pearl Moon kullanıcı seçimi Aşama 3'te)
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
        // Yazı ölçeği: maksimum 1.5 (200% sistem ölçeğine 15sp'nin altına düşmemek için)
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
