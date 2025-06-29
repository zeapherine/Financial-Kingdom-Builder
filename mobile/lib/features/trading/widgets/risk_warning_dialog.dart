import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/duolingo_theme.dart';

enum RiskLevel {
  low,
  medium,
  high,
  extreme,
}

class RiskWarningDialog extends StatefulWidget {
  final String title;
  final String message;
  final RiskLevel riskLevel;
  final List<String>? customRisks;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onCancel;

  const RiskWarningDialog({
    super.key,
    required this.title,
    required this.message,
    required this.riskLevel,
    this.customRisks,
    this.onAcknowledge,
    this.onCancel,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required RiskLevel riskLevel,
    List<String>? customRisks,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RiskWarningDialog(
        title: title,
        message: message,
        riskLevel: riskLevel,
        customRisks: customRisks,
        onAcknowledge: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ) ?? false;
  }

  @override
  State<RiskWarningDialog> createState() => _RiskWarningDialogState();
}

class _RiskWarningDialogState extends State<RiskWarningDialog>
    with TickerProviderStateMixin {
  
  bool _hasReadRisks = false;
  bool _acknowledgedRisks = false;
  int _currentRiskIndex = 0;
  
  late AnimationController _warningController;
  late AnimationController _progressController;
  late Animation<double> _warningAnimation;
  late Animation<double> _progressAnimation;

  List<String> get _riskPoints {
    if (widget.customRisks != null) {
      return widget.customRisks!;
    }

    switch (widget.riskLevel) {
      case RiskLevel.low:
        return [
          'Small potential for financial loss',
          'Recommended for beginners',
          'Good for learning and practice',
        ];
      case RiskLevel.medium:
        return [
          'Moderate potential for financial loss',
          'Requires basic trading knowledge',
          'Use appropriate position sizing',
          'Consider stop-loss orders',
        ];
      case RiskLevel.high:
        return [
          'High potential for significant financial loss',
          'You could lose a substantial portion of your investment',
          'Only trade with money you can afford to lose',
          'Requires advanced risk management skills',
          'Market conditions can change rapidly',
        ];
      case RiskLevel.extreme:
        return [
          'EXTREME risk of total capital loss',
          'You could lose your entire investment',
          'High leverage amplifies both gains and losses',
          'Liquidation can happen very quickly',
          'Only for experienced traders',
          'Never invest borrowed money',
          'Have a clear exit strategy',
        ];
    }
  }

  Color get _riskColor {
    switch (widget.riskLevel) {
      case RiskLevel.low:
        return DuolingoTheme.duoGreen;
      case RiskLevel.medium:
        return DuolingoTheme.duoYellow;
      case RiskLevel.high:
        return DuolingoTheme.duoOrange;
      case RiskLevel.extreme:
        return DuolingoTheme.duoRed;
    }
  }

  IconData get _riskIcon {
    switch (widget.riskLevel) {
      case RiskLevel.low:
        return Icons.info;
      case RiskLevel.medium:
        return Icons.warning_amber;
      case RiskLevel.high:
        return Icons.warning;
      case RiskLevel.extreme:
        return Icons.dangerous;
    }
  }

  String get _riskLevelText {
    switch (widget.riskLevel) {
      case RiskLevel.low:
        return 'LOW RISK';
      case RiskLevel.medium:
        return 'MEDIUM RISK';
      case RiskLevel.high:
        return 'HIGH RISK';
      case RiskLevel.extreme:
        return 'EXTREME RISK';
    }
  }

  @override
  void initState() {
    super.initState();
    
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _warningAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.riskLevel == RiskLevel.high || widget.riskLevel == RiskLevel.extreme) {
      _warningController.repeat(reverse: true);
    }

    _startRiskEducation();
  }

  @override
  void dispose() {
    _warningController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startRiskEducation() async {
    // Auto-advance through risk points for education
    for (int i = 0; i < _riskPoints.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentRiskIndex = i;
        });
        _progressController.forward();
        await Future.delayed(const Duration(milliseconds: 300));
        _progressController.reset();
      }
    }
    
    if (mounted) {
      setState(() {
        _hasReadRisks = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _warningAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _warningAnimation.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _riskColor,
                width: 3,
              ),
            ),
            title: _buildTitle(),
            content: _buildContent(),
            actions: _buildActions(),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _riskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _riskIcon,
                color: _riskColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: DuolingoTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _riskColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _riskLevelText,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _buildRiskEducation(),
        const SizedBox(height: 20),
        _buildAcknowledgmentCheckbox(),
      ],
    );
  }

  Widget _buildRiskEducation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _riskColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: _riskColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Risk Factors:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _riskColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: _riskPoints.length,
              itemBuilder: (context, index) {
                final isActive = index <= _currentRiskIndex;
                final isCurrent = index == _currentRiskIndex;
                
                return AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent 
                              ? _riskColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? _riskColor : _riskColor.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _riskPoints[index],
                                style: DuolingoTheme.bodySmall.copyWith(
                                  color: isActive 
                                      ? DuolingoTheme.textPrimary 
                                      : DuolingoTheme.textSecondary,
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgmentCheckbox() {
    return CheckboxListTile(
      value: _acknowledgedRisks,
      onChanged: _hasReadRisks 
          ? (value) {
              setState(() {
                _acknowledgedRisks = value ?? false;
              });
              HapticFeedback.lightImpact();
            }
          : null,
      activeColor: _riskColor,
      title: Text(
        'I understand and acknowledge these risks',
        style: DuolingoTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: _hasReadRisks 
              ? DuolingoTheme.textPrimary 
              : DuolingoTheme.textSecondary,
        ),
      ),
      subtitle: !_hasReadRisks 
          ? Text(
              'Please wait for the risk education to complete',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.textSecondary,
              ),
            )
          : null,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _handleCancel,
        style: TextButton.styleFrom(
          foregroundColor: DuolingoTheme.textSecondary,
        ),
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: (_hasReadRisks && _acknowledgedRisks) ? _handleAcknowledge : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _riskColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'I Understand',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    widget.onCancel?.call();
  }

  void _handleAcknowledge() {
    HapticFeedback.mediumImpact();
    widget.onAcknowledge?.call();
  }
}