FROM alpine:3.24

# tor, lyrebird and obfs4proxy come from Alpine edge (webtunnel needs a recent lyrebird)
RUN echo '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    echo '@edge https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk -U upgrade && \
    apk -v add tor@edge obfs4proxy@edge lyrebird@edge curl && \
    chmod 700 /var/lib/tor && \
    rm -rf /var/cache/apk/*

# No torrc in the image: the config (with bridges) is mounted at /etc/tor/torrc
USER tor
EXPOSE 8853/udp 9150/tcp

CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
