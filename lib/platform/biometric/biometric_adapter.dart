import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Biyometrik kilitleme adaptörü (local_auth)
abstract class BiometricAdapter {
  Future<bool> isAvailable();
  Future<bool> authenticate({required String localizedReason});
}

class LocalAuthAdapter implements BiometricAdapter {
  @override
  Future<bool> isAvailable() async {
    // TODO Aşama 3: local_auth paketi
    return false;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    // TODO Aşama 3
    return false;
  }
}

final biometricAdapterProvider = Provider<BiometricAdapter>((ref) {
  return LocalAuthAdapter();
});
