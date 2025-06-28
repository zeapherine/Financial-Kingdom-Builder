import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class AppState {
  final AppThemeMode themeMode;
  final bool isAuthenticated;
  final String? userId;
  final int selectedBottomNavIndex;

  const AppState({
    this.themeMode = AppThemeMode.system,
    this.isAuthenticated = false,
    this.userId,
    this.selectedBottomNavIndex = 0,
  });

  AppState copyWith({
    AppThemeMode? themeMode,
    bool? isAuthenticated,
    String? userId,
    int? selectedBottomNavIndex,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setAuthentication({required bool isAuthenticated, String? userId}) {
    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      userId: userId,
    );
  }

  void setBottomNavIndex(int index) {
    state = state.copyWith(selectedBottomNavIndex: index);
  }

  void logout() {
    state = state.copyWith(
      isAuthenticated: false,
      userId: null,
    );
  }
}

// Provider definition
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isAuthenticated;
});

final currentThemeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).userId;
});