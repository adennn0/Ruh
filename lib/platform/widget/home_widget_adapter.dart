import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';

/// Ana ekran widget'ı adaptörü (home_widget — Aşama 5B)
/// WidgetSnapshot veri sözleşmesi platformdan bağımsız tanımlanır.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.localDate,
    required this.headline,
    required this.body,
    this.moonPhaseLabel,
    this.streakCount,
    required this.themeId,
    required this.accentColors,
    required this.privacyMode,
    required this.contentSource,
  });

  final String localDate; // "YYYY-MM-DD"
  final String headline; // Kısa olumlama
  final String body; // Günün mesajı önizlemesi
  final String? moonPhaseLabel;
  final int? streakCount; // Yalnızca showStreak açıksa
  final String themeId;
  final List<String> accentColors; // Hex renk kodları
  final bool privacyMode; // true: kişisel veri gösterilmez
  final String contentSource; // ai | local | demo
}

abstract class HomeWidgetAdapter {
  /// Widget snapshot'ı güncelle
  Future<void> updateSnapshot(WidgetSnapshot snapshot);

  /// Widget'ları yenile
  Future<void> refresh();
}

class HomeWidgetAdapterImpl implements HomeWidgetAdapter {
  static const widgetProviderName =
      'com.ruhunparliyor.ruhun_parliyor.RuhunParliyorWidgetProvider';
  String? _lastSnapshot;

  @override
  Future<void> updateSnapshot(WidgetSnapshot snapshot) async {
    try {
      final serialized = jsonEncode({
        'localDate': snapshot.localDate,
        'headline': snapshot.headline,
        'body': snapshot.body,
        'moonPhaseLabel': snapshot.moonPhaseLabel,
        'streakCount': snapshot.streakCount,
        'themeId': snapshot.themeId,
        'accentColors': snapshot.accentColors,
        'privacyMode': snapshot.privacyMode,
        'contentSource': snapshot.contentSource,
      });
      if (_lastSnapshot == serialized) return;

      await HomeWidget.saveWidgetData<String>('localDate', snapshot.localDate);
      await HomeWidget.saveWidgetData<String>('headline', snapshot.headline);
      await HomeWidget.saveWidgetData<String>('body', snapshot.body);
      await HomeWidget.saveWidgetData<String>(
        'moonPhaseLabel',
        snapshot.moonPhaseLabel ?? '',
      );
      await HomeWidget.saveWidgetData<int>('streakCount', snapshot.streakCount);
      await HomeWidget.saveWidgetData<String>('themeId', snapshot.themeId);
      await HomeWidget.saveWidgetData<String>(
        'accentColors',
        snapshot.accentColors.join(','),
      );
      await HomeWidget.saveWidgetData<bool>(
          'privacyMode', snapshot.privacyMode);
      await HomeWidget.saveWidgetData<String>(
        'contentSource',
        snapshot.contentSource,
      );
      await refresh();
      _lastSnapshot = serialized;
    } on MissingPluginException catch (error) {
      debugPrint('Home widget plugin is unavailable: $error');
    } on PlatformException catch (error) {
      debugPrint('Home widget update failed: $error');
    }
  }

  @override
  Future<void> refresh() async {
    if (!Platform.isAndroid) return;
    await HomeWidget.updateWidget(qualifiedAndroidName: widgetProviderName);
    final now = DateTime.now();
    final nextLocalMidnights = List.generate(
      7,
      (offset) => DateTime(now.year, now.month, now.day + offset + 1, 0, 5),
    );
    await HomeWidget.scheduleWidgetUpdates(
      nextLocalMidnights,
      qualifiedAndroidName: widgetProviderName,
    );
  }
}

final homeWidgetAdapterProvider = Provider<HomeWidgetAdapter>((ref) {
  return HomeWidgetAdapterImpl();
});
