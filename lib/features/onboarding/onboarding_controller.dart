import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/enums.dart';

/// Onboarding form state — tüm adımları tutar
class OnboardingState {
  const OnboardingState({
    this.currentStep = 0, // 0=rıza, 1=doğum, 2=kimlik, 3=ton
    this.consentGiven = false,
    this.birthDate,
    this.birthTimeKnown = false,
    this.birthHour,
    this.birthMinute,
    this.displayName,
    this.selectedTone = MessageTone.spiritual,
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentStep;
  final bool consentGiven;
  final DateTime? birthDate;
  final bool birthTimeKnown;
  final int? birthHour;
  final int? birthMinute;
  final String? displayName;
  final MessageTone selectedTone;
  final bool isLoading;
  final String? errorMessage;

  bool get hasBirthDate => birthDate != null;

  bool get canProceedFromStep1 {
    if (!hasBirthDate) return false;
    // Saat bilinmiyorsa da geçişe izin ver (spec Bölüm 7)
    return true;
  }

  OnboardingState copyWith({
    int? currentStep,
    bool? consentGiven,
    DateTime? birthDate,
    bool? birthTimeKnown,
    int? birthHour,
    int? birthMinute,
    String? displayName,
    MessageTone? selectedTone,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      consentGiven: consentGiven ?? this.consentGiven,
      birthDate: birthDate ?? this.birthDate,
      birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      displayName: displayName ?? this.displayName,
      selectedTone: selectedTone ?? this.selectedTone,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repo) : super(const OnboardingState());

  final UserProfileRepository _repo;

  void acceptConsent() {
    state = state.copyWith(consentGiven: true, currentStep: 1);
    _repo.saveConsent();
  }

  void setBirthDate(DateTime date) {
    // Gelecek tarih yasak
    final today = DateTime.now();
    if (date.isAfter(today)) {
      state = state.copyWith(
        errorMessage: 'Gelecek bir tarih seçilemez.',
      );
      return;
    }
    // 16 yaş kontrolü (spec: 16+)
    final minAge = DateTime(today.year - 16, today.month, today.day);
    if (date.isAfter(minAge)) {
      state = state.copyWith(
        errorMessage: 'Bu uygulama 16 yaş ve üzeri içindir.',
      );
      return;
    }
    state = state.copyWith(
      birthDate: date,
      clearError: true,
    );
  }

  void setBirthTime(int hour, int minute) {
    state = state.copyWith(
      birthTimeKnown: true,
      birthHour: hour,
      birthMinute: minute,
      clearError: true,
    );
  }

  void setTimeUnknown() {
    state = state.copyWith(
      birthTimeKnown: false,
      birthHour: null,
      birthMinute: null,
      clearError: true,
    );
  }

  void setDisplayName(String? name) {
    state = state.copyWith(
        displayName: name?.trim().isEmpty == true ? null : name?.trim());
  }

  void setTone(MessageTone tone) {
    state = state.copyWith(selectedTone: tone);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  void goBack() {
    if (state.currentStep > 0) {
      state =
          state.copyWith(currentStep: state.currentStep - 1, clearError: true);
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final profile = UserProfile(
      birthDate: state.birthDate!,
      birthTimeKnown: state.birthTimeKnown,
      birthHour: state.birthHour,
      birthMinute: state.birthMinute,
      displayName: state.displayName,
      tone: state.selectedTone,
      themeId: 'amethystAurora',
    );
    await _repo.saveProfile(profile);
    state = state.copyWith(isLoading: false, currentStep: 4); // 4 = done
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return OnboardingController(repo);
});
