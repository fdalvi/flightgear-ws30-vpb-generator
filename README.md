# VirtualPlanetBuilder Terrain Generation for FlightGear

This repository provides a DockerFile that can generate an image to build VPB terrain. It is currently based on the following versions:

* Ubuntu 20.04 (LTS)
* GDAL 2.4
* OpenSceneGraph 3.6.5
* VirtualPlanetBuilder 1.0

To build the image, run `build_image.sh`. This will build and tag the image with the name `flightgear/ws30-vbp-generator:v1`.

## Building terrain
The provided `run_image.sh` script automatically builds terrain based on some assumptions:

* Upon running, the image looks for an executes all commands in `data/run.sh` (sample provided in the repo)
* The `data` directory itself is mounted as `/home/flightgear/data/` inside the container, so use this as reference when modifying `data/run.sh`
* The `run_image.sh` script also mounts an additional `output` directory, at `/home/flightgear/output/` inside the container. `data/run.sh` currently saves all output to this folder so its accessible outside the container.

To build some test terrain, first download SRTM heightmap and CORINE landclass data (see the wiki for details: [https://wiki.flightgear.org/Virtual_Planet_Builder](https://wiki.flightgear.org/Virtual_Planet_Builder)), extract the files to `./data` and run `./run_image.sh`. See `./data/run.sh` for sample data links and commands.