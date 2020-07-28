FROM debian:buster

# Install base deps
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
	git \
	ca-certificates \
	build-essential \
	libtool \
	pkg-config \
	wget \
	libfuse2 \
	strace \
	libcurl4-gnutls-dev \
	libjpeg-dev \
	libopenal-dev \
	libopus-dev \
	libopusfile-dev \
	libsdl2-dev \
	libvorbis-dev \
	libgl1 \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

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
    && mkdir -p /AppDir \
    && mkdir -p /AppDir/baseq3 \
    && mkdir -p /AppDir/missionpack \
    && cp ioq3/misc/quake3.svg /AppDir \
    && cp ioq3/build/release-linux-x86_64/ioquake3.x86_64 /AppDir \
    && cp ioq3/build/release-linux-x86_64/ioq3ded.x86_64 /AppDir \
    && cp ioq3/build/release-linux-x86_64/*.so /AppDir \
    && cp ioq3/build/release-linux-x86_64/baseq3/*.so /AppDir/baseq3 \
    && cp ioq3/build/release-linux-x86_64/missionpack/*.so /AppDir/missionpack

RUN set -ex \
    && wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage \
    && wget https://ioquake3.org/files/1.36/data/ioquake3-q3a-1.32-9.run \
    && wget https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3ademo-1.11-6.x86.gz.sh \
    && chmod +x appimagetool-x86_64.AppImage

COPY ioquake3.desktop AppDir/ioquake3.desktop

COPY AppRun AppDir/AppRun

COPY eula.txt AppDir/eula.txt

RUN set -ex \
    && chmod a+x AppDir/AppRun \
    && export LD_LIBRARY_PATH=/AppDir/usr/lib/ ; find /AppDir/ -type f -executable -exec ldd {} \; | grep "not found" | true \
    && ./appimagetool-x86_64.AppImage --appimage-extract-and-run AppDir \
    && bash /ioquake3-q3a-1.32-9.run --target data || true \
    && bash /linuxq3ademo-1.11-6.x86.gz.sh -target demo || true \
    && mkdir -p /ioquake3 \
    && cp ioquake3-x86_64.AppImage /ioquake3 \
    && mkdir -p /ioquake3/baseq3 \
    && tar xvf data/idpatchpk3s.tar -C /ioquake3/baseq3 \
    && mkdir -p /ioquake3/missionpack  \
    && tar xvf data/idtapatchpk3s.tar -C /ioquake3/missionpack \
    && cp /demo/demoq3/pak0.pk3 /ioquake3/baseq3 \
    && tar cvzf ioquake3.tgz ioquake3

