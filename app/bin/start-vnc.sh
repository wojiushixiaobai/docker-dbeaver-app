#!/usr/bin/env bash

mkdir -p "${HOME:-/root}/.vnc"

if [ -z "${JMS_VNC_PASSWORD}" ]; then
    JMS_VNC_PASSWORD=$(head -c100 < /dev/urandom | base64 | tr -dc A-Za-z0-9 | head -c 8; echo)
fi

x11vnc -storepasswd "${JMS_VNC_PASSWORD}" "${HOME:-/root}/.vnc/passwd"

/usr/bin/x11vnc -display :0 -xkb -rfbauth "${HOME:-/root}/.vnc/passwd" -forever -shared