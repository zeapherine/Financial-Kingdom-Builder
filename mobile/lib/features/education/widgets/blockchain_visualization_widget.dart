import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';

class BlockchainVisualizationWidget extends StatefulWidget {
  final Map<String, dynamic> visualizationData;
  final Function(Map<String, dynamic>)? onVisualizationComplete;

  const BlockchainVisualizationWidget({
    super.key,
    required this.visualizationData,
    this.onVisualizationComplete,
  });

  @override
  State<BlockchainVisualizationWidget> createState() => _BlockchainVisualizationWidgetState();
}

class _BlockchainVisualizationWidgetState extends State<BlockchainVisualizationWidget>
    with TickerProviderStateMixin {
  late AnimationController _stepController;
  late AnimationController _chainController;
  late Animation<double> _stepAnimation;
  late Animation<double> _chainAnimation;
  
  int currentStep = 0;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    ));
    
    _chainAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chainController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _stepController.dispose();
    _chainController.dispose();
    super.dispose();
  }

  void _playVisualization() async {
    if (isPlaying) return;
    
    setState(() {
      isPlaying = true;
      currentStep = 0;
    });
    
    final steps = widget.visualizationData['simulationSteps'] as List;
    
    for (int i = 0; i < steps.length; i++) {
      setState(() {
        currentStep = i;
      });
      
      _stepController.reset();
      await _stepController.forward();
      
      if (i == steps.length - 1) {
        // Final step - animate the chain update
        _chainController.reset();
        await _chainController.forward();
      }
      
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    
    setState(() {
      isPlaying = false;
    });
    
    if (widget.onVisualizationComplete != null) {
      widget.onVisualizationComplete!({
        'completed': true,
        'stepsShown': steps.length,
      });
    }
  }

  void _resetVisualization() {
    setState(() {
      currentStep = 0;
      isPlaying = false;
    });
    _stepController.reset();
    _chainController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.visualizationData['simulationSteps'] as List;
    final blockStructure = widget.visualizationData['blockStructure'] as Map<String, dynamic>;
    
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
          // Title
          Text(
            'Blockchain Process Visualization',
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isPlaying ? null : _playVisualization,
                icon: Icon(isPlaying ? Icons.hourglass_empty : Icons.play_arrow),
                label: Text(isPlaying ? 'Playing...' : 'Start Animation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DuolingoTheme.duoGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              ElevatedButton.icon(
                onPressed: _resetVisualization,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DuolingoTheme.duoBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Current Step Info
          if (currentStep < steps.length) ...[
            AnimatedBuilder(
              animation: _stepAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * _stepAnimation.value),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                          DuolingoTheme.duoPurple.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                      border: Border.all(
                        color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: DuolingoTheme.duoBlue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${steps[currentStep]['step']}',
                                  style: DuolingoTheme.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: DuolingoTheme.spacingMd),
                            Expanded(
                              child: Text(
                                steps[currentStep]['title'],
                                style: DuolingoTheme.h3.copyWith(
                                  color: DuolingoTheme.duoBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DuolingoTheme.spacingMd),
                        Text(
                          steps[currentStep]['description'],
                          style: DuolingoTheme.bodyLarge.copyWith(
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
          ],
          
          // Blockchain Visualization
          SizedBox(
            height: 300,
            child: AnimatedBuilder(
              animation: Listenable.merge([_stepAnimation, _chainAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: BlockchainPainter(
                    stepProgress: _stepAnimation.value,
                    chainProgress: _chainAnimation.value,
                    currentStep: currentStep,
                    blockData: blockStructure,
                  ),
                  size: const Size(double.infinity, 300),
                );
              },
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Block Structure Display
          if (currentStep >= 3) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: DuolingoTheme.duoYellow,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Block Structure',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.duoYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  _buildBlockField('Block Number', '${blockStructure['blockNumber']}'),
                  _buildBlockField('Timestamp', blockStructure['timestamp']),
                  _buildBlockField('Previous Hash', '${blockStructure['previousHash'].substring(0, 10)}...'),
                  _buildBlockField('Current Hash', '${blockStructure['currentHash'].substring(0, 10)}...'),
                  _buildBlockField('Nonce', '${blockStructure['nonce']}'),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Text(
                    'Transactions in this block:',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...List.generate(
                    blockStructure['transactions'].length,
                    (index) {
                      final tx = blockStructure['transactions'][index];
                      return Padding(
                        padding: const EdgeInsets.only(top: DuolingoTheme.spacingXs),
                        child: Text(
                          '• ${tx['from']} → ${tx['to']}: ${tx['amount']} coins',
                          style: DuolingoTheme.bodySmall.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlockField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.charcoal,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlockchainPainter extends CustomPainter {
  final double stepProgress;
  final double chainProgress;
  final int currentStep;
  final Map<String, dynamic> blockData;

  BlockchainPainter({
    required this.stepProgress,
    required this.chainProgress,
    required this.currentStep,
    required this.blockData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw blockchain (3 blocks connected)
    _drawBlockchain(canvas, size, paint, strokePaint);

    // Draw current step visualization
    if (currentStep < 6) {
      _drawStepVisualization(canvas, size, paint, strokePaint);
    }
  }

  void _drawBlockchain(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    final blockWidth = 80.0;
    final blockHeight = 60.0;
    final spacing = 20.0;
    final startX = (size.width - (3 * blockWidth + 2 * spacing)) / 2;
    final blockY = size.height - blockHeight - 40;

    // Draw blocks
    for (int i = 0; i < 3; i++) {
      final blockX = startX + i * (blockWidth + spacing);
      final rect = Rect.fromLTWH(blockX, blockY, blockWidth, blockHeight);

      // Block color based on step progress
      Color blockColor;
      if (i < 2) {
        blockColor = DuolingoTheme.duoGreen; // Existing blocks
      } else {
        // New block being added
        blockColor = currentStep >= 4
            ? DuolingoTheme.duoGreen.withValues(alpha: chainProgress)
            : DuolingoTheme.lightGray;
      }

      paint.color = blockColor;
      strokePaint.color = DuolingoTheme.charcoal;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        strokePaint,
      );

      // Block label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Block ${i + (i < 2 ? blockData['blockNumber'] - 2 : 0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          blockX + (blockWidth - textPainter.width) / 2,
          blockY + (blockHeight - textPainter.height) / 2,
        ),
      );

      // Draw connection lines
      if (i < 2) {
        final lineY = blockY + blockHeight / 2;
        final lineStart = blockX + blockWidth;
        final lineEnd = blockX + blockWidth + spacing;

        strokePaint.color = DuolingoTheme.duoBlue;
        strokePaint.strokeWidth = 3;
        canvas.drawLine(
          Offset(lineStart, lineY),
          Offset(lineEnd, lineY),
          strokePaint,
        );

        // Arrow
        final arrowSize = 8.0;
        final arrowPath = Path();
        arrowPath.moveTo(lineEnd - arrowSize, lineY - arrowSize / 2);
        arrowPath.lineTo(lineEnd, lineY);
        arrowPath.lineTo(lineEnd - arrowSize, lineY + arrowSize / 2);
        canvas.drawPath(arrowPath, strokePaint);
      }
    }
  }

  void _drawStepVisualization(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    final centerX = size.width / 2;
    final topY = 50.0;

    switch (currentStep) {
      case 0: // New Transaction
        _drawTransaction(canvas, centerX, topY, paint);
        break;
      case 1: // Transaction Pool
        _drawTransactionPool(canvas, centerX, topY, paint);
        break;
      case 2: // Miners Compete
        _drawMiners(canvas, size, paint, strokePaint);
        break;
      case 3: // Block Created
        _drawBlockCreation(canvas, centerX, topY, paint, strokePaint);
        break;
      case 4: // Network Verification
        _drawNetworkVerification(canvas, size, paint);
        break;
      case 5: // Chain Updated
        _drawChainUpdate(canvas, size, paint);
        break;
    }
  }

  void _drawTransaction(Canvas canvas, double centerX, double topY, Paint paint) {
    // Draw transaction as a glowing circle
    paint.color = DuolingoTheme.duoYellow.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(centerX, topY + 30), 25 * stepProgress, paint);

    paint.color = DuolingoTheme.duoYellow;
    canvas.drawCircle(Offset(centerX, topY + 30), 15 * stepProgress, paint);

    // Transaction details
    if (stepProgress > 0.5) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Alice → Bob\n5 coins',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          topY + 20,
        ),
      );
    }
  }

  void _drawTransactionPool(Canvas canvas, double centerX, double topY, Paint paint) {
    // Draw multiple transactions in a pool
    final transactions = [
      {'x': centerX - 30, 'y': topY + 20},
      {'x': centerX, 'y': topY + 40},
      {'x': centerX + 30, 'y': topY + 20},
      {'x': centerX - 15, 'y': topY + 60},
      {'x': centerX + 15, 'y': topY + 60},
    ];

    for (int i = 0; i < transactions.length; i++) {
      final delay = i * 0.2;
      final progress = math.max(0.0, math.min(1.0, (stepProgress - delay) / 0.8));
      
      if (progress > 0) {
        paint.color = DuolingoTheme.duoOrange.withValues(alpha: progress);
        canvas.drawCircle(
          Offset(transactions[i]['x']!, transactions[i]['y']!),
          8 * progress,
          paint,
        );
      }
    }
  }

  void _drawMiners(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    // Draw miners as working computers around the edge
    final miners = [
      {'x': 50.0, 'y': 100.0},
      {'x': size.width - 50, 'y': 100.0},
      {'x': 50.0, 'y': 150.0},
      {'x': size.width - 50, 'y': 150.0},
    ];

    for (int i = 0; i < miners.length; i++) {
      final delay = i * 0.25;
      final progress = math.max(0.0, math.min(1.0, (stepProgress - delay) / 0.75));
      
      if (progress > 0) {
        // Computer icon
        final rect = Rect.fromCenter(
          center: Offset(miners[i]['x']!, miners[i]['y']!),
          width: 30 * progress,
          height: 20 * progress,
        );
        
        paint.color = DuolingoTheme.duoBlue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );

        // Working animation (flashing)
        if (stepProgress > 0.5) {
          final flash = (stepProgress * 10) % 1;
          if (flash > 0.5) {
            paint.color = DuolingoTheme.duoYellow.withValues(alpha: 0.7);
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(4)),
              paint,
            );
          }
        }
      }
    }
  }

  void _drawBlockCreation(Canvas canvas, double centerX, double topY, Paint paint, Paint strokePaint) {
    // Draw new block being assembled
    final blockWidth = 60.0 * stepProgress;
    final blockHeight = 40.0 * stepProgress;
    final rect = Rect.fromCenter(
      center: Offset(centerX, topY + 30),
      width: blockWidth,
      height: blockHeight,
    );

    paint.color = DuolingoTheme.duoGreen.withValues(alpha: stepProgress);
    strokePaint.color = DuolingoTheme.charcoal;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      strokePaint,
    );

    // Sparkle effect
    if (stepProgress > 0.7) {
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) + (stepProgress * math.pi * 2);
        final sparkleX = centerX + 40 * math.cos(angle);
        final sparkleY = topY + 30 + 40 * math.sin(angle);
        
        paint.color = DuolingoTheme.duoYellow;
        canvas.drawCircle(Offset(sparkleX, sparkleY), 3, paint);
      }
    }
  }

  void _drawNetworkVerification(Canvas canvas, Size size, Paint paint) {
    // Draw network nodes verifying
    final nodes = [
      {'x': size.width * 0.2, 'y': size.height * 0.3},
      {'x': size.width * 0.8, 'y': size.height * 0.3},
      {'x': size.width * 0.3, 'y': size.height * 0.5},
      {'x': size.width * 0.7, 'y': size.height * 0.5},
      {'x': size.width * 0.5, 'y': size.height * 0.2},
    ];

    // Draw connections between nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final progress = math.max(0.0, math.min(1.0, stepProgress * 2 - 1));
        if (progress > 0) {
          paint.color = DuolingoTheme.duoBlue.withValues(alpha: progress * 0.3);
          canvas.drawLine(
            Offset(nodes[i]['x']!, nodes[i]['y']!),
            Offset(nodes[j]['x']!, nodes[j]['y']!),
            paint..strokeWidth = 2,
          );
        }
      }
    }

    // Draw nodes
    for (int i = 0; i < nodes.length; i++) {
      final delay = i * 0.1;
      final progress = math.max(0.0, math.min(1.0, (stepProgress - delay) / 0.9));
      
      if (progress > 0) {
        paint.color = DuolingoTheme.duoGreen;
        canvas.drawCircle(
          Offset(nodes[i]['x']!, nodes[i]['y']!),
          10 * progress,
          paint,
        );
        
        // Checkmark animation
        if (progress > 0.8) {
          paint.color = Colors.white;
          canvas.drawCircle(
            Offset(nodes[i]['x']!, nodes[i]['y']!),
            4,
            paint,
          );
        }
      }
    }
  }

  void _drawChainUpdate(Canvas canvas, Size size, Paint paint) {
    // Draw wave effect across the chain
    final waveProgress = stepProgress;
    final amplitude = 10.0;
    final frequency = 0.02;

    for (double x = 0; x < size.width; x += 2) {
      final y = size.height * 0.6 + amplitude * math.sin(frequency * x + waveProgress * math.pi * 2);
      paint.color = DuolingoTheme.duoGreen.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is BlockchainPainter &&
        (oldDelegate.stepProgress != stepProgress ||
         oldDelegate.chainProgress != chainProgress ||
         oldDelegate.currentStep != currentStep);
  }
}