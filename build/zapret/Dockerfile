FROM alpine:3.18 AS builder
RUN apk add --no-cache bsd-compat-headers gcc git libcap-dev libnetfilter_queue-dev make musl-dev zlib-dev
RUN git clone "https://github.com/bol-van/zapret.git" /opt/zapret && cd /opt/zapret && git reset --hard 8b4b8c3fb0e960bba43c25826cb1b2bf6c6a3376 #v67
RUN make -C /opt/zapret/nfq nfqws

FROM alpine:3.18
RUN apk add --no-cache libnetfilter_queue
COPY --from=builder /opt/zapret/nfq/nfqws /opt/zapret/nfq/nfqws
RUN mkdir -p /opt/zapret/etc && echo --qnum=200 > /opt/zapret/etc/zapret.conf
CMD ["/opt/zapret/nfq/nfqws", "@/opt/zapret/etc/zapret.conf"]
