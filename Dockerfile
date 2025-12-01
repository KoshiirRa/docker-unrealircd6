ARG PKG="build-essential pkg-config gdb libssl-dev libpcre2-dev libargon2-dev libsodium-dev libc-ares-dev libcurl4-openssl-dev"
ARG VER="latest"
ARG UID=10000

FROM alpine:3.22.2
ARG PKG
ARG VER
ARG UID

COPY ./config.settings /tmp/config.settings

WORKDIR /usr/src/ircd
RUN set -x \
    && apk add --no-cache --virtual build ${PKG} && apk add --no-cache libcurl \
    && wget -O /tmp/unrealircd https://www.unrealircd.org/downloads/unrealircd-${VER}.tar.gz \
    && tar xvfz /tmp/unrealircd \
    && cd ./unrealircd-${VER}/ \
    && cp /tmp/config.settings /usr/src/ircd/unrealircd-${VER}/config.settings \
    && ./Config -quick \
    && make -j$(nproc) && make install \
    && rm -rf /usr/src/ircd \
    && apk del build \
    && addgroup -S unreal && adduser -u ${UID} -S unreal -G unreal

WORKDIR /ircd
RUN set -x \
    && chown -R unreal:unreal /ircd /app
USER unreal
CMD ["/bin/sh" ]
