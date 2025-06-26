import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KingdomScreen extends ConsumerWidget {
  const KingdomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Kingdom'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.castle,
              size: 120,
              color: Color(0xFFD4AF37),
            ),
            SizedBox(height: 20),
            Text(
              'Village Stage',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Complete educational modules to grow your kingdom',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // Placeholder for kingdom buildings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _KingdomBuilding(
                  icon: Icons.library_books,
                  label: 'Library',
                  isUnlocked: true,
                ),
                _KingdomBuilding(
                  icon: Icons.store,
                  label: 'Trading Post',
                  isUnlocked: false,
                ),
                _KingdomBuilding(
                  icon: Icons.account_balance,
                  label: 'Treasury',
                  isUnlocked: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KingdomBuilding extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUnlocked;

  const _KingdomBuilding({
    required this.icon,
    required this.label,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFFD4AF37) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 40,
            color: isUnlocked ? Colors.white : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}