import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';

class GamificationAnalyticsDashboard extends StatefulWidget {
  final Map<String, dynamic> analyticsData;

  const GamificationAnalyticsDashboard({
    super.key,
    required this.analyticsData,
  });

  @override
  State<GamificationAnalyticsDashboard> createState() => _GamificationAnalyticsDashboardState();
}

class _GamificationAnalyticsDashboardState extends State<GamificationAnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard header
                Text(
                  'Gamification Analytics',
                  style: DuolingoTheme.h2.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                Text(
                  'Track your engagement and progress',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                ),
                
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // Overview cards
                OverviewCardsSection(
                  analyticsData: widget.analyticsData,
                ),
                
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // XP Progress Chart
                XPProgressChart(
                  xpData: widget.analyticsData['xpHistory'] ?? [],
                ),
                
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // Achievement Progress Chart
                AchievementProgressChart(
                  achievementData: widget.analyticsData['achievementProgress'] ?? {},
                ),
                
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // Activity Heat Map
                ActivityHeatMap(
                  activityData: widget.analyticsData['dailyActivity'] ?? {},
                ),
                
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                // Engagement Metrics
                EngagementMetrics(
                  metricsData: widget.analyticsData['engagement'] ?? {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OverviewCardsSection extends StatelessWidget {
  final Map<String, dynamic> analyticsData;

  const OverviewCardsSection({
    super.key,
    required this.analyticsData,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: DuolingoTheme.spacingMd,
      mainAxisSpacing: DuolingoTheme.spacingMd,
      childAspectRatio: 1.3,
      children: [
        _buildOverviewCard(
          'Total XP',
          '${analyticsData['totalXP'] ?? 0}',
          Icons.star,
          DuolingoTheme.duoYellow,
        ),
        _buildOverviewCard(
          'Achievements',
          '${analyticsData['achievementsUnlocked'] ?? 0}/${analyticsData['totalAchievements'] ?? 0}',
          Icons.emoji_events,
          DuolingoTheme.duoPurple,
        ),
        _buildOverviewCard(
          'Current Streak',
          '${analyticsData['currentStreak'] ?? 0} days',
          Icons.local_fire_department,
          DuolingoTheme.duoOrange,
        ),
        _buildOverviewCard(
          'Level',
          '${analyticsData['currentLevel'] ?? 1}',
          Icons.trending_up,
          DuolingoTheme.duoGreen,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: DuolingoTheme.iconLarge,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            value,
            style: DuolingoTheme.h3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          Text(
            title,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class XPProgressChart extends StatefulWidget {
  final List<Map<String, dynamic>> xpData;

  const XPProgressChart({
    super.key,
    required this.xpData,
  });

  @override
  State<XPProgressChart> createState() => _XPProgressChartState();
}

class _XPProgressChartState extends State<XPProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XP Progress (Last 7 Days)',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: XPChartPainter(
                    xpData: widget.xpData,
                    progress: _progressAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class XPChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> xpData;
  final double progress;

  XPChartPainter({
    required this.xpData,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (xpData.isEmpty) return;

    final paint = Paint()
      ..color = DuolingoTheme.duoYellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          DuolingoTheme.duoYellow.withValues(alpha: 0.3),
          DuolingoTheme.duoYellow.withValues(alpha: 0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxXP = xpData.map((data) => data['xp'] as int).reduce(math.max).toDouble();
    final stepWidth = size.width / (xpData.length - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < xpData.length; i++) {
      final x = i * stepWidth;
      final y = size.height - (xpData[i]['xp'] / maxXP * size.height * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw data points
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = DuolingoTheme.duoYellow,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < xpData.length; i++) {
      final x = i * stepWidth;
      
      textPainter.text = TextSpan(
        text: xpData[i]['day'],
        style: DuolingoTheme.caption.copyWith(
          color: DuolingoTheme.darkGray,
        ),
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(x - textPainter.width / 2, size.height + 10);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(XPChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.xpData != xpData;
  }
}

class AchievementProgressChart extends StatefulWidget {
  final Map<String, dynamic> achievementData;

  const AchievementProgressChart({
    super.key,
    required this.achievementData,
  });

  @override
  State<AchievementProgressChart> createState() => _AchievementProgressChartState();
}

class _AchievementProgressChartState extends State<AchievementProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Progress by Category',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: AchievementChartPainter(
                    achievementData: widget.achievementData,
                    progress: _progressAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementChartPainter extends CustomPainter {
  final Map<String, dynamic> achievementData;
  final double progress;

  AchievementChartPainter({
    required this.achievementData,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final categories = achievementData.keys.toList();
    if (categories.isEmpty) return;

    final barWidth = size.width / categories.length * 0.7;
    final spacing = size.width / categories.length * 0.3;
    final maxValue = achievementData.values.map((v) => v['total'] as int).reduce(math.max).toDouble();

    final colors = [
      DuolingoTheme.duoGreen,
      DuolingoTheme.duoBlue,
      DuolingoTheme.duoPurple,
      DuolingoTheme.duoYellow,
      DuolingoTheme.duoOrange,
      DuolingoTheme.duoRed,
    ];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final data = achievementData[category];
      final unlocked = data['unlocked'] as int;
      final total = data['total'] as int;
      
      final x = i * (barWidth + spacing) + spacing / 2;
      final totalBarHeight = (total / maxValue) * size.height * 0.8;
      final unlockedBarHeight = (unlocked / maxValue) * size.height * 0.8 * progress;
      
      // Draw total bar (background)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - totalBarHeight, barWidth, totalBarHeight),
          const Radius.circular(DuolingoTheme.radiusSmall),
        ),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.2),
      );
      
      // Draw unlocked bar (foreground)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - unlockedBarHeight, barWidth, unlockedBarHeight),
          const Radius.circular(DuolingoTheme.radiusSmall),
        ),
        Paint()..color = colors[i % colors.length],
      );
      
      // Draw category label
      final textPainter = TextPainter(
        text: TextSpan(
          text: category.substring(0, 3).toUpperCase(),
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(x + barWidth / 2 - textPainter.width / 2, size.height + 5);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(AchievementChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.achievementData != achievementData;
  }
}

class ActivityHeatMap extends StatefulWidget {
  final Map<String, int> activityData;

  const ActivityHeatMap({
    super.key,
    required this.activityData,
  });

  @override
  State<ActivityHeatMap> createState() => _ActivityHeatMapState();
}

class _ActivityHeatMapState extends State<ActivityHeatMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heat Map (Last 30 Days)',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 120),
                painter: HeatMapPainter(
                  activityData: widget.activityData,
                  progress: _progressAnimation.value,
                ),
              );
            },
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              ...List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: DuolingoTheme.duoGreen.withValues(alpha: (index + 1) * 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'More',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeatMapPainter extends CustomPainter {
  final Map<String, int> activityData;
  final double progress;

  HeatMapPainter({
    required this.activityData,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 7; // Days of week
    const cols = 5; // Weeks
    
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final maxActivity = activityData.values.isNotEmpty 
        ? activityData.values.reduce(math.max) 
        : 1;

    for (int week = 0; week < cols; week++) {
      for (int day = 0; day < rows; day++) {
        final dayKey = '${week}_$day';
        final activity = activityData[dayKey] ?? 0;
        final intensity = maxActivity > 0 ? activity / maxActivity : 0.0;
        
        final rect = Rect.fromLTWH(
          week * cellWidth + 2,
          day * cellHeight + 2,
          cellWidth - 4,
          cellHeight - 4,
        );
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()..color = DuolingoTheme.duoGreen.withValues(
            alpha: intensity * progress * 0.8 + 0.1,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(HeatMapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activityData != activityData;
  }
}

class EngagementMetrics extends StatelessWidget {
  final Map<String, dynamic> metricsData;

  const EngagementMetrics({
    super.key,
    required this.metricsData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Metrics',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Session',
                  '${metricsData['avgSessionTime'] ?? 0}m',
                  Icons.schedule,
                  DuolingoTheme.duoBlue,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: _buildMetricCard(
                  'Completion Rate',
                  '${metricsData['completionRate'] ?? 0}%',
                  Icons.check_circle,
                  DuolingoTheme.duoGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Weekly Goal',
                  '${metricsData['weeklyGoalProgress'] ?? 0}%',
                  Icons.flag,
                  DuolingoTheme.duoPurple,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: _buildMetricCard(
                  'Consistency',
                  '${metricsData['consistencyScore'] ?? 0}%',
                  Icons.trending_up,
                  DuolingoTheme.duoOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: DuolingoTheme.iconMedium,
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            value,
            style: DuolingoTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Mock data generator for development
class MockAnalyticsData {
  static Map<String, dynamic> generateMockData() {
    return {
      'totalXP': 2450,
      'achievementsUnlocked': 8,
      'totalAchievements': 24,
      'currentStreak': 12,
      'currentLevel': 7,
      'xpHistory': [
        {'day': 'Mon', 'xp': 150},
        {'day': 'Tue', 'xp': 200},
        {'day': 'Wed', 'xp': 180},
        {'day': 'Thu', 'xp': 220},
        {'day': 'Fri', 'xp': 300},
        {'day': 'Sat', 'xp': 250},
        {'day': 'Sun', 'xp': 180},
      ],
      'achievementProgress': {
        'education': {'unlocked': 4, 'total': 8},
        'trading': {'unlocked': 2, 'total': 6},
        'social': {'unlocked': 1, 'total': 4},
        'streaks': {'unlocked': 1, 'total': 3},
        'kingdom': {'unlocked': 0, 'total': 2},
        'milestones': {'unlocked': 0, 'total': 1},
      },
      'dailyActivity': Map.fromEntries(
        List.generate(35, (index) => MapEntry(
          '${index ~/ 7}_${index % 7}',
          math.Random().nextInt(5),
        )),
      ),
      'engagement': {
        'avgSessionTime': 25,
        'completionRate': 87,
        'weeklyGoalProgress': 65,
        'consistencyScore': 78,
      },
    };
  }
}