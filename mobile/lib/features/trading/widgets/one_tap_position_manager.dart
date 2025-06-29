import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_card.dart';
import '../../../shared/widgets/kingdom_button.dart';

class OneTapPositionManager extends StatefulWidget {
  final Position position;
  final Function(String action, {double? amount, double? price}) onAction;
  final VoidCallback? onClose;

  const OneTapPositionManager({
    super.key,
    required this.position,
    required this.onAction,
    this.onClose,
  });

  @override
  State<OneTapPositionManager> createState() => _OneTapPositionManagerState();
}

class _OneTapPositionManagerState extends State<OneTapPositionManager>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _showAdvancedOptions = false;
  double? _partialClosePercent;
  double? _customStopLoss;
  double? _customTakeProfit;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    
    // Pulse animation for urgent actions
    if (widget.position.isNearLiquidation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: KingdomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPositionSummary(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            if (_showAdvancedOptions) ...[
              const SizedBox(height: 20),
              _buildAdvancedOptions(),
            ],
            const SizedBox(height: 16),
            _buildToggleAdvanced(),
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
            gradient: widget.position.isLong 
                ? DuolingoTheme.successGradient 
                : DuolingoTheme.errorGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.position.isLong ? Icons.trending_up : Icons.trending_down,
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
                '${widget.position.symbol} Position',
                style: DuolingoTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.position.isLong ? 'Long' : 'Short'} • ${widget.position.leverage}x Leverage',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.onClose != null)
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            color: DuolingoTheme.textSecondary,
          ),
      ],
    );
  }

  Widget _buildPositionSummary() {
    final pnlColor = widget.position.unrealizedPnl >= 0 
        ? DuolingoTheme.duoGreen 
        : DuolingoTheme.duoRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pnlColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pnlColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Size', '${widget.position.size.toStringAsFixed(4)} ${widget.position.symbol}'),
          _buildSummaryRow('Entry Price', '\$${widget.position.entryPrice.toStringAsFixed(2)}'),
          _buildSummaryRow('Mark Price', '\$${widget.position.markPrice.toStringAsFixed(2)}'),
          _buildSummaryRow('Unrealized PnL', 
            '${widget.position.unrealizedPnl >= 0 ? '+' : ''}\$${widget.position.unrealizedPnl.toStringAsFixed(2)}',
            color: pnlColor,
          ),
          if (widget.position.liquidationPrice != null)
            _buildSummaryRow('Liquidation Price', 
              '\$${widget.position.liquidationPrice!.toStringAsFixed(2)}',
              color: DuolingoTheme.duoRed,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
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
              color: color ?? DuolingoTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCloseButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPartialCloseButton(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStopLossButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTakeProfitButton(),
            ),
          ],
        ),
        if (widget.position.isNearLiquidation) ...[
          const SizedBox(height: 12),
          _buildEmergencyCloseButton(),
        ],
      ],
    );
  }

  Widget _buildCloseButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.position.isNearLiquidation ? _pulseAnimation.value : 1.0,
          child: KingdomButton(
            text: 'Close Position',
            onPressed: () => _handleAction('close_full'),
            backgroundColor: DuolingoTheme.duoRed,
            icon: Icons.close,
          ),
        );
      },
    );
  }

  Widget _buildPartialCloseButton() {
    return KingdomButton(
      text: 'Partial Close',
      onPressed: () => _showPartialCloseDialog(),
      isSecondary: true,
      icon: Icons.remove_circle_outline,
    );
  }

  Widget _buildStopLossButton() {
    final hasStopLoss = widget.position.stopLossPrice != null;
    
    return KingdomButton(
      text: hasStopLoss ? 'Update SL' : 'Add Stop Loss',
      onPressed: () => _showStopLossDialog(),
      backgroundColor: hasStopLoss ? DuolingoTheme.duoOrange : DuolingoTheme.duoBlue,
      icon: hasStopLoss ? Icons.edit : Icons.shield,
    );
  }

  Widget _buildTakeProfitButton() {
    final hasTakeProfit = widget.position.takeProfitPrice != null;
    
    return KingdomButton(
      text: hasTakeProfit ? 'Update TP' : 'Add Take Profit',
      onPressed: () => _showTakeProfitDialog(),
      backgroundColor: hasTakeProfit ? DuolingoTheme.duoOrange : DuolingoTheme.duoGreen,
      icon: hasTakeProfit ? Icons.edit : Icons.flag,
    );
  }

  Widget _buildEmergencyCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: KingdomButton(
        text: 'EMERGENCY CLOSE - NEAR LIQUIDATION',
        onPressed: () => _handleAction('emergency_close'),
        backgroundColor: DuolingoTheme.duoRed,
        icon: Icons.warning,
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Options',
            style: DuolingoTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPartialCloseSlider(),
          const SizedBox(height: 16),
          _buildCustomPriceInputs(),
          const SizedBox(height: 16),
          _buildAdvancedActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPartialCloseSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Partial Close Amount',
              style: DuolingoTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_partialClosePercent ?? 25).toStringAsFixed(0)}%',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.duoBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            activeTrackColor: DuolingoTheme.duoBlue,
            inactiveTrackColor: DuolingoTheme.borderLight,
            thumbColor: DuolingoTheme.duoBlue,
          ),
          child: Slider(
            value: _partialClosePercent ?? 25,
            min: 10,
            max: 90,
            divisions: 8,
            onChanged: (value) {
              setState(() {
                _partialClosePercent = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomPriceInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                label: 'Custom Stop Loss',
                value: _customStopLoss,
                onChanged: (value) => setState(() => _customStopLoss = value),
                hint: widget.position.stopLossPrice?.toStringAsFixed(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceInput(
                label: 'Custom Take Profit',
                value: _customTakeProfit,
                onChanged: (value) => setState(() => _customTakeProfit = value),
                hint: widget.position.takeProfitPrice?.toStringAsFixed(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput({
    required String label,
    required double? value,
    required Function(double?) onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint ?? '0.00',
            prefixText: '\$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: DuolingoTheme.borderLight),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: DuolingoTheme.bodySmall,
          onChanged: (text) {
            final parsed = double.tryParse(text);
            onChanged(parsed);
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedActionButtons() {
    return Row(
      children: [
        Expanded(
          child: KingdomButton(
            text: 'Apply Custom',
            onPressed: _customStopLoss != null || _customTakeProfit != null
                ? () => _handleAdvancedAction()
                : null,
            isSecondary: true,
            icon: Icons.settings,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KingdomButton(
            text: 'Scale Out',
            onPressed: () => _handleAction('scale_out', amount: _partialClosePercent),
            backgroundColor: DuolingoTheme.duoOrange,
            icon: Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleAdvanced() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAdvancedOptions = !_showAdvancedOptions;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showAdvancedOptions ? 'Hide Advanced' : 'Show Advanced',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.duoBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: DuolingoTheme.duoBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, {double? amount, double? price}) {
    HapticFeedback.mediumImpact();
    widget.onAction(action, amount: amount, price: price);
  }

  void _handleAdvancedAction() {
    if (_customStopLoss != null) {
      _handleAction('update_stop_loss', price: _customStopLoss);
    }
    if (_customTakeProfit != null) {
      _handleAction('update_take_profit', price: _customTakeProfit);
    }
  }

  void _showPartialCloseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partial Close'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select percentage to close:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [25, 50, 75].map((percent) => 
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleAction('partial_close', amount: percent.toDouble());
                  },
                  child: Text('${percent}%'),
                )
              ).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showStopLossDialog() {
    final controller = TextEditingController(
      text: widget.position.stopLossPrice?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Loss Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current price: \$${widget.position.markPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stop Loss Price',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null) {
                Navigator.of(context).pop();
                _handleAction('update_stop_loss', price: price);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showTakeProfitDialog() {
    final controller = TextEditingController(
      text: widget.position.takeProfitPrice?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Take Profit Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current price: \$${widget.position.markPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Take Profit Price',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null) {
                Navigator.of(context).pop();
                _handleAction('update_take_profit', price: price);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}

// Data model for position
class Position {
  final String id;
  final String symbol;
  final double size;
  final double entryPrice;
  final double markPrice;
  final double leverage;
  final bool isLong;
  final double unrealizedPnl;
  final double? liquidationPrice;
  final double? stopLossPrice;
  final double? takeProfitPrice;
  final DateTime openedAt;

  const Position({
    required this.id,
    required this.symbol,
    required this.size,
    required this.entryPrice,
    required this.markPrice,
    required this.leverage,
    required this.isLong,
    required this.unrealizedPnl,
    this.liquidationPrice,
    this.stopLossPrice,
    this.takeProfitPrice,
    required this.openedAt,
  });

  bool get isNearLiquidation {
    if (liquidationPrice == null) return false;
    
    final currentDistance = (markPrice - liquidationPrice!).abs();
    final entryDistance = (entryPrice - liquidationPrice!).abs();
    
    return currentDistance / entryDistance < 0.2; // Within 20% of liquidation
  }

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      markPrice: (json['markPrice'] as num).toDouble(),
      leverage: (json['leverage'] as num).toDouble(),
      isLong: json['isLong'] as bool,
      unrealizedPnl: (json['unrealizedPnl'] as num).toDouble(),
      liquidationPrice: json['liquidationPrice'] != null 
          ? (json['liquidationPrice'] as num).toDouble() 
          : null,
      stopLossPrice: json['stopLossPrice'] != null 
          ? (json['stopLossPrice'] as num).toDouble() 
          : null,
      takeProfitPrice: json['takeProfitPrice'] != null 
          ? (json['takeProfitPrice'] as num).toDouble() 
          : null,
      openedAt: DateTime.parse(json['openedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'size': size,
      'entryPrice': entryPrice,
      'markPrice': markPrice,
      'leverage': leverage,
      'isLong': isLong,
      'unrealizedPnl': unrealizedPnl,
      'liquidationPrice': liquidationPrice,
      'stopLossPrice': stopLossPrice,
      'takeProfitPrice': takeProfitPrice,
      'openedAt': openedAt.toIso8601String(),
    };
  }
}