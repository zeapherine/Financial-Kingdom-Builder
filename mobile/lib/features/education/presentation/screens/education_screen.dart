import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/duo_progress_bar.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../providers/education_provider.dart';
import '../../widgets/library_bookshelf_widget.dart';
import '../../widgets/education_search_widget.dart';
import '../../widgets/offline_indicator_widget.dart';
import '../../widgets/achievement_badge_widget.dart';
import 'module_lessons_screen.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.local_library,
              color: DuolingoTheme.duoGreen,
              size: DuolingoTheme.iconMedium,
            ),
            const SizedBox(width: DuolingoTheme.spacingSm),
            const Expanded(
              child: Text(
                'Kingdom Library',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ),
            const OfflineIndicatorWidget(),
          ],
        ),
        backgroundColor: DuolingoTheme.lightGray,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: DuolingoTheme.duoGreen,
          unselectedLabelColor: DuolingoTheme.mediumGray,
          indicatorColor: DuolingoTheme.duoGreen,
          indicatorWeight: 3.0,
          labelStyle: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              icon: Semantics(
                label: 'Library tab',
                child: const Icon(Icons.library_books),
              ),
              text: 'Library',
            ),
            Tab(
              icon: Semantics(
                label: 'Search tab',
                child: const Icon(Icons.search),
              ),
              text: 'Search',
            ),
            Tab(
              icon: Semantics(
                label: 'Achievements tab',
                child: const Icon(Icons.star),
              ),
              text: 'Achievements',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: educationState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoGreen),
                  ),
                  SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Loading your library...',
                    style: DuolingoTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryView(educationState),
                _buildSearchView(educationState),
                _buildAchievementsView(educationState),
              ],
            ),
    );
  }

  Widget _buildLibraryView(EducationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header with animated circular progress
          _buildProgressHeader(state),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Error message if present
          if (state.error != null) ...[
            _buildErrorMessage(state.error!),
            const SizedBox(height: DuolingoTheme.spacingMd),
          ],
          
          // Library Bookshelf
          LibraryBookshelfWidget(
            modules: state.modules,
            moduleProgress: state.moduleProgress,
            onModuleTap: _onModuleTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(EducationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        children: [
          EducationSearchWidget(
            controller: _searchController,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          _buildSearchResults(state),
        ],
      ),
    );
  }

  Widget _buildAchievementsView(EducationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Achievements',
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          _buildAchievementGrid(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(EducationState state) {
    final totalModules = state.modules.length;
    final completedModules = state.moduleProgress.values
        .where((progress) => progress >= 1.0)
        .length;
    final overallProgress = totalModules > 0 ? completedModules / totalModules : 0.0;

    return DuoCard(
      type: DuoCardType.streak,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated circular progress indicator
              SizedBox(
                width: 60,
                height: 60,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: overallProgress),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    backgroundColor: DuolingoTheme.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(DuolingoTheme.white),
                    strokeWidth: 6.0,
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Village Foundations',
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.white,
                      ),
                    ),
                    const SizedBox(height: DuolingoTheme.spacingXs),
                    Text(
                      'Build your knowledge to unlock trading features',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          DuoProgressBar(
            progress: overallProgress,
            type: DuoProgressType.lesson,
            height: 10,
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            '$completedModules of $totalModules modules completed',
            style: DuolingoTheme.caption.copyWith(
              color: DuolingoTheme.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoRed.withValues(alpha: 0.1),
        border: Border.all(color: DuolingoTheme.duoRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: DuolingoTheme.duoRed,
            size: DuolingoTheme.iconMedium,
          ),
          const SizedBox(width: DuolingoTheme.spacingMd),
          Expanded(
            child: Text(
              error,
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.duoRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(EducationState state) {
    if (_searchQuery.isEmpty) {
      return Semantics(
        label: 'Search area',
        hint: 'Enter search terms to find educational modules',
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: DuolingoTheme.lightGray,
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 48,
                  color: DuolingoTheme.mediumGray,
                ),
                SizedBox(height: DuolingoTheme.spacingSm),
                Text(
                  'Search for lessons, topics, or concepts',
                  style: DuolingoTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredModules = state.modules.where((module) =>
        module.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        module.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    if (filteredModules.isEmpty) {
      return Semantics(
        label: 'No search results',
        child: Container(
          height: 150,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: DuolingoTheme.mediumGray,
                ),
                SizedBox(height: DuolingoTheme.spacingSm),
                Text(
                  'No modules found',
                  style: DuolingoTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: '${filteredModules.length} search results found',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredModules.length,
        cacheExtent: 500, // Optimize for performance
        itemBuilder: (context, index) {
          final module = filteredModules[index];
          return _EducationModule(
            module: module,
            progress: state.moduleProgress[module.id] ?? 0.0,
            onTap: () => _onModuleTap(module),
          );
        },
      ),
    );
  }

  Widget _buildAchievementGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DuolingoTheme.spacingMd,
        crossAxisSpacing: DuolingoTheme.spacingMd,
        childAspectRatio: 1.2,
      ),
      itemCount: 6, // Sample achievements
      itemBuilder: (context, index) {
        return AchievementBadgeWidget(
          title: _getAchievementTitle(index),
          description: _getAchievementDescription(index),
          isUnlocked: index < 3, // First 3 are unlocked
          icon: _getAchievementIcon(index),
        );
      },
    );
  }

  String _getAchievementTitle(int index) {
    switch (index) {
      case 0: return 'First Steps';
      case 1: return 'Knowledge Seeker';
      case 2: return 'Quick Learner';
      case 3: return 'Module Master';
      case 4: return 'Trading Ready';
      case 5: return 'Kingdom Builder';
      default: return 'Achievement';
    }
  }

  String _getAchievementDescription(int index) {
    switch (index) {
      case 0: return 'Complete your first lesson';
      case 1: return 'Complete 5 lessons';
      case 2: return 'Perfect quiz score';
      case 3: return 'Complete all modules';
      case 4: return 'Pass trading assessment';
      case 5: return 'Unlock new kingdom area';
      default: return 'Achievement description';
    }
  }

  IconData _getAchievementIcon(int index) {
    switch (index) {
      case 0: return Icons.play_arrow;
      case 1: return Icons.search;
      case 2: return Icons.flash_on;
      case 3: return Icons.school;
      case 4: return Icons.trending_up;
      case 5: return Icons.castle;
      default: return Icons.star;
    }
  }

  void _onModuleTap(EducationModule module) {
    if (!module.isLocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ModuleLessonsScreen(module: module),
        ),
      );
    }
  }
}

class _EducationModule extends StatelessWidget {
  final EducationModule module;
  final double progress;
  final VoidCallback? onTap;

  const _EducationModule({
    required this.module,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: DuoCard(
        type: DuoCardType.lesson,
        onTap: module.isLocked ? null : onTap,
        child: Row(
          children: [
            // Module Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: module.isLocked 
                    ? DuolingoTheme.mediumGray 
                    : (progress > 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoBlue),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: module.isLocked ? null : DuolingoTheme.cardShadow,
              ),
              child: Icon(
                module.isLocked ? Icons.lock : _getModuleIcon(module.category),
                color: DuolingoTheme.white,
                size: DuolingoTheme.iconLarge,
              ),
            ),
            const SizedBox(width: DuolingoTheme.spacingMd),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          module.title,
                          style: DuolingoTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: module.isLocked 
                                ? DuolingoTheme.mediumGray 
                                : DuolingoTheme.charcoal,
                          ),
                        ),
                      ),
                      if (!module.isLocked) ...[
                        Icon(
                          Icons.star,
                          color: DuolingoTheme.duoYellow,
                          size: DuolingoTheme.iconSmall,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+${_getXpReward(module.category)} XP',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.duoYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    module.description,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: module.isLocked 
                          ? DuolingoTheme.mediumGray 
                          : DuolingoTheme.darkGray,
                    ),
                  ),
                  if (!module.isLocked) ...[
                    const SizedBox(height: DuolingoTheme.spacingMd),
                    DuoProgressBar(
                      progress: progress,
                      type: DuoProgressType.lesson,
                    ),
                    const SizedBox(height: DuolingoTheme.spacingXs),
                    Text(
                      '${(progress * 100).toInt()}% complete',
                      style: DuolingoTheme.caption.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: module.isLocked 
                  ? DuolingoTheme.mediumGray 
                  : DuolingoTheme.duoGreen,
              size: DuolingoTheme.iconSmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuleIcon(String category) {
    switch (category) {
      case 'Financial Literacy':
        return Icons.account_balance_wallet;
      case 'Perpetual Trading':
        return Icons.swap_horiz;
      case 'Cryptocurrency':
        return Icons.currency_bitcoin;
      case 'Risk Management':
        return Icons.security;
      case 'Trading':
        return Icons.trending_up;
      case 'Compliance':
        return Icons.gavel;
      case 'Portfolio Management':
        return Icons.pie_chart;
      default:
        return Icons.school;
    }
  }

  int _getXpReward(String category) {
    switch (category) {
      case 'Financial Literacy':
        return 50;
      case 'Perpetual Trading':
        return 85;
      case 'Cryptocurrency':
        return 60;
      case 'Risk Management':
        return 75;
      case 'Trading':
        return 100;
      case 'Compliance':
        return 80;
      case 'Portfolio Management':
        return 125;
      default:
        return 25;
    }
  }
}