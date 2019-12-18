JAVA_OPTS="-XX:+UnlockDiagnosticVMOptions \
           -XX:+PrintFlagsFinal \
           -XX:+UnlockExperimentalVMOptions \
           -XX:+UseShenandoahGC \
           -Xmx500M"


JAVA_OPTS="$JAVA_OPTS $SERVICE_JAVA_OPTS"

/bin/sh -c "java $JAVA_OPTS \
              -cp app:app/lib/* com.example.dockerdemo.DockerDemoApplication"
