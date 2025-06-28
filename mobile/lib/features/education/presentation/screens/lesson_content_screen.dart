import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../models/lesson_content.dart';
import '../../widgets/education_chart_widgets.dart';
import '../../widgets/interactive_budget_planner.dart';
import '../../widgets/interactive_portfolio_builder.dart';
import '../../widgets/portfolio_pie_chart.dart';
import '../../widgets/education_quiz_widget.dart';

class LessonContentScreen extends ConsumerStatefulWidget {
  final LessonContent lesson;

  const LessonContentScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends ConsumerState<LessonContentScreen> {
  bool _isCompleted = false;
  int _quizScore = 0;
  int _quizTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.white,
          ),
        ),
        backgroundColor: DuolingoTheme.duoGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: DuolingoTheme.white),
        actions: [
          if (_isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: DuolingoTheme.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Complete',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            _buildLessonHeader(),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Lesson content based on type
            _buildLessonContent(),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Completion button (for non-quiz lessons)
            if (widget.lesson.type != LessonType.quiz && !_isCompleted)
              _buildCompletionButton(),
            
            if (_isCompleted) ...[
              const SizedBox(height: DuolingoTheme.spacingMd),
              _buildCompletionMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DuolingoTheme.duoGreen, DuolingoTheme.duoGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLessonIcon(),
                  color: DuolingoTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lesson.title,
                      style: DuolingoTheme.h4.copyWith(
                        color: DuolingoTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lesson.description,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: DuolingoTheme.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.lesson.estimatedMinutes} min',
                      style: DuolingoTheme.caption.copyWith(
                        color: DuolingoTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.lesson.learningObjectives.isNotEmpty) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'Learning Objectives:',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            ...widget.lesson.learningObjectives.map((objective) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: const BoxDecoration(
                      color: DuolingoTheme.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      objective,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    switch (widget.lesson.type) {
      case LessonType.text:
        return _buildTextContent();
      case LessonType.chart:
        return _buildChartContent();
      case LessonType.interactive:
        return _buildInteractiveContent();
      case LessonType.quiz:
        return _buildQuizContent();
      case LessonType.video:
        return _buildVideoContent();
    }
  }

  Widget _buildTextContent() {
    final content = widget.lesson.data['content'] as String? ?? '';
    final kingdomAnalogy = widget.lesson.data['kingdomAnalogy'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: DuolingoTheme.white,
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            boxShadow: DuolingoTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.darkGray,
                  height: 1.6,
                ),
              ),
              
              if (kingdomAnalogy.isNotEmpty) ...[
                const SizedBox(height: DuolingoTheme.spacingLg),
                Container(
                  padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                    border: Border.all(
                      color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.castle,
                        color: DuolingoTheme.duoYellow,
                        size: 24,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kingdom Wisdom',
                              style: DuolingoTheme.bodyMedium.copyWith(
                                color: DuolingoTheme.duoYellow,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kingdomAnalogy,
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.darkGray,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent() {
    final chartData = widget.lesson.data as Map<String, dynamic>;
    final chartType = chartData['chartType'] as String;
    final explanation = chartData['explanation'] as String;
    final keyTakeaways = chartData['keyTakeaways'] as List<String>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart display
        if (chartType == 'ChartType.barChart')
          EducationBarChart(
            incomeData: List<Map<String, dynamic>>.from(chartData['chartData']['incomeData']),
            expenseData: List<Map<String, dynamic>>.from(chartData['chartData']['expenseData']),
            title: 'Income vs Expenses Comparison',
          )
        else if (chartType == 'ChartType.pieChart')
          PortfolioPieChart(
            portfolioData: List<Map<String, dynamic>>.from(chartData['chartData']['portfolioAllocation']),
            title: 'Portfolio Allocation Example',
            totalValue: 100000,
          )
        else if (chartType == 'ChartType.riskMeter')
          RiskMeterWidget(
            riskLevel: 45.0,
            title: 'Risk Assessment',
            description: 'Understanding your investment risk level',
          )
        else if (chartType == 'ChartType.custom')
          EmergencyFundChart(
            progressData: List<Map<String, dynamic>>.from(chartData['chartData']['fundProgressExample']),
            targetAmount: 15000,
          ),
        
        const SizedBox(height: DuolingoTheme.spacingLg),
        
        // Explanation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: DuolingoTheme.white,
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            boxShadow: DuolingoTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Understanding the Chart',
                style: DuolingoTheme.h4.copyWith(
                  color: DuolingoTheme.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: DuolingoTheme.spacingMd),
              Text(
                explanation,
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.darkGray,
                  height: 1.6,
                ),
              ),
              
              if (keyTakeaways.isNotEmpty) ...[
                const SizedBox(height: DuolingoTheme.spacingLg),
                Text(
                  'Key Takeaways:',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                ...keyTakeaways.map((takeaway) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: const BoxDecoration(
                          color: DuolingoTheme.duoGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          takeaway,
                          style: DuolingoTheme.bodySmall.copyWith(
                            color: DuolingoTheme.darkGray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveContent() {
    final interactionType = widget.lesson.data['interactionType'] as String;
    final parameters = widget.lesson.data['parameters'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            border: Border.all(
              color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: DuolingoTheme.duoBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Instructions',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.duoBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.lesson.data['instructions'] as String,
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: DuolingoTheme.spacingLg),
        
        // Interactive component
        if (interactionType == 'budget_planner')
          InteractiveBudgetPlanner(
            monthlyIncome: (parameters['monthlyIncome'] as num).toDouble(),
            categories: List<Map<String, dynamic>>.from(parameters['categories']),
            onBudgetChanged: (allocations) {
              // Handle budget changes
            },
          )
        else if (interactionType == 'portfolio_builder')
          InteractivePortfolioBuilder(
            totalAmount: (parameters['totalAmount'] as num).toDouble(),
            assetTypes: List<Map<String, dynamic>>.from(parameters['assetTypes']),
            presetPortfolios: List<Map<String, dynamic>>.from(parameters['presetPortfolios']),
            onAllocationChanged: (allocations) {
              // Handle portfolio changes
            },
          ),
        
        const SizedBox(height: DuolingoTheme.spacingLg),
        
        // Explanation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: DuolingoTheme.white,
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            boxShadow: DuolingoTheme.cardShadow,
          ),
          child: Text(
            parameters['explanation'] as String,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizContent() {
    final questions = List<Map<String, dynamic>>.from(widget.lesson.data['questions']);
    
    return EducationQuizWidget(
      questions: questions,
      onQuizCompleted: (score, total) {
        setState(() {
          _isCompleted = true;
          _quizScore = score;
          _quizTotal = total;
        });
      },
    );
  }

  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.play_circle_outline,
            size: 64,
            color: DuolingoTheme.duoBlue,
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Text(
            'Video Content',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            'Video content coming soon!',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isCompleted = true;
          });
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mark as Complete',
              style: DuolingoTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.celebration,
                color: DuolingoTheme.duoGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Lesson Completed!',
                style: DuolingoTheme.bodyLarge.copyWith(
                  color: DuolingoTheme.duoGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          if (widget.lesson.type == LessonType.quiz) ...[
            const SizedBox(height: 8),
            Text(
              'Quiz Score: $_quizScore/$_quizTotal (${(_quizScore / _quizTotal * 100).round()}%)',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          Text(
            'Great work! You\'ve successfully completed this lesson. Your kingdom\'s knowledge grows stronger!',
            textAlign: TextAlign.center,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon() {
    switch (widget.lesson.type) {
      case LessonType.text:
        return Icons.article;
      case LessonType.chart:
        return Icons.bar_chart;
      case LessonType.interactive:
        return Icons.touch_app;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.video:
        return Icons.play_circle;
    }
  }
}