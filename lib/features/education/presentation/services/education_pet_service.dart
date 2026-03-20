import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  static const int _baseCoinsReward = 6;
  static const int _coinsPerCorrectAnswer = 4;

  Future<EducationPetState> loadPetState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawState = prefs.getString(_petStateKey);

    if (rawState == null || rawState.trim().isEmpty) {
      final initialState = EducationPetState.initial();
      await savePetState(initialState);
      return initialState;
    }

    try {
      final payload = Map<String, dynamic>.from(jsonDecode(rawState) as Map);
      return EducationPetState.fromJson(payload);
    } catch (_) {
      final initialState = EducationPetState.initial();
      await savePetState(initialState);
      return initialState;
    }
  }

  Future<EducationPetFeedResult> feedPet() async {
    final currentState = await loadPetState();

    if (!currentState.hasFood) {
      return EducationPetFeedResult(
        success: false,
        leveledUp: false,
        message: 'No tienes comida. Juega para conseguir mas.',
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
          ? '${updatedState.name} subio al nivel ${updatedState.level} y gano ${EducationPetState.xpPerMeal} XP.'
          : '${updatedState.name} gano ${EducationPetState.xpPerMeal} XP.',
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
}
