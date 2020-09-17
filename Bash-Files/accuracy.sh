#!/bin/sh
############################################################
# Created by: Daniel Voss, 2020-07-10
# Compute hydro power potential accuracy
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
PROG=./accuracy
############################################################
# Geography (Edit here if you change spatial domain/resolution.
# Note that L (n0l) is prescribed in main.f. You also need to
# edit main.f and re-compile it.)
############################################################
MAP=.GIS
SUF=.hires
############################################################
# Hydrological Input (Edit here if you wish)
############################################################
HYDROPOT=../../riv/out/hydro_pot_/${PRJ}${RUN}HYDROPOT${SUF} # Hydro Potential 
COMPPOT=../../riv/out/kankyosho_poten_/poten${MAP}${SUF}  # Kankyosho potentail
COMPID=../../riv/out/kankyosho_poten_/id${MAP}${SUF} # Kankyosho IDs
############################################################
# Output Directory (Do not edit here unless you are an expert)
############################################################
DIRHYDROPOT=../../riv/out/hydro_pot_
############################################################
# Output (Edit here if you wish)
############################################################
COMPLIST=../../riv/out/kankyosho_poten_/list_comparison${SUF}.txt # comp txt
HYDRLIST=../../riv/out/kankyosho_poten_/list_hydropot${SUF}.txt #hydro txt
ERROR=../../riv/out/kankyosho_poten_/error${MAP}${SUF} # error map
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
LOGFILE=${DIRLOG}/ACCURACY${RUN}${DATE}.log
############################################################
# Job (Making Setting file)
############################################################
DIRSET=../../riv/set
if [ ! -d $DIRSET ]; then
  mkdir $DIRSET
fi
SETFILE=${DIRSET}/${PRJ}${RUN}ACCURACY${DATE}.set
if [ -f $SETFILE ]; then
  rm $SETFILE
fi
cat << EOF >> $SETFILE
&setaccuracy
i0yearmin=$YEARMIN
i0yearmax=$YEARMAX
i0ldbg=$LDBG
i0secint=$SECINT
c0hydropot='$HYDROPOT'
c0comppot='$COMPPOT'
c0compid='$COMPID'
c0error='$ERROR'
c0hydrlist='$HYDRLIST'
c0complist='$COMPLIST'
&end
EOF
############################################################
# Job (Start)
############################################################
echo "$PROG $SETFILE > $LOGFILE 2>&1 &"
      $PROG $SETFILE > $LOGFILE 2>&1 &
echo "$PROG: See [$LOGFILE] to check the execusion. For example by,"
echo "% tail -f $LOGFILE"
