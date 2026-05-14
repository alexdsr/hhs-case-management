# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Build the WAR with Maven
# ─────────────────────────────────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn clean package -DskipTests -q

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Run on WildFly 31 (Jakarta EE 10 / Java 17)
# ─────────────────────────────────────────────────────────────────────────────
FROM quay.io/wildfly/wildfly:31.0.0.Final-jdk17

COPY --from=build /build/target/hhs-case-management.war \
     /opt/jboss/wildfly/standalone/deployments/

COPY --from=build /build/src/main/scripts/datasource.cli /opt/jboss/datasource.cli

# Run all setup as root — sed -i needs write access to /opt/jboss/
USER root
RUN mkdir -p /opt/jboss/hhsdb && \
    sed -i 's|~/hhsdb/hhsdb|/opt/jboss/hhsdb/hhsdb|g' /opt/jboss/datasource.cli && \
    chown -R jboss:jboss /opt/jboss/hhsdb /opt/jboss/datasource.cli

USER jboss

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
