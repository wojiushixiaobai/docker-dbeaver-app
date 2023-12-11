FROM python:3.11-slim-bullseye
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        dbus-x11                      \
        fonts-wqy-microhei            \
        gnupg2                        \
        ibus                          \
        ibus-pinyin                   \
        iso-codes                     \
        libffi-dev                    \
        libgbm-dev                    \
        libnss3                       \
        libssl-dev                    \
        locales                       \
        netcat-openbsd                \
        pulseaudio                    \
        supervisor                    \
        unzip                         \
        wget                          \
        x11vnc                        \
        xauth                         \
        xdg-user-dirs                 \
        xvfb"

ARG APT_MIRROR=http://mirrors.ustc.edu.cn

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=app-apt \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=app-apt \
    sed -i "s@http://.*.debian.org@${APT_MIRROR}@g" /etc/apt/sources.list \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && chmod +x /dev/shm \
    && mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=app-apt \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=app-apt \
    set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jre-headless

ARG DBEAVER_VERSION=23.3.0
RUN set -ex \
    && ARCH=$(uname -m) \
    && \
    case $ARCH in \
        x86_64|aarch64) \
            wget -qO /opt/dbeaver-ce.tar.gz https://github.com/dbeaver/dbeaver/releases/download/${DBEAVER_VERSION}/dbeaver-ce-${DBEAVER_VERSION}-linux.gtk.${ARCH}-nojdk.tar.gz; \
            tar -xzf /opt/dbeaver-ce.tar.gz -C /opt; \
            rm -f /opt/dbeaver-ce.tar.gz; \
            ;; \
        *) \
            echo "unsupported architecture: ${ARCH}" \
            && exit 1 \
            ;; \
    esac

RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && python3 -m venv /opt/py3 \
    && . /opt/py3/bin/activate

WORKDIR /opt

ENV PATH=/opt/py3/bin:$PATH \
    GTK_IM_MODULE="ibus" \
    XMODIFIERS="@im=ibus" \
    QT_IM_MODULE="ibus"

COPY app /opt/app
COPY etc/supervisor/app.conf /etc/supervisor/conf.d/app.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN LANG=C xdg-user-dirs-update --force

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
