#!/bin/bash

# Sample script to build a small ws30 tile

# This script assumes the data is already present (in the same directory as this script).
# SRTM data from:
#  https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_34_02.zip
#  https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_35_01.zip
#  https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_35_02.zip
#  https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_36_01.zip
#  https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_36_02.zip
#  
# CORINE landcover from:
#  https://land.copernicus.eu/pan-european/corine-land-cover/clc2018?tab=download
#  (behind registration wall - Corine Land Cover - 100 meter Raster)

osgdem \
	--TERRAIN \
	--compressor-nvtt \
	--compression-quality-highest \
	--no-interpolate-imagery \
	--disable-error-diffusion \
	--geocentric \
	-t /home/flightgear/data/u2018_clc2018_v2020_20u1_raster100m/DATA/U2018_CLC2018_V2020_20u1.tif \
	-d /home/flightgear/data/srtm_34_02.tif \
	-d /home/flightgear/data/srtm_35_01.tif \
	-d /home/flightgear/data/srtm_35_02.tif \
	-d /home/flightgear/data/srtm_36_01.tif \
	-d /home/flightgear/data/srtm_36_02.tif \
	-b -4 50 -3 51 \
	--PagedLOD \
	-l 7 \
	--radius-to-max-visible-distance-ratio 3 \
	-o /home/flightgear/output/vpb/w010n50/w004n50/ws_w004n50.osgb