#!/bin/sh

C=UA
O="Push Board VPN"
CA_CN=vpn.push-board.lviv.ua

#SERVER_CN=root@vpn.push-board.lviv.ua
#SERVER_SAN=root@vpn.push-board.lviv.ua
#CLIENT_CN=kpinch@push-board.lviv.ua

CONFIG_DIR=$PWD/../config/ipsec.d
IPSEC="docker run -it --rm=true -v $CONFIG_DIR:/etc/ipsec.d vpn"

mkdir -p $CONFIG_DIR/aacerts \
         $CONFIG_DIR/acerts \
         $CONFIG_DIR/cacerts \
         $CONFIG_DIR/certs \
         $CONFIG_DIR/crls \
         $CONFIG_DIR/ocspcerts \
         $CONFIG_DIR/private

if [ ! -f $CONFIG_DIR/private/caKey.pem ]; then
    echo "Generating CA certificate..."
    eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/caKey.pem
    eval $IPSEC pki --self --in /etc/ipsec.d/private/caKey.pem --dn \"C=$C, O=$O, CN=$CA_CN\" --ca --outform pem > $CONFIG_DIR/cacerts/caCert.pem
fi

if [ ! -f $CONFIG_DIR/private/serverKey.pem ]; then
    echo "Generating Server certificate..."

    USER=root
    SERVER_CN=$USER@$CA_CN
    SERVER_SAN=$CA_CN

    eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/serverKey.pem
    eval $IPSEC pki --issue --in /etc/ipsec.d/private/serverKey.pem --type priv --cacert /etc/ipsec.d/cacerts/caCert.pem --cakey /etc/ipsec.d/private/caKey.pem --dn \"C=$C, O=$O, CN=$SERVER_CN\" --san=\"$SERVER_SAN\" --flag serverAuth --flag ikeIntermediate --outform pem > $CONFIG_DIR/certs/serverCert.pem
    
#    eval $IPSEC ipsec restart
fi

if [ $# -gt 0 ]; then 
    USER=$1
    CLIENT_CN=$USER@$CA_CN
    KEY_NAME=${USER}Key
    CERT_NAME=${USER}Cert

    echo "Generating certificate for user: $USER ..."

    eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/$KEY_NAME.pem
    eval $IPSEC pki --issue --in /etc/ipsec.d/private/$KEY_NAME.pem --type priv --cacert /etc/ipsec.d/cacerts/caCert.pem --cakey /etc/ipsec.d/private/caKey.pem --dn \"C=$C, O=$O, CN=$CLIENT_CN\" --san=\"$CLIENT_CN\" --outform pem > $CONFIG_DIR/certs/$CERT_NAME.pem

#    eval $IPSEC ipsec restart

    openssl pkcs12 -export -inkey $CONFIG_DIR/private/$KEY_NAME.pem -in $CONFIG_DIR/certs/$CERT_NAME.pem -name \"$CLIENT_CN\" -certfile $CONFIG_DIR/cacerts/caCert.pem -caname \"$CA_CN\" -out $CONFIG_DIR/$CERT_NAME.p12

    rm $CONFIG_DIR/private/$KEY_NAME.pem 
fi

docker exec -it vpn ipsec rereadsecrets
