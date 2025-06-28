import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class EducationQuizWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int score, int total) onQuizCompleted;

  const EducationQuizWidget({
    super.key,
    required this.questions,
    required this.onQuizCompleted,
  });

  @override
  State<EducationQuizWidget> createState() => _EducationQuizWidgetState();
}

class _EducationQuizWidgetState extends State<EducationQuizWidget> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _quizCompleted = false;
  
  late AnimationController _cardAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _resultAnimationController;
  
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _resultBounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOut,
    ));
    
    _resultBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressAnimationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildQuizResults();
    }

    final currentQuestion = widget.questions[_currentQuestionIndex];
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          _buildQuizHeader(),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Question card
          AnimatedBuilder(
            animation: _cardSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_cardSlideAnimation.value * 300, 0),
                child: Opacity(
                  opacity: 1.0 - _cardSlideAnimation.value,
                  child: _buildQuestionCard(currentQuestion),
                ),
              );
            },
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Answer options
          ...List.generate(
            (currentQuestion['options'] as List).length,
            (index) => _buildAnswerOption(index, currentQuestion['options'][index]),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Next/Submit button
          _buildActionButton(currentQuestion),
          
          // Result feedback
          if (_showResult) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            _buildResultFeedback(currentQuestion),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizHeader() {
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.quiz,
                color: DuolingoTheme.duoYellow,
                size: 24,
              ),
            ),
            const SizedBox(width: DuolingoTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Royal Wisdom Test',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            // Score indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: DuolingoTheme.duoYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_score/${widget.questions.length}',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.duoGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: DuolingoTheme.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * progress * _progressAnimation.value,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DuolingoTheme.duoGreen, DuolingoTheme.duoGreenLight],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DuolingoTheme.duoBlue, DuolingoTheme.duoBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            blurRadius: 8,
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
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: DuolingoTheme.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_currentQuestionIndex + 1}',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.duoBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              const Icon(
                Icons.help_outline,
                color: DuolingoTheme.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Text(
            question['question'],
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, String option) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = _showResult && index == widget.questions[_currentQuestionIndex]['correctAnswer'];
    final isWrong = _showResult && isSelected && !isCorrect;
    
    Color backgroundColor = DuolingoTheme.white;
    Color borderColor = DuolingoTheme.lightGray;
    Color textColor = DuolingoTheme.charcoal;
    
    if (_showResult) {
      if (isCorrect) {
        backgroundColor = DuolingoTheme.duoGreen.withValues(alpha: 0.1);
        borderColor = DuolingoTheme.duoGreen;
        textColor = DuolingoTheme.duoGreen;
      } else if (isWrong) {
        backgroundColor = DuolingoTheme.duoRed.withValues(alpha: 0.1);
        borderColor = DuolingoTheme.duoRed;
        textColor = DuolingoTheme.duoRed;
      }
    } else if (isSelected) {
      backgroundColor = DuolingoTheme.duoBlue.withValues(alpha: 0.1);
      borderColor = DuolingoTheme.duoBlue;
      textColor = DuolingoTheme.duoBlue;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
      child: GestureDetector(
        onTap: _showResult ? null : () {
          setState(() {
            _selectedAnswer = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected || _showResult ? borderColor : Colors.transparent,
                  border: Border.all(color: borderColor, width: 2),
                  shape: BoxShape.circle,
                ),
                child: _showResult && isCorrect
                    ? const Icon(Icons.check, color: DuolingoTheme.white, size: 16)
                    : _showResult && isWrong
                        ? const Icon(Icons.close, color: DuolingoTheme.white, size: 16)
                        : isSelected
                            ? Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: DuolingoTheme.white,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Text(
                  option,
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> question) {
    final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;
    String buttonText;
    
    if (_showResult) {
      buttonText = isLastQuestion ? 'Complete Quiz' : 'Next Question';
    } else {
      buttonText = 'Check Answer';
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedAnswer == null ? null : () {
          if (_showResult) {
            _nextQuestion();
          } else {
            _checkAnswer(question);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: DuolingoTheme.duoGreen,
          foregroundColor: DuolingoTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
          elevation: 4,
        ),
        child: Text(
          buttonText,
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildResultFeedback(Map<String, dynamic> question) {
    final isCorrect = _selectedAnswer == question['correctAnswer'];
    
    return AnimatedBuilder(
      animation: _resultBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultBounceAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
                  : DuolingoTheme.duoRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(
                color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCorrect ? 'Correct!' : 'Incorrect',
                      style: DuolingoTheme.bodyLarge.copyWith(
                        color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                Text(
                  question['explanation'],
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.darkGray,
                    height: 1.4,
                  ),
                ),
                if (question['kingdomMetaphor'].isNotEmpty) ...[
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.castle,
                          color: DuolingoTheme.duoYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question['kingdomMetaphor'],
                            style: DuolingoTheme.caption.copyWith(
                              color: DuolingoTheme.duoYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizResults() {
    final percentage = (_score / widget.questions.length * 100).round();
    final isGoodScore = percentage >= 80;
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Trophy/Crown icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isGoodScore ? DuolingoTheme.duoYellow : DuolingoTheme.duoBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isGoodScore ? DuolingoTheme.duoYellow : DuolingoTheme.duoBlue).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isGoodScore ? Icons.emoji_events : Icons.school,
              color: DuolingoTheme.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          Text(
            isGoodScore ? 'Excellent Work!' : 'Good Effort!',
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            'You scored $_score out of ${widget.questions.length} ($percentage%)',
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          Text(
            isGoodScore 
                ? 'You\'ve mastered the fundamentals! Your kingdom\'s treasury is in good hands.'
                : 'Keep learning! Even the wisest rulers started somewhere. Review the lessons and try again.',
            textAlign: TextAlign.center,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // XP Reward
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: DuolingoTheme.duoYellow,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${_score * 25} XP Earned!',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    color: DuolingoTheme.duoYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer(Map<String, dynamic> question) {
    final isCorrect = _selectedAnswer == question['correctAnswer'];
    
    if (isCorrect) {
      _score++;
    }
    
    setState(() {
      _showResult = true;
    });
    
    _resultAnimationController.forward();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      _cardAnimationController.forward().then((_) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _showResult = false;
        });
        
        _cardAnimationController.reset();
        _resultAnimationController.reset();
        _progressAnimationController.reset();
        _progressAnimationController.forward();
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
      
      widget.onQuizCompleted(_score, widget.questions.length);
    }
  }
}