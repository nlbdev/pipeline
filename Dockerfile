FROM openjdk:8

MAINTAINER Jostein Austvik Jacobsen

WORKDIR /root

# Install dependencies
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
RUN apt-get update && apt-get install -y git build-essential maven gradle libxml2-utils pcregrep rsync
RUN apt-get update && apt-get install -y golang vim zip

# Build and install Pipeline 2
ADD . /root/pipeline/
RUN cd ~/pipeline && mkdir -p .maven-cache
RUN cd ~/pipeline && make dist-zip || cd ~/pipeline && make dist-zip
RUN unzip pipeline/pipeline2-*_linux.zip
RUN rm ~/pipeline -rf

ENTRYPOINT /root/daisy-pipeline/cli/dp2
