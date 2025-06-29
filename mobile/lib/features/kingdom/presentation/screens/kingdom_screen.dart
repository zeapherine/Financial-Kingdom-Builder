import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/gamification_widgets.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/tutorial_overlay.dart';
import '../../../../shared/widgets/tutorial_target.dart';
import '../widgets/kingdom_tier_transitions.dart';
import '../widgets/kingdom_progression_visuals.dart';
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
        padding: const EdgeInsets.only(
          left: DuolingoTheme.spacingSm,
          right: DuolingoTheme.spacingSm,
          top: DuolingoTheme.spacingSm,
          bottom: DuolingoTheme.spacingXl + DuolingoTheme.spacingLg, // Increased bottom padding to prevent overflow
        ),
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
            const SizedBox(height: DuolingoTheme.spacingMd),
            
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
            const SizedBox(height: DuolingoTheme.spacingMd),
            
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
            const SizedBox(height: DuolingoTheme.spacingMd),
            
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
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            // Kingdom Buildings with Enhanced Visuals - Using KingdomProgressionBuilder
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: DuolingoTheme.spacingSm,
              mainAxisSpacing: DuolingoTheme.spacingSm,
              childAspectRatio: 1.1,
              children: [
                // Town Center - shows progression from village to kingdom
                GestureDetector(
                  onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.townCenter) 
                      ? () {
                          context.go('/kingdom/town-center');
                        }
                      : null,
                  child: _buildKingdomBuilding(
                    kingdomState,
                    KingdomBuilding.townCenter,
                    kingdomState.isBuildingUnlocked(KingdomBuilding.townCenter),
                  ),
                ),
                
                // Library - available from start, shows progression  
                TutorialTarget(
                  tutorialKey: _libraryKey,
                  child: GestureDetector(
                    onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.library) 
                        ? () {
                            context.go('/education');
                          }
                        : null,
                    child: _buildKingdomBuilding(
                      kingdomState,
                      KingdomBuilding.library,
                      kingdomState.isBuildingUnlocked(KingdomBuilding.library),
                    ),
                  ),
                ),
                
                // Trading Post - unlocked after completing education modules
                GestureDetector(
                  onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.tradingPost) 
                      ? () {
                          context.go('/trading');
                        }
                      : null,
                  child: _buildKingdomBuilding(
                    kingdomState,
                    KingdomBuilding.tradingPost,
                    kingdomState.isBuildingUnlocked(KingdomBuilding.tradingPost),
                  ),
                ),
                
                // Treasury - unlocked after first trades
                GestureDetector(
                  onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.treasury) 
                      ? () {
                          context.go('/kingdom/treasury');
                        }
                      : null,
                  child: _buildKingdomBuilding(
                    kingdomState,
                    KingdomBuilding.treasury,
                    kingdomState.isBuildingUnlocked(KingdomBuilding.treasury),
                  ),
                ),
                
                // Marketplace
                GestureDetector(
                  onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.marketplace) 
                      ? () {
                          context.go('/kingdom/marketplace');
                        }
                      : null,
                  child: _buildKingdomBuilding(
                    kingdomState,
                    KingdomBuilding.marketplace,
                    kingdomState.isBuildingUnlocked(KingdomBuilding.marketplace),
                  ),
                ),
                
                // Observatory
                GestureDetector(
                  onTap: kingdomState.isBuildingUnlocked(KingdomBuilding.observatory) 
                      ? () {
                          context.go('/kingdom/observatory');
                        }
                      : null,
                  child: _buildKingdomBuilding(
                    kingdomState,
                    KingdomBuilding.observatory,
                    kingdomState.isBuildingUnlocked(KingdomBuilding.observatory),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildKingdomBuilding(KingdomState kingdomState, KingdomBuilding building, bool isUnlocked) {
    return KingdomProgressionBuilder(
      tier: kingdomState.tier,
      building: building,
      isUnlocked: isUnlocked,
      buildingLevel: kingdomState.getBuildingLevel(building),
    );
  }
}

