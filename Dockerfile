#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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


RUN curl https://archive.apache.org/dist/ignite/${IGNITE_VERSION}/apache-ignite-fabric-${IGNITE_VERSION}-bin.zip -o ignite.zip \
    && unzip ignite.zip \
    && rm ignite.zip

# Copy sh files and set permission
COPY run.sh $IGNITE_HOME/

RUN chmod +x $IGNITE_HOME/run.sh

EXPOSE 11211 47100 47500 49112 49505

WORKDIR /workdir

COPY build-cp.sh /workdir/
COPY TestCacheLoader.java /workdir/
COPY run-ignite.sh .
COPY server.xml /workdir/.

ENV SERVER_CONFIG /workdir/server.xml

RUN chmod +x build-cp.sh && \
    chmod +x run-ignite.sh && \
    MLCP=`bash build-cp.sh` && \
    javac -cp ${MLCP} TestCacheLoader.java

RUN mkdir /entries

COPY entries/entries.txt /entries

VOLUME /entries/

CMD /bin/bash run-ignite.sh
