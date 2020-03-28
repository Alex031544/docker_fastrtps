
FROM debian:10-slim

### Dependencies

# To fix the bug then installing Java-JDK on debian slim images.
# see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

RUN \
	echo 'APT::Acquire::Queue-Mode "access";' >> /etc/apt/apt.conf.d/99parallel && \
	echo 'APT::Acquire::Retries 3;' >> /etc/apt/apt.conf.d/99parallel
RUN apt-get update && \
	apt-get install -y \
		libasio-dev libtinyxml2-dev \
		python3-pip  \
		git \
		gcc g++ cmake \
		gradle && \
	pip3 install -U colcon-common-extensions vcstool


### Fast CDR

WORKDIR /opt/build
RUN git clone --depth=1 https://github.com/eProsima/Fast-CDR.git
RUN mkdir Fast-CDR/build && \
	cd Fast-CDR/build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . --target install -j 16


### Foonathan memory

WORKDIR /opt/build
RUN git clone --depth=1 https://github.com/eProsima/foonathan_memory_vendor.git
RUN cd foonathan_memory_vendor && \
	mkdir build && \
	cd build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . --target install -j 16


### Fast RTPS

WORKDIR /opt/build
RUN git clone --depth=1 https://github.com/eProsima/Fast-RTPS.git
RUN mkdir Fast-RTPS/build && \
	cd Fast-RTPS/build && \
	cmake .. \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . --target install -j 16


### Fast-RTPS-Gen

WORKDIR /opt/build
RUN git clone --recursive https://github.com/eProsima/Fast-RTPS-Gen.git
RUN cd Fast-RTPS-Gen && \
	gradle assemble && \
	mv scripts/ /usr/local/share/fastrtps/ && \
	mv share/ /usr/local/share/fastrtps/

ENV PATH="/usr/local/share/fastrtps/scripts:${PATH}"


### clean up

WORKDIR /opt
RUN rm -rf /opt/build && \
	apt-get auto-remove -y && \
	apt-get auto-clean
