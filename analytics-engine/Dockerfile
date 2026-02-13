# Build stage
FROM eclipse-temurin:25-jdk-alpine AS builder

WORKDIR /app

# Copy the parent pom
COPY pom.xml ./

# Copy all module poms (needed for Maven reactor)
COPY common-lib/pom.xml common-lib/
COPY event-generator/pom.xml event-generator/
COPY analytics-engine/pom.xml analytics-engine/
COPY api-gateway/pom.xml api-gateway/

# Copy source code for modules needed by analytics-engine
COPY common-lib/src common-lib/src
COPY analytics-engine/src analytics-engine/src

# Install Maven and build
RUN apk add --no-cache maven && \
    mvn clean package -pl analytics-engine -am -DskipTests -B

# Runtime stage
FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the built JAR from builder stage
COPY --from=builder /app/analytics-engine/target/*.jar app.jar

# Expose port (if needed for monitoring)
EXPOSE 8082

# Health check (adjust if you add health endpoint)
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD ps aux | grep -v grep | grep java || exit 1

# Set memory options for Beam pipeline
ENV JAVA_OPTS="-Xmx2g -Xms1g"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]

