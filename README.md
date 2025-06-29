# Financial Kingdom Builder

A gamified trading education platform that combines kingdom-building mechanics with progressive financial and trading education. Users grow their own virtual financial kingdom, unlocking new features and advanced trading capabilities as they master educational modules and trading skills.

---

## Project Structure

```
financial-kingdom-builder/
├── mobile/                 # Flutter mobile application
│   ├── lib/
│   │   ├── core/          # Core utilities and constants
│   │   ├── features/      # Feature-based modules (kingdom, education, trading, social, auth)
│   │   ├── shared/        # Shared widgets and utilities
│   │   └── main.dart
│   └── test/              # Flutter tests
├── backend/               # Node.js/TypeScript microservices (API, gamification, education, etc.)
├── smart-contracts/       # Cairo contracts for StarkNet (NFTs, leaderboards, kingdom state, paymasters)
├── docs/                  # Documentation files
├── CLAUDE.md              # AI assistant instructions
├── PLANNING.md            # Architecture and planning
├── PRD.md                 # Product Requirements Document
└── TASK.md                # Task tracking and management
```

---

## Key Features

- **Kingdom Metaphor**: Visualize financial growth as a kingdom, expanding with each educational and trading milestone.
- **Progressive Education**: Tiered learning system, from basic financial literacy to advanced perpetuals trading.
- **Interactive Learning**: 6 comprehensive educational modules with animations, quizzes, and visual aids.
- **Gamification**: XP, achievements, streaks, and leaderboards to drive engagement and retention.
- **Multi-Language Support**: Localized content in English, Spanish, and French.
- **Smart Contracts**: StarkNet Cairo contracts for NFTs, leaderboards, and kingdom state.
- **Microservices Backend**: Node.js/TypeScript services for trading, gamification, education, and social features.

---

## Current Status

### ✅ Completed Features

**Infrastructure & Core Systems:**
- Flutter project with modular architecture
- Riverpod state management
- Go Router navigation system
- Duolingo-inspired design system
- Multi-language localization (EN/ES/FR)

**Kingdom Building Interface:**
- Interactive kingdom screen with building progression
- 6 building types with tier-based visual evolution
- Building unlock system based on educational progress
- Resource management system with pie charts
- XP and achievement tracking

**Educational System:**
- 6 comprehensive educational modules:
  - Financial Literacy Basics
  - Cryptocurrency Basics
  - Risk Management
  - Trading Terminology
  - Building Permits & Regulations
  - Portfolio Management
- Interactive widgets and visualizations
- Progress tracking and XP rewards
- Service layer for API integration
- Error handling and offline support

**Navigation & Integration:**
- Functional navigation between all kingdom buildings
- Library → Education system fully integrated
- Treasury → Resource management accessible
- Placeholder screens for future features

### 🚧 In Progress

- Educational Progress UI enhancements
- Paper trading system implementation
- Backend API integration

### 📋 Next Up

- Real money trading integration
- Social features implementation
- Advanced analytics and insights

---

## Getting Started

### Prerequisites

- **Flutter SDK 3.16+** ([Install Guide](https://flutter.dev/docs/get-started/install))
- **Node.js** (for backend and MCP servers)
- **Cairo & Scarb** (for smart contracts)
- **StarkNet Foundry** (for contract testing)

### Mobile App Setup

```sh
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

- Configure environment variables in `.env`, `.env.dev`, `.env.staging`, `.env.prod` (see `SETUP.md` for details).

### Smart Contracts

```sh
cd smart-contracts/financial_kingdom_contracts
scarb build
snforge test
```

### Backend

- See `backend/` for microservices setup (Node.js/TypeScript, Docker recommended).

---

## Development Workflow

- **Code Generation**: Run `dart run build_runner build` after editing Riverpod providers.
- **Testing**: `flutter test` for mobile, `snforge test` for contracts.
- **Build**: `flutter build apk` or `flutter build ios` for mobile.
- **Task Tracking**: All work is tracked in `TASK.md` and follows the workflow in `CLAUDE.md`.

---

## Documentation

- **Product Requirements**: See `PRD.md`
- **Architecture & Planning**: See `PLANNING.md`
- **Setup Guide**: See `SETUP.md`
- **AI Assistant Protocols**: See `CLAUDE.md`

---

## Contributing

1. Read `CLAUDE.md` and `PLANNING.md` before starting.
2. Check `TASK.md` for active and pending tasks.
3. Follow the modular, test-driven, and documentation-first approach.
4. Open issues or pull requests for improvements.

---

## License

This project is licensed under the MIT License.

---

## Acknowledgements

- Inspired by the success of gamified learning (Duolingo) and kingdom-building games.
- Built with Flutter, StarkNet, Cairo, and Node.js. 