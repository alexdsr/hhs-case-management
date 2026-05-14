# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Build the WAR with Maven
# ─────────────────────────────────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build
COPY pom.xml .
# Download dependencies first (layer-cached unless pom.xml changes)
RUN mvn dependency:go-offline -q

COPY src ./src
# Build WAR, skip tests (tests run in CI separately)
RUN mvn clean package -DskipTests -q

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Run on WildFly 31 (Jakarta EE 10 / Java 17)
# ─────────────────────────────────────────────────────────────────────────────
FROM quay.io/wildfly/wildfly:31.0.0.Final-jdk17

# Copy the built WAR into the deployments directory
COPY --from=build /build/target/hhs-case-management.war \
     /opt/jboss/wildfly/standalone/deployments/

# Copy datasource CLI script to /opt/jboss (jboss user home) so sed -i
# can write its temp file — /tmp denies rename for the jboss user
COPY --from=build /build/src/main/scripts/datasource.cli /opt/jboss/datasource.cli

USER root
RUN mkdir -p /opt/jboss/hhsdb && chown jboss:jboss /opt/jboss/hhsdb
USER jboss

# Rewrite the H2 path to the container path
RUN sed -i 's|~/hhsdb/hhsdb|/opt/jboss/hhsdb/hhsdb|g' /opt/jboss/datasource.cli

CMD ["/bin/bash", "-c", \
     "/opt/jboss/wildfly/bin/standalone.sh \
        -b 0.0.0.0 \
        -bmanagement 0.0.0.0 \
        -c standalone-full.xml \
        --read-only-server-config=false & \
      sleep 25 && \
      /opt/jboss/wildfly/bin/jboss-cli.sh \
        --connect \
        --file=/opt/jboss/datasource.cli && \
      wait"]
