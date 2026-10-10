import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paylaşım adaptörü (share_plus)
abstract class SharingAdapter {
  Future<void> shareText(String text, {String? subject});
  Future<void> shareImage(String filePath, {String? text});
}

class SharePlusAdapter implements SharingAdapter {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    // TODO Aşama 3: share_plus
  }

  @override
  Future<void> shareImage(String filePath, {String? text}) async {
    // TODO Aşama 3
  }
}

final sharingAdapterProvider = Provider<SharingAdapter>((ref) {
  return SharePlusAdapter();
});
