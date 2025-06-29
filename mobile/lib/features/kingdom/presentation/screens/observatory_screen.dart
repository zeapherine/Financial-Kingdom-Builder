import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/app_drawer.dart';

class ObservatoryScreen extends StatelessWidget {
  const ObservatoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observatory'),
        backgroundColor: DuolingoTheme.duoOrange,
        foregroundColor: DuolingoTheme.white,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 80,
              color: DuolingoTheme.duoOrange,
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'Observatory',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.charcoal,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              'Analytics & Insights',
              style: TextStyle(
                fontSize: 16,
                color: DuolingoTheme.darkGray,
              ),
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
              child: Text(
                'Coming Soon: Track your performance, analyze market trends, and get insights into your trading and learning journey.',
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