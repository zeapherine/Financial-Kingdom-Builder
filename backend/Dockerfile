# Shared Dockerfile for all Financial Kingdom Builder microservices
FROM node:18-alpine

# Accept build arguments
ARG SERVICE_NAME
ARG PORT=3000

# Set working directory
WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy root package.json and package-lock.json (contains all dependencies)
COPY package*.json ./

# Install all dependencies
RUN npm ci --only=production

# Copy shared utilities
COPY services/shared/ ./services/shared/

# Copy the specific service source code
COPY services/${SERVICE_NAME}/ ./services/${SERVICE_NAME}/

# Copy TypeScript configurations
COPY tsconfig.json ./
COPY .eslintrc.js ./

# Build the shared package first
RUN npm run build:shared

# Build the specific service
RUN npm run build -w @financial-kingdom/${SERVICE_NAME}

# Set environment variables
ENV PORT=${PORT}
ENV NODE_ENV=production

# Expose the service port
EXPOSE ${PORT}

# Health check (uses the PORT argument)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Start the specific service
CMD ["sh", "-c", "npm run start -w @financial-kingdom/${SERVICE_NAME}"]