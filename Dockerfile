FROM ubuntu:18.04 as builder
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
RUN apt-get update && apt-get install -y build-essential apt-utils pkg-config patch make curl unzip vim emacs git pcregrep
RUN apt-get update && apt-get install -y libxml2 libxml2-dev libxml2-utils libxslt1-dev zlib1g-dev liblzma-dev
RUN apt-get update && apt-get install -y maven autoconf automake libtool make
RUN apt-get update && apt-get install -y ruby-full ruby-dev rubygems-integration
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
RUN gem install bundler
RUN gem install nokogiri:1.5.6
RUN gem install commaparty:0.0.2

# Add nlbdev/pipeline
ADD . /opt/pipeline
WORKDIR /opt/pipeline

# build until first error in case of build errors (easier to debug)
RUN make dist-zip-linux || true

# build for linux and minimal
RUN make dist-zip-linux
RUN make dist-zip-minimal

# test NLB and Nordic modules
RUN make RUBY=ruby check-modules/nlb
RUN make RUBY=ruby check-modules/nordic

RUN unzip pipeline2-*_linux.zip -d /opt/pipeline2-linux
RUN unzip pipeline2-*_minimal.zip -d /opt/pipeline2-minimal

# ----------------------------------------

FROM openjdk:8-jre
LABEL MAINTAINER Jostein Austvik Jacobsen <jostein@nlb.no> <http://www.nlb.no/>

COPY --from=builder /opt/pipeline2-linux/daisy-pipeline/ /opt/daisy-pipeline2/
EXPOSE 8181
ENTRYPOINT ["/opt/daisy-pipeline2/bin/pipeline2"]
