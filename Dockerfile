FROM ubuntu:latest
MAINTAINER Dylan Perry <dylan.perry@gmail.com>

RUN apt-get update
RUN apt-get -y install curl
RUN apt-get -y install xz-utils

ENV FACTORIO_URL=https://www.factorio.com/get-download/0.15.40/headless/linux64

WORKDIR /opt

RUN curl -L -o - $FACTORIO_URL | tar -xJf -

WORKDIR /opt/factorio

COPY server-settings.json data/server-settings.json

# Generate map
RUN bin/x64/factorio --create bootstrap.zip

EXPOSE 34197:34197/udp

CMD ["bin/x64/factorio", "--server-settings", "data/server-settings.json", "--start-server", "bootstrap.zip"]

