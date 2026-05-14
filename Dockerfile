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

# Copy the H2 datasource CLI script
COPY --from=build /build/src/main/scripts/datasource.cli /tmp/datasource.cli

# Switch to root to set up the datasource, then drop back to jboss
USER root

# Create directory for the H2 database file
RUN mkdir -p /opt/jboss/hhsdb && chown jboss:jboss /opt/jboss/hhsdb

USER jboss

# Update the datasource connection URL to use the container path
# (~/hhsdb_j8 resolves to /opt/jboss/hhsdb in the container)
RUN sed -i 's|~/hhsdb/hhsdb|/opt/jboss/hhsdb/hhsdb|g' /tmp/datasource.cli

# Start WildFly, run the CLI script to register the datasource, then leave running
# Using standalone-full.xml for EJB + JMS support
CMD ["/bin/bash", "-c", \
     "/opt/jboss/wildfly/bin/standalone.sh \
        -b 0.0.0.0 \
        -bmanagement 0.0.0.0 \
        -c standalone-full.xml \
        --read-only-server-config=false & \
      sleep 20 && \
      /opt/jboss/wildfly/bin/jboss-cli.sh \
        --connect \
        --file=/tmp/datasource.cli && \
      wait"]
