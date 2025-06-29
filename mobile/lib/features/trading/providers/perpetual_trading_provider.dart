import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/perpetual_position.dart';
import '../models/market_data.dart';

class PerpetualTradingState {
  final List<PerpetualPosition> positions;
  final Map<String, MarketData> marketData;
  final double paperBalance;
  final double totalPnl;
  final bool isLoading;
  final String? error;
  final bool isPaperTrading;

  const PerpetualTradingState({
    this.positions = const [],
    this.marketData = const {},
    this.paperBalance = 10000.0,
    this.totalPnl = 0.0,
    this.isLoading = false,
    this.error,
    this.isPaperTrading = true,
  });

  PerpetualTradingState copyWith({
    List<PerpetualPosition>? positions,
    Map<String, MarketData>? marketData,
    double? paperBalance,
    double? totalPnl,
    bool? isLoading,
    String? error,
    bool? isPaperTrading,
  }) {
    return PerpetualTradingState(
      positions: positions ?? this.positions,
      marketData: marketData ?? this.marketData,
      paperBalance: paperBalance ?? this.paperBalance,
      totalPnl: totalPnl ?? this.totalPnl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPaperTrading: isPaperTrading ?? this.isPaperTrading,
    );
  }
}

class PerpetualTradingNotifier extends StateNotifier<PerpetualTradingState> {
  PerpetualTradingNotifier() : super(const PerpetualTradingState()) {
    _initializeMarketData();
  }

  void _initializeMarketData() {
    // Initialize with sample market data for demo
    final sampleMarketData = {
      'BTC': MarketData(
        symbol: 'BTCUSDT',
        price: 45230.0,
        change24h: 1087.50,
        changePercent24h: 2.45,
        volume24h: 28756234.50,
        fundingRate: 0.0001,
        lastUpdate: DateTime.now(),
        indexPrice: 45225.0,
        markPrice: 45230.0,
        openInterest: 125486,
      ),
      'ETH': MarketData(
        symbol: 'ETHUSDT',
        price: 3150.0,
        change24h: 38.25,
        changePercent24h: 1.23,
        volume24h: 15234567.25,
        fundingRate: -0.0002,
        lastUpdate: DateTime.now(),
        indexPrice: 3148.5,
        markPrice: 3150.0,
        openInterest: 89342,
      ),
    };

    state = state.copyWith(marketData: sampleMarketData);
  }

  Future<void> openPosition({
    required String asset,
    required PositionSide side,
    required double leverage,
    required double size,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final marketPrice = state.marketData[asset]?.price ?? 0.0;
      if (marketPrice == 0.0) {
        throw Exception('Market data not available for $asset');
      }

      final margin = size / leverage;
      
      // Check if user has sufficient balance
      if (margin > state.paperBalance) {
        throw Exception('Insufficient balance. Required: \$${margin.toStringAsFixed(2)}');
      }

      final position = PerpetualPosition(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        asset: asset,
        side: side,
        entryPrice: marketPrice,
        size: size,
        leverage: leverage,
        margin: margin,
        status: PositionStatus.open,
        openTime: DateTime.now(),
        isPaperTrading: state.isPaperTrading,
      );

      final updatedPositions = [...state.positions, position];
      final newBalance = state.paperBalance - margin;

      state = state.copyWith(
        positions: updatedPositions,
        paperBalance: newBalance,
        isLoading: false,
      );

      // Calculate and update total PnL
      await _updateTotalPnl();

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> closePosition(String positionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final positionIndex = state.positions.indexWhere((p) => p.id == positionId);
      if (positionIndex == -1) {
        throw Exception('Position not found');
      }

      final position = state.positions[positionIndex];
      final marketPrice = state.marketData[position.asset]?.price ?? position.entryPrice;
      
      final realizedPnl = position.calculatePnl(marketPrice);
      final closedPosition = position.copyWith(
        status: PositionStatus.closed,
        closeTime: DateTime.now(),
        closePrice: marketPrice,
        pnl: realizedPnl,
      );

      final updatedPositions = [...state.positions];
      updatedPositions[positionIndex] = closedPosition;

      // Return margin + PnL to balance
      final newBalance = state.paperBalance + position.margin + realizedPnl;

      state = state.copyWith(
        positions: updatedPositions,
        paperBalance: newBalance,
        isLoading: false,
      );

      await _updateTotalPnl();

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _updateTotalPnl() async {
    double totalUnrealizedPnl = 0.0;
    
    for (final position in state.positions) {
      if (position.status == PositionStatus.open) {
        final marketPrice = state.marketData[position.asset]?.price ?? position.entryPrice;
        totalUnrealizedPnl += position.calculatePnl(marketPrice);
      }
    }

    state = state.copyWith(totalPnl: totalUnrealizedPnl);
  }

  Future<void> updateMarketData(String asset, MarketData data) async {
    final updatedMarketData = Map<String, MarketData>.from(state.marketData);
    updatedMarketData[asset] = data;
    
    state = state.copyWith(marketData: updatedMarketData);
    await _updateTotalPnl();
  }

  Future<void> simulatePriceMovement(String asset, double newPrice) async {
    final currentData = state.marketData[asset];
    if (currentData == null) return;

    final change = newPrice - currentData.price;
    final changePercent = (change / currentData.price) * 100;

    final updatedData = currentData.copyWith(
      price: newPrice,
      change24h: change,
      changePercent24h: changePercent,
      lastUpdate: DateTime.now(),
    );

    await updateMarketData(asset, updatedData);
  }

  List<PerpetualPosition> get openPositions {
    return state.positions.where((p) => p.status == PositionStatus.open).toList();
  }

  List<PerpetualPosition> get closedPositions {
    return state.positions.where((p) => p.status == PositionStatus.closed).toList();
  }

  double get totalEquity {
    return state.paperBalance + state.totalPnl;
  }

  double get usedMargin {
    return state.positions
        .where((p) => p.status == PositionStatus.open)
        .fold(0.0, (sum, p) => sum + p.margin);
  }

  double get freeMargin {
    return state.paperBalance;
  }

  double get marginRatio {
    final equity = totalEquity;
    if (equity <= 0) return 0.0;
    return (usedMargin / equity) * 100;
  }

  /// Check if any positions are near liquidation
  List<PerpetualPosition> get positionsNearLiquidation {
    return openPositions.where((position) {
      final marketPrice = state.marketData[position.asset]?.price ?? position.entryPrice;
      return position.isNearLiquidation(marketPrice);
    }).toList();
  }

  /// Reset to initial state (for demo purposes)
  void resetAccount() {
    state = const PerpetualTradingState();
    _initializeMarketData();
  }

  /// Calculate funding payments (simplified)
  Future<void> applyFundingPayments() async {
    double totalFunding = 0.0;
    final updatedPositions = <PerpetualPosition>[];

    for (final position in state.positions) {
      if (position.status == PositionStatus.open) {
        final marketData = state.marketData[position.asset];
        if (marketData != null) {
          final fundingPayment = _calculateFundingPayment(position, marketData);
          totalFunding += fundingPayment;
          
          final updatedPosition = position.copyWith(
            fundingPaid: (position.fundingPaid ?? 0.0) + fundingPayment,
          );
          updatedPositions.add(updatedPosition);
        } else {
          updatedPositions.add(position);
        }
      } else {
        updatedPositions.add(position);
      }
    }

    state = state.copyWith(
      positions: updatedPositions,
      paperBalance: state.paperBalance - totalFunding,
    );
  }

  double _calculateFundingPayment(PerpetualPosition position, MarketData marketData) {
    // Simplified funding calculation
    // Long positions pay when funding rate is positive
    // Short positions pay when funding rate is negative
    final fundingRate = marketData.fundingRate;
    final notionalValue = position.size;
    
    if (position.side == PositionSide.long) {
      return notionalValue * fundingRate;
    } else {
      return -notionalValue * fundingRate;
    }
  }
}

// Providers
final perpetualTradingProvider = StateNotifierProvider<PerpetualTradingNotifier, PerpetualTradingState>((ref) {
  return PerpetualTradingNotifier();
});

// Computed providers
final openPositionsProvider = Provider<List<PerpetualPosition>>((ref) {
  final trading = ref.watch(perpetualTradingProvider);
  return trading.positions.where((p) => p.status == PositionStatus.open).toList();
});

final totalEquityProvider = Provider<double>((ref) {
  final trading = ref.watch(perpetualTradingProvider);
  return trading.paperBalance + trading.totalPnl;
});

final marginRatioProvider = Provider<double>((ref) {
  ref.watch(perpetualTradingProvider);
  final notifier = ref.read(perpetualTradingProvider.notifier);
  return notifier.marginRatio;
});

final riskWarningsProvider = Provider<List<String>>((ref) {
  ref.watch(perpetualTradingProvider);
  final notifier = ref.read(perpetualTradingProvider.notifier);
  final warnings = <String>[];

  // Check margin ratio
  final marginRatio = notifier.marginRatio;
  if (marginRatio > 80) {
    warnings.add('High margin usage: ${marginRatio.toStringAsFixed(1)}%');
  }

  // Check positions near liquidation
  final nearLiquidation = notifier.positionsNearLiquidation;
  if (nearLiquidation.isNotEmpty) {
    warnings.add('${nearLiquidation.length} position(s) near liquidation');
  }

  // Check total equity
  final equity = notifier.totalEquity;
  if (equity < 1000) {
    warnings.add('Low account equity: \$${equity.toStringAsFixed(2)}');
  }

  return warnings;
});