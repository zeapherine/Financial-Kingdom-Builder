import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_drawer.dart';

class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Post'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paper Trading Portfolio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Virtual Balance: \$10,000.00',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'P&L: \$0.00 (0.00%)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Assets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _AssetTile(
                    symbol: 'BTC',
                    name: 'Bitcoin',
                    price: '\$45,230.00',
                    change: '+2.45%',
                    isPositive: true,
                  ),
                  _AssetTile(
                    symbol: 'ETH',
                    name: 'Ethereum',
                    price: '\$3,150.00',
                    change: '+1.23%',
                    isPositive: true,
                  ),
                  _AssetTile(
                    symbol: 'ADA',
                    name: 'Cardano',
                    price: '\$0.52',
                    change: '-0.75%',
                    isPositive: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Show trading interface
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complete educational modules to unlock trading'),
                    ),
                  );
                },
                child: const Text('Start Trading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isPositive;

  const _AssetTile({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD4AF37),
          child: Text(
            symbol.substring(0, 2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Show asset details
        },
      ),
    );
  }
}