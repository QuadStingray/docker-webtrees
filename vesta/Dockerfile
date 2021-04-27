FROM quadstingray/webtrees:2.0.15

WORKDIR /tmp_download

ADD https://cissee.de/vesta.latest.zip .

RUN apt-get update
RUN apt-get install unzip
RUN unzip vesta.latest.zip
RUN apt-get -y remove unzip
RUN apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/*
RUN mv /tmp_download/modules_v4/* /var/www/html/modules_v4/

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/scripts/entrypoint.sh"]
