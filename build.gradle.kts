plugins {
    id("java")
    id("org.sonarqube") version "6.2.0.5505"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:6.1.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

sonar {
    properties {
        property("sonar.projectKey", "gradle")
        property("sonar.projectName", "gradle")
    }
}
