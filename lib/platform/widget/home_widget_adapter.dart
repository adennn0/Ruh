import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  Future<void> updateSnapshot(WidgetSnapshot snapshot) async {
    // TODO Aşama 5B: home_widget paketi
    // Güvenlik: günlük metni, niyet ve kişisel bilgi asla buraya gelmez
  }

  @override
  Future<void> refresh() async {
    // TODO Aşama 5B
  }
}

final homeWidgetAdapterProvider = Provider<HomeWidgetAdapter>((ref) {
  return HomeWidgetAdapterImpl();
});
