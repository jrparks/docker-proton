FROM alpine:latest
LABEL maintainer.name="Jason Parks" \
    maintainer.email="jrparks@gmail.com" \
    version="1.0.1" \
    description="OpenVPN client and socks5 server with NAT configured for Proton VPN"
WORKDIR /vpn
ENV PROTON_USER=Proton_OpenVPN_Username
ENV PROTON_PASSWORD=Proton_OpenVPN_Password
ENV PROTON_CONFIG=us-free-07.protonvpn.net.udp.ovpn
ENV OPENVPN_OPTS=
ENV LAN_NETWORK=
ENV CREATE_TUN_DEVICE=true
ENV ENABLE_MASQUERADE=
ENV OVPN_CONFIGS=
ENV ENABLE_KILL_SWITCH=true
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s CMD /vpn/healthcheck.sh
COPY startup.sh .
COPY healthcheck.sh .
COPY Proton*.zip .
COPY sockd.conf /etc/
COPY sockd.sh .
RUN apk add --update --no-cache openvpn unzip coreutils curl ufw dante-server \
    && chmod +x ./startup.sh \
    && chmod +x ./healthcheck.sh \
    && chmod +x ./sockd.sh
ENTRYPOINT [ "./startup.sh" ]
