#!/bin/sh
#########################################################
# Created by: Daniel Voss, 2019-06-06
# Collect data for a location over a user-defined range
#########################################################
 
# Years to process
YEARS="1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006"
# Months to process
MONTHS="01 02 03 04 05 06 07 08 09 10 11 12"
# Observation site name
RUN="manganji_obs_"
 
# For each month in each year
for YEAR in $YEARS; do
    for MONTH in $MONTHS; do
        # Define input and output files
        FILE=`echo *${YEAR}${MONTH}*.dat`
        OUT=${RUN}${YEAR}${MONTH}.csv
        echo $FILE
        echo $OUT
        # Run extract_means.py for each day
        python extract_means.py $FILE $OUT
    done
done
