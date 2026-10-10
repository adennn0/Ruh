import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/limits.dart';
import '../../core/entitlement/entitlement.dart';
import '../../widgets/cosmic_widgets.dart';

// --- State Models ---

class NotificationSettings {
  const NotificationSettings({
    this.intentionReminder = false,
    this.intentionTime = const TimeOfDay(hour: 9, minute: 0),
    this.timeMoment = false,
    this.timeMomentTime = const TimeOfDay(hour: 11, minute: 11),
    this.eveningReview = false,
    this.eveningReviewTime = const TimeOfDay(hour: 20, minute: 0),
    this.dailyMessage = false,
    this.dailyMessageTime = const TimeOfDay(hour: 10, minute: 0),
    this.quietHoursStart =
        const TimeOfDay(hour: AppLimits.defaultQuietHoursStart, minute: 0),
    this.quietHoursEnd =
        const TimeOfDay(hour: AppLimits.defaultQuietHoursEnd, minute: 0),
  });

  final bool intentionReminder;
  final TimeOfDay intentionTime;
  final bool timeMoment;
  final TimeOfDay timeMomentTime;
  final bool eveningReview;
  final TimeOfDay eveningReviewTime;
  final bool dailyMessage;
  final TimeOfDay dailyMessageTime;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  int get activeCount {
    int count = 0;
    if (intentionReminder) count++;
    if (timeMoment) count++;
    if (eveningReview) count++;
    if (dailyMessage) count++;
    return count;
  }

  NotificationSettings copyWith({
    bool? intentionReminder,
    TimeOfDay? intentionTime,
    bool? timeMoment,
    TimeOfDay? timeMomentTime,
    bool? eveningReview,
    TimeOfDay? eveningReviewTime,
    bool? dailyMessage,
    TimeOfDay? dailyMessageTime,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      intentionReminder: intentionReminder ?? this.intentionReminder,
      intentionTime: intentionTime ?? this.intentionTime,
      timeMoment: timeMoment ?? this.timeMoment,
      timeMomentTime: timeMomentTime ?? this.timeMomentTime,
      eveningReview: eveningReview ?? this.eveningReview,
      eveningReviewTime: eveningReviewTime ?? this.eveningReviewTime,
      dailyMessage: dailyMessage ?? this.dailyMessage,
      dailyMessageTime: dailyMessageTime ?? this.dailyMessageTime,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

// --- Controller ---

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController(this.prefs)
      : super(const NotificationSettings()) {
    _load();
  }

  final SharedPreferences prefs;

  TimeOfDay _parseTime(String? timeStr, TimeOfDay defaultTime) {
    if (timeStr == null) return defaultTime;
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return defaultTime;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  void _load() {
    state = NotificationSettings(
      intentionReminder: prefs.getBool('notif_intention') ?? false,
      intentionTime: _parseTime(prefs.getString('notif_intention_time'),
          const TimeOfDay(hour: 9, minute: 0)),
      timeMoment: prefs.getBool('notif_time_moment') ?? false,
      timeMomentTime: _parseTime(prefs.getString('notif_time_moment_time'),
          const TimeOfDay(hour: 11, minute: 11)),
      eveningReview: prefs.getBool('notif_evening') ?? false,
      eveningReviewTime: _parseTime(prefs.getString('notif_evening_time'),
          const TimeOfDay(hour: 20, minute: 0)),
      dailyMessage: prefs.getBool('notif_daily_message') ?? false,
      dailyMessageTime: _parseTime(prefs.getString('notif_daily_message_time'),
          const TimeOfDay(hour: 10, minute: 0)),
      quietHoursStart: _parseTime(prefs.getString('notif_quiet_start'),
          const TimeOfDay(hour: 22, minute: 0)),
      quietHoursEnd: _parseTime(prefs.getString('notif_quiet_end'),
          const TimeOfDay(hour: 8, minute: 0)),
    );
  }

  Future<bool> updateToggle(String key, bool value, int limit) async {
    if (value) {
      // check if we are at limit
      if (state.activeCount >= limit) {
        return false;
      }
      // Request permission logic would go here in real app
    }

    await prefs.setBool('notif_$key', value);
    _load();
    return true;
  }

  Future<void> updateTime(String key, TimeOfDay time) async {
    await prefs.setString('notif_${key}_time', _formatTime(time));
    _load();
  }

  Future<void> updateQuietTime(bool isStart, TimeOfDay time) async {
    final key = isStart ? 'notif_quiet_start' : 'notif_quiet_end';
    await prefs.setString(key, _formatTime(time));
    _load();
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
        (ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationSettingsController(prefs);
});

// --- Screen ---

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      void Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        final tokens = Theme.of(context).extension<CosmicTokens>()!;
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: tokens.accentPrimary,
              onSurface: tokens.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final state = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);

    final isPremium = ref.watch(isPremiumProvider);
    final maxLimit = ref
        .watch(entitlementServiceProvider)
        .limitFor(AppFeature.dailyNotifications);

    Widget buildSettingRow({
      required String title,
      required String key,
      required bool value,
      required TimeOfDay time,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: CosmicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall(tokens)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _selectTime(
                          context, time, (t) => controller.updateTime(key, t)),
                      child: Text(
                        time.format(context),
                        style: AppTextStyles.bodyLarge(tokens).copyWith(
                          color: tokens.accentPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeTrackColor: tokens.accentPrimary,
                onChanged: (val) async {
                  final success =
                      await controller.updateToggle(key, val, maxLimit);
                  if (!context.mounted) return;
                  if (!success && val) {
                    showCosmicSnackbar(
                      context,
                      'Limit ulaşıldı! Premium ile daha fazla bildirim ekleyebilirsiniz.',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text('Bildirim Ayarları', style: AppTextStyles.h2(tokens)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bugün aktif bildirimler: ${state.activeCount}/$maxLimit',
              style: AppTextStyles.body(tokens).copyWith(
                color: state.activeCount >= maxLimit && !isPremium
                    ? tokens.errorColor
                    : tokens.onSurface,
              ),
            ),
          ),
          buildSettingRow(
            title: 'Günlük niyet hatırlatıcısı',
            key: 'intention',
            value: state.intentionReminder,
            time: state.intentionTime,
          ),
          buildSettingRow(
            title: 'Saat Anı (11:11)',
            key: 'time_moment',
            value: state.timeMoment,
            time: state.timeMomentTime,
          ),
          buildSettingRow(
            title: 'Akşam değerlendirmesi',
            key: 'evening',
            value: state.eveningReview,
            time: state.eveningReviewTime,
          ),
          buildSettingRow(
            title: 'Günlük mesaj hazır',
            key: 'daily_message',
            value: state.dailyMessage,
            time: state.dailyMessageTime,
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Sessiz Saatler (Rahatsız Etmeyin)',
                style: AppTextStyles.title(tokens)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: CosmicCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => _selectTime(context, state.quietHoursStart,
                        (t) => controller.updateQuietTime(true, t)),
                    child: Column(
                      children: [
                        Text('Başlangıç', style: AppTextStyles.caption(tokens)),
                        Text(state.quietHoursStart.format(context),
                            style: AppTextStyles.titleSmall(tokens)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CosmicCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => _selectTime(context, state.quietHoursEnd,
                        (t) => controller.updateQuietTime(false, t)),
                    child: Column(
                      children: [
                        Text('Bitiş', style: AppTextStyles.caption(tokens)),
                        Text(state.quietHoursEnd.format(context),
                            style: AppTextStyles.titleSmall(tokens)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Not: İzin istemeden hiçbir bildirim planlanmaz.',
              style: AppTextStyles.caption(tokens)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
