#добавить Dockerfile
FROM openjdk:20
WORKDIR /app

COPY target/*.jar jira-1.0.jar
COPY resources ./resources

ENTRYPOINT ["java", "-jar", "/app/jira-1.0.jar"]


