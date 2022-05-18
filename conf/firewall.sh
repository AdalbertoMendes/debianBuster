#!/bin/sh
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 22
ufw allow 53
ufw allow 88
ufw allow 123/udp
ufw allow 135/tcp
ufw allow 137/udp
ufw allow 138/udp
ufw allow 139/tcp
ufw allow 389
ufw allow 445/tcp
ufw allow 464
ufw allow 636/tcp
ufw allow 3268/tcp
ufw allow 3269/tcp
ufw allow 49152:65535/tcp
ufw enable
ufw status verbose
