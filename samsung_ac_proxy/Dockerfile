FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    stunnel4 \
    socat \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh
COPY ac14k_m.pem /etc/ssl/ac14k_m.pem

CMD [ "/run.sh" ]
