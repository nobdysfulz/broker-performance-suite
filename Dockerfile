# Multi-stage build for React + Node.js
FROM node:18-alpine AS base

# Install system dependencies needed for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat \
    && rm -rf /var/cache/apk/*

# Set npm configuration for better reliability
RUN npm config set registry https://registry.npmjs.org/
RUN npm config set fetch-retry-maxtimeout 600000
RUN npm config set fetch-retry-mintimeout 10000
RUN npm config set fetch-retries 5

# Stage 1: Build React App
FROM base AS client-build
WORKDIR /app/client

# Copy package files
COPY client/package*.json ./

# Install dependencies with fallback strategy
RUN npm install --production --no-audit --no-fund || \
    (npm cache clean --force && npm install --production --no-audit --no-fund)

# Copy source code and build
COPY client/ .
RUN npm run build

# Stage 2: Build Node.js App
FROM base AS server-build
WORKDIR /app/server

# Copy package files
COPY server/package*.json ./

# Install dependencies with fallback strategy
RUN npm install --production --no-audit --no-fund || \
    (npm cache clean --force && npm install --production --no-audit --no-fund)

# Copy server source
COPY server/ .

# Stage 3: Production
FROM node:18-alpine AS production
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy built application
COPY --from=client-build --chown=nodejs:nodejs /app/client/build ./client/build
COPY --from=server-build --chown=nodejs:nodejs /app/server ./server

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node server/healthcheck.js || exit 1

# Start application
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server/index.js"]
