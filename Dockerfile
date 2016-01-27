FROM reo7sp/nginx
MAINTAINER Oleg Morozenkov

RUN apt-get update && \
	apt-get install -y npm && \
	rm -rf /var/lib/apt/lists/* && \
	ln -s /usr/bin/nodejs /usr/bin/node && \
	npm install -g gulp && \
	npm install

COPY . /tmp/reo7sp.ru
WORKDIR /tmp/reo7sp.ru
RUN gulp compile && \
	mkdir -p /var/lib/www/reo7sp.ru && \
	cp -r /tmp/reo7sp.ru/bin/* /var/lib/www/reo7sp.ru/ && \
	rm -rf /tmp/reo7sp.ru/*

RUN rm -rf /etc/nginx/sites-enabled/*
COPY nginxsite.conf /etc/nginx/sites-enabled/

VOLUME /var/lib/www/host.reo7sp.ru

EXPOSE 80
