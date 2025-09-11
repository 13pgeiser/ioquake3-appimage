#!/bin/bash
set -ex
source bash-scripts/helpers.sh
run_shfmt_and_shellcheck ./*.sh
docker_setup "ioquake3-appimage"
dockerfile_create bookworm
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
        cmake \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
EOF
dockerfile_switch_to_user
cat >>"$DOCKERFILE" <<'EOF'
WORKDIR /work
RUN set -ex \
    && git clone https://github.com/ioquake/ioq3.git
RUN set -ex \
    && cd ioq3 \
    && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build -j$(nproc)
RUN set -ex \
    ls -al ioq3/build/
RUN set -ex \
    && mkdir -p /work/AppDir \
    && mkdir -p /work/AppDir/baseq3 \
    && mkdir -p /work/AppDir/missionpack \
    && cp ioq3/misc/quake3.svg /work/AppDir \
    && cp ioq3/build/Release/ioquake3 /work/AppDir \
    && cp ioq3/build/Release/ioq3ded /work/AppDir \
    && cp ioq3/build/Release/*.so /work/AppDir \
    && cp ioq3/build/Release/baseq3/*.so /work/AppDir/baseq3 \
    && cp ioq3/build/Release/missionpack/*.so /work/AppDir/missionpack
COPY ioquake3.desktop /work/AppDir/ioquake3.desktop
COPY eula.txt /work/AppDir/eula.txt
RUN set -ex \
    && export LD_LIBRARY_PATH=/work/AppDir/usr/lib/ ; find /work/AppDir/ -type f -executable -exec ldd {} \; | grep "not found" | true \
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
cp -f ioquake3.desktop "$(dirname "$DOCKERFILE")"
cp -f eula.txt "$(dirname "$DOCKERFILE")"
cp -f AppRun "$(dirname "$DOCKERFILE")"
docker_build_image_and_create_volume
mkdir -p release
if [ $# -eq 0 ]; then
	$DOCKER_RUN_I cp ioquake3.tgz /mnt/release
else
	$DOCKER_RUN_I "$@"
fi
