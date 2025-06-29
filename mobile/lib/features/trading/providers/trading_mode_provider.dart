import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';

enum TradingMode {
  paper,
  real,
}

class TradingModeState {
  final TradingMode currentMode;
  final bool hasRealTradingAccess;
  final bool isTransitioning;
  final double paperBalance;
  final double? realBalance;

  const TradingModeState({
    required this.currentMode,
    required this.hasRealTradingAccess,
    this.isTransitioning = false,
    this.paperBalance = 10000.0,
    this.realBalance,
  });

  TradingModeState copyWith({
    TradingMode? currentMode,
    bool? hasRealTradingAccess,
    bool? isTransitioning,
    double? paperBalance,
    double? realBalance,
  }) {
    return TradingModeState(
      currentMode: currentMode ?? this.currentMode,
      hasRealTradingAccess: hasRealTradingAccess ?? this.hasRealTradingAccess,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      paperBalance: paperBalance ?? this.paperBalance,
      realBalance: realBalance ?? this.realBalance,
    );
  }

  bool get isRealMode => currentMode == TradingMode.real;
  bool get isPaperMode => currentMode == TradingMode.paper;
  
  double get currentBalance => isRealMode ? (realBalance ?? 0.0) : paperBalance;
  
  String get modeDisplayName => isRealMode ? 'Real Trading' : 'Paper Trading';
  
  String get balanceDisplayText => isRealMode 
      ? 'Real Balance: \$${currentBalance.toStringAsFixed(2)}'
      : 'Paper Balance: \$${currentBalance.toStringAsFixed(2)}';
}

class TradingModeNotifier extends StateNotifier<TradingModeState> {
  final SecureStorage _secureStorage;

  TradingModeNotifier(this._secureStorage) : super(const TradingModeState(
    currentMode: TradingMode.paper,
    hasRealTradingAccess: false,
  )) {
    _loadTradingMode();
  }

  Future<void> _loadTradingMode() async {
    try {
      final savedMode = await _secureStorage.read('trading_mode');
      final hasAccess = await _secureStorage.read('has_real_trading_access') == 'true';
      final paperBalance = double.tryParse(await _secureStorage.read('paper_balance') ?? '') ?? 10000.0;
      final realBalance = double.tryParse(await _secureStorage.read('real_balance') ?? '');

      final mode = savedMode == 'real' ? TradingMode.real : TradingMode.paper;
      
      state = state.copyWith(
        currentMode: mode,
        hasRealTradingAccess: hasAccess,
        paperBalance: paperBalance,
        realBalance: realBalance,
      );
    } catch (e) {
      // Default to paper trading if any error
      state = state.copyWith(currentMode: TradingMode.paper);
    }
  }

  Future<bool> switchToRealTrading() async {
    if (!state.hasRealTradingAccess) {
      return false;
    }

    state = state.copyWith(isTransitioning: true);

    try {
      // Simulate validation and switching process
      await Future.delayed(const Duration(milliseconds: 800));
      
      await _secureStorage.write('trading_mode', 'real');
      
      state = state.copyWith(
        currentMode: TradingMode.real,
        isTransitioning: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isTransitioning: false);
      return false;
    }
  }

  Future<bool> switchToPaperTrading() async {
    state = state.copyWith(isTransitioning: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _secureStorage.write('trading_mode', 'paper');
      
      state = state.copyWith(
        currentMode: TradingMode.paper,
        isTransitioning: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isTransitioning: false);
      return false;
    }
  }

  Future<void> enableRealTrading() async {
    await _secureStorage.write('has_real_trading_access', 'true');
    state = state.copyWith(hasRealTradingAccess: true);
  }

  Future<void> updateBalance(double newBalance) async {
    if (state.isRealMode) {
      await _secureStorage.write('real_balance', newBalance.toString());
      state = state.copyWith(realBalance: newBalance);
    } else {
      await _secureStorage.write('paper_balance', newBalance.toString());
      state = state.copyWith(paperBalance: newBalance);
    }
  }

  void resetPaperBalance() {
    updateBalance(10000.0);
  }
}

final tradingModeProvider = StateNotifierProvider<TradingModeNotifier, TradingModeState>(
  (ref) => TradingModeNotifier(ref.read(secureStorageProvider)),
);

// Convenience providers
final currentTradingModeProvider = Provider<TradingMode>((ref) {
  return ref.watch(tradingModeProvider).currentMode;
});

final isRealTradingProvider = Provider<bool>((ref) {
  return ref.watch(tradingModeProvider).isRealMode;
});

final currentBalanceProvider = Provider<double>((ref) {
  return ref.watch(tradingModeProvider).currentBalance;
});

final hasRealTradingAccessProvider = Provider<bool>((ref) {
  return ref.watch(tradingModeProvider).hasRealTradingAccess;
});