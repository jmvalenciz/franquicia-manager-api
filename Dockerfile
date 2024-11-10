FROM openjdk:21-jdk-slim

WORKDIR /app

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

ENV PORT=8080
ENV DB_HOST=127.0.0.1
ENV DB_PASSWORD=root
ENV DB_USER=root
ENV DB_DATABASE=franquicias-manager
ENV DB_PORT=5432

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
