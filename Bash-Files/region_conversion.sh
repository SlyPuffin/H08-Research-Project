#!/bin/sh
#source ~/.bashrc
##############################################
# Modified from H08 base files by Daniel Voss
##############################################
 
# Target directories
DIRS="../../met/dat/Wind____/wfde____ ../../met/dat/LWdown__/wfde____ ../../met/dat/Qair____/wfde____ ../../met/dat/SWdown__/wfde____"
# Latitude and Longitude Range
RFLAG=134.0004166/135.9995833/34.00041664/35.99958332
# Target cell size (degrees)
IFLAG=0.0008333/0.0008333
# Input resolution extension
SUF=.hyo
# Target resolution extension
TSUF=.hires
# Target resolution land mask file
LNDMSK=../../map/dat/lnd_msk_/lndmsk.GIS.hires
# Years to process
YEARS="1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006"
# Months to process
MONTH="01 02 03 04 05 06 07 08 09 10 11 12"
 
echo $ARGHYO $ARGHLF
for DIR in $DIRS; do
    # Loop over set years
    for YEAR in $YEARS; do
        # Loop over set months
                for MON in $MONTH; do
                        DAY=1
                        DAYMAX=`htcal $YEAR $MON`
            # Loop over days in the month
                        while [ $DAY -le $DAYMAX ]; do
                                DAY=`echo $DAY | awk '{printf("%2.2d",$1)}'`
                                echo $YEAR $MON $DAY
                echo ${DIR}${YEAR}${MON}${DAY}${SUF}
                # Convert binary file to .xyz ascii3 file
                htmaskrplc $ARGHYO ${DIR}${YEAR}${MON}${DAY}${SUF} ../../map/dat/lnd_msk_/lndmsk.GIS.rh1 eq 0 NaN ./temp.hyo
                htlinear $ARGHYO $ARGHIRES ./temp${SUF} ./temp${TSUF}
                htformat $ARGHIRES binary ascii3 ./temp${TSUF} ./temp.xyz
                # Convert ascii file resolution to target resolution
                gmt xyz2grd ./temp.xyz -R$RFLAG -I$IFLAG -G./grd -r
                gmt surface ./temp.xyz -R$RFLAG -I$IFLAG -G./grd -T0 -Ll0
                gmt grd2xyz grd > ${DIR}${YEAR}${MON}${DAY}.xyz
                # Convert ascii file back to H08 binary format
                htformat $ARGHIRES ascii3 binary ${DIR}${YEAR}${MON}${DAY}.xyz  ${DIR}${YEAR}${MON}${DAY}${TSUF}
                htmaskrplc $ARGHIRES ${DIR}${YEAR}${MON}${DAY}${TSUF} $LNDMSK eq 0 0 ${DIR}${YEAR}${MON}${DAY}${TSUF}
                DAY=`expr $DAY + 1`
            done
            # Clean up leftover .xyz files after each month
            rm ${DIR}*.xyz
        done
    done
done
