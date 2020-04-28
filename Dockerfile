FROM alpine AS builder

ENV NSCA_NG_VERSION=1.6

RUN apk --no-cache add build-base
RUN apk --no-cache add confuse-dev
RUN apk --no-cache add libev-dev
RUN apk --no-cache add openssl-dev
RUN wget https://github.com/weiss/nsca-ng/releases/download/v${NSCA_NG_VERSION}/nsca-ng-${NSCA_NG_VERSION}.tar.gz
RUN tar -xzf *.tar.gz

WORKDIR /nsca-ng-${NSCA_NG_VERSION}

RUN ./configure --enable-server
RUN make
RUN make install

FROM alpine

RUN apk --no-cache add confuse
RUN apk --no-cache add libev
RUN apk --no-cache add openssl
RUN apk --no-cache add su-exec

COPY --from=builder /usr/local/sbin /usr/local/sbin
COPY --from=builder /usr/local/etc /usr/local/etc
COPY --from=builder /usr/local/share/man /usr/local/share/man

CMD ["su-exec", "nobody", "/usr/local/sbin/send_nsca"]
