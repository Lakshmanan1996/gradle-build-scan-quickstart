# =========================
# Gradle Build
# =========================
FROM gradle:8.7-jdk21 AS build

WORKDIR /app

# Copy Gradle wrapper + project files first (better caching)
COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

# Copy source code
COPY src src

# Make gradlew executable
RUN chmod +x gradlew

# Build the jar (skip tests optional)
RUN ./gradlew clean bootJar -x test


# =========================
# Stage 2: Runtime stage
# =========================
FROM eclipse-temurin:21-jdk

WORKDIR /app

# Copy only the generated jar
COPY --from=build /app/build/libs/*.jar app.jar

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
