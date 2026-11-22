# ========================================================
# Production Multi-Stage Dockerfile for AWS (ECS / App Runner)
# ========================================================

# Stage 1: Build TypeScript source
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package*.json tsconfig.json ./

# Install all dependencies (including devDependencies)
RUN npm ci --legacy-peer-deps --cache /tmp/npm-cache

# Copy source code
COPY src/ ./src/

# Compile TypeScript to JavaScript
RUN npm run build

# Stage 2: Production runtime
FROM node:22-alpine AS runner

WORKDIR /app

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Copy manifests and install production-only dependencies
COPY package*.json ./
RUN npm ci --only=production --legacy-peer-deps --cache /tmp/npm-cache && \
    rm -rf /tmp/npm-cache

# Copy compiled JavaScript output from builder stage
COPY --from=builder /app/dist ./dist

# Use non-root node user for security compliance
USER node

EXPOSE 3000

# Start server
CMD ["node", "dist/server.js"]
