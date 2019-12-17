#STAGE 1 - build artefact with dependencies
FROM azul/zulu-openjdk-alpine:13.0.1 as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN ./mvnw dependency:resolve -B

COPY src src


RUN ./mvnw install -DskipTests
RUN mkdir -p target && (cd target; jar -xf *.jar)


#STAGE 2: build resulted image
FROM azul/zulu-openjdk-alpine:13.0.1
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/target

#Dependency layer
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib

#Resource layer
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes/db /app/db
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes/application.properties /app

#Codebase layer
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes/com /app/com

ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.dockerdemo.DockerDemoApplication"]
EXPOSE 8080

