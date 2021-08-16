# syntax=docker/dockerfile:1.2
# Distroless TAG '11' , '11-debug' , '11-nonroot'
ARG DIST_TAG=11

FROM openjdk:11-jre-slim as builder
WORKDIR application
ARG JAR_FILE=/build/libs/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM gcr.io/distroless/java:$DIST_TAG AS production-env
VOLUME /tmp
WORKDIR application

EXPOSE 8080
EXPOSE 8081
EXPOSE 8787

# userId 65532
USER nonroot

COPY --chown=nonroot:nonroot --from=builder application/dependencies/ ./
COPY --chown=nonroot:nonroot --from=builder application/spring-boot-loader/ ./
COPY --chown=nonroot:nonroot --from=builder application/snapshot-dependencies/ ./
COPY --chown=nonroot:nonroot --from=builder application/application/ ./

# Default ENV.
ENV JAVA_TOOL_OPTIONS='-Xms64m -Xmx512m -XX:MaxRAMPercentage=90 \
 -XX:MaxDirectMemorySize=10M -XX:MaxMetaspaceSize=96435K \
 -XX:ReservedCodeCacheSize=240M -Xss1M \
 -Djava.security.egd=file:/dev/./urandom \
 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8787'

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]