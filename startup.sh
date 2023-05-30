#!/bin/sh
rm -rf ovpn_configs*
unzip "Proton*.zip" -d ovpn_configs
cd ovpn_configs
VPN_FILE="${PROTON_CONFIG}"
echo Choose: ${VPN_FILE}

apk add --update --no-cache sed
sed -i 's#up /etc/openvpn/update-resolv-conf#up /etc/openvpn/up.sh#g' ${VPN_FILE}
sed -i 's#down /etc/openvpn/update-resolv-conf#down /etc/openvpn/down.sh#g' ${VPN_FILE}
apk del sed # remove after finished using it #

printf "${PROTON_USER}\n${PROTON_PASSWORD}" > vpn-auth.txt

if [ -n ${LAN_NETWORK}  ]
then
    DEFAULT_GATEWAY=$(ip -4 route list 0/0 | cut -d ' ' -f 3)

    splitSubnets=$(echo ${LAN_NETWORK} | tr "," "\n")

    for subnet in $splitSubnets
    do
        ip route add "$subnet" via "${DEFAULT_GATEWAY}" dev eth0
        echo Adding ip route add "$subnet" via "${DEFAULT_GATEWAY}" dev eth0 for attached container web ui access
    done

    echo Do not forget to expose the ports for attached container web ui access
fi

if [ "${CREATE_TUN_DEVICE}" = "true" ]; then
  echo "Creating TUN device /dev/net/tun"
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 0666 /dev/net/tun
fi

# Enable devices MASQUERADE mode
if [ "${ENABLE_MASQUERADE}" = "true" ]; then
  echo "Enabling IP MASQUERADE using iptables"
  iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
  # nft add rule nat postrouting oifname "tun*" masquerade
fi

# Start OpenVPN
openvpn --config $VPN_FILE --auth-user-pass vpn-auth.txt --mute-replay-warnings $OPENVPN_OPTS --script-security 2 --up /vpn/sockd.sh

if [ "${ENABLE_KILL_SWITCH}" = "true" ]; then
  ufw reset
  ufw default deny incoming
  ufw default deny outgoing
  ufw allow out on tun0 from any to any
  ufw allow 1080
  ufw enable
fi
