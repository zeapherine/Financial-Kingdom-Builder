import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/app_drawer.dart';

class TownCenterScreen extends StatelessWidget {
  const TownCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Town Center'),
        backgroundColor: DuolingoTheme.duoBlue,
        foregroundColor: DuolingoTheme.white,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.castle,
              size: 80,
              color: DuolingoTheme.duoBlue,
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'Town Center',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.charcoal,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              'Kingdom Management Hub',
              style: TextStyle(
                fontSize: 16,
                color: DuolingoTheme.darkGray,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
              child: Text(
                'Coming Soon: Manage your kingdom\'s development, view your progress, and plan your educational journey.',
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