FROM ubuntu:focal AS build

# Set timezone:
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      cmake \
      git \
      libnvtt-dev

RUN useradd --create-home --home-dir=/home/flightgear --shell=/bin/false flightgear
USER flightgear

WORKDIR /home/flightgear/build/
ARG INSTALLPREFIX=/home/flightgear/dist

RUN git clone --branch release/2.4 https://github.com/OSGeo/gdal.git
WORKDIR /home/flightgear/build/gdal/gdal
RUN ./configure --prefix=${INSTALLPREFIX}
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/build/
RUN git clone --branch OpenSceneGraph-3.6.5 https://github.com/openscenegraph/OpenSceneGraph.git
RUN mkdir OpenSceneGraph/build/
USER root
RUN cat /etc/apt/sources.list
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN apt-get update && apt-get build-dep -y openscenegraph
USER flightgear
WORKDIR OpenSceneGraph/build
RUN cmake -D CMAKE_BUILD_TYPE="Release" -D CMAKE_CXX_FLAGS_RELEASE="-O3 -pipe" -D CMAKE_C_FLAGS_RELEASE="-O3 -pipe" -D CMAKE_PREFIX_PATH:PATH=${INSTALLPREFIX} -D CMAKE_INSTALL_PREFIX:PATH=${INSTALLPREFIX} -D CMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOLEAN="true" -G "Unix Makefiles" ..
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/build/
RUN git clone https://github.com/openscenegraph/VirtualPlanetBuilder.git && cd VirtualPlanetBuilder && git checkout VirtualPlanetBuilder-1.0
RUN mkdir VirtualPlanetBuilder/build/
WORKDIR /home/flightgear/build/VirtualPlanetBuilder/build/
RUN cmake -D CMAKE_PREFIX_PATH:PATH=${INSTALLPREFIX} -D CMAKE_INSTALL_PREFIX:PATH=${INSTALLPREFIX} ..
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/
COPY build/fgmeta fgmeta

FROM ubuntu:focal
LABEL maintainer="Fahim Dalvi"
LABEL version="1"
LABEL description="FlightGear WS30 VPB tools"

RUN true && \
    apt-get update && \
    apt-get install -y libgl1 libfontconfig libnvtt-dev libproj-dev python3 python3-pip xvfb && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid 1000 flightgear && useradd --uid 1000 --gid flightgear --create-home --home-dir=/home/flightgear --shell=/bin/bash flightgear

WORKDIR /home/flightgear
COPY --from=build /home/flightgear/dist/bin/* /usr/local/bin/
COPY --from=build /home/flightgear/dist/share/* /usr/local/share/
COPY --from=build /home/flightgear/dist/lib/* /usr/lib/
COPY --from=build /home/flightgear/dist/lib64/* /usr/lib64/
COPY --from=build /home/flightgear/fgmeta/ws30 /home/flightgear/scripts

RUN ln -s /usr/bin/python3 /usr/bin/python

USER flightgear
RUN pip install -r scripts/requirements.txt

COPY scripts/xvfb-osgdem.sh /home/flightgear/bin/osgdem

ENV PATH "/home/flightgear/bin:$PATH"
ENV LD_LIBRARY_PATH /usr/lib64:/usr/lib
ENV GDAL_DATA /usr/local/share

CMD ["/bin/bash"]