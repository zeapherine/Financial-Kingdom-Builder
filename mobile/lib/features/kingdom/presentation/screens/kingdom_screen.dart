import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/gamification_widgets.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/tutorial_overlay.dart';
import '../../../../shared/widgets/tutorial_target.dart';
import '../widgets/kingdom_buildings.dart';
import '../widgets/additional_buildings.dart';
import '../widgets/kingdom_tier_transitions.dart';
import '../widgets/building_upgrade_animations.dart';
import '../../domain/models/kingdom_state.dart';
import '../../providers/kingdom_provider.dart';

class KingdomScreen extends ConsumerStatefulWidget {
  const KingdomScreen({super.key});

  @override
  ConsumerState<KingdomScreen> createState() => _KingdomScreenState();
}

class _KingdomScreenState extends ConsumerState<KingdomScreen> {
  final GlobalKey _levelBadgeKey = GlobalKey();
  final GlobalKey _libraryKey = GlobalKey();
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _xpBadgeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final kingdomState = ref.watch(kingdomProvider);
    return TutorialOverlay(
      steps: [
        TutorialStep(
          targetKey: _drawerKey,
          title: 'Navigation Menu',
          description: 'Tap the menu icon to access your profile, settings, and more!',
          tooltipPosition: const Offset(20, 100),
        ),
        TutorialStep(
          targetKey: _xpBadgeKey,
          title: 'Experience Points',
          description: 'Complete lessons and trading activities to earn XP and level up!',
          tooltipPosition: const Offset(50, 100),
        ),
        TutorialStep(
          targetKey: _levelBadgeKey,
          title: 'Your Current Level',
          description: 'Start as a Village Citizen and progress to Kingdom Mastery through education!',
          tooltipPosition: const Offset(50, 200),
        ),
        TutorialStep(
          targetKey: _libraryKey,
          title: 'Library - Start Here!',
          description: 'Begin your journey with financial education. Complete modules to unlock trading features.',
          tooltipPosition: const Offset(50, 300),
        ),
      ],
      onComplete: () {
        // TODO: Mark tutorial as completed in preferences
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Your Kingdom'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
            child: Row(
              children: [
                TutorialTarget(
                  tutorialKey: _xpBadgeKey,
                  child: const XPBadge(xp: 150),
                ),
                const SizedBox(width: DuolingoTheme.spacingSm),
                const StreakCounter(streakCount: 7),
              ],
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Level Badge
            TutorialTarget(
              tutorialKey: _levelBadgeKey,
              child: Semantics(
                label: 'Current kingdom level: Village Citizen, Level 1',
                hint: 'Complete education modules to advance to the next level',
                child: const LevelBadge(
                  level: 'Village Citizen',
                  subtitle: 'Level 1',
                ),
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Kingdom Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DuolingoTheme.duoGreen,
                shape: BoxShape.circle,
                boxShadow: DuolingoTheme.elevatedShadow,
              ),
              child: const Icon(
                Icons.castle,
                size: DuolingoTheme.iconXlarge + 16,
                color: DuolingoTheme.white,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Title
            Text(
              '${kingdomState.tierDisplayName} Stage',
              style: DuolingoTheme.h2.copyWith(
                color: DuolingoTheme.charcoal,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            
            // Subtitle
            Text(
              'Complete educational modules to grow your kingdom',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Kingdom tier progression indicator
            Semantics(
              label: 'Kingdom progression: ${kingdomState.tierDisplayName} stage, ${(kingdomState.progressToNextTier * 100).toInt()}% progress to next tier',
              hint: 'Complete activities to advance your kingdom',
              child: TierProgressionIndicator(
                currentTier: kingdomState.tier,
                progress: kingdomState.progressToNextTier,
                isUpgrading: false, // TODO: Connect to actual tier upgrade state
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingXl),
            
            // Kingdom Buildings with Enhanced Visuals - Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive column count based on screen width
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth < 400) {
                  crossAxisCount = 2;
                }
                
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: DuolingoTheme.spacingMd,
                  mainAxisSpacing: DuolingoTheme.spacingMd,
                  childAspectRatio: constraints.maxWidth > 600 ? 0.85 : 0.9,
              children: [
                // Town Center - unlocked at higher levels
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.townCenter),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.townCenter),
                    building: KingdomBuilding.townCenter,
                    child: TownCenterBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.townCenter),
                      onTap: () {
                        // TODO: Navigate to kingdom management
                      },
                    ),
                  ),
                ),
                
                // Library - available from start
                TutorialTarget(
                  tutorialKey: _libraryKey,
                  child: KingdomTierTransition(
                    currentTier: kingdomState.tier,
                    child: BuildingUpgradeAnimation(
                      currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.library),
                      targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.library),
                      building: KingdomBuilding.library,
                      child: LibraryBuilding(
                        isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.library),
                        onTap: () => context.go('/education'),
                      ),
                    ),
                  ),
                ),
                
                // Trading Post - unlocked after completing education modules
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.tradingPost),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.tradingPost),
                    building: KingdomBuilding.tradingPost,
                    child: TradingPostBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.tradingPost),
                      onTap: () => context.go('/trading'),
                    ),
                  ),
                ),
                
                // Treasury - unlocked after first trades
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.treasury),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.treasury),
                    building: KingdomBuilding.treasury,
                    child: TreasuryBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.treasury),
                      onTap: () {
                        // TODO: Navigate to portfolio management
                      },
                    ),
                  ),
                ),
                
                // Marketplace - unlocked at City level for social trading
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.marketplace),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.marketplace),
                    building: KingdomBuilding.marketplace,
                    child: MarketplaceBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.marketplace),
                      onTap: () => context.go('/social'),
                    ),
                  ),
                ),
                
                // Observatory - unlocked at Kingdom level for advanced analytics
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.observatory),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.observatory),
                    building: KingdomBuilding.observatory,
                    child: ObservatoryBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.observatory),
                      onTap: () {
                        // TODO: Navigate to market analysis
                      },
                    ),
                  ),
                ),
                
                // Academy - unlocked at Town level for advanced education
                KingdomTierTransition(
                  currentTier: kingdomState.tier,
                  child: BuildingUpgradeAnimation(
                    currentLevel: kingdomState.getBuildingLevel(KingdomBuilding.academy),
                    targetLevel: kingdomState.getBuildingLevel(KingdomBuilding.academy),
                    building: KingdomBuilding.academy,
                    child: AcademyBuilding(
                      isUnlocked: kingdomState.isBuildingUnlocked(KingdomBuilding.academy),
                      onTap: () {
                        // TODO: Navigate to advanced education modules
                      },
                    ),
                  ),
                ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}

