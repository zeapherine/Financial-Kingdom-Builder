// import 'dart:convert';  // TODO: Uncomment when implementing real API calls
// import 'package:http/http.dart' as http;  // TODO: Add http dependency and uncomment
import '../models/lesson_content.dart';
import '../providers/education_provider.dart';
import 'localized_lesson_service.dart';

class EducationService {
  static final EducationService _instance = EducationService._internal();
  factory EducationService() => _instance;
  EducationService._internal();

  final LocalizedLessonService _localizedService = LocalizedLessonService();
  
  // Base URL for education API - in real app this would come from environment config
  static const String _baseUrl = 'https://api.financialkingdom.com/education';
  
  /// Fetch all available education modules
  /// For now, returns local data but structured for future API integration
  Future<List<EducationModule>> fetchModules({String? userId}) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/modules${userId != null ? '?userId=$userId' : ''}'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // For now, return the hardcoded modules but simulate API structure
      return _getLocalModules();
    } catch (e) {
      throw EducationServiceException('Failed to fetch modules: $e');
    }
  }

  /// Fetch user progress for all modules
  Future<Map<String, double>> fetchUserProgress(String userId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/progress/$userId'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // Simulate realistic user progress
      return {
        'financial-literacy': 0.7,
        'cryptocurrency-basics': 0.3,
        'risk-management': 0.1,
        'trading-terminology': 0.0,
        'building-permits': 0.0,
        'portfolio-management': 0.0,
      };
    } catch (e) {
      throw EducationServiceException('Failed to fetch user progress: $e');
    }
  }

  /// Update lesson completion progress
  Future<bool> updateLessonProgress({
    required String userId,
    required String moduleId,
    required String lessonId,
    required double progress,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/progress'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'userId': userId,
      //     'moduleId': moduleId,
      //     'lessonId': lessonId,
      //     'progress': progress,
      //     'timestamp': DateTime.now().toIso8601String(),
      //   }),
      // );
      
      // Simulate success
      return true;
    } catch (e) {
      throw EducationServiceException('Failed to update lesson progress: $e');
    }
  }

  /// Complete a lesson and award XP
  Future<Map<String, dynamic>> completeLesson({
    required String userId,
    required String moduleId,
    required String lessonId,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/complete'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'userId': userId,
      //     'moduleId': moduleId,
      //     'lessonId': lessonId,
      //     'completedAt': DateTime.now().toIso8601String(),
      //   }),
      // );
      
      // Simulate lesson completion response
      return {
        'success': true,
        'xpAwarded': 50,
        'newTotalXp': 300,
        'achievementsUnlocked': [],
        'modulesUnlocked': [],
      };
    } catch (e) {
      throw EducationServiceException('Failed to complete lesson: $e');
    }
  }

  /// Get lessons for a specific module
  Future<List<LessonContent>> fetchModuleLessons(String moduleId, {String? locale}) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Use localized service to get content
      final category = _moduleIdToCategory(moduleId);
      return _localizedService.getModulesByCategory(category, locale: locale);
    } catch (e) {
      throw EducationServiceException('Failed to fetch module lessons: $e');
    }
  }

  /// Check if user meets requirements to unlock a module
  Future<bool> checkModuleUnlockRequirements({
    required String userId,
    required String moduleId,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // TODO: Replace with actual API call that checks:
      // - User XP level
      // - Prerequisite modules completed
      // - Any special requirements
      
      // For now, simulate based on local logic
      final userProgress = await fetchUserProgress(userId);
      final totalXp = _calculateTotalXp(userProgress);
      
      // Simple unlock logic - in real app this would be more sophisticated
      switch (moduleId) {
        case 'building-permits':
          return totalXp >= 200;
        case 'portfolio-management':
          return totalXp >= 300;
        default:
          return true; // Village tier modules are always unlocked
      }
    } catch (e) {
      throw EducationServiceException('Failed to check unlock requirements: $e');
    }
  }

  // Helper methods

  List<EducationModule> _getLocalModules() {
    // Return the same modules as defined in education_provider.dart
    // This ensures consistency between service and provider
    return [
      const EducationModule(
        id: 'financial-literacy',
        title: 'Financial Literacy Basics',
        description: 'Master the fundamentals of personal finance and money management',
        category: 'Financial Literacy',
        isLocked: false,
      ),
      const EducationModule(
        id: 'cryptocurrency-basics',
        title: 'Cryptocurrency Basics',
        description: 'Understand digital currencies and blockchain technology',
        category: 'Cryptocurrency',
        isLocked: false,
      ),
      const EducationModule(
        id: 'risk-management',
        title: 'Risk Management',
        description: 'Learn to identify, assess, and manage investment risks',
        category: 'Risk Management',
        isLocked: false,
      ),
      const EducationModule(
        id: 'trading-terminology',
        title: 'Trading Terminology',
        description: 'Master essential trading vocabulary and concepts',
        category: 'Trading',
        isLocked: false,
      ),
      const EducationModule(
        id: 'building-permits',
        title: 'Building Permits & Regulations',
        description: 'Understand financial regulations and compliance',
        category: 'Compliance',
        isLocked: true,
        requiredXp: 200,
      ),
      const EducationModule(
        id: 'portfolio-management',
        title: 'Portfolio Management',
        description: 'Learn to build and manage investment portfolios',
        category: 'Portfolio Management',
        isLocked: true,
        requiredXp: 300,
      ),
    ];
  }

  String _moduleIdToCategory(String moduleId) {
    switch (moduleId) {
      case 'financial-literacy':
        return 'financial_literacy';
      case 'cryptocurrency-basics':
        return 'cryptocurrency';
      case 'risk-management':
        return 'risk_management';
      case 'trading-terminology':
        return 'trading_terminology';
      case 'building-permits':
        return 'building_permits';
      case 'portfolio-management':
        return 'portfolio_management';
      default:
        return 'financial_literacy';
    }
  }

  int _calculateTotalXp(Map<String, double> progress) {
    // Simple XP calculation - in real app this would be more sophisticated
    return progress.values.fold<double>(0.0, (sum, progress) => sum + (progress * 100)).round();
  }
}

class EducationServiceException implements Exception {
  final String message;
  const EducationServiceException(this.message);

  @override
  String toString() => 'EducationServiceException: $message';
}