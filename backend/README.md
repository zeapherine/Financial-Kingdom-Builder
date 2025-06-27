# Financial Kingdom Builder - Backend Services

This directory contains the backend microservices architecture for the Financial Kingdom Builder application.

## Services Overview

### API Gateway (Port 3000)
- **Purpose**: Request routing, authentication, rate limiting
- **Routes**: Proxies requests to appropriate microservices
- **Features**: JWT authentication, CORS, security headers, health checks

### Trading Service (Port 3001)
- **Purpose**: Portfolio management, order execution, market data
- **Routes**: `/portfolio`, `/orders`, `/market-data`
- **Features**: Paper trading, real trading integration, risk management

### Gamification Service (Port 3002)
- **Purpose**: XP tracking, achievements, leaderboards
- **Routes**: `/xp`, `/achievements`, `/leaderboard`
- **Features**: Level progression, badge system, kingdom tier management

### Education Service (Port 3003)
- **Purpose**: Educational content management and progress tracking
- **Routes**: `/modules`, `/progress`
- **Features**: Module completion, quiz management, tier progression

### Social Service (Port 3004)
- **Purpose**: User profiles, messaging, friend system
- **Routes**: `/profiles`, `/messages`, `/friends`
- **Features**: Social interactions, kingdom showcases, community features

### Notification Service (Port 3005)
- **Purpose**: Push notifications, user preferences
- **Routes**: `/push`, `/preferences`
- **Features**: Device registration, notification history, preference management

## Architecture

### Microservices Pattern
- Each service is independently deployable
- Services communicate via HTTP/REST APIs
- API Gateway handles cross-cutting concerns
- Shared utilities and types in `/shared` directory

### Technology Stack
- **Runtime**: Node.js 18+ with TypeScript
- **Framework**: Express.js with security middleware
- **Logging**: Winston with structured logging
- **Validation**: Express-validator for input validation
- **Containerization**: Docker with multi-stage builds

## Development Setup

### Prerequisites
- Node.js 18+
- Docker and Docker Compose
- Git

### Installation

1. **Install dependencies for each service**:
```bash
# Install API Gateway dependencies
cd services/api-gateway && npm install

# Install other services
cd ../trading && npm install
cd ../gamification && npm install
cd ../education && npm install
cd ../social && npm install
cd ../notifications && npm install

# Install shared utilities
cd ../shared && npm install
```

2. **Environment Configuration**:
   - Copy `.env.example` to `.env` in each service directory
   - Update environment variables as needed
   - **Never commit actual API keys or secrets**

3. **Build and Start Services**:
```bash
# Start all services with Docker Compose
docker-compose up --build

# Or start individual services for development
cd services/api-gateway && npm run dev
cd services/trading && npm run dev
# etc.
```

### Development Commands

```bash
# Start all services
docker-compose up

# Start with rebuild
docker-compose up --build

# Start specific service
docker-compose up api-gateway

# View logs
docker-compose logs -f [service-name]

# Stop all services
docker-compose down

# Development mode (individual service)
cd services/[service-name]
npm run dev
```

## API Documentation

### Authentication
All protected routes require JWT authentication via:
- `Authorization: Bearer <token>` header, or
- `x-api-key: <token>` header

### Health Checks
Each service provides health check endpoints:
- `GET /health` - Service health status
- API Gateway also provides: `GET /health/ready`, `GET /health/live`

### Error Handling
Standardized error responses:
```json
{
  "error": "Error Type",
  "message": "Human readable message",
  "timestamp": "2023-12-01T12:00:00.000Z",
  "path": "/api/endpoint",
  "statusCode": 400
}
```

## Security

### Authentication & Authorization
- JWT tokens with configurable expiration
- User tier-based access control
- API key validation for service-to-service communication

### Security Middleware
- Helmet for security headers
- CORS configuration
- Rate limiting per service
- Input validation on all endpoints
- Request/response logging

### Environment Variables
```bash
# Required for all services
NODE_ENV=development|staging|production
PORT=service_port

# API Gateway specific
JWT_SECRET=your-secret-key
CORS_ORIGIN=allowed-origins
RATE_LIMIT_MAX_REQUESTS=100

# Service URLs for API Gateway
TRADING_SERVICE_URL=http://localhost:3001
GAMIFICATION_SERVICE_URL=http://localhost:3002
# etc.
```

## Monitoring & Logging

### Health Monitoring
- Health check endpoints for each service
- Docker health checks with automatic restarts
- Service dependency checking

### Logging
- Structured JSON logging with Winston
- Configurable log levels (debug, info, warn, error)
- Request/response logging
- Error tracking with stack traces

### Metrics
Health check responses include:
- Service uptime
- Memory usage
- Dependency status
- Response times

## Deployment

### Docker Deployment
```bash
# Production build
docker-compose -f docker-compose.prod.yml up --build

# Scale specific services
docker-compose up --scale trading-service=3
```

### Environment Configuration
- Development: `docker-compose.yml`
- Staging: `docker-compose.staging.yml`
- Production: `docker-compose.prod.yml`

## Testing

```bash
# Run tests for specific service
cd services/[service-name]
npm test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

## Contributing

1. Follow TypeScript strict mode
2. Include comprehensive error handling
3. Add unit tests for new features
4. Update API documentation
5. Follow established patterns and conventions
6. Never commit sensitive data or API keys

## Service Communication

Services communicate through the API Gateway, which:
- Routes requests to appropriate services
- Handles authentication and authorization
- Applies rate limiting and security policies
- Provides centralized logging and monitoring

## Shared Utilities

The `/shared` directory contains:
- **Types**: Common TypeScript interfaces and types
- **Validation**: Reusable validation rules
- **Constants**: Application-wide constants
- **Utilities**: Common helper functions

These can be imported by services using:
```typescript
import { User, ApiResponse } from '@shared/types';
import { userIdValidation } from '@shared/utils/validation';
```