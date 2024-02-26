FROM amazoncorretto:21-alpine-jdk

WORKDIR /app

COPY target/spring-test-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8080 80

CMD ["java", "-jar", "app.jar"]