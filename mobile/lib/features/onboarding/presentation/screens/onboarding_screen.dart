import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Your Financial Kingdom!',
      description: 'Build your trading empire through gamified education. Start as a village citizen and grow to kingdom mastery.',
      icon: Icons.castle,
      color: DuolingoTheme.duoGreen,
    ),
    OnboardingPage(
      title: 'Learn Before You Earn',
      description: 'Complete educational modules to unlock real trading features. We prioritize your financial safety above all.',
      icon: Icons.school,
      color: DuolingoTheme.duoBlue,
    ),
    OnboardingPage(
      title: 'Start With Paper Trading',
      description: 'Practice with virtual currency first. Master the basics before risking real money.',
      icon: Icons.trending_up,
      color: DuolingoTheme.duoOrange,
    ),
    OnboardingPage(
      title: 'Build Your Community',
      description: 'Connect with other learners, share achievements, and grow together on your financial journey.',
      icon: Icons.people,
      color: DuolingoTheme.duoPurple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                child: TextButton(
                  onPressed: () => _finishOnboarding(),
                  child: Text(
                    'Skip',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
              child: Row(
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    Expanded(
                      child: DuoButton(
                        text: 'Previous',
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        type: DuoButtonType.outline,
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: DuolingoTheme.spacingMd),
                  
                  // Next/Get Started button
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: DuoButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      type: DuoButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingXl),
          
          // Title
          Text(
            page.title,
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Description
          Text(
            page.description,
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.darkGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingXs),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? DuolingoTheme.duoGreen 
            : DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
      ),
    );
  }

  void _finishOnboarding() {
    // TODO: Mark onboarding as completed in preferences
    context.go('/kingdom');
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}