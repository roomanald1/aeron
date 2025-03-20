FROM openjdk:21

# Copy the necessary JARs
COPY *.jar .

EXPOSE 40123

# Add necessary JVM options to allow internal API access if required
ENTRYPOINT ["java", "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-cp", "aeron-all-1.47.5-SNAPSHOT.jar", "io.aeron.driver.MediaDriver"]
 