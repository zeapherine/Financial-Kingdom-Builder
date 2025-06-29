import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/app_drawer.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: DuolingoTheme.duoGreen,
        foregroundColor: DuolingoTheme.white,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 80,
              color: DuolingoTheme.duoGreen,
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.charcoal,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              'Social Trading Hub',
              style: TextStyle(
                fontSize: 16,
                color: DuolingoTheme.darkGray,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
              child: Text(
                'Coming Soon: Connect with other traders, share strategies, and explore community-driven trading opportunities.',
                style: TextStyle(
                  fontSize: 14,
                  color: DuolingoTheme.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}