FROM alpine:latest

ADD install_cloudeve.sh /opt/install_cloudeve.sh

RUN apk add --no-cache --virtual .build-deps ca-certificates curl \
 && chmod +x /opt/install_cloudeve.sh

ENTRYPOINT ["sh", "-c", "/opt/install_cloudeve.sh"]
