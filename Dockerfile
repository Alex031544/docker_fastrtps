ARG TAG_DEBIAN='10-slim'
ARG TAG_FASTRTPS='v2.0.1'
ARG TAG_FASTCDR='v1.0.15'
ARG TAG_FASTRTPSGEN='v1.0.4'
ARG TAG_FOONATHAN='v1.0.0'
ARG NPROC=16


### CORE ###################################################

FROM debian:${TAG_DEBIAN} AS core

# To fix the bug then installing Java-JDK on debian slim images
# create a directory for man-pages.
# see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install -y \
		libasio-dev libtinyxml2-dev \
		python3-pip  \
		git \
		gcc g++ cmake \
		ant groovy default-jre-headless && \
	pip3 install -U colcon-common-extensions vcstool


### BUILDER ################################################

FROM core AS builder

ARG TAG_FASTRTPS
ARG TAG_FASTCDR
ARG TAG_FASTRTPSGEN
ARG TAG_FOONATHAN
ARG NPROC


### Fast CDR

WORKDIR /opt/build

RUN git clone \
		--branch ${TAG_FASTCDR} \
		https://github.com/eProsima/Fast-CDR.git && \
	mkdir Fast-CDR/build && \
	cd Fast-CDR/build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . \
		--target install \
		-j $NPROC


### Foonathan memory

WORKDIR /opt/build

RUN git clone \
		--branch ${TAG_FOONATHAN} \
		https://github.com/eProsima/foonathan_memory_vendor.git && \
	cd foonathan_memory_vendor && \
	mkdir build && \
	cd build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . \
		--target install \
		-j ${NPROC}


### Fast RTPS

WORKDIR /opt/build

RUN git clone \
		--branch ${TAG_FASTRTPS} \
		https://github.com/eProsima/Fast-RTPS.git && \
	mkdir Fast-RTPS/build && \
	cd Fast-RTPS/build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . \
		--target install \
		-j ${NPROC}


### Fast-RTPS-Gen

WORKDIR /opt/build
RUN git clone \
		--branch ${TAG_FASTRTPSGEN} \
		--recursive \
		https://github.com/eProsima/Fast-RTPS-Gen.git && \
	cd Fast-RTPS-Gen && \
	./gradlew assemble && \
	mkdir /usr/local/share/fastrtpsgen/ && \
	mv scripts/ /usr/local/share/fastrtpsgen/ && \
	mv share/ /usr/local/share/fastrtpsgen/


### DEV ####################################################

FROM core AS dev

### Fast CDR

COPY --from=builder \
	/usr/local/share/fastcdr \
	/usr/local/share/fastcdr

COPY --from=builder \
	/usr/local/include/fastcdr \
	/usr/local/include/fastcdr

COPY --from=builder \
	/usr/local/lib/libfastcdr.so* \
	/usr/local/lib/

COPY --from=builder \
	/usr/local/lib/cmake/fastcdr \
	/usr/local/lib/cmake/fastcdr


### Foonathan memory

COPY --from=builder \
	/usr/local/include/foonathan_memory \
	/usr/local/include/foonathan_memory

COPY --from=builder \
	/usr/local/lib/foonathan_memory \
	/usr/local/lib/foonathan_memory

COPY --from=builder \
	/usr/local/lib/libfoonathan_memory-*.a \
	/usr/local/lib/

COPY --from=builder \
	/usr/local/bin/nodesize_dbg \
	/usr/local/bin/

COPY --from=builder \
	/usr/local/share/foonathan_memory \
	/usr/local/share/foonathan_memory

COPY --from=builder \
	/usr/local/share/foonathan_memory_vendor \
	/usr/local/share/foonathan_memory_vendor


### FastRTPS & FastDDS

COPY --from=builder \
	/usr/local/share/fastrtps \
	/usr/local/share/fastrtps

COPY --from=builder \
	/usr/local/include/fastrtps \
	/usr/local/include/fastrtps

COPY --from=builder \
	/usr/local/include/fastdds \
	/usr/local/include/fastdds

COPY --from=builder \
	/usr/local/lib/libfastrtps.so* \
	/usr/local/lib/


### Fast-RTPS-Gen

COPY --from=builder \
	/usr/local/share/fastrtpsgen/ \
	/usr/local/share/fastrtpsgen/

ENV PATH="/usr/local/share/fastrtpsgen/scripts:${PATH}"


### RUNTIME ################################################

FROM debian:${TAG_DEBIAN} AS runtime

RUN apt-get update && \
	apt-get install -y \
		libtinyxml2-6 \
		libssl1.1

COPY --from=builder \
	/usr/local/lib/libfastcdr.so* \
	/usr/local/lib/

COPY --from=builder \
	/usr/local/lib/libfastrtps.so* \
	/usr/local/lib/


### EXAMPLES ###############################################

FROM dev AS example-builder

ARG TAG_FASTRTPS
ARG NPROC

RUN git clone \
		--branch ${TAG_FASTRTPS} \
		https://github.com/eProsima/Fast-RTPS.git && \
	mkdir Fast-RTPS/build && \
	cd Fast-RTPS/build && \
	cmake .. \
		-DCOMPILE_EXAMPLES=ON \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . \
		--target install \
		-j ${NPROC}


FROM runtime AS example

COPY --from=example-builder \
	/usr/local/examples/C++ \
	/usr/local/examples/C++
