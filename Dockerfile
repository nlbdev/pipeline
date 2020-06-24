FROM ubuntu:16.04 as builder
LABEL MAINTAINER Jostein Austvik Jacobsen <jostein@nlb.no> <http://www.nlb.no/>

WORKDIR /opt/

# Set locales
RUN apt-get clean && apt-get update && apt-get install -y locales && locale-gen en_GB en_GB.UTF-8
RUN echo 'LC_ALL="en_US.UTF-8"' > /etc/default/locale
ENV LANG C.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL C.UTF-8

# Install Java 8
RUN apt-get update && apt-get install -y openjdk-8-jdk

# Install other dependencies and various useful utilities
RUN apt-get update && apt-get install -y curl unzip vim

# Add source code and set working directory
ADD daisy-pipeline2 /opt/daisy-pipeline2/
WORKDIR /opt/daisy-pipeline2/

# Enable calabash debugging
RUN sed -i 's/\(com.xmlcalabash.*\)INFO/\1DEBUG/' /opt/daisy-pipeline2/etc/config-logback.xml

# Other configuration
ENV PIPELINE2_WS_LOCALFS=false \
    PIPELINE2_WS_AUTHENTICATION=false \
    PIPELINE2_WS_AUTHENTICATION_KEY=clientid \
    PIPELINE2_WS_AUTHENTICATION_SECRET=sekret
EXPOSE 8181

# for the healthcheck use PIPELINE2_HOST if defined. Otherwise use localhost
HEALTHCHECK --interval=30s --timeout=10s --start-period=1m CMD http_proxy="" https_proxy="" HTTP_PROXY="" HTTPS_PROXY="" curl --fail http://${PIPELINE2_WS_HOST-localhost}:${PIPELINE2_WS_PORT:-8181}/${PIPELINE2_WS_PATH:-ws}/alive || exit 1

ADD docker-entrypoint.sh /opt/daisy-pipeline2/docker-entrypoint.sh
ENTRYPOINT ["/opt/daisy-pipeline2/docker-entrypoint.sh"]
