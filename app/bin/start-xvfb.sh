#!/usr/bin/env bash

SCREEN_WIDTH=${JUMPSERVER_WIDTH:-1280}
SCREEN_HEIGHT=${JUMPSERVER_HEIGHT:-800}
SCREEN_DEPTH=${JUMPSERVER_DEPTH:-24}
SCREEN_DPI=${JUMPSERVER_DPI:-96}

export GEOMETRY="${SCREEN_WIDTH}""x""${SCREEN_HEIGHT}""x""${SCREEN_DEPTH}"

mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
rm -f /tmp/.X*lock

/usr/bin/xvfb-run --server-num=0 --listen-tcp \
    --server-args="-screen 0 ${GEOMETRY} -fbdir /var/tmp -dpi ${SCREEN_DPI} -listen tcp -noreset -ac +extension RANDR" \
    /usr/local/bin/entrypoint.sh