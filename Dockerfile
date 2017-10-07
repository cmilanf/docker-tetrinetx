FROM alpine:latest

LABEL title="Tetrinetx + Tetristats Docker Image" \
  maintainer="Carlos Milán Figueredo" \
  email="cmilanf@hispamsx.org" \
  version="1.0" \
  contrib1="tetrinetx - http://tetrinetx.sourceforge.net" \
  contrib2="tetristats - https://github.com/fcambus/tetristats" \
  url="https://calnus.com" \
  twitter="@cmilanf" \
  usage="docker run -d -p 31457:31457 -p 31458:31458 -p 80:80 -h myhostname.domain.com -e OP_PASSWORD=mypassword -e SPEC_PASSWORD=mypassword --name tetrix cmilanf/tetrinetx" \
  thanksto="Beatriz Sebastián Peña"

RUN apk update \
 && apk add --no-cache nano nginx busybox nano openssl \
 && mkdir /opt \
 && mkdir -p /run/nginx \
 && adduser -D -u 1000 -g 'www' www \
 && mkdir /www \
 && chown -R www:www /var/lib/nginx \
 && chown -R www:www /www \
 && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig \
 && cp -f /var/lib/nginx/html/index.html /www

COPY nginx.conf /etc/nginx

RUN wget -O /tmp/tetrinetx-1.13.16+qirc-1.40c.tar.gz http://prdownloads.sourceforge.net/tetrinetx/tetrinetx-1.13.16+qirc-1.40c.tar.gz?download \
 && tar -xzf /tmp/tetrinetx-1.13.16+qirc-1.40c.tar.gz -C /tmp \
 && mkdir /opt/tetrinetx \
 && mv -f /tmp/tetrinetx-1.13.16+qirc-1.40c/* /opt/tetrinetx

WORKDIR /opt
RUN apk update \
 && apk add --no-cache build-base m4 git \
 && git clone git://git.chiark.greenend.org.uk/~ianmdlvl/adns.git \
 && cd adns \
 && ./configure && make && make install \
 && cd /opt/tetrinetx/src \
 && ./compile.linux \
 && cd /opt \
 && git clone https://github.com/fcambus/tetristats.git \
 && cd tetristats && make && cp -f tetristats.css /www/ \
 && echo -ne '#!/bin/sh\n/opt/tetristats/tetristats -tx /opt/tetrinetx/bin/game.winlist /www/tetristats.html \n\n' > /etc/periodic/15min/tetristats \
 && chmod +x /etc/periodic/15min/tetristats \
 && apk del build-base m4 git

WORKDIR /opt/tetrinetx/bin
COPY game.motd /opt/tetrinetx/bin/
COPY game.winlist /opt/tetrinetx/bin/
COPY channels.conf /tmp
RUN cat /tmp/channels.conf >> /opt/tetrinetx/bin/game.conf \
 && /opt/tetristats/tetristats -tx /opt/tetrinetx/bin/game.winlist /www/tetristats.html

RUN sed -i "s|maxchannels=8|maxchannels=16 |g" /opt/tetrinetx/bin/game.conf \
 && sed -i "s|sd_timeout=0|sd_timeout=600 |g" /opt/tetrinetx/bin/game.conf

ADD tetriweb.tar.gz /www

COPY entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh

HEALTHCHECK --interval=5m --timeout=3s \
  CMD pidof tetrix.linux

EXPOSE 31457 31458 80

ENTRYPOINT /opt/entrypoint.sh
