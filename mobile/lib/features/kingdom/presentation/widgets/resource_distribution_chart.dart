import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/models/resource_types.dart';
import '../../domain/models/resource_management_state.dart';
import '../../../../core/config/duolingo_theme.dart';

class ResourceDistributionChart extends StatefulWidget {
  final ResourceManagementState resourceState;
  final double size;
  final bool showLabels;
  final Function(ResourceType)? onResourceTap;

  const ResourceDistributionChart({
    super.key,
    required this.resourceState,
    this.size = 200.0,
    this.showLabels = true,
    this.onResourceTap,
  });

  @override
  State<ResourceDistributionChart> createState() => _ResourceDistributionChartState();
}

class _ResourceDistributionChartState extends State<ResourceDistributionChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;
  ResourceType? _hoveredResource;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onResourceHover(ResourceType? resource) {
    setState(() {
      _hoveredResource = resource;
    });
    
    if (resource != null) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return const Color(0xFFFFD700);
      case ResourceType.gems:
        return DuolingoTheme.duoBlue;
      case ResourceType.wood:
        return const Color(0xFF8B4513);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size + (widget.showLabels ? 60 : 0),
      child: Column(
        children: [
          // Pie chart
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: Listenable.merge([_animation, _pulseAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: ResourcePieChartPainter(
                    resourceState: widget.resourceState,
                    animationValue: _animation.value,
                    hoveredResource: _hoveredResource,
                    pulseValue: _pulseAnimation.value,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) => _handleTap(details.localPosition),
                    onPanUpdate: (details) => _handlePan(details.localPosition),
                    onPanEnd: (_) => _onResourceHover(null),
                    child: Container(),
                  ),
                );
              },
            ),
          ),
          
          // Labels
          if (widget.showLabels) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  void _handleTap(Offset position) {
    final resource = _getResourceAtPosition(position);
    if (resource != null && widget.onResourceTap != null) {
      widget.onResourceTap!(resource);
    }
  }

  void _handlePan(Offset position) {
    final resource = _getResourceAtPosition(position);
    _onResourceHover(resource);
  }

  ResourceType? _getResourceAtPosition(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (position - center).distance;
    final radius = widget.size / 2 - 20; // Account for stroke width
    
    if (distance > radius) return null;
    
    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    final normalizedAngle = (angle + math.pi * 2) % (math.pi * 2);
    
    double currentAngle = -math.pi / 2; // Start from top
    
    for (final type in ResourceType.values) {
      final percentage = widget.resourceState.getAllocationPercentage(type);
      final sweepAngle = (percentage / 100) * 2 * math.pi;
      
      if (normalizedAngle >= currentAngle && normalizedAngle < currentAngle + sweepAngle) {
        return type;
      }
      
      currentAngle += sweepAngle;
    }
    
    return null;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ResourceType.values.map((type) {
        final isHovered = _hoveredResource == type;
        final percentage = widget.resourceState.getAllocationPercentage(type);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isHovered ? 1.1 : 1.0),
          child: GestureDetector(
            onTap: () {
              _onResourceHover(type);
              widget.onResourceTap?.call(type);
            },
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getResourceColor(type),
                    shape: BoxShape.circle,
                    boxShadow: isHovered ? [
                      BoxShadow(
                        color: _getResourceColor(type).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.displayName,
                  style: DuolingoTheme.caption.copyWith(
                    fontWeight: isHovered ? FontWeight.w600 : FontWeight.w400,
                    color: isHovered ? DuolingoTheme.charcoal : DuolingoTheme.darkGray,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: DuolingoTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getResourceColor(type),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ResourcePieChartPainter extends CustomPainter {
  final ResourceManagementState resourceState;
  final double animationValue;
  final ResourceType? hoveredResource;
  final double pulseValue;

  ResourcePieChartPainter({
    required this.resourceState,
    required this.animationValue,
    this.hoveredResource,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw background circle
    final backgroundPaint = Paint()
      ..color = DuolingoTheme.lightGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw pie slices
    double currentAngle = -math.pi / 2; // Start from top
    
    for (final type in ResourceType.values) {
      final percentage = resourceState.getAllocationPercentage(type);
      final sweepAngle = (percentage / 100) * 2 * math.pi * animationValue;
      
      if (sweepAngle > 0) {
        final isHovered = hoveredResource == type;
        final sliceRadius = radius + (isHovered ? 10 * pulseValue : 0);
        
        // Draw slice
        final slicePaint = Paint()
          ..color = _getResourceColor(type)
          ..style = PaintingStyle.fill;
        
        final slicePath = Path();
        slicePath.moveTo(center.dx, center.dy);
        slicePath.arcTo(
          Rect.fromCenter(center: center, width: sliceRadius * 2, height: sliceRadius * 2),
          currentAngle,
          sweepAngle,
          false,
        );
        slicePath.close();
        
        canvas.drawPath(slicePath, slicePaint);
        
        // Draw slice border
        final borderPaint = Paint()
          ..color = DuolingoTheme.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        canvas.drawPath(slicePath, borderPaint);
        
        // Draw resource icon in center of slice
        if (sweepAngle > 0.3) { // Only draw icon if slice is large enough
          final iconAngle = currentAngle + sweepAngle / 2;
          final iconRadius = sliceRadius * 0.7;
          final iconCenter = Offset(
            center.dx + math.cos(iconAngle) * iconRadius,
            center.dy + math.sin(iconAngle) * iconRadius,
          );
          
          _drawResourceIcon(canvas, type, iconCenter, isHovered);
        }
      }
      
      currentAngle += sweepAngle;
    }
    
    // Draw center circle with total value
    final centerCirclePaint = Paint()
      ..color = DuolingoTheme.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 30, centerCirclePaint);
    
    final centerBorderPaint = Paint()
      ..color = DuolingoTheme.duoGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, 30, centerBorderPaint);
    
    // Draw total value text in center
    final totalValue = resourceState.totalAllocatedResources;
    final textPainter = TextPainter(
      text: TextSpan(
        text: totalValue.toString(),
        style: DuolingoTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: DuolingoTheme.duoGreen,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawResourceIcon(Canvas canvas, ResourceType type, Offset center, bool isHovered) {
    final iconPaint = Paint()
      ..color = DuolingoTheme.white
      ..style = PaintingStyle.fill;
    
    final iconSize = isHovered ? 16.0 : 12.0;
    
    switch (type) {
      case ResourceType.gold:
        // Draw coin
        canvas.drawCircle(center, iconSize / 2, iconPaint);
        final coinBorderPaint = Paint()
          ..color = _getResourceColor(type)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(center, iconSize / 2, coinBorderPaint);
        break;
        
      case ResourceType.gems:
        // Draw diamond
        final diamondPath = Path();
        diamondPath.moveTo(center.dx, center.dy - iconSize / 2);
        diamondPath.lineTo(center.dx + iconSize / 3, center.dy);
        diamondPath.lineTo(center.dx, center.dy + iconSize / 2);
        diamondPath.lineTo(center.dx - iconSize / 3, center.dy);
        diamondPath.close();
        canvas.drawPath(diamondPath, iconPaint);
        break;
        
      case ResourceType.wood:
        // Draw tree
        final trunkPaint = Paint()
          ..color = DuolingoTheme.white
          ..style = PaintingStyle.fill;
        
        final trunkRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + iconSize / 4),
          width: iconSize / 4,
          height: iconSize / 2,
        );
        canvas.drawRect(trunkRect, trunkPaint);
        
        canvas.drawCircle(
          Offset(center.dx, center.dy - iconSize / 4),
          iconSize / 3,
          iconPaint,
        );
        break;
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return const Color(0xFFFFD700);
      case ResourceType.gems:
        return DuolingoTheme.duoBlue;
      case ResourceType.wood:
        return const Color(0xFF8B4513);
    }
  }

  @override
  bool shouldRepaint(ResourcePieChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.hoveredResource != hoveredResource ||
           oldDelegate.pulseValue != pulseValue ||
           oldDelegate.resourceState != resourceState;
  }
}