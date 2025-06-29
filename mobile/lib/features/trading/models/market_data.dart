class MarketData {
  final String symbol;
  final double price;
  final double change24h;
  final double changePercent24h;
  final double volume24h;
  final double fundingRate;
  final DateTime lastUpdate;
  final double? indexPrice;
  final double? markPrice;
  final int? openInterest;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.volume24h,
    required this.fundingRate,
    required this.lastUpdate,
    this.indexPrice,
    this.markPrice,
    this.openInterest,
  });

  /// Get kingdom-themed price description
  String get kingdomPriceDescription {
    final territory = symbol == 'BTCUSDT' 
        ? 'Bitcoin Kingdom' 
        : symbol == 'ETHUSDT' 
        ? 'Ethereum Realm' 
        : '$symbol Territory';
    
    return '$territory trading at ${price.toStringAsFixed(2)} gold pieces';
  }

  /// Get funding rate description
  String get fundingDescription {
    if (fundingRate > 0) {
      return 'Expansion tax: ${(fundingRate * 100).toStringAsFixed(4)}%';
    } else if (fundingRate < 0) {
      return 'Defense reward: ${(fundingRate.abs() * 100).toStringAsFixed(4)}%';
    } else {
      return 'Balanced kingdom: 0.0000%';
    }
  }

  /// Get trend direction
  String get trendDirection {
    if (changePercent24h > 2) {
      return 'Strong Growth';
    } else if (changePercent24h > 0) {
      return 'Growing';
    } else if (changePercent24h > -2) {
      return 'Declining';
    } else {
      return 'Under Siege';
    }
  }

  /// Get trend color based on change
  String get trendColorHex {
    if (changePercent24h > 0) {
      return '#059669'; // Green
    } else if (changePercent24h < 0) {
      return '#DC2626'; // Red
    } else {
      return '#6B7280'; // Gray
    }
  }

  /// Check if funding rate favors longs or shorts
  bool get favorLongs => fundingRate < 0;
  bool get favorShorts => fundingRate > 0;

  /// Create a copy with updated values
  MarketData copyWith({
    String? symbol,
    double? price,
    double? change24h,
    double? changePercent24h,
    double? volume24h,
    double? fundingRate,
    DateTime? lastUpdate,
    double? indexPrice,
    double? markPrice,
    int? openInterest,
  }) {
    return MarketData(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      changePercent24h: changePercent24h ?? this.changePercent24h,
      volume24h: volume24h ?? this.volume24h,
      fundingRate: fundingRate ?? this.fundingRate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      indexPrice: indexPrice ?? this.indexPrice,
      markPrice: markPrice ?? this.markPrice,
      openInterest: openInterest ?? this.openInterest,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'change24h': change24h,
      'changePercent24h': changePercent24h,
      'volume24h': volume24h,
      'fundingRate': fundingRate,
      'lastUpdate': lastUpdate.toIso8601String(),
      'indexPrice': indexPrice,
      'markPrice': markPrice,
      'openInterest': openInterest,
    };
  }

  /// Create from JSON
  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'],
      price: json['price'].toDouble(),
      change24h: json['change24h'].toDouble(),
      changePercent24h: json['changePercent24h'].toDouble(),
      volume24h: json['volume24h'].toDouble(),
      fundingRate: json['fundingRate'].toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate']),
      indexPrice: json['indexPrice']?.toDouble(),
      markPrice: json['markPrice']?.toDouble(),
      openInterest: json['openInterest']?.toInt(),
    );
  }
}