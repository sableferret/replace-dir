FROM alpine:3.12

RUN apk add --no-cache git

COPY sanitycheck.sh /sanitycheck.sh

ENTRYPOINT ["/sanitycheck.sh"]