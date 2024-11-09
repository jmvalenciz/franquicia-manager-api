FROM maven:3.9.8-eclipse-temurin-21-alpine AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

ENV PORT=8080
ENV DB_HOST=127.0.0.1
ENV DB_PASSWORD=root
ENV DB_USER=root
ENV DB_DATABASE=franquicias-manager
ENV DB_PORT=5432

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "franquicias-manager-api.jar"]
