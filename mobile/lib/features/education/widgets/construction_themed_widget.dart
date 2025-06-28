import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';

class ConstructionPermitWidget extends StatefulWidget {
  final Map<String, dynamic> permitData;
  final Function(String)? onPermitSelected;

  const ConstructionPermitWidget({
    super.key,
    required this.permitData,
    this.onPermitSelected,
  });

  @override
  State<ConstructionPermitWidget> createState() => _ConstructionPermitWidgetState();
}

class _ConstructionPermitWidgetState extends State<ConstructionPermitWidget>
    with TickerProviderStateMixin {
  late AnimationController _buildingController;
  late Animation<double> _buildingAnimation;
  String? selectedPermit;

  @override
  void initState() {
    super.initState();
    
    _buildingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _buildingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buildingController,
      curve: Curves.easeInOut,
    ));
    
    _buildingController.repeat();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    super.dispose();
  }

  void _selectPermit(String permitName) {
    setState(() {
      selectedPermit = permitName;
    });
    
    if (widget.onPermitSelected != null) {
      widget.onPermitSelected!(permitName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permits = widget.permitData['permits'] as List<dynamic>;
    
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
          // Construction Site Header
          Row(
            children: [
              Icon(
                Icons.construction,
                color: DuolingoTheme.duoOrange,
                size: 32,
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Text(
                  'Financial Construction Permits',
                  style: DuolingoTheme.h2.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            'Build your financial knowledge step by step, just like constructing a building',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Construction Animation
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _buildingAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConstructionSitePainter(
                    animationProgress: _buildingAnimation.value,
                  ),
                  size: const Size(double.infinity, 150),
                );
              },
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Permit Cards
          ...permits.map<Widget>((permit) {
            final permitName = permit['name'] as String;
            final isSelected = selectedPermit == permitName;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
              child: GestureDetector(
                onTap: () => _selectPermit(permitName),
                child: _buildPermitCard(permit, isSelected),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPermitCard(Map<String, dynamic> permit, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: isSelected
            ? DuolingoTheme.duoOrange.withValues(alpha: 0.1)
            : DuolingoTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: isSelected ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: DuolingoTheme.duoOrange.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getPermitIcon(permit['name']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permit['name'],
                      style: DuolingoTheme.h4.copyWith(
                        color: isSelected ? DuolingoTheme.duoOrange : DuolingoTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      permit['description'],
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (isSelected) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            // Requirements
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements:',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  ...List.generate(
                    permit['requirements'].length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_box_outline_blank,
                            color: DuolingoTheme.duoOrange,
                            size: 16,
                          ),
                          const SizedBox(width: DuolingoTheme.spacingXs),
                          Expanded(
                            child: Text(
                              permit['requirements'][index],
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.darkGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            // Building Analogy
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.architecture,
                        color: DuolingoTheme.duoBlue,
                        size: 16,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingXs),
                      Text(
                        'Building Analogy:',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: DuolingoTheme.duoBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Text(
                    permit['buildingAnalogy'],
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            // Unlocks
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_open,
                        color: DuolingoTheme.duoGreen,
                        size: 16,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingXs),
                      Text(
                        'Unlocks:',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: DuolingoTheme.duoGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Text(
                    permit['unlocks'],
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getPermitIcon(String permitName) {
    switch (permitName) {
      case 'Foundation Permit':
        return Icons.foundation;
      case 'Framing Permit':
        return Icons.account_tree;
      case 'Electrical Permit':
        return Icons.electrical_services;
      case 'Plumbing Permit':
        return Icons.plumbing;
      default:
        return Icons.assignment;
    }
  }
}

class ConstructionSitePainter extends CustomPainter {
  final double animationProgress;

  ConstructionSitePainter({
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw ground
    paint.color = DuolingoTheme.lightGray;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 20, size.width, 20),
      paint,
    );

    // Draw building foundation
    paint.color = DuolingoTheme.mediumGray;
    final foundationHeight = 30.0 * math.min(1.0, animationProgress * 4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height - 20 - foundationHeight,
        size.width * 0.6,
        foundationHeight,
      ),
      paint,
    );

    // Draw building frame
    if (animationProgress > 0.25) {
      paint.color = DuolingoTheme.duoOrange.withValues(alpha: 0.7);
      final frameProgress = math.min(1.0, (animationProgress - 0.25) * 2);
      final frameHeight = 60 * frameProgress;
      
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.25,
          size.height - 50 - frameHeight,
          size.width * 0.5,
          frameHeight,
        ),
        paint,
      );
    }

    // Draw construction crane
    if (animationProgress > 0.5) {
      strokePaint.color = DuolingoTheme.duoBlue;
      
      // Crane pole
      canvas.drawLine(
        Offset(size.width * 0.8, size.height - 20),
        Offset(size.width * 0.8, 30),
        strokePaint,
      );
      
      // Crane arm
      canvas.drawLine(
        Offset(size.width * 0.8, 40),
        Offset(size.width * 0.95, 40),
        strokePaint,
      );
      
      // Hook and movement
      final hookX = size.width * 0.8 + (size.width * 0.15 * math.sin(animationProgress * math.pi * 4));
      canvas.drawLine(
        Offset(hookX, 40),
        Offset(hookX, 60),
        strokePaint,
      );
      
      // Hook
      paint.color = DuolingoTheme.duoRed;
      canvas.drawCircle(Offset(hookX, 65), 5, paint);
    }

    // Draw construction workers (simple figures)
    if (animationProgress > 0.3) {
      paint.color = DuolingoTheme.duoYellow;
      
      // Worker 1
      canvas.drawCircle(
        Offset(size.width * 0.3, size.height - 35),
        8,
        paint,
      );
      
      // Worker 2
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height - 35),
        8,
        paint,
      );
    }

    // Draw progress indicators (safety cones)
    paint.color = DuolingoTheme.duoOrange;
    for (int i = 0; i < 3; i++) {
      final coneX = size.width * 0.1 + (i * size.width * 0.1);
      if (animationProgress > i * 0.2) {
        _drawCone(canvas, Offset(coneX, size.height - 20), paint);
      }
    }
  }

  void _drawCone(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.lineTo(position.dx - 8, position.dy - 20);
    path.lineTo(position.dx + 8, position.dy - 20);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ConstructionSitePainter &&
        oldDelegate.animationProgress != animationProgress;
  }
}

// Final Inspection Widget
class FinalInspectionWidget extends StatefulWidget {
  final Map<String, dynamic> inspectionData;
  final Function(Map<String, dynamic>)? onInspectionComplete;

  const FinalInspectionWidget({
    super.key,
    required this.inspectionData,
    this.onInspectionComplete,
  });

  @override
  State<FinalInspectionWidget> createState() => _FinalInspectionWidgetState();
}

class _FinalInspectionWidgetState extends State<FinalInspectionWidget> {
  Map<String, List<bool>> areaCompletions = {};
  bool inspectionStarted = false;
  bool inspectionComplete = false;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _initializeInspection();
  }

  void _initializeInspection() {
    final areas = widget.inspectionData['inspectionAreas'] as List;
    for (final area in areas) {
      final areaName = area['area'] as String;
      final requirements = area['requirements'] as List;
      areaCompletions[areaName] = List.filled(requirements.length, false);
    }
  }

  void _toggleRequirement(String areaName, int requirementIndex) {
    setState(() {
      areaCompletions[areaName]![requirementIndex] = 
          !areaCompletions[areaName]![requirementIndex];
      _calculateScore();
    });
  }

  void _calculateScore() {
    final areas = widget.inspectionData['inspectionAreas'] as List;
    totalScore = 0;
    
    for (final area in areas) {
      final areaName = area['area'] as String;
      final weight = area['weight'] as int;
      final completions = areaCompletions[areaName]!;
      
      final areaProgress = completions.where((c) => c).length / completions.length;
      totalScore += (areaProgress * weight).round();
    }
    
    final passingScore = widget.inspectionData['passingScore'] as int;
    if (totalScore >= passingScore && !inspectionComplete) {
      setState(() {
        inspectionComplete = true;
      });
      
      if (widget.onInspectionComplete != null) {
        widget.onInspectionComplete!({
          'passed': true,
          'score': totalScore,
          'certification': widget.inspectionData['certification'],
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final areas = widget.inspectionData['inspectionAreas'] as List;
    final passingScore = widget.inspectionData['passingScore'] as int;
    
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
          // Header
          Row(
            children: [
              Icon(
                Icons.fact_check,
                color: DuolingoTheme.duoGreen,
                size: 32,
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Text(
                  'Final Building Inspection',
                  style: DuolingoTheme.h2.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Score Display
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: totalScore >= passingScore
                  ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
                  : DuolingoTheme.duoOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(
                color: totalScore >= passingScore
                    ? DuolingoTheme.duoGreen
                    : DuolingoTheme.duoOrange,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inspection Score:',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalScore / 100 (Need $passingScore to pass)',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    color: totalScore >= passingScore
                        ? DuolingoTheme.duoGreen
                        : DuolingoTheme.duoOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Inspection Areas
          ...areas.map<Widget>((area) => _buildInspectionArea(area)),
          
          if (inspectionComplete) ...[
            const SizedBox(height: DuolingoTheme.spacingLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DuolingoTheme.duoGreen,
                    DuolingoTheme.duoGreenLight,
                  ],
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
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Inspection Passed!',
                    style: DuolingoTheme.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.inspectionData['certification'],
                    style: DuolingoTheme.bodyLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInspectionArea(Map<String, dynamic> area) {
    final areaName = area['area'] as String;
    final weight = area['weight'] as int;
    final requirements = area['requirements'] as List;
    final completions = areaCompletions[areaName]!;
    final completed = completions.where((c) => c).length;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        decoration: BoxDecoration(
          color: DuolingoTheme.lightGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          border: Border.all(
            color: DuolingoTheme.mediumGray,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  areaName,
                  style: DuolingoTheme.h4.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completed/${requirements.length} ($weight% weight)',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            ...List.generate(
              requirements.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
                child: GestureDetector(
                  onTap: () => _toggleRequirement(areaName, index),
                  child: Row(
                    children: [
                      Icon(
                        completions[index] ? Icons.check_box : Icons.check_box_outline_blank,
                        color: completions[index] ? DuolingoTheme.duoGreen : DuolingoTheme.mediumGray,
                        size: 24,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingSm),
                      Expanded(
                        child: Text(
                          requirements[index],
                          style: DuolingoTheme.bodyMedium.copyWith(
                            color: completions[index] ? DuolingoTheme.duoGreen : DuolingoTheme.darkGray,
                            decoration: completions[index] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}