#!/bin/bash
set -ex
source bash-helpers/helpers.sh
docker_setup "ioquake3-appimage"
dockerfile_create
dockerfile_appimage
cat >>"$DOCKERFILE" <<'EOF'
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        libncurses5 \
	libcurl4-gnutls-dev \
	libjpeg-dev \
	libopenal-dev \
	libopus-dev \
	libopusfile-dev \
	libsdl2-dev \
	libvorbis-dev \
	libgl1 \
        unzip \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
EOF
dockerfile_switch_to_user
cat >>"$DOCKERFILE" <<'EOF'
WORKDIR /work
RUN set -ex \
    && git clone https://github.com/ioquake/ioq3.git \
    && cd ioq3 \
    && git checkout 2b42f0bdab93284b291c29817f6401d8a156aa63
RUN set -ex \
    && cd ioq3 \
    && make -j \
	USE_CODEC_OPUS=1 \
	USE_CODEC_VORBIS=1 \
	USE_CURL=1 \
	USE_CURL_DLOPEN=0 \
	USE_INTERNAL_LIBS=0 \
	USE_LOCAL_HEADERS=0 \
	USE_OPENAL=1 \
	USE_OPENAL_DLOPEN=0 \
	USE_VOIP=1 \
	BUILD_CLIENT=1 \
	BUILD_CLIENT_SMP=1 \
	BUILD_GAME_SO=1 \
	BUILD_GAME_QVM=1
RUN set -ex \
    && mkdir -p /work/AppDir \
    && mkdir -p /work/AppDir/baseq3 \
    && mkdir -p /work/AppDir/missionpack \
    && cp ioq3/misc/quake3.svg /work/AppDir \
    && cp ioq3/build/release-linux-x86_64/ioquake3.x86_64 /work/AppDir \
    && cp ioq3/build/release-linux-x86_64/ioq3ded.x86_64 /work/AppDir \
    && cp ioq3/build/release-linux-x86_64/*.so /work/AppDir \
    && cp ioq3/build/release-linux-x86_64/baseq3/*.so /work/AppDir/baseq3 \
    && cp ioq3/build/release-linux-x86_64/missionpack/*.so /work/AppDir/missionpack
COPY ioquake3.desktop /work/AppDir/ioquake3.desktop
COPY eula.txt /work/AppDir/eula.txt
RUN set -ex \
    && export LD_LIBRARY_PATH=/work/AppDir/usr/lib/ ; find /work/AppDir/ -type f -executable -exec ldd {} \; | grep "not found" | true \
    && cp /usr/lib/libopus* AppDir \
    && ./appimagetool-x86_64.AppImage --appimage-extract-and-run AppDir \
    && mkdir -p /work/ioquake3 \
    && cp ioquake3-x86_64.AppImage /work/ioquake3
RUN set -ex \
    && wget https://files.ioquake3.org/quake3-latest-pk3s.zip
RUN set -ex \
    && unzip quake3-latest-pk3s.zip \
    && mkdir -p /work/ioquake3/baseq3 \
    && cp quake3-latest-pk3s/baseq3/* /work/ioquake3/baseq3 \
    && mkdir -p /work/ioquake3/missionpack  \
    && cp quake3-latest-pk3s/missionpack/* /work/ioquake3/missionpack
RUN set -ex \
    && wget https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3ademo-1.11-6.x86.gz.sh
RUN set -ex \
    && bash linuxq3ademo-1.11-6.x86.gz.sh -target demo || true \
    && cp demo/demoq3/pak0.pk3 /work/ioquake3/baseq3 \
    && chmod 644 ioquake3/baseq3/*
RUN set -ex \
    && tar cvzf ioquake3.tgz ioquake3
RUN ls -al ioquake3/baseq3
EOF
docker_build_image_and_create_volume
run_shfmt_and_shellcheck
if [ $# -eq 0 ]; then
	$DOCKER_RUN_I cp ioquake3.tgz /mnt
else
	$DOCKER_RUN_I "$@"
fi
