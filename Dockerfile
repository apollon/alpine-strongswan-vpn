#
# StrongSwan VPN + Alpine Linux
#

FROM alpine:latest

ENV STRONGSWAN_RELEASE https://download.strongswan.org/strongswan.tar.bz2

RUN apk --update add --no-cache \
        ip6tables \
        iptables-dev \
        iproute2 \
        ca-certificates \
        curl \
        openssl && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        curl-dev \
        openssl-dev && \
    mkdir -p /tmp/strongswan && \
    curl -Lo /tmp/strongswan.tar.bz2 $STRONGSWAN_RELEASE && \
    tar --strip-components=1 -C /tmp/strongswan -xjf /tmp/strongswan.tar.bz2 && \
    cd /tmp/strongswan && \
    ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib \
            --with-ipsecdir=/usr/lib/strongswan \
#           for OpenVZ VPS hosting
#            --enable-kernel-libipsec \
            --enable-aesni \
            --enable-chapoly \
            --enable-cmd \
            --enable-curl \
            --enable-dhcp \
            --enable-eap-dynamic \
            --enable-eap-identity \
            --enable-eap-md5 \
            --enable-eap-mschapv2 \
            --enable-eap-radius \
            --enable-eap-tls \
            --enable-farp \
            --enable-files \
            --enable-gcm \
            --enable-md4 \
            --enable-newhope \
            --enable-ntru \
            --enable-openssl \
            --enable-sha3 \
            --enable-shared \
            --disable-aes \
            --disable-des \
            --disable-gmp \
            --disable-hmac \
            --disable-ikev1 \
            --disable-md5 \
            --disable-rc2 \
            --disable-sha1 \
            --disable-sha2 \
            --disable-static && \
    make && \
    make install && \
    rm -rf /tmp/* && \
    apk del .build-deps

# ENV TZ=Asia/Shanghai
#   && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Change local zonetime(BeiJing)
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

EXPOSE 500/udp \
       4500/udp

ENTRYPOINT ["/usr/sbin/ipsec"]
CMD ["start", "--nofork"]
