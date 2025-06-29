enum PositionSide { long, short }

enum PositionStatus { open, closed, liquidated }

class PerpetualPosition {
  final String id;
  final String asset;
  final PositionSide side;
  final double entryPrice;
  final double size;
  final double leverage;
  final double margin;
  final PositionStatus status;
  final DateTime openTime;
  final DateTime? closeTime;
  final double? closePrice;
  final double? pnl;
  final double? liquidationPrice;
  final double? fundingPaid;
  final bool isPaperTrading;

  const PerpetualPosition({
    required this.id,
    required this.asset,
    required this.side,
    required this.entryPrice,
    required this.size,
    required this.leverage,
    required this.margin,
    required this.status,
    required this.openTime,
    this.closeTime,
    this.closePrice,
    this.pnl,
    this.liquidationPrice,
    this.fundingPaid,
    this.isPaperTrading = false,
  });

  /// Calculate current PnL based on current market price
  double calculatePnl(double currentPrice) {
    final priceDiff = side == PositionSide.long
        ? currentPrice - entryPrice
        : entryPrice - currentPrice;
    return (priceDiff / entryPrice) * size * leverage;
  }

  /// Calculate liquidation price for this position
  double calculateLiquidationPrice() {
    final marginRatio = 1 / leverage;
    if (side == PositionSide.long) {
      return entryPrice * (1 - marginRatio * 0.9); // 90% of margin
    } else {
      return entryPrice * (1 + marginRatio * 0.9);
    }
  }

  /// Calculate percentage PnL
  double calculatePnlPercentage(double currentPrice) {
    final unrealizedPnl = calculatePnl(currentPrice);
    return (unrealizedPnl / margin) * 100;
  }

  /// Check if position is close to liquidation
  bool isNearLiquidation(double currentPrice, {double threshold = 0.1}) {
    final liquidationPrice = calculateLiquidationPrice();
    if (side == PositionSide.long) {
      return currentPrice <= liquidationPrice * (1 + threshold);
    } else {
      return currentPrice >= liquidationPrice * (1 - threshold);
    }
  }

  /// Get kingdom-themed position description
  String get kingdomDescription {
    final territory = asset == 'BTC' 
        ? 'Bitcoin Kingdom' 
        : asset == 'ETH' 
        ? 'Ethereum Realm' 
        : '$asset Territory';
    
    final action = side == PositionSide.long 
        ? 'expanding into' 
        : 'defending against';
    
    return 'Currently $action $territory with ${leverage}x force';
  }

  /// Get position size in kingdom metaphor
  String get kingdomSize {
    if (size >= 1000) {
      return '${(size / 1000).toStringAsFixed(1)}K gold army';
    } else {
      return '${size.toStringAsFixed(0)} gold army';
    }
  }

  /// Create a copy with updated values
  PerpetualPosition copyWith({
    String? id,
    String? asset,
    PositionSide? side,
    double? entryPrice,
    double? size,
    double? leverage,
    double? margin,
    PositionStatus? status,
    DateTime? openTime,
    DateTime? closeTime,
    double? closePrice,
    double? pnl,
    double? liquidationPrice,
    double? fundingPaid,
    bool? isPaperTrading,
  }) {
    return PerpetualPosition(
      id: id ?? this.id,
      asset: asset ?? this.asset,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      size: size ?? this.size,
      leverage: leverage ?? this.leverage,
      margin: margin ?? this.margin,
      status: status ?? this.status,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      closePrice: closePrice ?? this.closePrice,
      pnl: pnl ?? this.pnl,
      liquidationPrice: liquidationPrice ?? this.liquidationPrice,
      fundingPaid: fundingPaid ?? this.fundingPaid,
      isPaperTrading: isPaperTrading ?? this.isPaperTrading,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset': asset,
      'side': side.name,
      'entryPrice': entryPrice,
      'size': size,
      'leverage': leverage,
      'margin': margin,
      'status': status.name,
      'openTime': openTime.toIso8601String(),
      'closeTime': closeTime?.toIso8601String(),
      'closePrice': closePrice,
      'pnl': pnl,
      'liquidationPrice': liquidationPrice,
      'fundingPaid': fundingPaid,
      'isPaperTrading': isPaperTrading,
    };
  }

  /// Create from JSON
  factory PerpetualPosition.fromJson(Map<String, dynamic> json) {
    return PerpetualPosition(
      id: json['id'],
      asset: json['asset'],
      side: PositionSide.values.firstWhere((e) => e.name == json['side']),
      entryPrice: json['entryPrice'].toDouble(),
      size: json['size'].toDouble(),
      leverage: json['leverage'].toDouble(),
      margin: json['margin'].toDouble(),
      status: PositionStatus.values.firstWhere((e) => e.name == json['status']),
      openTime: DateTime.parse(json['openTime']),
      closeTime: json['closeTime'] != null ? DateTime.parse(json['closeTime']) : null,
      closePrice: json['closePrice']?.toDouble(),
      pnl: json['pnl']?.toDouble(),
      liquidationPrice: json['liquidationPrice']?.toDouble(),
      fundingPaid: json['fundingPaid']?.toDouble(),
      isPaperTrading: json['isPaperTrading'] ?? false,
    );
  }
}