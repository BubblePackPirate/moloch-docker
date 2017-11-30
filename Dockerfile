FROM ubuntu:16.04

WORKDIR /data/moloch

#Dependencies & Nice things to have
RUN apt-get update && \
apt-get install -y wget locate nano curl libpcre3-dev uuid-dev libmagic-dev pkg-config g++ flex \
bison zlib1g-dev libffi-dev gettext libgeoip-dev make libjson-perl libbz2-dev libwww-perl \
libpng-dev xz-utils libffi-dev ethtool libyaml-dev default-jre


#ADD https://github.com/aol/moloch/blob/master/easybutton-build.sh .
#RUN chmod +x easybutton-build.sh && ./easybutton-build.sh

ADD https://files.molo.ch/builds/ubuntu-16.04/moloch_0.20.0-1_amd64.deb .
RUN dpkg --install moloch_0.20.0-1_amd64.deb

ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.4.deb .
RUN dpkg --install elasticsearch-5.6.4.deb

#GeoIP and IP databases
ADD http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz .
RUN gunzip GeoIP.dat.gz && mv GeoIP.dat /data/moloch/etc/GeoIP.dat
ADD http://www.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz .
RUN gunzip GeoIPASNum.dat.gz && mv GeoIPASNum.dat /data/moloch/etc/GeoIPASNum.dat
ADD https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv .
RUN mv ipv4-address-space.csv /data/moloch/etc/ipv4-address-space.csv

#Bake your configs into the image. Hope u like them
COPY config.ini /data/moloch/etc/config.ini
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh
EXPOSE 8005
EXPOSE 9200
