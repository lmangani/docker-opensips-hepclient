FROM debian:jessie
MAINTAINER "Lorenzo Mangani <lorenzo.mangani@gmail.com>"

USER root

RUN apt-get update && apt-get install -y sudo git make bison flex curl libcurl3 libcurl3-dev libssl-dev && \
    echo "mysql-server mysql-server/root_password password passwd" | sudo debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password passwd" | sudo debconf-set-selections && \
    apt-get install -y mysql-server libmysqlclient-dev libncurses5 libncurses5-dev mysql-client expect && \
    apt-get clean

RUN curl ipinfo.io/ip > /etc/public_ip.txt

COPY /rtpengine /rtpengine
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -qqy dpkg-dev debhelper libevent-dev iptables-dev libcurl4-openssl-dev libglib2.0-dev libhiredis-dev libpcre3-dev libssl-dev libxmlrpc-core-c3-dev markdown zlib1g-dev module-assistant dkms gettext \
    libavcodec-dev libavfilter-dev libavformat-dev libjson-glib-dev libpcap-dev nfs-common \
    libbencode-perl libcrypt-rijndael-perl libdigest-hmac-perl libio-socket-inet6-perl libsocket6-perl netcat && \
    dpkg -i /rtpengine/*.deb && \
    apt-get clean

RUN git clone https://github.com/OpenSIPS/opensips.git -b 3.1 ~/opensips && \
    sed -i 's/#define HEP_PROTO_TYPE_XLOG 0x056/#define HEP_PROTO_TYPE_XLOG 0x064/g'  ~/opensips/modules/proto_hep/hep.h && \
    sed -i 's/0x56/0x64/g'  ~/opensips/modules/proto_hep/hep.c && \
    sed -i 's/0x57/0x64/g'  ~/opensips/modules/proto_hep/hep.c && \
    sed -i 's/0x58/0x64/g'  ~/opensips/modules/proto_hep/hep.c && \
    sed -i 's/db_http db_mysql db_oracle/db_http db_oracle/g' ~/opensips/Makefile.conf.template && \
    sed -i 's/rabbitmq rest_client rls/rabbitmq rls/g' ~/opensips/Makefile.conf.template && \
    cd ~/opensips && \
    include_modules=rest_client make all && make prefix=/usr/local install && \
    cd .. && rm -rf ~/opensips
    
RUN apt-get purge -y bison build-essential ca-certificates flex git m4 pkg-config curl  && \
    apt-get autoremove -y && \
    apt-get install -y libmicrohttpd10 rsyslog ngrep && \
    apt-get clean

COPY conf/opensips-hep.cfg /usr/local/etc/opensips/opensips.cfg

COPY boot_run.sh /etc/boot_run.sh
RUN chown root.root /etc/boot_run.sh && chmod 700 /etc/boot_run.sh

EXPOSE 5060/udp
EXPOSE 5060/tcp
EXPOSE 9060/udp
EXPOSE 9060/tcp
EXPOSE 6060/udp
EXPOSE 20000-20100/udp

ENTRYPOINT ["/etc/boot_run.sh"]
