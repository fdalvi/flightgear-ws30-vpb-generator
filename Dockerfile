FROM ubuntu:focal

WORKDIR /home/flightgear/build/

# Set timezone:
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      cmake \
      git \
      libnvtt-dev

RUN git clone --branch release/2.4 https://github.com/OSGeo/gdal.git
WORKDIR /home/flightgear/build/gdal/gdal
RUN ./configure
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/build/
RUN git clone --branch OpenSceneGraph-3.6.5 https://github.com/openscenegraph/OpenSceneGraph.git
RUN mkdir OpenSceneGraph/build/
RUN cat /etc/apt/sources.list
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN apt-get update && apt-get build-dep -y openscenegraph
WORKDIR OpenSceneGraph/build
RUN cmake -D CMAKE_BUILD_TYPE="Release" -D CMAKE_CXX_FLAGS_RELEASE="-O3 -pipe" -D CMAKE_C_FLAGS_RELEASE="-O3 -pipe" -D CMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOLEAN="true" -G "Unix Makefiles" ..
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/build/
RUN git clone https://github.com/openscenegraph/VirtualPlanetBuilder.git && cd VirtualPlanetBuilder && git checkout VirtualPlanetBuilder-1.0
RUN mkdir VirtualPlanetBuilder/build/
WORKDIR /home/flightgear/build/VirtualPlanetBuilder/build/
RUN cmake ..
RUN make -j $(nproc)
RUN make install

WORKDIR /home/flightgear/
ENV LD_LIBRARY_PATH /usr/local/lib64:/usr/local/lib

CMD ["/bin/bash"]