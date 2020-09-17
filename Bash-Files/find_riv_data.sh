#!/bin/sh
#source ~/.bashrc
#########################################################
# Created by: Daniel Voss, 2020-05-17
# Find maximum discharge in a user-defined range
#########################################################
 
# River discharge file directory
DIR="/media/h08user/h08spillover/riv/out/riv_out_/"
 
# Latitude, Longitude, and cell range
LONIN=$1
LATIN=$2
PRANGE=$3
 
# Best value, X-value Pointer, Y-value Pointer
BEST=0
XX=0
YY=0
 
# Convert input Latitude and Longitude into 1D L value
MIDHOR=`htid $ARGHIRES lonlat ${LONIN} ${LATIN} | awk '{printf($1)}'`
MIDVER=`htid $ARGHIRES lonlat ${LONIN} ${LATIN} | awk '{printf($2)}'`
# Compute corners of search square
LEFT=`expr $MIDHOR - $PRANGE`
RIGHT=`expr $MIDHOR + $PRANGE`
BOTTOM=`expr $MIDVER - $PRANGE`
TOP=`expr $MIDVER + $PRANGE`
 
# Iterate from top left corner to bottom right corner
while [ $LEFT -le $RIGHT ]; do
    INC=$BOTTOM
    while [ $INC -le $TOP ]; do
            # Computer value at location
        OUT=`htpoint $ARGHIRES xy ${DIR}WFDE10YR00000000.hir ${LEFT} ${INC}`
        OUT=`echo $OUT | awk '{printf("%3.5f",($1 / 1000))}'`
        RESULT=`echo "$OUT>$BEST" | bc`
        # Compare value against current best
        # If greater than best, create new best
        if [ $RESULT -eq "1" ]; then
              BEST=$OUT
                  XX=$LEFT
                  YY=$INC 
            fi    
        INC=`expr $INC + 1`
    done
    LEFT=`expr $LEFT + 1`
    done
 
# Convert to XY values and print
CONVERSION=`htid $ARGHIRES xy ${XX} ${YY}`
echo ${CONVERSION}
