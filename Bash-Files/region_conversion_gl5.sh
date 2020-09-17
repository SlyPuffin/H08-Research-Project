#!/bin/sh
#source ~/.bashrc
##############################################
# Modified from H08 base files by Daniel Voss
##############################################
 
# Target directories
DIRS="../dat/pop_tot_/C05_a___20000000 ../dat/nat_msk_/C05_____20000000 ../dat/wit_agr_/AQUASTAT20000000 ../dat/wit_ind_/AQUASTAT20000000 ../dat/wit_dom_/AQUASTAT20000000"
# Latitude and Longitude Range
RFLAG=134.004166/135.995833/34.0041664/35.9958332
# Target cell size (degrees)
IFLAG=0.008333/0.008333
# Input resolution extension
SUF=.gl5
# Target resolution extension
TSUF=.hyo
# Target resolution land mask file
LNDMSK=../../map/dat/lnd_msk_/lndmsk.GIS.hyo
 
echo $ARGHYO $ARGGL5
for DIR in $DIRS; do
    echo ${DIR}
    # Convert binary file to .xyz ascii3 file
    htmaskrplc $ARGGL5 ${DIR}${SUF} ../../map/dat/lnd_msk_/lndmsk.C05.gl5 eq 0 NaN ./temp.hlf
    htmaskrplc $ARGGL5 ./temp.hlf ./temp.hlf eq 1.00000002E+20 NaN ./temp.hlf
    htlinear $ARGGL5 $ARGHYO ./temp.hlf ./temp.hyo
    htformat $ARGHYO binary ascii3 ./temp.hyo ./temp.xyz
    # Convert ascii file resolution to target resolution
    gmt xyz2grd ./temp.xyz -R$RFLAG -I$IFLAG -G./grd -r
    gmt surface ./temp.xyz -R$RFLAG -I$IFLAG -G./grd -T0 -Ll0
    gmt grd2xyz grd > ${DIR}.xyz
    # Convert ascii file back to H08 binary format
    htformat $ARGHYO ascii3 binary ${DIR}.xyz  ${DIR}.hyo
    htmask $ARGHYO ${DIR}.hyo $LNDMSK eq 1 ${DIR}.hyo    
done
