import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_provider.g.dart';

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

@Riverpod(keepAlive: true)
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    return const AppState();
  }

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
}