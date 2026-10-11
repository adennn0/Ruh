import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruhun_parliyor/domain/astrology/astrology_engine.dart';
import 'package:ruhun_parliyor/domain/energy/personal_energy_flow.dart';
import 'package:ruhun_parliyor/domain/models/enums.dart';
import 'package:ruhun_parliyor/core/entitlement/entitlement_service.dart';

void main() {
  test('daily flow is stable for a person and date', () {
    final input = (
      date: DateTime(2026, 10, 11),
      sign: ZodiacSign.libra,
      tone: MessageTone.soft,
      salt: 'local-profile-salt',
    );
    final first = PersonalEnergyFlow.forDate(
      date: input.date,
      sign: input.sign,
      tone: input.tone,
      personalSalt: input.salt,
    );
    final second = PersonalEnergyFlow.forDate(
      date: input.date,
      sign: input.sign,
      tone: input.tone,
      personalSalt: input.salt,
    );

    expect(first, hasLength(3));
    expect(
      first
          .map((window) =>
              (window.time, window.energy, window.focus, window.reflection))
          .toList(),
      second
          .map((window) =>
              (window.time, window.energy, window.focus, window.reflection))
          .toList(),
    );
    expect(first.every((window) => window.energy >= 2 && window.energy <= 5),
        isTrue);
    expect(first.every((window) => window.focus >= 2 && window.focus <= 5),
        isTrue);
  });

  test('flow responds to different profile inputs', () {
    final libra = PersonalEnergyFlow.forDate(
      date: DateTime(2026, 10, 11),
      sign: ZodiacSign.libra,
      tone: MessageTone.soft,
      personalSalt: 'one',
    );
    final aries = PersonalEnergyFlow.forDate(
      date: DateTime(2026, 10, 11),
      sign: ZodiacSign.aries,
      tone: MessageTone.strong,
      personalSalt: 'two',
    );
    expect(libra.first.reflection, isNot(aries.first.reflection));
  });

  test('free users get one preview slot and premium users get the full flow',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final entitlement = EntitlementService(preferences);

    expect(entitlement.limitFor(AppFeature.personalEnergyFlow), 1);
    await entitlement.setPremium(active: true);
    expect(entitlement.limitFor(AppFeature.personalEnergyFlow), 3);
  });
}
