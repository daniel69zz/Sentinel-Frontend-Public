import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../domain/models/education_pet_state.dart';

class EducationPetFeedResult {
  final bool success;
  final bool leveledUp;
  final String message;
  final EducationPetState state;

  const EducationPetFeedResult({
    required this.success,
    required this.leveledUp,
    required this.message,
    required this.state,
  });
}

class EducationGameRewardResult {
  final int foodEarned;
  final int coinsEarned;
  final EducationPetState state;

  const EducationGameRewardResult({
    required this.foodEarned,
    required this.coinsEarned,
    required this.state,
  });
}

class EducationPetService {
  static const String _petStateKey = 'education_pet_state_v1';
  static const String _petEnabledKey = 'education_pet_enabled';
  static const int _baseCoinsReward = 6;
  static const int _coinsPerCorrectAnswer = 4;

  Future<EducationPetState> loadPetState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawState = prefs.getString(_petStateKey);

    if (rawState == null || rawState.trim().isEmpty) {
      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      final initialState =
          EducationPetState.initial().copyWith(lastFedAtMillis: nowMillis);
      await savePetState(initialState);
      return initialState;
    }

    try {
      final payload = Map<String, dynamic>.from(jsonDecode(rawState) as Map);
      final state = EducationPetState.fromJson(payload);
      if (state.lastFedAtMillis == null) {
        final hydrated = state.copyWith(
          lastFedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await savePetState(hydrated);
        return hydrated;
      }
      return state;
    } catch (_) {
      final initialState = EducationPetState.initial().copyWith(
        lastFedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      await savePetState(initialState);
      return initialState;
    }
  }

  Future<EducationPetFeedResult> feedPet() async {
    final l10n = AppLanguageService.instance;
    final currentState = await loadPetState();

    if (!currentState.hasFood) {
      return EducationPetFeedResult(
        success: false,
        leveledUp: false,
        message: l10n.pick(
          es: 'No tienes comida. Juega para conseguir mas.',
          en: 'You do not have food. Play to get more.',
        ),
        state: currentState,
      );
    }

    final previousLevel = currentState.level;
    final updatedState = currentState.feed();
    await savePetState(updatedState);
    final leveledUp = updatedState.level > previousLevel;

    return EducationPetFeedResult(
      success: true,
      leveledUp: leveledUp,
      message: leveledUp
          ? l10n.pick(
              es:
                  '${updatedState.name} subio al nivel ${updatedState.level} y gano ${EducationPetState.xpPerMeal} XP.',
              en:
                  '${updatedState.name} reached level ${updatedState.level} and earned ${EducationPetState.xpPerMeal} XP.',
            )
          : l10n.pick(
              es:
                  '${updatedState.name} gano ${EducationPetState.xpPerMeal} XP.',
              en:
                  '${updatedState.name} earned ${EducationPetState.xpPerMeal} XP.',
            ),
      state: updatedState,
    );
  }

  Future<EducationGameRewardResult> rewardGame({
    required int correctAnswers,
  }) async {
    final currentState = await loadPetState();
    final foodEarned = correctAnswers <= 0 ? 1 : correctAnswers;
    final coinsEarned =
        _baseCoinsReward + (correctAnswers * _coinsPerCorrectAnswer);
    final updatedState = currentState.rewardFromGame(
      foodEarned: foodEarned,
      coinsEarned: coinsEarned,
    );

    await savePetState(updatedState);

    return EducationGameRewardResult(
      foodEarned: foodEarned,
      coinsEarned: coinsEarned,
      state: updatedState,
    );
  }

  Future<void> savePetState(EducationPetState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_petStateKey, jsonEncode(state.toJson()));
  }

  Future<bool> isPetEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_petEnabledKey) ?? true;
  }

  Future<void> setPetEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_petEnabledKey, enabled);
  }
}
