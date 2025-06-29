import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../models/perpetual_position.dart';
import '../../providers/perpetual_trading_provider.dart';
import '../../widgets/swipe_trading_widget.dart';
import '../../../education/presentation/screens/education_screen.dart';

class PerpetualTradingScreen extends ConsumerStatefulWidget {
  const PerpetualTradingScreen({super.key});

  @override
  ConsumerState<PerpetualTradingScreen> createState() => _PerpetualTradingScreenState();
}

class _PerpetualTradingScreenState extends ConsumerState<PerpetualTradingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedAsset = 'BTC';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(perpetualTradingProvider);
    final openPositions = ref.watch(openPositionsProvider);
    final totalEquity = ref.watch(totalEquityProvider);
    final riskWarnings = ref.watch(riskWarningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.swap_horiz,
              color: DuolingoTheme.duoBlue,
              size: DuolingoTheme.iconMedium,
            ),
            const SizedBox(width: DuolingoTheme.spacingSm),
            const Expanded(
              child: Text(
                'Perpetual Trading Post',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: DuolingoTheme.lightGray,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: DuolingoTheme.duoBlue,
          unselectedLabelColor: DuolingoTheme.mediumGray,
          indicatorColor: DuolingoTheme.duoBlue,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.swap_vert), text: 'Trade'),
            Tab(icon: Icon(Icons.list), text: 'Positions'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Portfolio'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Risk Warnings
          if (riskWarnings.isNotEmpty) _buildRiskWarnings(riskWarnings),
          
          // Account Summary
          _buildAccountSummary(tradingState, totalEquity),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradeTab(tradingState),
                _buildPositionsTab(openPositions),
                _buildPortfolioTab(tradingState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskWarnings(List<String> warnings) {
    return Container(
      margin: const EdgeInsets.all(DuolingoTheme.spacingMd),
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoRed.withValues(alpha: 0.1),
        border: Border.all(color: DuolingoTheme.duoRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: DuolingoTheme.duoRed,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Kingdom Alerts',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.duoRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          ...warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $warning',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.duoRed,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAccountSummary(PerpetualTradingState state, double totalEquity) {
    return DuoCard(
      type: DuoCardType.achievement,
      margin: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Equity',
                  '\$${totalEquity.toStringAsFixed(2)}',
                  state.totalPnl >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Free Balance',
                  '\$${state.paperBalance.toStringAsFixed(2)}',
                  DuolingoTheme.duoBlue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Unrealized PnL',
                  '${state.totalPnl >= 0 ? '+' : ''}\$${state.totalPnl.toStringAsFixed(2)}',
                  state.totalPnl >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTradeTab(PerpetualTradingState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Asset Selector
          _buildAssetSelector(state),
          
          // Swipe Trading Widget
          if (state.marketData[_selectedAsset] != null)
            SwipeTradingWidget(
              marketData: state.marketData[_selectedAsset]!,
              availableBalance: state.paperBalance,
              onPositionOpen: _handlePositionOpen,
              onEducationTap: _navigateToEducation,
            ),
        ],
      ),
    );
  }

  Widget _buildAssetSelector(PerpetualTradingState state) {
    final assets = state.marketData.keys.toList();
    
    return Container(
      margin: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Row(
        children: assets.map((asset) {
          final isSelected = asset == _selectedAsset;
          final marketData = state.marketData[asset]!;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAsset = asset;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? DuolingoTheme.duoBlue 
                      : DuolingoTheme.white,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected 
                        ? DuolingoTheme.duoBlue 
                        : DuolingoTheme.mediumGray,
                  ),
                  boxShadow: isSelected ? DuolingoTheme.cardShadow : null,
                ),
                child: Column(
                  children: [
                    Text(
                      asset,
                      style: DuolingoTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected 
                            ? DuolingoTheme.white 
                            : DuolingoTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${marketData.price.toStringAsFixed(2)}',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: isSelected 
                            ? DuolingoTheme.white.withValues(alpha: 0.9)
                            : DuolingoTheme.darkGray,
                      ),
                    ),
                    Text(
                      '${marketData.changePercent24h >= 0 ? '+' : ''}${marketData.changePercent24h.toStringAsFixed(2)}%',
                      style: DuolingoTheme.caption.copyWith(
                        color: isSelected 
                            ? DuolingoTheme.white.withValues(alpha: 0.8)
                            : (marketData.changePercent24h >= 0 
                                ? DuolingoTheme.duoGreen 
                                : DuolingoTheme.duoRed),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPositionsTab(List<PerpetualPosition> positions) {
    if (positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_flat,
              size: 64,
              color: DuolingoTheme.mediumGray,
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'No Active Territories',
              style: DuolingoTheme.h3.copyWith(
                color: DuolingoTheme.mediumGray,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              'Open your first position to start trading',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        return _buildPositionCard(position);
      },
    );
  }

  Widget _buildPositionCard(PerpetualPosition position) {
    final tradingState = ref.watch(perpetualTradingProvider);
    final marketPrice = tradingState.marketData[position.asset]?.price ?? position.entryPrice;
    final unrealizedPnl = position.calculatePnl(marketPrice);
    final pnlPercent = position.calculatePnlPercentage(marketPrice);
    
    return DuoCard(
      type: DuoCardType.lesson,
      margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DuolingoTheme.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: position.side == PositionSide.long 
                      ? DuolingoTheme.duoGreen 
                      : DuolingoTheme.duoRed,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                ),
                child: Text(
                  position.side == PositionSide.long ? 'LONG' : 'SHORT',
                  style: DuolingoTheme.caption.copyWith(
                    color: DuolingoTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: Text(
                  '${position.asset} ${position.leverage.toInt()}x',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _closePosition(position.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.duoRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: DuolingoTheme.iconSmall,
                    color: DuolingoTheme.duoRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildPositionStat('Size', '\$${position.size.toStringAsFixed(0)}'),
              ),
              Expanded(
                child: _buildPositionStat('Entry', '\$${position.entryPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildPositionStat('Mark', '\$${marketPrice.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildPositionStat(
                  'PnL',
                  '${unrealizedPnl >= 0 ? '+' : ''}\$${unrealizedPnl.toStringAsFixed(2)}',
                  color: unrealizedPnl >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                ),
              ),
              Expanded(
                child: _buildPositionStat(
                  'PnL%',
                  '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%',
                  color: pnlPercent >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                ),
              ),
              Expanded(
                child: _buildPositionStat(
                  'Liq. Price',
                  '\$${position.calculateLiquidationPrice().toStringAsFixed(2)}',
                  color: position.isNearLiquidation(marketPrice) 
                      ? DuolingoTheme.duoRed 
                      : DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? DuolingoTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioTab(PerpetualTradingState state) {
    final notifier = ref.read(perpetualTradingProvider.notifier);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Overview',
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Portfolio Stats
          DuoCard(
            type: DuoCardType.lesson,
            child: Column(
              children: [
                _buildPortfolioStat('Total Equity', '\$${notifier.totalEquity.toStringAsFixed(2)}'),
                const Divider(),
                _buildPortfolioStat('Used Margin', '\$${notifier.usedMargin.toStringAsFixed(2)}'),
                const Divider(),
                _buildPortfolioStat('Free Margin', '\$${notifier.freeMargin.toStringAsFixed(2)}'),
                const Divider(),
                _buildPortfolioStat('Margin Ratio', '${notifier.marginRatio.toStringAsFixed(1)}%'),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Demo Controls
          Text(
            'Demo Controls',
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _simulatePriceMovement('BTC', 46000),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuolingoTheme.duoGreen,
                  ),
                  child: const Text('BTC +\$800'),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _simulatePriceMovement('BTC', 44000),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuolingoTheme.duoRed,
                  ),
                  child: const Text('BTC -\$1200'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => notifier.resetAccount(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DuolingoTheme.mediumGray,
              ),
              child: const Text('Reset Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DuolingoTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          Text(
            value,
            style: DuolingoTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DuolingoTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePositionOpen(PositionSide side, double leverage, double size) {
    final notifier = ref.read(perpetualTradingProvider.notifier);
    notifier.openPosition(
      asset: _selectedAsset,
      side: side,
      leverage: leverage,
      size: size,
    );
  }

  void _closePosition(String positionId) {
    final notifier = ref.read(perpetualTradingProvider.notifier);
    notifier.closePosition(positionId);
  }

  void _simulatePriceMovement(String asset, double newPrice) {
    final notifier = ref.read(perpetualTradingProvider.notifier);
    notifier.simulatePriceMovement(asset, newPrice);
  }

  void _navigateToEducation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EducationScreen(),
      ),
    );
  }
}