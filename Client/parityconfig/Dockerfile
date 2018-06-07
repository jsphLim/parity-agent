FROM ubuntu:16.04
LABEL maintainer="Kaiya Xiong"
RUN mkdir /parity
WORKDIR /parity
RUN apt-get -qq update
RUN apt-get -qq install -y wget git vim nginx
RUN wget http://d1h4xl4cr1h0mo.cloudfront.net/v1.9.5/x86_64-unknown-linux-gnu/parity_1.9.5_ubuntu_amd64.deb \
    && dpkg -i parity_1.9.5_ubuntu_amd64.deb
RUN rm parity_1.9.5_ubuntu_amd64.deb

EXPOSE 30300 8545 8180 8450
