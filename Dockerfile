FROM alpine:3.13 as builder

ARG COMMIT=7f4cc1a239d75f959c451f243d08ecb2598b0e26

RUN apk add --update alpine-sdk linux-headers \
  && git clone --quiet https://github.com/zerotier/ZeroTierOne.git /src \
  && git -C src reset --quiet --hard ${COMMIT} \
  && cd /src \
  && make -f make-linux.mk

FROM alpine:3.13
LABEL version="1.8.3"
LABEL description="ZeroTier One docker image for Synology NAS"

RUN apk add --update --no-cache libc6-compat libstdc++

EXPOSE 9993/udp

COPY --from=builder /src/zerotier-one /usr/sbin/
RUN mkdir -p /var/lib/zerotier-one \
  && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool \
  && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli

ENTRYPOINT ["zerotier-one"]
