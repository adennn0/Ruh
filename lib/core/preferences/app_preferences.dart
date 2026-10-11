import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entitlement/entitlement.dart';

final reduceMotionProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('reduce_motion') ?? false;
});

final hapticsEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('haptics_enabled') ??
      true;
});

final birthDataSharingProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('ai_use_birth_data') ??
      false;
});

final intentionSharingProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('ai_know_intentions') ??
      false;
});

final widgetPrivacyModeProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('widget_privacy_mode') ??
      false;
});

final showStreakOnWidgetProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).getBool('widget_show_streak') ??
      false;
});

Future<void> saveBooleanPreference(
  WidgetRef ref,
  String key,
  bool value,
) async {
  final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
  await prefs.setBool(key, value);
  if (key == 'reduce_motion') {
    ref.read(reduceMotionProvider.notifier).state = value;
  } else if (key == 'haptics_enabled') {
    ref.read(hapticsEnabledProvider.notifier).state = value;
  } else if (key == 'ai_use_birth_data') {
    ref.read(birthDataSharingProvider.notifier).state = value;
  } else if (key == 'ai_know_intentions') {
    ref.read(intentionSharingProvider.notifier).state = value;
  } else if (key == 'widget_privacy_mode') {
    ref.read(widgetPrivacyModeProvider.notifier).state = value;
  } else if (key == 'widget_show_streak') {
    ref.read(showStreakOnWidgetProvider.notifier).state = value;
  }
}
