#!/bin/sh
#########################################################
# Created by: Daniel Voss, 2020-04-10
# Prepare averages for hydropower calculation
#########################################################
# Geographical settings
L=5760000
XY="2400 2400"
L2X=../../map/dat/l2x_l2y_/l2x.hires.txt
L2Y=../../map/dat/l2x_l2y_/l2y.hires.txt
LONLAT="134 136 34 36"
SUF=.hir
# File format and date range settings
PRJ=WFDE
RUN=10YR
YEARMIN=1995
YEARMAX=2006
YEAROUT=0000
# Input data folder
DIR=/media/h08user/h08spillover/riv/out/riv_out_
# Divide average data by 1000 to convert from kg/s to m^3/s
htmath $L div ${DIR}/${PRJ}${RUN}00000000${SUF} 1000 ${DIR}/${PRJ}${RUN}USABDISC${SUF}
