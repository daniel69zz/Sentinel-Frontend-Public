import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../services/education_pet_service.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class _Question {
  final String emoji;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Color color;

  const _Question({
    required this.emoji,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.color,
  });
}

const List<_Question> _allQuestions = [
  _Question(
    emoji: '🤝',
    question: '¿Qué es el consentimiento en una relación íntima?',
    options: [
      'Estar de acuerdo solo la primera vez',
      'Un acuerdo libre, informado y que puede retirarse en cualquier momento',
      'El silencio significa sí',
      'Solo aplica en relaciones formales',
    ],
    correctIndex: 1,
    explanation:
        'El consentimiento debe ser libre, informado, entusiasta y puede retirarse en cualquier momento. En contextos de paz, garantizarlo es un derecho humano fundamental.',
    color: Color(0xFF7ACEC3),
  ),
  _Question(
    emoji: '🕊️',
    question:
        '¿Qué tipo de violencia fue usada como arma de guerra en el conflicto armado colombiano?',
    options: [
      'Violencia económica',
      'Violencia simbólica',
      'Violencia sexual',
      'Violencia cultural',
    ],
    correctIndex: 2,
    explanation:
        'La violencia sexual fue usada sistemáticamente como arma de guerra. Reconocerla es el primer paso para la no repetición y la construcción de paz.',
    color: Color(0xFFE05B88),
  ),
  _Question(
    emoji: '🛡️',
    question: '¿Cuál es el método más efectivo para prevenir ITS y embarazos no planeados?',
    options: [
      'Solo abstinencia',
      'Pastillas anticonceptivas',
      'Uso correcto y consistente del condón',
      'Método del ritmo',
    ],
    correctIndex: 2,
    explanation:
        'El condón usado correctamente es el único método que protege simultáneamente contra ITS y embarazo no planeado. En zonas de postconflicto el acceso a ellos es un derecho.',
    color: Color(0xFF73D0A2),
  ),
  _Question(
    emoji: '🌈',
    question: '¿Qué significa orientación sexual?',
    options: [
      'La preferencia de pareja a la que se siente atracción emocional y/o física',
      'La forma en que te vistes',
      'El rol de género que desempeñas',
      'Algo que se puede cambiar con terapia',
    ],
    correctIndex: 0,
    explanation:
        'La orientación sexual es la atracción emocional, romántica o sexual hacia otras personas. No se elige ni se puede cambiar, y todas las orientaciones son válidas.',
    color: Color(0xFFF0B36A),
  ),
  _Question(
    emoji: '💊',
    question: '¿Qué es la anticoncepción de emergencia (píldora del día después)?',
    options: [
      'Una forma de aborto',
      'Un método para usar siempre',
      'Un método hormonal de emergencia que previene el embarazo hasta 72 horas después',
      'Solo para mujeres casadas',
    ],
    correctIndex: 2,
    explanation:
        'La anticoncepción de emergencia NO interrumpe un embarazo ya establecido. Previene la ovulación o fertilización y debe usarse solo en emergencias, no como método habitual.',
    color: Color(0xFFFF7A8F),
  ),
  _Question(
    emoji: '⚖️',
    question: 'En Colombia, ¿quién tiene derecho a servicios de salud sexual y reproductiva?',
    options: [
      'Solo personas mayores de 18 años',
      'Solo personas con pareja estable',
      'Todas las personas, sin discriminación de edad, género u orientación',
      'Solo quienes puedan pagarlo',
    ],
    correctIndex: 2,
    explanation:
        'Los derechos sexuales y reproductivos son universales. El Estado colombiano, en el marco del Acuerdo de Paz, debe garantizarlos especialmente en territorios históricamente afectados.',
    color: Color(0xFF7ACEC3),
  ),
  _Question(
    emoji: '🧬',
    question: '¿Cuál de estas NO es una Infección de Transmisión Sexual (ITS)?',
    options: [
      'VIH',
      'Sífilis',
      'Herpes genital',
      'Infección urinaria común',
    ],
    correctIndex: 3,
    explanation:
        'La infección urinaria es causada generalmente por bacterias del propio cuerpo y no se transmite sexualmente. Las ITS como VIH, sífilis y herpes sí requieren prevención activa.',
    color: Color(0xFFE05B88),
  ),
  _Question(
    emoji: '💬',
    question: '¿Qué es el "mansplaining" en relaciones de pareja?',
    options: [
      'Un tipo de juego',
      'Cuando alguien explica algo de forma condescendiente asumiendo ignorancia por el género',
      'Una forma de comunicación respetuosa',
      'Un término médico',
    ],
    correctIndex: 1,
    explanation:
        'El mansplaining es una forma de violencia simbólica. En relaciones sanas, se comunica desde el respeto y la igualdad, sin asumir superioridad por el género.',
    color: Color(0xFF73D0A2),
  ),
  _Question(
    emoji: '🏥',
    question: '¿Con qué frecuencia se recomienda hacerse la prueba del VIH si se tienen relaciones sin protección?',
    options: [
      'Solo cuando hay síntomas',
      'Una vez en la vida',
      'Al menos una vez al año o después de cada situación de riesgo',
      'Solo si tienes pareja nueva',
    ],
    correctIndex: 2,
    explanation:
        'El VIH puede no presentar síntomas por años. Hacerse la prueba regularmente permite tratamiento temprano y rompe cadenas de transmisión. En zonas de postconflicto el acceso a estas pruebas es vital.',
    color: Color(0xFFF0B36A),
  ),
  _Question(
    emoji: '🌱',
    question: '¿Qué es la identidad de género?',
    options: [
      'El sexo biológico asignado al nacer',
      'La vivencia interna e individual del género que puede o no coincidir con el sexo de nacimiento',
      'Lo que dice tu documento de identidad',
      'Solo puede ser hombre o mujer',
    ],
    correctIndex: 1,
    explanation:
        'La identidad de género es la experiencia interna y personal del género. En Colombia, la Ley 1955 y los Acuerdos de Paz reconocen el enfoque de género como eje transversal.',
    color: Color(0xFFFF7A8F),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class EducationGamesScreen extends StatefulWidget {
  const EducationGamesScreen({super.key});

  @override
  State<EducationGamesScreen> createState() => _EducationGamesScreenState();
}

enum _GamePhase { menu, question, feedback, summary }

class _EducationGamesScreenState extends State<EducationGamesScreen>
    with TickerProviderStateMixin {
  final EducationPetService _petService = EducationPetService();

  _GamePhase _phase = _GamePhase.menu;
  late List<_Question> _questions;
  int _current = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isApplyingReward = false;
  EducationGameRewardResult? _reward;

  late AnimationController _cardAnim;
  late Animation<double> _cardScale;
  late AnimationController _feedbackAnim;
  late Animation<double> _feedbackOpacity;
  late AnimationController _progressAnim;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _cardScale = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutBack);

    _feedbackAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackOpacity =
        CurvedAnimation(parent: _feedbackAnim, curve: Curves.easeIn);

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressValue =
        CurvedAnimation(parent: _progressAnim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _cardAnim.dispose();
    _feedbackAnim.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  void _startGame() {
    final rng = math.Random();
    _questions = List<_Question>.from(_allQuestions)..shuffle(rng);
    _questions = _questions.take(6).toList();
    setState(() {
      _phase = _GamePhase.question;
      _current = 0;
      _score = 0;
      _selectedOption = null;
      _reward = null;
    });
    _cardAnim.forward(from: 0);
    _progressAnim.animateTo(0);
  }

  void _selectOption(int index) {
    if (_selectedOption != null) return;
    final isCorrect = index == _questions[_current].correctIndex;
    setState(() {
      _selectedOption = index;
      _phase = _GamePhase.feedback;
      if (isCorrect) _score++;
    });
    _feedbackAnim.forward(from: 0);
    _progressAnim.animateTo(
      (_current + 1) / _questions.length,
    );
  }

  void _nextQuestion() {
    if (_current + 1 >= _questions.length) {
      _finishGame();
      return;
    }
    setState(() {
      _current++;
      _selectedOption = null;
      _phase = _GamePhase.question;
    });
    _cardAnim.forward(from: 0);
    _feedbackAnim.reset();
  }

  Future<void> _finishGame() async {
    setState(() {
      _phase = _GamePhase.summary;
      _isApplyingReward = true;
    });
    try {
      final reward = await _petService.rewardGame(correctAnswers: _score);
      if (!mounted) return;
      setState(() {
        _reward = reward;
        _isApplyingReward = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isApplyingReward = false);
    }
  }

  void _reset() {
    setState(() {
      _phase = _GamePhase.menu;
      _selectedOption = null;
      _reward = null;
    });
    _cardAnim.reset();
    _feedbackAnim.reset();
    _progressAnim.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Aprende & Gana'),
        elevation: 0,
        actions: [
          if (_phase != _GamePhase.menu && _phase != _GamePhase.summary)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_current + 1} / ${_questions.length}',
                    style: AppTheme.labelLarge
                        .copyWith(color: AppTheme.primary, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position:
                  Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                      .animate(anim),
              child: child,
            ),
          ),
          child: switch (_phase) {
            _GamePhase.menu => _buildMenu(),
            _GamePhase.question || _GamePhase.feedback => _buildQuiz(),
            _GamePhase.summary => _buildSummary(),
          },
        ),
      ),
    );
  }

  // ── Menu ──────────────────────────────────────────────────────────────────

  Widget _buildMenu() {
    return SingleChildScrollView(
      key: const ValueKey('menu'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradientBanner(),
          const SizedBox(height: 24),
          Text(
            'Categorías del quiz',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _buildCategoryChips(),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Text('🎮', style: TextStyle(fontSize: 18)),
              label: const Text('¡Empezar Quiz!'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('💰', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gana recompensas', style: AppTheme.titleLarge.copyWith(fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(
                        'Por cada respuesta correcta tu mascota recibe comida y monedas',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.85),
            AppTheme.accent.withValues(alpha: 0.7),
            AppTheme.icedMint.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🕊️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Educación Sexual\npara la Paz',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz interactivo para jóvenes de 15 a 25 años\nen el contexto del proceso de paz',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    const cats = [
      ('🤝', 'Consentimiento'),
      ('🛡️', 'Prevención'),
      ('🌈', 'Diversidad'),
      ('⚖️', 'Derechos'),
      ('🕊️', 'Paz y género'),
      ('🧬', 'Salud sexual'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats
          .map(
            (c) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.$1, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    c.$2,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    final q = _questions[_current];
    return SingleChildScrollView(
      key: ValueKey('quiz-$_current'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _cardScale,
            child: _buildQuestionCard(q),
          ),
          const SizedBox(height: 16),
          ..._buildOptions(q),
          if (_phase == _GamePhase.feedback) ...[
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _feedbackOpacity,
              child: _buildExplanationCard(q),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _feedbackOpacity,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: Icon(
                    _current + 1 >= _questions.length
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _current + 1 >= _questions.length
                        ? '¡Ver resultados!'
                        : 'Siguiente pregunta',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta ${_current + 1} de ${_questions.length}',
              style: AppTheme.bodyMedium,
            ),
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_score correctas',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _progressValue,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: _progressValue.value,
                minHeight: 6,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primary),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_Question q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: q.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: q.color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: q.color.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: q.color.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(q.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: q.color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Educación Sexual · Paz',
                  style: TextStyle(
                    color: q.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            q.question,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 17,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(_Question q) {
    final optionLetters = ['A', 'B', 'C', 'D'];
    return List.generate(q.options.length, (i) {
      final isSelected = _selectedOption == i;
      final isCorrect = i == q.correctIndex;
      final showResult = _selectedOption != null;

      Color borderColor;
      Color bgColor;
      Color textColor = AppTheme.textPrimary;
      Widget? trailing;

      if (!showResult) {
        borderColor = AppTheme.divider;
        bgColor = AppTheme.cardBg;
      } else if (isCorrect) {
        borderColor = AppTheme.success;
        bgColor = AppTheme.success.withValues(alpha: 0.14);
        trailing = const Icon(Icons.check_circle_rounded,
            color: AppTheme.success, size: 22);
      } else if (isSelected) {
        borderColor = AppTheme.error;
        bgColor = AppTheme.error.withValues(alpha: 0.12);
        trailing =
            const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 22);
      } else {
        borderColor = AppTheme.divider.withValues(alpha: 0.4);
        bgColor = AppTheme.cardBg.withValues(alpha: 0.5);
        textColor = AppTheme.textSecondary;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isSelected && showResult
                ? [
                    BoxShadow(
                      color: (isCorrect ? AppTheme.success : AppTheme.error)
                          .withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: InkWell(
            onTap: showResult ? null : () => _selectOption(i),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: showResult && isCorrect
                          ? AppTheme.success.withValues(alpha: 0.2)
                          : showResult && isSelected
                              ? AppTheme.error.withValues(alpha: 0.2)
                              : AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      optionLetters[i],
                      style: TextStyle(
                        color: showResult && isCorrect
                            ? AppTheme.success
                            : showResult && isSelected
                                ? AppTheme.error
                                : AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q.options[i],
                      style: AppTheme.bodyLarge.copyWith(
                        color: textColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExplanationCard(_Question q) {
    final isCorrect = _selectedOption == q.correctIndex;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect
              ? AppTheme.success.withValues(alpha: 0.4)
              : AppTheme.warning.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '✅' : '💡',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? '¡Correcto!' : 'Aprendamos juntos',
                style: AppTheme.titleLarge.copyWith(
                  color: isCorrect ? AppTheme.success : AppTheme.warning,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q.explanation,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary.withValues(alpha: 0.9),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Widget _buildSummary() {
    final total = _questions.length;
    final pct = (_score / total * 100).round();
    final isHighScore = _score >= (total * 0.7).ceil();

    final (medal, title, subtitle) = switch (pct) {
      >= 90 => ('🏆', '¡Experto/a en paz!', 'Dominas la educación sexual y los derechos'),
      >= 70 => ('🌟', '¡Muy bien!', 'Tienes bases sólidas, sigue aprendiendo'),
      >= 50 => ('📚', '¡Buen intento!', 'Cada pregunta es una oportunidad de crecer'),
      _ => ('🌱', '¡Sigue creciendo!', 'El aprendizaje es un camino, no un destino'),
    };

    return SingleChildScrollView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(medal, style: const TextStyle(fontSize: 54)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _buildScoreRing(pct, isHighScore),
          const SizedBox(height: 28),
          if (_isApplyingReward)
            const CircularProgressIndicator()
          else if (_reward != null) ...[
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text('Recompensa para tu mascota',
                          style: AppTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _RewardTile(
                          icon: '🍕',
                          label: 'Comida',
                          value: '+${_reward!.foodEarned}',
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RewardTile(
                          icon: '💰',
                          label: 'Monedas',
                          value: '+${_reward!.coinsEarned}',
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total mascota', style: AppTheme.bodyMedium),
                        Text(
                          '🍕 ${_reward!.state.foodBalance}  💰 ${_reward!.state.coins}',
                          style: AppTheme.labelLarge
                              .copyWith(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Jugar de nuevo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing(int pct, bool isHighScore) {
    final total = _questions.length;
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _score / total),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHighScore ? AppTheme.success : AppTheme.warning,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_score',
                      style: AppTheme.headlineMedium.copyWith(fontSize: 22),
                    ),
                    Text(
                      '/$total',
                      style: AppTheme.bodyMedium.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$pct% de aciertos', style: AppTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '$_score de $total respuestas correctas',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                _ScoreBar(
                  value: _score / total,
                  color: isHighScore ? AppTheme.success : AppTheme.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _RewardTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _RewardTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.labelLarge.copyWith(color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ScoreBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: 8,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
