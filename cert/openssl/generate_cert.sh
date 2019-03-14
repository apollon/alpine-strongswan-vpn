#!/bin/sh

C=UA
O="Push Board VPN"
CA_CN=vpn.push-board.lviv.ua
SERVER_CN=root@vpn.push-board.lviv.ua
CLIENT_CN=kpinch@vpn.push-board.lviv.ua

mkdir -p ./sign/certs ./ca ./server

if [ ! -f ./ca/caKey.pem ]; then
# rsa:4096
    openssl req -x509 -days 3650 -newkey rsa:2048 -nodes -subj "/C=$C/O=$O/CN=$CA_CN" -keyout ./ca/caKey.pem -out ./ca/caCert.pem
#    openssl x509 -in ./ca/caCert.csr -noout -text
fi

if [ ! -f ./server/serverKey.pem ]; then
    openssl req -newkey rsa:2048 -nodes -subj "/C=$C/O=$O/CN=$SERVER_CN" -keyout ./server/serverKey.pem -out ./server/serverCert.csr
    openssl ca -batch -cert ./ca/caCert.pem -keyfile ./ca/caKey.pem -days 3650 -config ./sign/sign.conf -in ./server/serverCert.csr -out ./server/serverCert.pem -notext
    rm ./server/serverCert.csr

    openssl verify -CAfile ./ca/caCert.pem ./server/serverCert.pem
fi

openssl req -newkey rsa:2048 -nodes -subj "/C=$C/O=$O/CN=$CLIENT_CN" -keyout clientKey.pem -out clientCert.csr
openssl ca -batch -cert ./ca/caCert.pem -keyfile ./ca/caKey.pem -days 3650 -config ./sign/sign.conf -in clientCert.csr -out clientCert.pem -notext
rm clientCert.csr

openssl verify -CAfile ./ca/caCert.pem clientCert.pem

openssl pkcs12 -export -nodes -passout pass:pass -inkey clientKey.pem -in clientCert.pem -name \"$CLIENT_CN\" -certfile ./ca/caCert.pem -caname \"$CA_CN\" -out clientCert.p12
