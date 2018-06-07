# Start from a Java image.
FROM openjdk:8-jdk

# Ignite version
ENV IGNITE_VERSION 2.4.0

# Ignite home
ENV IGNITE_HOME /opt/ignite/apache-ignite-fabric-${IGNITE_VERSION}-bin

# Do not rely on anything provided by base image(s), but be explicit, if they are installed already it is noop then
RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ignite

RUN curl https://dist.apache.org/repos/dist/release/ignite/${IGNITE_VERSION}/apache-ignite-fabric-${IGNITE_VERSION}-bin.zip -o ignite.zip \
    && unzip ignite.zip \
    && rm ignite.zip

# Copy sh files and set permission
COPY scripts/run.sh $IGNITE_HOME/

RUN chmod +x $IGNITE_HOME/run.sh

CMD $IGNITE_HOME/run.sh

EXPOSE 11211 47100 47500 49112

WORKDIR /workdir

COPY scripts/build-cp.sh /workdir/
COPY scripts/TestLoader.java /workdir/
COPY scripts/run-ignite.sh .
COPY scripts/server.xml /workdir/.

ENV SERVER_CONFIG /workdir/server.xml

RUN chmod +x build-cp.sh && \
    chmod +x run-ignite-mnist.sh && \
    MLCP=`bash build-cp.sh` && \
    javac -cp ${MLCP} TestLoader.java

CMD /bin/bash run-ignite-mnist.sh
