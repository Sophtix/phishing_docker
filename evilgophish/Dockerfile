FROM alpine AS clone

# Install git
RUN apk add --no-cache git

# Clone the latest gophish repository
RUN git clone https://github.com/kgretzky/gophish.git /tmp/gophish

FROM node:latest AS build-js

RUN npm install gulp gulp-cli -g

WORKDIR /build
COPY --from=clone /tmp/gophish  .
RUN npm install --only=dev
RUN gulp


# Build Golang binary
FROM golang:1.22 AS build-golang

WORKDIR /go/src/github.com/gophish/gophish
COPY --from=clone /tmp/gophish .
RUN go get -v 
RUN go build -v


# Runtime container
FROM debian:stable-slim

RUN useradd -m -d /opt/gophish -s /bin/bash app

RUN apt-get update && \
	apt-get install --no-install-recommends -y jq libcap2-bin ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/gophish
COPY --from=build-golang /go/src/github.com/gophish/gophish/ ./
COPY --from=build-js /build/static/js/dist/ ./static/js/dist/
COPY --from=build-js /build/static/css/dist/ ./static/css/dist/
COPY config.json ./
RUN chown -R app:app ./

RUN setcap 'cap_net_bind_service=+ep' /opt/gophish/gophish

USER app

ARG DB_USER
ARG DB_PASS
ARG DB_HOST

RUN sed -i "s|USER|$DB_USER|g" /opt/gophish/config.json
RUN sed -i "s|PASS|$DB_PASS|g" /opt/gophish/config.json
RUN sed -i "s|HOST|$DB_HOST|g" /opt/gophish/config.json

# Expose port (optional, adjust based on your needs)
EXPOSE 4444

# Run gophish (modify the command for specific flags)
CMD ["./gophish"]
