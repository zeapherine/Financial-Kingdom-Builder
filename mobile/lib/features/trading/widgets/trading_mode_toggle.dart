import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_card.dart';
import '../providers/trading_mode_provider.dart';
import 'enhanced_confirmation_dialog.dart';
import 'risk_warning_dialog.dart';

class TradingModeToggle extends ConsumerStatefulWidget {
  final VoidCallback? onModeChanged;
  final bool showBalance;
  final bool compactMode;

  const TradingModeToggle({
    super.key,
    this.onModeChanged,
    this.showBalance = true,
    this.compactMode = false,
  });

  @override
  ConsumerState<TradingModeToggle> createState() => _TradingModeToggleState();
}

class _TradingModeToggleState extends ConsumerState<TradingModeToggle>
    with TickerProviderStateMixin {
  
  late AnimationController _switchController;
  late AnimationController _pulseController;
  late Animation<double> _switchAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _switchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _switchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingModeProvider);
    
    // Update animations based on state
    if (tradingState.isRealMode) {
      _switchController.forward();
      _pulseController.repeat(reverse: true);
    } else {
      _switchController.reverse();
      _pulseController.stop();
      _pulseController.reset();
    }

    if (widget.compactMode) {
      return _buildCompactToggle(tradingState);
    }

    return KingdomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(tradingState),
          const SizedBox(height: 16),
          _buildToggleSwitch(tradingState),
          if (widget.showBalance) ...[
            const SizedBox(height: 16),
            _buildBalanceDisplay(tradingState),
          ],
          const SizedBox(height: 16),
          _buildModeDescription(tradingState),
        ],
      ),
    );
  }

  Widget _buildCompactToggle(TradingModeState state) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: state.isRealMode ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _handleModeSwitch(state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: state.isRealMode 
                    ? DuolingoTheme.errorGradient 
                    : DuolingoTheme.successGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isRealMode ? Icons.warning : Icons.school,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.modeDisplayName.toUpperCase(),
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(TradingModeState state) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: state.isRealMode 
                ? DuolingoTheme.errorGradient 
                : DuolingoTheme.successGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            state.isRealMode ? Icons.attach_money : Icons.school,
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
                'Trading Mode',
                style: DuolingoTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.isRealMode ? 'Real money trading active' : 'Practice with virtual money',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (state.isTransitioning)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildToggleSwitch(TradingModeState state) {
    return AnimatedBuilder(
      animation: _switchAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: state.isTransitioning ? null : () => _handleModeSwitch(state),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: DuolingoTheme.surfaceLight,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Background options
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleOption(
                        'Paper Trading',
                        Icons.school,
                        !state.isRealMode,
                        DuolingoTheme.duoGreen,
                      ),
                    ),
                    Expanded(
                      child: _buildToggleOption(
                        'Real Trading',
                        Icons.attach_money,
                        state.isRealMode,
                        DuolingoTheme.duoRed,
                      ),
                    ),
                  ],
                ),
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: state.isRealMode ? MediaQuery.of(context).size.width * 0.5 - 40 : 4,
                  top: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5 - 44,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: state.isRealMode 
                          ? DuolingoTheme.errorGradient 
                          : DuolingoTheme.successGradient,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: (state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      state.isRealMode ? Icons.attach_money : Icons.school,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isSelected, Color color) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        label,
        style: DuolingoTheme.bodyMedium.copyWith(
          color: isSelected ? Colors.white : DuolingoTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBalanceDisplay(TradingModeState state) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: state.isRealMode ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${state.currentBalance.toStringAsFixed(2)}',
                      style: DuolingoTheme.headingMedium.copyWith(
                        color: state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!state.isRealMode)
                  TextButton.icon(
                    onPressed: () => _resetPaperBalance(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: DuolingoTheme.duoBlue,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeDescription(TradingModeState state) {
    final description = state.isRealMode
        ? 'You are trading with real money. All trades will use your actual balance and incur real profits or losses.'
        : 'You are practicing with virtual money. Perfect for learning without any financial risk.';

    final tips = state.isRealMode
        ? [
            'Double-check all trades before confirming',
            'Start with small position sizes',
            'Always use stop-losses',
            'Never risk more than you can afford to lose',
          ]
        : [
            'Experiment with different strategies',
            'Practice risk management',
            'Learn from your mistakes',
            'Build confidence before real trading',
          ];

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
          Row(
            children: [
              Icon(
                state.isRealMode ? Icons.warning : Icons.lightbulb,
                color: state.isRealMode ? DuolingoTheme.duoOrange : DuolingoTheme.duoBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                state.isRealMode ? 'Important' : 'Tips',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: state.isRealMode ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _handleModeSwitch(TradingModeState state) async {
    HapticFeedback.mediumImpact();

    if (state.isRealMode) {
      // Switching to paper - simple confirmation
      final confirmed = await _showPaperModeConfirmation();
      if (confirmed) {
        final success = await ref.read(tradingModeProvider.notifier).switchToPaperTrading();
        if (success) {
          widget.onModeChanged?.call();
          _showModeChangedSnackBar('Switched to Paper Trading');
        }
      }
    } else {
      // Switching to real - enhanced warnings and confirmations
      if (!state.hasRealTradingAccess) {
        _showRealTradingAccessDialog();
        return;
      }

      if (!mounted) return;
      
      final riskAcknowledged = await RiskWarningDialog.show(
        context,
        title: 'Switch to Real Trading',
        message: 'You are about to switch to real money trading. This involves significant financial risk.',
        riskLevel: RiskLevel.high,
      );

      if (riskAcknowledged && mounted) {
        final confirmed = await EnhancedConfirmationDialog.show(
          context,
          title: 'Confirm Real Trading',
          message: 'Are you absolutely sure you want to trade with real money?',
          confirmText: 'Start Real Trading',
          isDestructive: true,
          requiresTyping: true,
          requiredPhrase: 'I understand the risks',
        );

        if (confirmed) {
          final success = await ref.read(tradingModeProvider.notifier).switchToRealTrading();
          if (success) {
            widget.onModeChanged?.call();
            _showModeChangedSnackBar('Switched to Real Trading - Trade Carefully!');
          }
        }
      }
    }
  }

  Future<bool> _showPaperModeConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch to Paper Trading'),
        content: const Text('Switch back to risk-free practice mode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch to Paper'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showRealTradingAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Real Trading Not Available'),
        content: const Text(
          'Complete your KYC verification and reach Town tier to access real trading.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to KYC or education
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showModeChangedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetPaperBalance() {
    ref.read(tradingModeProvider.notifier).resetPaperBalance();
    _showModeChangedSnackBar('Paper balance reset to \$10,000');
  }
}