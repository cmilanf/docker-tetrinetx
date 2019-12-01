FROM alpine:3.5
ARG TETRINETX_URL="http://prdownloads.sourceforge.net/tetrinetx/tetrinetx-1.13.16+qirc-1.40c.tar.gz?download"
ARG ADNS_URL="git://git.chiark.greenend.org.uk/~ianmdlvl/adns.git"

LABEL title="Tetrinetx Docker Image" \
  maintainer="Carlos Milán Figueredo" \
  version="1.1" \
  contrib1="tetrinetx - http://tetrinetx.sourceforge.net" \
  url="https://calnus.com" \
  twitter="@cmilanf" \
  usage="docker run -d -p 31457:31457 -p 31458:31458 -p 80:80 -h myhostname.domain.com -e OP_PASSWORD=mypassword -e SPEC_PASSWORD=mypassword --name tetrix cmilanf/tetrinetx" \
  thanksto="Beatriz Sebastián Peña"

RUN apk update \
 && apk add --no-cache supervisor nano nginx openssl \
 && mkdir -p /run/nginx \
 && adduser -D -u 1000 -g 'www' www \
 && mkdir /www \
 && chown -R www:www /var/lib/nginx \
 && chown -R www:www /www \
 && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig \
 && cp -f /var/lib/nginx/html/index.html /www

COPY nginx.conf /etc/nginx

RUN wget --no-check-certificate -O /tmp/tetrinetx.tar.gz ${TETRINETX_URL} \
 && tar -xzf /tmp/tetrinetx.tar.gz -C /tmp \
 && mkdir -p /opt/tetrinetx/ \
 && mv -f /tmp/tetrinetx-1.13.16+qirc-1.40c/* /opt/tetrinetx \
 && apk add --no-cache build-base m4 git \
 && git clone ${ADNS_URL} /opt/adns \
 && /opt/adns/configure && make && make install \
 && cd /opt/tetrinetx/src \
 && ./compile.linux \
 && rm -rf /tmp/tetrinetx* \
 && apk del build-base m4 git

COPY game.motd /opt/tetrinetx/bin/
COPY game.winlist /opt/tetrinetx/bin/
COPY channels.conf /tmp
ADD tetriweb.tar.gz /www

RUN cat /tmp/channels.conf >> /opt/tetrinetx/bin/game.conf \
 && sed -i "s|maxchannels=8|maxchannels=16 |g" /opt/tetrinetx/bin/game.conf \
 && sed -i "s|sd_timeout=0|sd_timeout=600 |g" /opt/tetrinetx/bin/game.conf \
 && rm -f /tmp/channels.conf \
 && mkdir -p /var/log/supervisor/

COPY supervisord.conf /etc/
COPY docker-entrypoint.sh /usr/local/bin/
COPY tetrix.linux.fg.sh /opt/tetrinetx/bin/

HEALTHCHECK --interval=5m --timeout=3s \
  CMD pidof supervisor

EXPOSE 31457 31458 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
