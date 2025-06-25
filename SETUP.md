# Financial Kingdom Builder - Setup Guide

## Prerequisites

### 1. Flutter SDK Installation
Install Flutter SDK 3.16+ from [flutter.dev](https://flutter.dev/docs/get-started/install)

```bash
# Verify installation
flutter --version
flutter doctor
```

### 2. IDE Setup
- **VS Code**: Install Flutter and Dart extensions
- **Android Studio**: Install Flutter plugin

## Project Setup

### 1. Navigate to Project Directory
```bash
cd /Users/zeapherineislary/Desktop/projects/claude/mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code (Riverpod Providers)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Environment Configuration
The `.env` files are already created with the following structure:
- `.env` - Default development environment
- `.env.dev` - Development environment
- `.env.staging` - Staging environment  
- `.env.prod` - Production environment

**Important**: Replace placeholder API keys with actual values:
- `COINGECKO_API_KEY` - Get from [CoinGecko API](https://www.coingecko.com/en/api)
- `EXTENDED_API_KEY` - Extended trading platform API key
- `BRAVE_API_KEY` - Brave Search API key (for MCP server)

### 5. Run the Application
```bash
flutter run
```

## Project Structure

The project follows a feature-based architecture:

```
lib/
├── core/
│   ├── app.dart              # Main app widget
│   ├── config/
│   │   ├── environment.dart  # Environment configuration
│   │   └── theme.dart       # App theming
│   └── router/
│       └── app_router.dart  # GoRouter configuration
├── features/
│   ├── auth/                # Authentication feature
│   ├── education/           # Educational content
│   ├── kingdom/             # Kingdom building mechanics
│   ├── social/              # Social/community features
│   └── trading/             # Trading functionality
└── shared/
    ├── providers/           # Global state providers
    └── presentation/        # Shared UI components
```

## Development Workflow

### 1. Code Generation
When you modify Riverpod providers (files with `@riverpod` annotations), run:
```bash
dart run build_runner build
```

For continuous code generation during development:
```bash
dart run build_runner watch
```

### 2. Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### 3. Building
```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## Phase 1 Foundation Status ✅

The following Phase 1 foundation tasks have been completed:

- ✅ **INFRA-001**: Flutter project initialization with proper architecture
- ✅ **Feature-based folder structure**: kingdom/, education/, trading/, social/, auth/
- ✅ **Environment configuration**: .env files for dev/staging/prod environments
- ✅ **Basic theming**: Kingdom-themed color palette and Material 3 design
- ✅ **Riverpod 2.x setup**: State management architecture with providers
- ✅ **Navigation**: GoRouter setup with all main screens
- ✅ **Core screens**: Home, Kingdom, Education, Trading, Social, Login screens

## Next Steps

1. **Install Flutter SDK** (if not already installed)
2. **Run code generation**: `dart run build_runner build`
3. **Start Kingdom UI implementation** (UI-001 from TASK.md)
4. **Implement educational content system** (EDU-001 from TASK.md)

## API Keys Required

Before running the app in production mode, ensure you have:
- CoinGecko API key for market data
- Extended API key for trading functionality
- Brave API key for search capabilities (MCP server)

## Troubleshooting

### Code Generation Issues
If you encounter code generation errors:
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Dependency Issues
```bash
flutter clean
flutter pub get
```

### SDK Issues
```bash
flutter doctor
flutter upgrade
```