import '../../../../core/localization/app_language_service.dart';

class EducationPetState {
  static const int xpPerLevel = 100;
  static const int xpPerMeal = 18;

  final String name;
  final int level;
  final int currentXp;
  final int totalXp;
  final int feedCount;
  final int foodBalance;
  final int coins;
  final int? lastFedAtMillis;

  const EducationPetState({
    required this.name,
    required this.level,
    required this.currentXp,
    required this.totalXp,
    required this.feedCount,
    required this.foodBalance,
    required this.coins,
    required this.lastFedAtMillis,
  });

  factory EducationPetState.initial() {
    return const EducationPetState(
      name: 'Luma',
      level: 1,
      currentXp: 24,
      totalXp: 24,
      feedCount: 0,
      foodBalance: 1,
      coins: 0,
      lastFedAtMillis: null,
    );
  }

  bool get hasFood => foodBalance > 0;

  double get progress {
    final value = currentXp / xpPerLevel;
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  String get moodLabel {
    final l10n = AppLanguageService.instance;
    if (!hasFood) {
      return l10n.pick(
        es: 'Esperando comida',
        en: 'Waiting for food',
      );
    }
    if (feedCount == 0) {
      return l10n.pick(es: 'Curiosa', en: 'Curious');
    }
    if (progress >= 0.75) {
      return l10n.pick(es: 'Motivada', en: 'Motivated');
    }
    if (progress >= 0.40) {
      return l10n.pick(es: 'Activa', en: 'Active');
    }
    return l10n.pick(es: 'Con hambre', en: 'Hungry');
  }

  String get statusMessage {
    final l10n = AppLanguageService.instance;
    if (!hasFood) {
      return l10n.pick(
        es: '$name necesita comida del juego para seguir creciendo.',
        en: '$name needs food from the game to keep growing.',
      );
    }
    if (feedCount == 0) {
      return l10n.pick(
        es: '$name esta lista para aprender contigo.',
        en: '$name is ready to learn with you.',
      );
    }
    if (progress >= 0.75) {
      return l10n.pick(
        es: '$name esta con toda la energia para seguir.',
        en: '$name has all the energy to keep going.',
      );
    }
    if (progress >= 0.40) {
      return l10n.pick(
        es: '$name sigue creciendo con cada actividad.',
        en: '$name keeps growing with every activity.',
      );
    }
    return l10n.pick(
      es: '$name necesita otra ayuda para subir mas rapido.',
      en: '$name needs another boost to level up faster.',
    );
  }

  String get lastFedLabel {
    final l10n = AppLanguageService.instance;
    if (lastFedAtMillis == null) {
      return l10n.pick(
        es: 'Todavia no la alimentaste.',
        en: 'You have not fed her yet.',
      );
    }

    final date = DateTime.fromMillisecondsSinceEpoch(
      lastFedAtMillis!,
    ).toLocal();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return l10n.pick(
      es: 'Ultima comida: $hour:$minute',
      en: 'Last meal: $hour:$minute',
    );
  }

  EducationPetState feed() {
    var updatedLevel = level;
    var updatedXp = currentXp + xpPerMeal;

    while (updatedXp >= xpPerLevel) {
      updatedXp -= xpPerLevel;
      updatedLevel += 1;
    }

    return copyWith(
      level: updatedLevel,
      currentXp: updatedXp,
      totalXp: totalXp + xpPerMeal,
      feedCount: feedCount + 1,
      foodBalance: foodBalance - 1,
      lastFedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  EducationPetState rewardFromGame({
    required int foodEarned,
    required int coinsEarned,
  }) {
    return copyWith(
      foodBalance: foodBalance + foodEarned,
      coins: coins + coinsEarned,
    );
  }

  EducationPetState copyWith({
    String? name,
    int? level,
    int? currentXp,
    int? totalXp,
    int? feedCount,
    int? foodBalance,
    int? coins,
    int? lastFedAtMillis,
  }) {
    return EducationPetState(
      name: name ?? this.name,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      feedCount: feedCount ?? this.feedCount,
      foodBalance: foodBalance ?? this.foodBalance,
      coins: coins ?? this.coins,
      lastFedAtMillis: lastFedAtMillis ?? this.lastFedAtMillis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'currentXp': currentXp,
      'totalXp': totalXp,
      'feedCount': feedCount,
      'foodBalance': foodBalance,
      'coins': coins,
      'lastFedAtMillis': lastFedAtMillis,
    };
  }

  factory EducationPetState.fromJson(Map<String, dynamic> json) {
    final initial = EducationPetState.initial();

    return EducationPetState(
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString()
          : initial.name,
      level: _asInt(json['level'], initial.level),
      currentXp: _asInt(json['currentXp'], initial.currentXp),
      totalXp: _asInt(json['totalXp'], initial.totalXp),
      feedCount: _asInt(json['feedCount'], initial.feedCount),
      foodBalance: _asInt(json['foodBalance'], initial.foodBalance),
      coins: _asInt(json['coins'], initial.coins),
      lastFedAtMillis: _asNullableInt(json['lastFedAtMillis']),
    );
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }
}
