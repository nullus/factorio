FROM ubuntu:latest AS build
LABEL maintainer="Dylan Perry <dylan.perry@gmail.com>"

RUN apt-get update
RUN apt-get -y install curl
RUN apt-get -y install xz-utils

ENV FACTORIO_URL=https://www.factorio.com/get-download/0.15.40/headless/linux64

WORKDIR /
RUN curl -L -o - $FACTORIO_URL | tar -xJf -

COPY server-settings.json factorio/data/server-settings.json

# Generate map
RUN factorio/bin/x64/factorio --create factorio/bootstrap.zip

FROM scratch 

COPY --from=build /lib/x86_64-linux-gnu/libpthread.so.0 \
    /lib/x86_64-linux-gnu/librt.so.1 \
    /lib/x86_64-linux-gnu/libdl.so.2 \
    /lib/x86_64-linux-gnu/libm.so.6 \
    /lib/x86_64-linux-gnu/libgcc_s.so.1 \
    /lib/x86_64-linux-gnu/libc.so.6 \
    /lib/x86_64-linux-gnu/libresolv.so.2 \
    /lib/x86_64-linux-gnu/libnss*.so.2 \
    /lib/x86_64-linux-gnu/

COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

# Factorio
COPY --from=build /factorio /factorio/

EXPOSE 34197:34197/udp

CMD ["factorio/bin/x64/factorio", "--server-settings", "factorio/data/server-settings.json", "--start-server", "factorio/bootstrap.zip"]

