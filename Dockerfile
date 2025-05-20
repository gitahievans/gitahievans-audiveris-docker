# Stage 1: Build Audiveris
FROM openjdk:21-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y git gradle wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone and build Audiveris
WORKDIR /app
RUN git clone https://github.com/Audiveris/audiveris.git && \
    cd audiveris && \
    git checkout tags/5.6.1 && \
    ./gradlew clean distZip -x test

# Verify the ZIP exists and unzip it, flattening the structure
RUN ls -l audiveris/app/build/distributions/ && \
    unzip -j audiveris/app/build/distributions/app-5.6.1.zip -d /app/Audiveris && \
    rm audiveris/app/build/distributions/app-5.6.1.zip

# Stage 2: Final image
FROM openjdk:21-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    locales \
    fontconfig \
    fonts-dejavu \
    libfreetype6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Copy Audiveris from builder stage
COPY --from=builder /app/Audiveris /app

# Ensure JARs are readable
RUN chmod -R 644 /app/*.jar

# Create input and output directories
RUN mkdir -p /input /output

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set working directory
WORKDIR /app

ENTRYPOINT [ "/app/entrypoint.sh" ]