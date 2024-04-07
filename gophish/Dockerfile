FROM gophish/gophish:latest

WORKDIR /opt/gophish

USER root

COPY config.json /opt/gophish/config.json
RUN chown app:app ./config.json

USER app

ARG DB_USER
ARG DB_PASS
ARG DB_HOST

RUN sed -i "s|USER|$DB_USER|g" /opt/gophish/config.json
RUN sed -i "s|PASS|$DB_PASS|g" /opt/gophish/config.json
RUN sed -i "s|HOST|$DB_HOST|g" /opt/gophish/config.json
EXPOSE 3333

CMD ["/opt/gophish/gophish"]
