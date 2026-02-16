# Multi-stage Dockerfile for Flutter Web Application
# Stage 1: Build Flutter Web App
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ARG FLUTTER_VERSION=3.38.3
RUN git clone https://github.com/flutter/flutter.git /flutter --depth 1 --branch stable
ENV PATH="/flutter/bin:${PATH}"

# Verify Flutter installation
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY ridermate_app/pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY ridermate_app/ ./

# Build web app
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Production - Serve with Nginx
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
