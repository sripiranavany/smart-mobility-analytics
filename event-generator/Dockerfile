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

# Copy source code for modules needed by event-generator
COPY common-lib/src common-lib/src
COPY event-generator/src event-generator/src

# Install Maven and build
RUN apk add --no-cache maven && \
    mvn clean package -pl event-generator -am -DskipTests -B

# Runtime stage
FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the built JAR from builder stage
COPY --from=builder /app/event-generator/target/*.jar app.jar

# Expose port (adjust as needed)
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8081/actuator/health || exit 1

# Set memory options
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]

