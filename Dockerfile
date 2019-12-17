# STAGE 1: prepare custom JRE
FROM azul/zulu-openjdk-alpine:13.0.1 as packager

RUN { \
       java --version ; \
       echo "jlink version:" && \
       jlink --version ; \
   }

ENV JAVA_MINIMAL=/opt/jre

# build modules distribution
RUN jlink \
   --verbose \
   --add-modules \
       java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
       # java.naming - javax/naming/NamingException
       # java.desktop - java/beans/PropertyEditorSupport
       # java.management - javax/management/MBeanServer
       # java.security.jgss - org/ietf/jgss/GSSException
       # java.instrument - java/lang/instrument/IllegalClassFormatException
   --compress 2 \
#    --strip-debug \
   --no-header-files \
   --no-man-pages \
   --output "$JAVA_MINIMAL"


#STAGE 2 - build artefact with dependencies
FROM azul/zulu-openjdk-alpine:13.0.1 as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN ./mvnw -e -B dependency:resolve

COPY src src


RUN ./mvnw install -DskipTests

#RUN mkdir -p target \
#    && (cd target; jar -xf *.jar)
WORKDIR /workspace/app/target

RUN jar -xf ./docker-demo*.jar

#STAGE 3: build resulted image (baseimage with custom JRE could be moved into separate project)
FROM alpine:3.10.3

LABEL maintainer="nolik03@gmail.com"

USER guest

ARG PATH="$PATH:$JAVA_MINIMAL/bin"

COPY --from=packager "$JAVA_MINIMAL" "$JAVA_MINIMAL"

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

CMD ["java","-cp","app:app/lib/*","com.example.dockerdemo.DockerDemoApplication"]
EXPOSE 8080
