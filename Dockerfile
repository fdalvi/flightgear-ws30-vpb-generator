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

RUN mkdir /home/flightgear/build/

WORKDIR /home/flightgear/build/
ARG INSTALLPREFIX=/home/flightgear/dist
ARG GDAL_INSTALLPREFIX=/home/flightgear/gdal_3.4.1

# gdal 2.4 required by VirtualPlanetBuilder
RUN git clone --branch release/2.4 https://github.com/OSGeo/gdal.git gdal_2.4
WORKDIR /home/flightgear/build/gdal_2.4/gdal
RUN ./configure --prefix=${INSTALLPREFIX}
RUN make -j $(nproc)
RUN make install

# gdal 3.4.1 required for the python gdal tools, used by genVPB.py.
WORKDIR /home/flightgear/build/
RUN git clone --branch v3.4.1 https://github.com/OSGeo/gdal.git gdal_3.4.1
USER root
RUN apt-get update && apt-get install -y autotools-dev automake
RUN apt-get update && apt-get install -y proj-bin libproj-dev
USER flightgear
WORKDIR /home/flightgear/build/gdal_3.4.1/gdal
RUN ./autogen.sh
RUN ./configure --prefix=${GDAL_INSTALLPREFIX}
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

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN true && \
    apt-get update && \
    apt-get install -y libgl1 libfontconfig libnvtt-dev libproj-dev python3 python3-pip xvfb imagemagick-6.q16 zip wget && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid 1000 flightgear && useradd --uid 1000 --gid flightgear --create-home --home-dir=/home/flightgear --shell=/bin/bash flightgear

WORKDIR /home/flightgear
COPY --from=build /home/flightgear/dist/include/* /usr/include/
COPY --from=build /home/flightgear/dist/bin/* /usr/local/bin/
COPY --from=build /home/flightgear/dist/share/* /usr/local/share/
COPY --from=build /home/flightgear/dist/lib/* /usr/lib/
COPY --from=build /home/flightgear/dist/lib64/* /usr/lib64/

# GDAL 3.4.1 copied across afterwards, as it needs to be installed over gdal 2.4.1
COPY --from=build /home/flightgear/gdal_3.4.1/include/* /usr/include/
COPY --from=build /home/flightgear/gdal_3.4.1/bin/* /usr/local/bin/
COPY --from=build /home/flightgear/gdal_3.4.1/share/* /usr/local/share/
COPY --from=build /home/flightgear/gdal_3.4.1/lib/* /usr/lib/

COPY --from=build /home/flightgear/fgmeta/ws30 /home/flightgear/scripts

RUN ln -s /usr/bin/python3 /usr/bin/python


USER flightgear
RUN pip install -r scripts/requirements.txt
# gdal doesn't install well with build isolation, so is installed explicity
RUN pip install -U setuptools wheel
RUN pip install --no-build-isolation --no-cache-dir --force-reinstall gdal==3.4.1

COPY scripts/xvfb-osgdem.sh /home/flightgear/bin/osgdem

ENV PATH "/home/flightgear/bin:$PATH"
ENV LD_LIBRARY_PATH /usr/lib64:/usr/lib
ENV GDAL_DATA /usr/local/share

CMD ["/bin/bash"]