import 'package:flutter/material.dart';

// Helper widget to add tutorial capability to any widget
class TutorialTarget extends StatelessWidget {
  final GlobalKey tutorialKey;
  final Widget child;

  const TutorialTarget({
    super.key,
    required this.tutorialKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: tutorialKey,
      child: child,
    );
  }
}