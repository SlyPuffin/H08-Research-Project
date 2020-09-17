#!/bin/sh
############################################################
# Created by: Daniel Voss, 2020-03-15
# Compute hydro power potential
# Input data modified from river discharge files
############################################################
# Basic Settings (Edit here if you wish)
############################################################
PRJ=WFDE
RUN=10YR
YEARMIN=1995
YEARMAX=2006
SECINT=86400
LDBG=2764
############################################################
# Expert Settings (Do not edit here unless you are an expert)
############################################################
SPNFLG=0
SPNERR=0.05
SPNRAT=0.95
PROG=./hydro
############################################################
# Geography (Edit here if you change spatial domain/resolution.
# Note that L (n0l) is prescribed in hydro.f. You also need to
# edit hydro.f and re-compile it.)
############################################################
MAP=.GIS
SUF=.hires
############################################################
# Hydrological Input (Edit here if you wish)
############################################################
RIVOUT=/media/h08user/h08spillover/riv/out/riv_out_/${PRJ}${RUN}.hirMO # River discharge
############################################################
# Map (Do not edit here unless you are an expert)
############################################################
RIVSEQ=../../map/out/riv_seq_/rivseq${MAP}${SUF}    # River sequence
RIVNXL=../../map/out/riv_nxl_/rivnxl${MAP}${SUF}.new    # Next grid
RIVNXD=../../map/out/riv_nxd_/rivnxd${MAP}${SUF}.new    # Distance to next grid
LNDARA=../../map/dat/lnd_ara_/lndara${MAP}${SUF}    # Land area
HEAD=../../map/dat/hydrohead_/hydrohead${MAP}${SUF}     # Hydro Head
USABDISC=/media/h08user/h08spillover/riv/out/riv_out_/${PRJ}${RUN}USABDISC.hir # Usable Discharge 
############################################################
# Output Directory (Do not edit here unless you are an expert)
############################################################
DIRHYDROPOT=../../riv/out/hydro_pot_
############################################################
# Output (Edit here if you wish)
############################################################
HYDROPOT=${DIRHYDROPOT}/${PRJ}${RUN}HYDROPOT${SUF} # Hydropower Potential
HYDROPERC=${DIRHYDROPOT}/${PRJ}${RUN}PERC____${SUF} # Hydropower Percentage
############################################################
# Job (Prepare directory)
############################################################
if [ ! -d $DIRHYDROPOT    ]; then mkdir -p $DIRHYDROPOT;    fi
############################################################
# Job (Making Log file)
############################################################
DATE=`date +"%Y%m%d"`
DIRLOG=../../riv/log
if [ ! -d $DIRLOG ]; then
  mkdir $DIRLOG
fi
LOGFILE=${DIRLOG}/${PRJ}${RUN}${DATE}.log
############################################################
# Job (Making Setting file)
############################################################
DIRSET=../../riv/set
if [ ! -d $DIRSET ]; then
  mkdir $DIRSET
fi
SETFILE=${DIRSET}/${PRJ}${RUN}HYDROPOT${DATE}.set
if [ -f $SETFILE ]; then
  rm $SETFILE
fi
cat << EOF >> $SETFILE
&sethydro
i0yearmin=$YEARMIN
i0yearmax=$YEARMAX
i0ldbg=$LDBG
i0secint=$SECINT
c0rivout='$RIVOUT'
c0rivnxd='$RIVNXD'
c0lndara='$LNDARA'
c0head='$HEAD'
c0perc='$HYDROPERC'
c0usabdisc='$USABDISC'
c0hydropot='$HYDROPOT'
&end
EOF
############################################################
# Job (Start)
############################################################
echo "$PROG $SETFILE > $LOGFILE 2>&1 &"
      $PROG $SETFILE > $LOGFILE 2>&1 &
echo "$PROG: See [$LOGFILE] to check the execusion. For example by,"
echo "% tail -f $LOGFILE"
