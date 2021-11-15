# VirtualPlanetBuilder Terrain Generation for FlightGear

This repository provides a DockerFile that can generate an image to build VPB terrain. It is currently based on the following versions:

* Ubuntu 20.04 (LTS)
* GDAL 2.4
* OpenSceneGraph 3.6.5
* VirtualPlanetBuilder 1.0

To build the image, run `build_image.sh`. This will build and tag the image with the name `flightgear/ws30-vbp-generator:v1`.

## Building terrain
The provided `run_image.sh` will launch a container and present a `bash` prompt with the environment for building all set up:

* GDAL and VPB executables will be available to run
* The `data` directory will be mounted at `/home/flightgear/data/` inside the container (readonly)
* The `output` directory will be mounted at `/home/flightgear/output` inside the container with write access

A sample script in `data/run.sh` is provided to automatically build a small area around Edinburgh. To build the terrain:
1. First download SRTM heightmap and CORINE landclass data (see the wiki for details: [https://wiki.flightgear.org/Virtual_Planet_Builder](https://wiki.flightgear.org/Virtual_Planet_Builder) and `data/run.sh` for links)
2. Extract the files to `./data`
3. Launch the container with `./run_image.sh`
4. Run `./data/run.sh` at the prompt. The script will saves all output to the mounted `./output` folder, so its accessible outside the container.

A shorthand for steps 3-4 is also available:

```bash
./run_image.sh ./data/run.sh
```
