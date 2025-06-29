import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';
import '../../../shared/widgets/duo_card.dart';

class PerpetualQuizWidget extends StatefulWidget {
  final String quizType; // 'leverage', 'funding', 'liquidation', 'comprehensive'
  final Function(int score, int total, Map<String, dynamic> details) onQuizCompleted;

  const PerpetualQuizWidget({
    super.key,
    required this.quizType,
    required this.onQuizCompleted,
  });

  @override
  State<PerpetualQuizWidget> createState() => _PerpetualQuizWidgetState();
}

class _PerpetualQuizWidgetState extends State<PerpetualQuizWidget>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int> _userAnswers = [];
  List<Map<String, dynamic>> _questions = [];
  bool _showResult = false;
  bool _quizCompleted = false;
  
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _resultController;
  late AnimationController _kingdomController;
  
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _resultBounceAnimation;
  late Animation<double> _kingdomAnimation;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _kingdomController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _resultBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));

    _kingdomAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _kingdomController,
      curve: Curves.easeInOut,
    ));

    _generateQuestions();
    _cardController.forward();
    _kingdomController.repeat();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    _resultController.dispose();
    _kingdomController.dispose();
    super.dispose();
  }

  void _generateQuestions() {
    switch (widget.quizType) {
      case 'leverage':
        _questions = _generateLeverageQuestions();
        break;
      case 'funding':
        _questions = _generateFundingQuestions();
        break;
      case 'liquidation':
        _questions = _generateLiquidationQuestions();
        break;
      case 'comprehensive':
        _questions = _generateComprehensiveQuestions();
        break;
      default:
        _questions = _generateBasicQuestions();
    }
    _userAnswers = List.filled(_questions.length, -1);
  }

  void _selectAnswer(int answerIndex) {
    if (_showResult) return;
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
      _showResult = true;
    });

    // Check if answer is correct
    if (answerIndex == _questions[_currentQuestionIndex]['correctAnswer']) {
      _score++;
    }

    // Show result for 2 seconds, then move to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showResult = false;
      });
      
      _cardController.reset();
      _cardController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    
    _resultController.forward();
    
    final details = {
      'quizType': widget.quizType,
      'userAnswers': _userAnswers,
      'questions': _questions,
      'wrongAnswers': _getWrongAnswers(),
      'strengths': _getStrengths(),
      'recommendations': _getRecommendations(),
    };
    
    widget.onQuizCompleted(_score, _questions.length, details);
  }

  List<Map<String, dynamic>> _getWrongAnswers() {
    final wrongAnswers = <Map<String, dynamic>>[];
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] != _questions[i]['correctAnswer']) {
        wrongAnswers.add({
          'question': _questions[i],
          'userAnswer': _userAnswers[i],
          'correctAnswer': _questions[i]['correctAnswer'],
        });
      }
    }
    return wrongAnswers;
  }

  List<String> _getStrengths() {
    final strengths = <String>[];
    
    // Analyze performance by topic
    final topics = <String, List<bool>>{};
    for (int i = 0; i < _questions.length; i++) {
      final topic = _questions[i]['topic'] as String;
      topics[topic] ??= [];
      topics[topic]!.add(_userAnswers[i] == _questions[i]['correctAnswer']);
    }
    
    topics.forEach((topic, results) {
      final correctCount = results.where((r) => r).length;
      final percentage = correctCount / results.length;
      if (percentage >= 0.8) {
        strengths.add(topic);
      }
    });
    
    return strengths;
  }

  List<String> _getRecommendations() {
    final scorePercentage = _score / _questions.length;
    
    if (scorePercentage >= 0.9) {
      return [
        'Excellent mastery! You\'re ready for advanced perpetual trading strategies.',
        'Consider exploring higher leverage techniques with proper risk management.',
        'Practice with larger position sizes to gain confidence.',
      ];
    } else if (scorePercentage >= 0.7) {
      return [
        'Good understanding! Review the concepts you missed before real trading.',
        'Practice more with demo trading to build confidence.',
        'Focus on risk management techniques.',
      ];
    } else if (scorePercentage >= 0.5) {
      return [
        'Basic understanding achieved. More study needed before trading.',
        'Review leverage, funding rates, and liquidation concepts.',
        'Practice with very small positions only.',
      ];
    } else {
      return [
        'More study required before attempting perpetual trading.',
        'Review all educational modules thoroughly.',
        'Practice with paper trading extensively.',
        'Consider starting with simpler trading concepts.',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildQuizResults();
    }

    return DuoCard(
      type: DuoCardType.lesson,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz Header
          _buildQuizHeader(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Progress Bar
          _buildProgressBar(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Question Card
          _buildQuestionCard(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Answer Options
          _buildAnswerOptions(),
          
          if (_showResult) ...[
            const SizedBox(height: DuolingoTheme.spacingLg),
            _buildResultFeedback(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _kingdomAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: math.sin(_kingdomAnimation.value * math.pi * 2) * 0.1,
              child: const Icon(
                Icons.quiz,
                color: DuolingoTheme.duoBlue,
                size: DuolingoTheme.iconMedium,
              ),
            );
          },
        ),
        const SizedBox(width: DuolingoTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getQuizTitle()} Quiz',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.charcoal,
                ),
              ),
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DuolingoTheme.spacingSm,
            vertical: DuolingoTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
          ),
          child: Text(
            'Score: $_score/${_currentQuestionIndex + (_showResult ? 1 : 0)}',
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.duoGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final progress = (_currentQuestionIndex + (_showResult ? 1 : 0)) / _questions.length;
            return LinearProgressIndicator(
              value: progress * _progressAnimation.value,
              backgroundColor: DuolingoTheme.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoGreen),
              minHeight: 8,
            );
          },
        ),
        const SizedBox(height: DuolingoTheme.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kingdom Knowledge Test',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
            Text(
              '${((_currentQuestionIndex + (_showResult ? 1 : 0)) / _questions.length * 100).toInt()}%',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.duoGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DuolingoTheme.duoBlue.withValues(alpha: 0.1),
              DuolingoTheme.duoPurple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          border: Border.all(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_questions[_currentQuestionIndex]['scenario'] != null) ...[
              Container(
                padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
                decoration: BoxDecoration(
                  color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      color: DuolingoTheme.duoYellow,
                      size: DuolingoTheme.iconSmall,
                    ),
                    const SizedBox(width: DuolingoTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _questions[_currentQuestionIndex]['scenario'],
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.darkGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DuolingoTheme.spacingMd),
            ],
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: DuolingoTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: DuolingoTheme.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    final answers = _questions[_currentQuestionIndex]['answers'] as List<String>;
    
    return Column(
      children: answers.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;
        final isSelected = _userAnswers[_currentQuestionIndex] == index;
        final isCorrect = index == _questions[_currentQuestionIndex]['correctAnswer'];
        
        Color borderColor = DuolingoTheme.mediumGray;
        Color backgroundColor = DuolingoTheme.white;
        Color textColor = DuolingoTheme.charcoal;
        
        if (_showResult) {
          if (isCorrect) {
            borderColor = DuolingoTheme.duoGreen;
            backgroundColor = DuolingoTheme.duoGreen.withValues(alpha: 0.1);
            textColor = DuolingoTheme.duoGreen;
          } else if (isSelected && !isCorrect) {
            borderColor = DuolingoTheme.duoRed;
            backgroundColor = DuolingoTheme.duoRed.withValues(alpha: 0.1);
            textColor = DuolingoTheme.duoRed;
          }
        } else if (isSelected) {
          borderColor = DuolingoTheme.duoBlue;
          backgroundColor = DuolingoTheme.duoBlue.withValues(alpha: 0.1);
          textColor = DuolingoTheme.duoBlue;
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
          child: GestureDetector(
            onTap: () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: borderColor,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DuolingoTheme.spacingMd),
                  Expanded(
                    child: Text(
                      answer,
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_showResult && isCorrect) ...[
                    const Icon(
                      Icons.check_circle,
                      color: DuolingoTheme.duoGreen,
                      size: DuolingoTheme.iconMedium,
                    ),
                  ] else if (_showResult && isSelected && !isCorrect) ...[
                    const Icon(
                      Icons.cancel,
                      color: DuolingoTheme.duoRed,
                      size: DuolingoTheme.iconMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultFeedback() {
    final isCorrect = _userAnswers[_currentQuestionIndex] == _questions[_currentQuestionIndex]['correctAnswer'];
    final explanation = _questions[_currentQuestionIndex]['explanation'] as String;
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: isCorrect 
          ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
          : DuolingoTheme.duoRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: isCorrect 
            ? DuolingoTheme.duoGreen.withValues(alpha: 0.3)
            : DuolingoTheme.duoRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                isCorrect ? 'Excellent!' : 'Not quite right...',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            explanation,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResults() {
    final percentage = (_score / _questions.length * 100).round();
    final isExcellent = percentage >= 90;
    final isGood = percentage >= 70;
    final isPassing = percentage >= 60;
    
    return AnimatedBuilder(
      animation: _resultBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultBounceAnimation.value,
          child: DuoCard(
            type: DuoCardType.achievement,
            child: Column(
              children: [
                // Results Header
                Icon(
                  isExcellent ? Icons.emoji_events : 
                  isGood ? Icons.thumb_up : 
                  isPassing ? Icons.check : Icons.refresh,
                  color: isExcellent ? DuolingoTheme.duoYellow :
                        isGood ? DuolingoTheme.duoGreen :
                        isPassing ? DuolingoTheme.duoBlue : DuolingoTheme.duoRed,
                  size: 64,
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                
                Text(
                  isExcellent ? 'Kingdom Master!' :
                  isGood ? 'Well Done!' :
                  isPassing ? 'Keep Learning!' : 'Study More!',
                  style: DuolingoTheme.h2.copyWith(
                    color: DuolingoTheme.charcoal,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                
                Text(
                  'You scored $_score out of ${_questions.length} ($percentage%)',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // Recommendations
                Container(
                  padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Royal Recommendations:',
                        style: DuolingoTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DuolingoTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: DuolingoTheme.spacingSm),
                      ..._getRecommendations().map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.star,
                              color: DuolingoTheme.duoYellow,
                              size: DuolingoTheme.iconSmall,
                            ),
                            const SizedBox(width: DuolingoTheme.spacingSm),
                            Expanded(
                              child: Text(
                                rec,
                                style: DuolingoTheme.bodySmall.copyWith(
                                  color: DuolingoTheme.darkGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getQuizTitle() {
    switch (widget.quizType) {
      case 'leverage':
        return 'Army Amplification';
      case 'funding':
        return 'Kingdom Taxation';
      case 'liquidation':
        return 'Defense Systems';
      case 'comprehensive':
        return 'Royal Assessment';
      default:
        return 'Perpetual Trading';
    }
  }

  // Question Generation Methods
  List<Map<String, dynamic>> _generateLeverageQuestions() {
    return [
      {
        'topic': 'Leverage Basics',
        'question': 'If you control \$10,000 worth of Bitcoin with \$1,000 of your own gold, what leverage are you using?',
        'answers': ['5x leverage', '10x leverage', '20x leverage', '1x leverage'],
        'correctAnswer': 1,
        'explanation': 'With \$1,000 controlling \$10,000 position, you\'re using 10x leverage (10,000 ÷ 1,000 = 10).',
      },
      {
        'topic': 'Risk Amplification',
        'scenario': 'Your kingdom uses 5x leverage on a territory worth \$2,000. The territory value increases by 10%.',
        'question': 'How much profit do you make?',
        'answers': ['\$100', '\$200', '\$500', '\$1,000'],
        'correctAnswer': 3,
        'explanation': 'With 5x leverage, a 10% price increase gives you 50% profit on your margin: \$1,000 × 50% = \$500.',
      },
      {
        'topic': 'Leverage Selection',
        'question': 'Which leverage is most appropriate for a beginner kingdom ruler?',
        'answers': ['20x leverage for maximum profits', '2x leverage for learning', '50x leverage for quick gains', '1x leverage is too boring'],
        'correctAnswer': 1,
        'explanation': 'Beginners should start with low leverage (2x-5x) to learn without risking kingdom destruction.',
      },
    ];
  }

  List<Map<String, dynamic>> _generateFundingQuestions() {
    return [
      {
        'topic': 'Funding Direction',
        'question': 'When funding rate is +0.01%, who pays whom?',
        'answers': ['Shorts pay longs', 'Longs pay shorts', 'Exchange pays everyone', 'Nobody pays'],
        'correctAnswer': 1,
        'explanation': 'Positive funding means too many longs, so longs pay shorts to balance the market.',
      },
      {
        'topic': 'Funding Frequency',
        'question': 'How often are funding payments made in perpetual contracts?',
        'answers': ['Every hour', 'Every 8 hours', 'Daily', 'Weekly'],
        'correctAnswer': 1,
        'explanation': 'Funding payments occur every 8 hours in most perpetual contracts (00:00, 08:00, 16:00 UTC).',
      },
      {
        'topic': 'Funding Strategy',
        'scenario': 'Bitcoin funding rate has been consistently +0.05% for several days.',
        'question': 'What does this suggest about market sentiment?',
        'answers': ['Too many short positions', 'Too many long positions', 'Balanced market', 'Market is broken'],
        'correctAnswer': 1,
        'explanation': 'Persistently positive funding indicates too many traders are long, creating upward pressure.',
      },
    ];
  }

  List<Map<String, dynamic>> _generateLiquidationQuestions() {
    return [
      {
        'topic': 'Liquidation Risk',
        'scenario': 'You open a long position on Bitcoin at \$40,000 with 10x leverage.',
        'question': 'At approximately what price would your position be liquidated?',
        'answers': ['\$39,000', '\$36,000', '\$30,000', '\$20,000'],
        'correctAnswer': 1,
        'explanation': 'With 10x leverage, liquidation occurs around 10% below entry price: \$40,000 - (\$40,000 × 0.1) = \$36,000.',
      },
      {
        'topic': 'Liquidation Prevention',
        'question': 'What\'s the best way to prevent liquidation?',
        'answers': ['Use maximum leverage', 'Add more margin', 'Ignore price movements', 'Hope for the best'],
        'correctAnswer': 1,
        'explanation': 'Adding margin increases your liquidation buffer, giving your position more room to move.',
      },
      {
        'topic': 'Liquidation Consequences',
        'question': 'What happens when your position gets liquidated?',
        'answers': ['You keep some money', 'You lose your entire margin', 'You owe the exchange money', 'Nothing happens'],
        'correctAnswer': 1,
        'explanation': 'Liquidation means losing your entire margin deposit to prevent further losses.',
      },
    ];
  }

  List<Map<String, dynamic>> _generateBasicQuestions() {
    return [
      {
        'topic': 'Perpetual Basics',
        'question': 'What makes perpetual contracts different from regular contracts?',
        'answers': ['They expire monthly', 'They never expire', 'They only trade on weekends', 'They require physical delivery'],
        'correctAnswer': 1,
        'explanation': 'Perpetual contracts have no expiry date, allowing indefinite position holding.',
      },
      {
        'topic': 'Position Types',
        'question': 'If you think Bitcoin price will fall, which position should you take?',
        'answers': ['Long position', 'Short position', 'No position', 'Both positions'],
        'correctAnswer': 1,
        'explanation': 'Short positions profit when prices fall - you\'re betting against the territory\'s value.',
      },
    ];
  }

  List<Map<String, dynamic>> _generateComprehensiveQuestions() {
    final allQuestions = [
      ..._generateLeverageQuestions(),
      ..._generateFundingQuestions(),
      ..._generateLiquidationQuestions(),
      ..._generateBasicQuestions(),
    ];
    
    // Shuffle and take 8 questions for comprehensive test
    allQuestions.shuffle();
    return allQuestions.take(8).toList();
  }
}