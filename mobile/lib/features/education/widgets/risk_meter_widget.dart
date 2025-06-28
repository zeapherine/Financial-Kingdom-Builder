import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';

class RiskMeterWidget extends StatefulWidget {
  final double riskLevel; // 0.0 to 1.0
  final String title;
  final String description;
  final Function(double)? onRiskChanged;
  final bool isInteractive;
  final List<String>? riskLabels;

  const RiskMeterWidget({
    super.key,
    required this.riskLevel,
    required this.title,
    required this.description,
    this.onRiskChanged,
    this.isInteractive = false,
    this.riskLabels,
  });

  @override
  State<RiskMeterWidget> createState() => _RiskMeterWidgetState();
}

class _RiskMeterWidgetState extends State<RiskMeterWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _riskAnimation;
  double _currentRisk = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRisk = widget.riskLevel;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _riskAnimation = Tween<double>(
      begin: 0.0,
      end: widget.riskLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RiskMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riskLevel != widget.riskLevel) {
      _animateToNewRisk(widget.riskLevel);
    }
  }

  void _animateToNewRisk(double newRisk) {
    _riskAnimation = Tween<double>(
      begin: _currentRisk,
      end: newRisk,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _currentRisk = newRisk;
    _animationController.reset();
    _animationController.forward();
  }

  Color _getRiskColor(double risk) {
    if (risk < 0.3) return DuolingoTheme.duoGreen;
    if (risk < 0.6) return DuolingoTheme.duoYellow;
    if (risk < 0.8) return DuolingoTheme.duoOrange;
    return DuolingoTheme.duoRed;
  }

  String _getRiskLabel(double risk) {
    if (widget.riskLabels != null && widget.riskLabels!.isNotEmpty) {
      int index = (risk * (widget.riskLabels!.length - 1)).round();
      return widget.riskLabels![index];
    }
    
    if (risk < 0.2) return 'Very Low';
    if (risk < 0.4) return 'Low';
    if (risk < 0.6) return 'Moderate';
    if (risk < 0.8) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            widget.description,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Risk Meter
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _riskAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RiskMeterPainter(
                      riskLevel: _riskAnimation.value,
                      color: _getRiskColor(_riskAnimation.value),
                    ),
                    child: widget.isInteractive
                        ? GestureDetector(
                            onPanUpdate: (details) {
                              if (widget.onRiskChanged != null) {
                                final center = const Offset(100, 100);
                                final touchPoint = details.localPosition;
                                final angle = math.atan2(
                                  touchPoint.dy - center.dy,
                                  touchPoint.dx - center.dx,
                                );
                                
                                // Convert angle to risk level (0-1)
                                double risk = (angle + math.pi) / (2 * math.pi);
                                risk = risk.clamp(0.0, 1.0);
                                
                                setState(() {
                                  _currentRisk = risk;
                                });
                                widget.onRiskChanged!(risk);
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              color: Colors.transparent,
                            ),
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            color: Colors.transparent,
                          ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Risk Level Indicator
          Center(
            child: AnimatedBuilder(
              animation: _riskAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DuolingoTheme.spacingMd,
                        vertical: DuolingoTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: _getRiskColor(_riskAnimation.value).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                        border: Border.all(
                          color: _getRiskColor(_riskAnimation.value),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _getRiskLabel(_riskAnimation.value),
                        style: DuolingoTheme.bodyLarge.copyWith(
                          color: _getRiskColor(_riskAnimation.value),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    Text(
                      '${(_riskAnimation.value * 100).toInt()}%',
                      style: DuolingoTheme.h3.copyWith(
                        color: _getRiskColor(_riskAnimation.value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          if (widget.isInteractive) ...[
            const SizedBox(height: DuolingoTheme.spacingLg),
            Center(
              child: Text(
                'Drag around the meter to adjust risk level',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RiskMeterPainter extends CustomPainter {
  final double riskLevel;
  final Color color;

  RiskMeterPainter({
    required this.riskLevel,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw risk level arc
    final riskPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * riskLevel;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      riskPaint,
    );

    // Draw needle
    final needleAngle = startAngle + sweepAngle;
    final needleEnd = Offset(
      center.dx + (radius - 10) * math.cos(needleAngle),
      center.dy + (radius - 10) * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // Draw needle line
    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i <= 10; i++) {
      final tickAngle = -math.pi / 2 + (2 * math.pi * i / 10);
      final tickStart = Offset(
        center.dx + (radius + 5) * math.cos(tickAngle),
        center.dy + (radius + 5) * math.sin(tickAngle),
      );
      final tickEnd = Offset(
        center.dx + (radius + 15) * math.cos(tickAngle),
        center.dy + (radius + 15) * math.sin(tickAngle),
      );

      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RiskMeterPainter &&
        (oldDelegate.riskLevel != riskLevel || oldDelegate.color != color);
  }
}

// Risk Assessment Widget
class RiskAssessmentWidget extends StatefulWidget {
  final Map<String, dynamic> assessmentData;
  final Function(Map<String, dynamic>)? onAssessmentComplete;

  const RiskAssessmentWidget({
    super.key,
    required this.assessmentData,
    this.onAssessmentComplete,
  });

  @override
  State<RiskAssessmentWidget> createState() => _RiskAssessmentWidgetState();
}

class _RiskAssessmentWidgetState extends State<RiskAssessmentWidget> {
  int currentQuestionIndex = 0;
  Map<int, int> answers = {};
  bool showResults = false;

  void _answerQuestion(int optionIndex) {
    setState(() {
      answers[currentQuestionIndex] = optionIndex;
      
      if (currentQuestionIndex < widget.assessmentData['questions'].length - 1) {
        currentQuestionIndex++;
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    setState(() {
      showResults = true;
    });

    // Calculate total score
    int totalScore = answers.values.fold(0, (sum, score) => sum + score);
    
    // Determine risk profile
    String profile = 'Moderate';
    String description = 'You have a balanced approach to risk';
    
    final scoring = widget.assessmentData['scoring'];
    for (String range in scoring.keys) {
      final rangeParts = range.split('-');
      final min = int.parse(rangeParts[0]);
      final max = int.parse(rangeParts[1]);
      
      if (totalScore >= min && totalScore <= max) {
        profile = scoring[range]['profile'];
        description = scoring[range]['description'];
        break;
      }
    }

    if (widget.onAssessmentComplete != null) {
      widget.onAssessmentComplete!({
        'totalScore': totalScore,
        'profile': profile,
        'description': description,
        'answers': answers,
      });
    }
  }

  void _resetAssessment() {
    setState(() {
      currentQuestionIndex = 0;
      answers.clear();
      showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResults();
    }

    final questions = widget.assessmentData['questions'] as List;
    final currentQuestion = questions[currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoGreen),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),

          const SizedBox(height: DuolingoTheme.spacingLg),

          // Question
          Text(
            currentQuestion['question'],
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: DuolingoTheme.spacingLg),

          // Options
          ...List.generate(
            currentQuestion['options'].length,
            (index) {
              final option = currentQuestion['options'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(option['score']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DuolingoTheme.duoGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                      ),
                    ),
                    child: Text(
                      option['text'],
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    int totalScore = answers.values.fold(0, (sum, score) => sum + score);
    
    String profile = 'Moderate';
    String description = 'You have a balanced approach to risk';
    
    final scoring = widget.assessmentData['scoring'];
    for (String range in scoring.keys) {
      final rangeParts = range.split('-');
      final min = int.parse(rangeParts[0]);
      final max = int.parse(rangeParts[1]);
      
      if (totalScore >= min && totalScore <= max) {
        profile = scoring[range]['profile'];
        description = scoring[range]['description'];
        break;
      }
    }

    double riskLevel = (totalScore - 3) / 9; // Normalize to 0-1

    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.assessment,
            size: 48,
            color: DuolingoTheme.duoGreen,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Text(
            'Your Risk Profile',
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DuolingoTheme.spacingLg,
              vertical: DuolingoTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(color: DuolingoTheme.duoGreen),
            ),
            child: Text(
              profile,
              style: DuolingoTheme.h3.copyWith(
                color: DuolingoTheme.duoGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Text(
            description,
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          RiskMeterWidget(
            riskLevel: riskLevel,
            title: 'Risk Tolerance Level',
            description: 'Based on your assessment responses',
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: DuolingoTheme.duoBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Take Assessment Again',
                style: DuolingoTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}