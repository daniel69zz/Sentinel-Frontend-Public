import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../services/education_pet_service.dart';

class EducationGamesScreen extends StatefulWidget {
  const EducationGamesScreen({super.key});

  @override
  State<EducationGamesScreen> createState() => _EducationGamesScreenState();
}

class _EducationGamesScreenState extends State<EducationGamesScreen> {
  final EducationPetService _petService = EducationPetService();
  List<_QuestionItem> _questionBank = const [];
  List<_QuestionItem> _questions = const [];

  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _correctAnswers = 0;
  bool _isSubmitting = false;
  bool _isApplyingReward = false;
  bool _quizFinished = false;
  EducationGameRewardResult? _reward;
  int _roundsPlayed = 1;
  bool _isLoading = true;
  bool _showAnswer = false;
  bool _lastAnswerCorrect = false;
  final List<_AnswerSummary> _answersSummary = [];

  _QuestionItem get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final raw = await rootBundle.loadString('assets/data/education_quiz.json');
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = list
          .map((e) => _QuestionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      setState(() {
        _questionBank = parsed;
        _isLoading = false;
        _startNewRound();
      });
    } catch (_) {
      setState(() {
        _questions = const [];
        _isLoading = false;
      });
    }
  }

  void _startNewRound() {
    final bank = List<_QuestionItem>.from(_questionBank);
    bank.shuffle();
    final selected = bank.take(3).map((q) => q.shuffled()).toList();
    setState(() {
      _questions = selected;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _correctAnswers = 0;
      _isSubmitting = false;
      _isApplyingReward = false;
      _quizFinished = false;
      _reward = null;
      _showAnswer = false;
      _answersSummary.clear();
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedOptionIndex == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showAnswer = false;
    });

    final isCorrect = _selectedOptionIndex == _currentQuestion.correctIndex;

    if (isCorrect) {
      _correctAnswers++;
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _showAnswer = true;
      _lastAnswerCorrect = isCorrect;
      _addAnswerSummary(isCorrect);
    });

    setState(() => _isSubmitting = false);
  }

  void _goToNext() async {
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    if (isLastQuestion) {
      await _applyRewardAndComplete();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _isSubmitting = false;
      _showAnswer = false;
    });
  }

  void _addAnswerSummary(bool isCorrect) {
    _answersSummary.add(
      _AnswerSummary(
        question: _currentQuestion.question,
        selected: _currentQuestion.options[_selectedOptionIndex!],
        correct: _currentQuestion.options[_currentQuestion.correctIndex],
        isCorrect: isCorrect,
        explanation: _currentQuestion.explanation,
      ),
    );
  }

  Future<void> _applyRewardAndComplete() async {
    if (_isApplyingReward) {
      return;
    }

    setState(() {
      _isApplyingReward = true;
    });

    try {
      EducationGameRewardResult? reward;

      if (_correctAnswers > 0) {
        reward = await _petService.rewardGame(
          correctAnswers: _correctAnswers,
        );
      }

      if (!mounted) return;

      setState(() {
        _reward = reward;
        _quizFinished = true;
        _isSubmitting = false;
        _isApplyingReward = false;
      });

      if (_correctAnswers == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'education.games.no_reward',
                fallback:
                    'No hubo respuestas correctas. Intenta otra ronda para ganar recompensas.',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _isApplyingReward = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('education.games.save_reward_error')),
        ),
      );
    }
  }

  void _resetQuiz() {
    _roundsPlayed = (_roundsPlayed % 3) + 1;
    _startNewRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(context.tr('education.games.title')),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: _quizFinished ? _buildResultView() : _buildQuizView(),
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    if (_isLoading || _questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: _isLoading
              ? const CircularProgressIndicator(color: AppTheme.primary)
              : Text(
                  context.tr(
                    'education.games.load_error',
                    fallback: 'No se pudieron cargar las preguntas.',
                  ),
                ),
        ),
      );
    }

    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🧠 Juego de preguntas',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Responde correctamente', style: AppTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Contesta las preguntas y gana recompensas para tu mascota.',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress, minHeight: 8),
              ),
              const SizedBox(height: 8),
              Text(
                'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CustomCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentQuestion.question, style: AppTheme.titleLarge),
              const SizedBox(height: 16),
              ...List.generate(_currentQuestion.options.length, (index) {
                final isSelected = _selectedOptionIndex == index;
                final isCorrect = _currentQuestion.correctIndex == index;
                final showFeedback = _showAnswer;
                Color borderColor = AppTheme.divider;
                Color fillColor = AppTheme.cardBg;

                if (showFeedback) {
                  if (isCorrect) {
                    borderColor = Colors.green;
                    fillColor = Colors.green.withValues(alpha: 0.10);
                  } else if (isSelected && !isCorrect) {
                    borderColor = Colors.red;
                    fillColor = Colors.red.withValues(alpha: 0.10);
                  }
                } else if (isSelected) {
                  borderColor = AppTheme.primary;
                  fillColor = AppTheme.primary.withValues(alpha: 0.12);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _selectedOptionIndex = index;
                            });
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        _currentQuestion.options[index],
                        style: AppTheme.bodyLarge,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              if (_showAnswer) ...[
                Text(
                  _lastAnswerCorrect
                      ? '¡Correcto!'
                      : 'Respuesta correcta: ${_currentQuestion.options[_currentQuestion.correctIndex]}',
                  style: AppTheme.labelLarge.copyWith(
                    color: _lastAnswerCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentQuestion.explanation,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  if (_showAnswer)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _showAnswer = false;
                                });
                                _goToNext();
                              },
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        label: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? 'Ver resultados'
                              : 'Siguiente',
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_selectedOptionIndex == null || _isSubmitting)
                            ? null
                            : _submitAnswer,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_rounded),
                        label: const Text('Responder'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: AppTheme.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Juego completado!',
          style: AppTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Respondiste $_correctAnswers de ${_questions.length} correctamente.',
          style: AppTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Ronda $_roundsPlayed de 3 recomendadas.',
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_answersSummary.isNotEmpty)
          CustomCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen de respuestas', style: AppTheme.labelLarge),
                const SizedBox(height: 10),
                ..._answersSummary.map((a) {
                  final color = a.isCorrect ? Colors.green : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.question,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tu respuesta: ${a.selected}',
                          style:
                              AppTheme.bodyMedium.copyWith(color: color),
                        ),
                        if (!a.isCorrect)
                          Text(
                            'Correcta: ${a.correct}',
                            style: AppTheme.bodyMedium,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          a.explanation,
                          style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 24),
        if (_reward != null) ...[
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recompensa', style: AppTheme.labelLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RewardItem(
                        icon: '🍕',
                        label: 'Comida',
                        value: '${_reward!.foodEarned}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RewardItem(
                        icon: '💰',
                        label: 'Monedas',
                        value: '${_reward!.coinsEarned}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total de tu mascota', style: AppTheme.bodyMedium),
                      Text(
                        '🍕 ${_reward!.state.foodBalance} | 💰 ${_reward!.state.coins}',
                        style: AppTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _resetQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.tr('education.games.play_again')),
          ),
        ),
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            '+$value',
            style: AppTheme.labelLarge.copyWith(color: AppTheme.success),
          ),
        ],
      ),
    );
  }
}

class _QuestionItem {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _QuestionItem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory _QuestionItem.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).map((e) => e.toString()).toList();
    return _QuestionItem(
      question: json['question']?.toString() ?? '',
      options: options,
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  _QuestionItem shuffled() {
    final pairs = options.asMap().entries.toList();
    pairs.shuffle();
    final newOptions = pairs.map((e) => e.value).toList();
    final newCorrectIndex =
        pairs.indexWhere((entry) => entry.key == correctIndex);
    return _QuestionItem(
      question: question,
      options: newOptions,
      correctIndex: newCorrectIndex,
      explanation: explanation,
    );
  }
}

class _AnswerSummary {
  final String question;
  final String selected;
  final String correct;
  final String explanation;
  final bool isCorrect;

  const _AnswerSummary({
    required this.question,
    required this.selected,
    required this.correct,
    required this.explanation,
    required this.isCorrect,
  });
}
