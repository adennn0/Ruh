import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entitlement/entitlement.dart';
import '../../data/repositories/user_profile_repository.dart';

class CompanionProfile {
  const CompanionProfile({
    this.name = 'Işık',
    required this.species,
    this.coat = 'Lavanta',
    this.eyeColor = 'Ametist',
    this.equippedCosmetic = 'yildiz-isigi',
    this.equippedItems = const {'aura': 'yildiz-isigi'},
  });

  final String name;
  final String species;
  final String coat;
  final String eyeColor;
  final String equippedCosmetic;
  final Map<String, String> equippedItems;

  CompanionProfile copyWith({
    String? name,
    String? species,
    String? coat,
    String? eyeColor,
    String? equippedCosmetic,
    Map<String, String>? equippedItems,
  }) =>
      CompanionProfile(
        name: name ?? this.name,
        species: species ?? this.species,
        coat: coat ?? this.coat,
        eyeColor: eyeColor ?? this.eyeColor,
        equippedCosmetic: equippedCosmetic ?? this.equippedCosmetic,
        equippedItems: equippedItems ?? this.equippedItems,
      );

  Map<String, Object?> toJson() => {
        'name': name,
        'species': species,
        'coat': coat,
        'eyeColor': eyeColor,
        'equippedCosmetic': equippedCosmetic,
        'equippedItems': equippedItems,
      };

  factory CompanionProfile.fromJson(Map<String, dynamic> json) =>
      CompanionProfile(
        name: json['name'] as String? ?? 'Işık',
        species: json['species'] as String? ?? 'Kelebek',
        coat: json['coat'] as String? ?? 'Lavanta',
        eyeColor: json['eyeColor'] as String? ?? 'Ametist',
        equippedCosmetic: json['equippedCosmetic'] as String? ?? 'yildiz-isigi',
        equippedItems: (json['equippedItems'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            {'aura': json['equippedCosmetic'] as String? ?? 'yildiz-isigi'},
      );

  static CompanionProfile? decode(String? source) {
    if (source == null) return null;
    try {
      return CompanionProfile.fromJson(
          jsonDecode(source) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }
}

class CompanionCosmetic {
  const CompanionCosmetic({
    required this.id,
    required this.name,
    required this.milestone,
    required this.description,
    required this.slot,
  });

  final String id;
  final String name;
  final int milestone;
  final String description;
  final String slot;

  bool isUnlocked(int longestStreak) => longestStreak >= milestone;
}

const companionCosmetics = [
  CompanionCosmetic(
    id: 'yildiz-isigi',
    name: 'Yıldız Işığı',
    milestone: 0,
    description: 'Başlangıç görünümü',
    slot: 'aura',
  ),
  CompanionCosmetic(
    id: 'hilal-kolye',
    name: 'Hilal Kolye',
    milestone: 3,
    description: '3 günlük en uzun seride açılır',
    slot: 'kolye',
  ),
  CompanionCosmetic(
    id: 'aurora-pelerini',
    name: 'Aurora Pelerini',
    milestone: 7,
    description: '7 günlük en uzun seride açılır',
    slot: 'pelerin',
  ),
  CompanionCosmetic(
    id: 'kozmik-taç',
    name: 'Kozmik Taç',
    milestone: 14,
    description: '14 günlük en uzun seride açılır',
    slot: 'şapka',
  ),
  CompanionCosmetic(
    id: 'ay-kanatlari',
    name: 'Ay Kanatları',
    milestone: 21,
    description: '21 günlük en uzun seride açılır',
    slot: 'aura',
  ),
  CompanionCosmetic(
    id: 'gece-pelerini',
    name: 'Gece Pelerini',
    milestone: 49,
    description: '49 günlük en uzun seride açılır',
    slot: 'atkı',
  ),
  CompanionCosmetic(
    id: 'yildiz-halesi',
    name: 'Yıldız Halesi',
    milestone: 100,
    description: '100 günlük en uzun seride açılır',
    slot: 'gözlük',
  ),
  CompanionCosmetic(
    id: 'kozmos-isiltisi',
    name: 'Kozmos Işıltısı',
    milestone: 365,
    description: '365 günlük en uzun seride açılır',
    slot: 'aura',
  ),
];

final companionProfileProvider = StateProvider<CompanionProfile>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final stored = CompanionProfile.decode(
    preferences.getString('companion_profile'),
  );
  if (stored != null) return stored;
  final profile = ref.watch(userProfileProvider);
  return CompanionProfile(
    species: profile?.zodiacSign.primarySpiritAnimal ?? 'Kelebek',
  );
});

Future<void> saveCompanionProfile(
  WidgetRef ref,
  CompanionProfile profile,
) async {
  await ref
      .read(sharedPreferencesProvider)
      .setString('companion_profile', jsonEncode(profile.toJson()));
  ref.read(companionProfileProvider.notifier).state = profile;
}
