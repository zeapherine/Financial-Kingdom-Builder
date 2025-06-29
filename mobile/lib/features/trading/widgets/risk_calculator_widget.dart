import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_button.dart';
import '../../../shared/widgets/kingdom_card.dart';

class RiskCalculatorWidget extends StatefulWidget {
  final double portfolioValue;
  final Function(PositionSizeRecommendation) onRecommendationCalculated;
  final VoidCallback? onApplyRecommendation;

  const RiskCalculatorWidget({
    super.key,
    required this.portfolioValue,
    required this.onRecommendationCalculated,
    this.onApplyRecommendation,
  });

  @override
  State<RiskCalculatorWidget> createState() => _RiskCalculatorWidgetState();
}

class _RiskCalculatorWidgetState extends State<RiskCalculatorWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _symbolController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _leverageController = TextEditingController(text: '1');
  
  // State variables
  String _tradeDirection = 'long';
  bool _isCalculating = false;
  PositionSizeRecommendation? _recommendation;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _leverageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _calculatePositionSize() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final entryPrice = double.parse(_entryPriceController.text);
      final stopLossPrice = _stopLossController.text.isNotEmpty 
          ? double.parse(_stopLossController.text) 
          : null;
      final leverage = double.parse(_leverageController.text);
      
      // Mock calculation - replace with actual API response
      final recommendation = PositionSizeRecommendation(
        recommendedSize: 0.85,
        maxSize: 1.2,
        minSize: 0.1,
        riskPercentage: 2.0,
        stopLossDistance: stopLossPrice != null 
            ? (entryPrice - stopLossPrice).abs() / entryPrice * 100 
            : 2.0,
        leverageRecommended: leverage.clamp(1.0, 5.0),
        maxLeverage: 5.0,
        warnings: _generateWarnings(leverage, stopLossPrice),
        reasoning: _generateReasoning(leverage),
      );

      setState(() {
        _recommendation = recommendation;
        _isCalculating = false;
      });

      widget.onRecommendationCalculated(recommendation);
      
      // Trigger animations
      _fadeController.forward();
      _slideController.forward();

    } catch (error) {
      setState(() {
        _isCalculating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating position size: $error'),
            backgroundColor: DuolingoTheme.duoRed,
          ),
        );
      }
    }
  }

  List<String> _generateWarnings(double leverage, double? stopLoss) {
    final warnings = <String>[];
    
    if (leverage > 5.0) {
      warnings.add('Leverage reduced to tier limit (5x)');
    }
    
    if (stopLoss == null) {
      warnings.add('Consider setting a stop loss for better risk management');
    }
    
    return warnings;
  }

  List<String> _generateReasoning(double leverage) {
    return [
      'Position size calculated based on Village tier limits',
      'Max position size: 5% of portfolio',
      'Max risk per trade: 1% of portfolio',
      'Conservative sizing recommended for new traders',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 24),
            _buildCalculateButton(),
            if (_recommendation != null) ...[
              const SizedBox(height: 24),
              _buildRecommendationSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: DuolingoTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calculate,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk Calculator',
                style: DuolingoTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Smart position sizing for your tier',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuolingoTheme.duoGreen),
          ),
          child: Text(
            'VILLAGE',
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.duoGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _symbolController,
                label: 'Symbol',
                hint: 'BTC, ETH, SOL',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Symbol required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTradeDirectionToggle(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _entryPriceController,
                label: 'Entry Price',
                hint: '45,000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Price required';
                  if (double.tryParse(value!) == null) return 'Invalid price';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stopLossController,
                label: 'Stop Loss (Optional)',
                hint: '43,000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLeverageSlider(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DuolingoTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DuolingoTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DuolingoTheme.duoBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTradeDirectionToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direction',
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DuolingoTheme.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildDirectionOption('Long', 'long', DuolingoTheme.duoGreen),
              ),
              Expanded(
                child: _buildDirectionOption('Short', 'short', DuolingoTheme.duoRed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionOption(String label, String value, Color color) {
    final isSelected = _tradeDirection == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tradeDirection = value;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: DuolingoTheme.bodyMedium.copyWith(
            color: isSelected ? color : DuolingoTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLeverageSlider() {
    final leverage = double.tryParse(_leverageController.text) ?? 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leverage',
              style: DuolingoTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: DuolingoTheme.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${leverage.toStringAsFixed(1)}x',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.duoBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: DuolingoTheme.duoBlue,
            inactiveTrackColor: DuolingoTheme.borderLight,
            thumbColor: DuolingoTheme.duoBlue,
          ),
          child: Slider(
            value: leverage,
            min: 1.0,
            max: 5.0, // Village tier max
            divisions: 8,
            onChanged: (value) {
              setState(() {
                _leverageController.text = value.toStringAsFixed(1);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: KingdomButton(
        text: _isCalculating ? 'Calculating...' : 'Calculate Position Size',
        onPressed: _isCalculating ? null : _calculatePositionSize,
        icon: _isCalculating ? null : Icons.calculate,
        isLoading: _isCalculating,
      ),
    );
  }

  Widget _buildRecommendationSection() {
    if (_recommendation == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecommendationHeader(),
            const SizedBox(height: 16),
            _buildRecommendationDetails(),
            if (_recommendation!.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWarnings(),
            ],
            const SizedBox(height: 16),
            _buildReasoning(),
            const SizedBox(height: 20),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DuolingoTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.recommend, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Position Size Recommendation',
                  style: DuolingoTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_recommendation!.recommendedSize.toStringAsFixed(4)} units',
                  style: DuolingoTheme.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.borderLight),
      ),
      child: Column(
        children: [
          _buildDetailRow('Risk Percentage', '${_recommendation!.riskPercentage.toStringAsFixed(1)}%'),
          _buildDetailRow('Stop Loss Distance', '${_recommendation!.stopLossDistance.toStringAsFixed(1)}%'),
          _buildDetailRow('Recommended Leverage', '${_recommendation!.leverageRecommended.toStringAsFixed(1)}x'),
          _buildDetailRow('Max Size Allowed', '${_recommendation!.maxSize.toStringAsFixed(4)} units'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: DuolingoTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.duoOrange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: DuolingoTheme.duoOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Warnings',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DuolingoTheme.duoOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_recommendation!.warnings.map((warning) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $warning',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoOrange,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReasoning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.duoBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: DuolingoTheme.duoBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Why this size?',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DuolingoTheme.duoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_recommendation!.reasoning.map((reason) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $reason',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoBlue,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: KingdomButton(
        text: 'Apply Recommendation',
        onPressed: widget.onApplyRecommendation,
        isSecondary: true,
        icon: Icons.check,
      ),
    );
  }
}

// Data model for position size recommendation
class PositionSizeRecommendation {
  final double recommendedSize;
  final double maxSize;
  final double minSize;
  final double riskPercentage;
  final double stopLossDistance;
  final double leverageRecommended;
  final double maxLeverage;
  final List<String> warnings;
  final List<String> reasoning;

  const PositionSizeRecommendation({
    required this.recommendedSize,
    required this.maxSize,
    required this.minSize,
    required this.riskPercentage,
    required this.stopLossDistance,
    required this.leverageRecommended,
    required this.maxLeverage,
    required this.warnings,
    required this.reasoning,
  });

  factory PositionSizeRecommendation.fromJson(Map<String, dynamic> json) {
    return PositionSizeRecommendation(
      recommendedSize: (json['recommendedSize'] as num).toDouble(),
      maxSize: (json['maxSize'] as num).toDouble(),
      minSize: (json['minSize'] as num).toDouble(),
      riskPercentage: (json['riskPercentage'] as num).toDouble(),
      stopLossDistance: (json['stopLossDistance'] as num).toDouble(),
      leverageRecommended: (json['leverageRecommended'] as num).toDouble(),
      maxLeverage: (json['maxLeverage'] as num).toDouble(),
      warnings: List<String>.from(json['warnings'] as List),
      reasoning: List<String>.from(json['reasoning'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedSize': recommendedSize,
      'maxSize': maxSize,
      'minSize': minSize,
      'riskPercentage': riskPercentage,
      'stopLossDistance': stopLossDistance,
      'leverageRecommended': leverageRecommended,
      'maxLeverage': maxLeverage,
      'warnings': warnings,
      'reasoning': reasoning,
    };
  }
}