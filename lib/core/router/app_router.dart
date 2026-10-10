import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/guide/guide_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/notification_settings_screen.dart';
import '../../features/time_moment/time_moment_screen.dart';
import '../../features/breath/breath_screen.dart';
import '../../widgets/scaffold_with_nav_bar.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../theme/theme.dart';

/// Uygulama route isimleri
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const journal = '/journal';
  static const guide = '/guide';
  static const discover = '/discover';
  static const profile = '/profile';
  static const notificationSettings = '/profile/notifications';
  static const timeMoment = '/time-moment';
  static const breath = '/breath';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash → onboarding veya home
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashRedirect(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.timeMoment,
        builder: (context, state) => const TimeMomentScreen(),
      ),
      GoRoute(
        path: AppRoutes.breath,
        builder: (context, state) => const BreathScreen(),
      ),
      // 5 sekmeli ana yapı
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.guide,
                builder: (context, state) => const GuideScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Onboarding tamamlandıysa → Home, değilse → Onboarding
class _SplashRedirect extends ConsumerWidget {
  const _SplashRedirect();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(userProfileRepositoryProvider);

    return FutureBuilder<void>(
      future: Future<void>.delayed(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (repo.onboardingDone) {
              context.go(AppRoutes.home);
            } else {
              context.go(AppRoutes.onboarding);
            }
          });
        }
        return const Scaffold(
          body: Center(child: _SplashBody()),
        );
      },
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: tokens?.accentPrimary,
        ),
        const SizedBox(height: 16),
        if (tokens != null)
          Text(
            'Ruhun Parlıyor',
            style: AppTextStyles.title(tokens),
          ),
      ],
    );
  }
}
