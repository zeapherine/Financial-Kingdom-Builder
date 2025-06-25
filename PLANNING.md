# PLANNING.md

## Project Overview
**Financial Kingdom Builder** - A gamified trading education app that combines kingdom building mechanics with progressive trading education, culminating in StarkNet perpetuals trading. This project follows a modular, test-driven development approach with strict file size limits and comprehensive documentation requirements.

### Product Vision
Transform complex financial education into an engaging, social, and rewarding experience that builds both knowledge and wealth over time. Target Gen-Z users with a responsible pathway to financial sophistication through proven gamification mechanics.

## Architecture

### Core Principles
- **Modular Design**: Code is organized into clearly separated modules grouped by feature or responsibility
- **File Size Limits**: Maximum 500 lines per file to maintain readability and maintainability
- **Test-Driven Development**: All features require comprehensive unit tests
- **Documentation-First**: Clear documentation and comments for all non-obvious code

### Project Structure
```
financial-kingdom-builder/
├── mobile/                 # Flutter mobile application
│   ├── lib/
│   │   ├── core/          # Core utilities and constants
│   │   ├── features/      # Feature-based modules
│   │   │   ├── kingdom/   # Kingdom building UI and logic
│   │   │   ├── education/ # Educational content and progress
│   │   │   ├── trading/   # Trading interface and logic
│   │   │   ├── social/    # Community and social features
│   │   │   └── auth/      # Authentication and security
│   │   ├── shared/        # Shared widgets and utilities
│   │   └── main.dart
│   └── test/              # Flutter tests
├── backend/               # Node.js/TypeScript microservices
│   ├── services/
│   │   ├── api-gateway/   # Request routing and rate limiting
│   │   ├── trading/       # Extended API integration
│   │   ├── gamification/  # XP, achievements, progression
│   │   ├── education/     # Learning content management
│   │   ├── social/        # Community features
│   │   └── notifications/ # Push notifications
│   └── shared/            # Shared utilities and types
├── smart-contracts/       # Cairo contracts for StarkNet
│   ├── achievements/      # NFT achievement contracts
│   ├── leaderboards/      # Ranking and competition contracts
│   ├── kingdom-state/     # User progression contracts
│   └── paymasters/        # Gas sponsorship contracts
├── docs/                  # Documentation files
├── CLAUDE.md             # AI assistant instructions
├── PLANNING.md           # This file - architecture and planning
├── PRD.md                # Product Requirements Document
└── TASK.md               # Task tracking and management
```

### Module Organization
- Group related functionality into coherent modules
- Use consistent naming conventions across modules
- Prefer relative imports within packages
- Maintain clear separation of concerns

## Goals

### Primary Objectives
1. **User Safety**: Graduated complexity prevents overleverage and financial losses
2. **Educational Effectiveness**: 80% module completion rate through gamification
3. **Engagement**: 65% 30-day retention vs 40% industry average
4. **Scalability**: Architecture supports 100,000+ concurrent users
5. **Maintainability**: Code should be easy to understand and modify
6. **Reliability**: Comprehensive testing ensures system stability
7. **Documentation**: All code is well-documented and self-explaining

### Quality Standards
- **Code Coverage**: All new features must include unit tests
- **Performance**: Mobile app launch under 3 seconds, API responses under 100ms
- **Security**: SOC 2 Type II compliance, end-to-end encryption
- **Documentation**: Every function requires clear documentation
- **Type Safety**: Use type annotations (Flutter/Dart, TypeScript)
- **Code Style**: Consistent formatting and conventions
- **Accessibility**: WCAG 2.1 AA compliance for inclusive design

## Technology Stack & Style Guide

### Mobile Development (Flutter/Dart)
- **Framework**: Flutter 3.16+ with Dart SDK
- **State Management**: Riverpod 2.x for dependency injection
- **Architecture**: Feature-based modular architecture
- **Naming Conventions**: 
  - Variables: camelCase (e.g., `kingdomLevel`, `tradingBalance`)
  - Functions: camelCase verbs (e.g., `calculateXP`, `unlockTerritory`)
  - Classes: PascalCase (e.g., `KingdomBuilder`, `TradingService`)
  - Files: snake_case (e.g., `kingdom_screen.dart`, `trading_service.dart`)

### Backend Development (Node.js/TypeScript)
- **Runtime**: Node.js with TypeScript
- **Architecture**: Microservices with API Gateway
- **Database**: PostgreSQL + TimescaleDB + Redis + MongoDB
- **Naming Conventions**:
  - Variables: camelCase
  - Functions: camelCase
  - Classes: PascalCase
  - Files: kebab-case (e.g., `trading-service.ts`, `gamification-controller.ts`)

### Smart Contracts (Cairo)
- **Language**: Cairo 1.0+ for StarkNet
- **Contracts**: Achievement NFTs, leaderboards, kingdom state
- **Naming Conventions**: snake_case following Cairo conventions

### Code Standards
- **Formatting**: Use project's configured formatter (dartfmt, prettier)
- **Comments**: Explain the "why" not just the "what"
- **Documentation**: Function-level documentation for all public APIs
- **Error Handling**: Comprehensive error handling with user-friendly messages

### File Organization
- **Maximum 500 lines per file** - refactor when approaching this limit
- **Logical grouping** by feature or responsibility
- **Clear imports** section at the top of each file
- **Consistent export patterns**

## Constraints

### Technical Constraints
- **File Size**: Hard limit of 500 lines per file
- **Performance**: App launch <3s, trading execution <500ms, 60 FPS animations
- **Memory**: Mobile app stays under 150MB RAM during active trading
- **Testing**: Every feature requires unit tests (expected use, edge case, failure case)
- **Documentation**: All functions must be documented
- **Dependencies**: Only use verified packages from project dependencies
- **Security**: All API keys in environment variables, no hardcoded secrets
- **Compliance**: GDPR, SOC 2 Type II, PCI DSS where applicable

### Development Constraints
- **No Hallucination**: Never assume libraries or functions exist without verification
- **Explicit Confirmation**: Always verify file paths and module names
- **Preservation**: Never delete existing code without explicit instruction
- **Task Tracking**: All work must be tracked in TASK.md
- **User Safety First**: All trading features must include risk management
- **Progressive Disclosure**: Complex features unlocked through education completion
- **Gamification Ethics**: Encourage learning and safe trading, not addictive behavior

### External Integration Constraints
- **Extended API**: Comply with rate limits and authentication requirements
- **StarkNet**: Handle blockchain transaction delays and gas optimization
- **Market Data**: Implement circuit breakers for high-volatility periods
- **Environment Variables**: All API keys must use environment variables
- **No Hardcoding**: Never hardcode sensitive information
- **MCP Servers**: Always verify MCP server availability before use

## Development Workflow

### Starting New Work
1. Read this PLANNING.md file and PRD.md for context
2. Check TASK.md for existing tasks
3. Add new tasks to TASK.md with date
4. Follow established patterns and conventions
5. Consider user safety and educational impact for trading features

### Feature Development Phases
**Phase 1: Foundation (Months 1-3)**
- Core kingdom interface development
- Basic educational content creation
- Paper trading system implementation
- Social features framework

**Phase 2: Real Trading (Months 4-6)**
- Real money integration with graduated limits
- Advanced educational modules
- Risk management systems
- Community platform launch

**Phase 3: Advanced Features (Months 7-9)**
- Options trading capabilities
- Margin functionality
- Advanced analytics and tools
- Creator partnership program

**Phase 4: Perpetuals Launch (Months 10-12)**
- StarkNet perpetuals integration
- Advanced derivatives education
- Full feature ecosystem
- Global market expansion

### Educational Tier Implementation
**Tier 1: Village Foundations (Days 1-30)**
- Virtual trading only (100% paper trading)
- Basic financial literacy modules
- Kingdom building mechanics introduction
- Success: 5+ virtual trades, 3+ education modules, 7-day streak

**Tier 2: Town Development (Days 31-90)**
- Limited real money trading unlocked
- Risk management education
- Technical analysis introduction
- Success: 10+ real trades, stop-loss usage, maintain 90%+ capital

**Tier 3: City Expansion (Days 91-180)**
- Options education and trading
- Advanced charting tools
- Graduated margin trading
- Success: Options quiz completion, portfolio diversification

**Tier 4: Kingdom Mastery (Days 181+)**
- Perpetuals trading access
- Full platform features
- Social trading and mentorship
- Advanced derivatives strategies

### Completing Work
1. Create comprehensive unit tests
2. Update existing tests if needed
3. Update documentation (README.md, function docs)
4. Verify educational progression requirements
5. Test risk management features
6. Mark tasks complete in TASK.md
7. Add any discovered sub-tasks to TASK.md

### Code Review Checklist
- [ ] File under 500 lines
- [ ] Unit tests created/updated (expected use, edge case, failure case)
- [ ] Documentation updated
- [ ] Follows naming conventions
- [ ] No hardcoded secrets or API keys
- [ ] Type annotations present
- [ ] Comments explain complex logic
- [ ] Performance requirements met
- [ ] Security best practices followed
- [ ] Accessibility considerations addressed
- [ ] Error handling comprehensive
- [ ] Risk management for trading features
- [ ] Gamification promotes learning, not addiction