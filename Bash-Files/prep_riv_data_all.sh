#!/bin/bash
#source ~/.bashrc
#########################################################
# Created by: Daniel Voss, 2020-05-17
# Extract simulated river discharge data
# Store daily data as .txt files for each month
# over each observation station
#########################################################
 
# List of observation station names
DIRS=(inagawabashi kamikema funamachi ooshima kunikane tanigawa furukawadaini manganji besshobashi magari yamazakidaini tatsuno kamigawara higashikurisu homare kamae nishikumon fukuno kyouguchi kamioda fuichiba tachino nakama juunisho hirohara miyai)
# Years to process
YEARS="1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006"
# Months to process
MONTH="01 02 03 04 05 06 07 08 09 10 11 12"
 
# Latitude values for each observation station
declare -A lat=(
[minamitahara]=34.905833
[mushuu]=34.872778
[ginbashi]=34.854167
[gunkoubashi]=34.796667
[inagawabashi]=34.770278
[kamikema]=34.763333
[funamachi]=35.063056
[itaba]=34.964167
[ooshima]=34.8375
[kunikane]=34.800556
[tanigawa]=35.081667
[furukawadaini]=34.878889
[manganji]=34.856667
[besshobashi]=34.801944
[magari]=35.099722
[yamazakidaini]=34.996944
[tatsuno]=34.866111
[kamigawara]=34.804444
[higashikurisu]=34.921111
[homare]=34.853056
[kamae]=34.814444
[nishikumon]=35.207778
[fukuno]=35.171667
[kyouguchi]=35.337222
[kamioda]=35.418611
[fuichiba]=35.4825
[tachino]=35.543611
[nakama]=35.32
[juunisho]=35.371389
[hirohara]=35.463611
[miyai]=35.547778
)
# Longitude values for each observation station
declare -A lon=(
[minamitahara]=135.37
[mushuu]=135.395556
[ginbashi]=135.415278
[gunkoubashi]=135.4225
[inagawabashi]=135.434167
[kamikema]=135.438333
[funamachi]=135.008056
[itaba]=134.973056
[ooshima]=134.921111
[kunikane]=134.915
[tanigawa]=135.042222
[furukawadaini]=134.95
[manganji]=134.901389
[besshobashi]=134.951111
[magari]=134.583056
[yamazakidaini]=134.553056
[tatsuno]=134.548611
[kamigawara]=134.560556
[higashikurisu]=134.540278
[homare]=134.564722
[kamae]=134.556389
[nishikumon]=134.620278
[fukuno]=134.621111
[kyouguchi]=134.86
[kamioda]=134.789444
[fuichiba]=134.799167
[tachino]=134.828056
[nakama]=134.609722
[juunisho]=134.765
[hirohara]=134.868056
[miyai]=134.786389
)
 
# Iterate over each defined directory
for DIR in "${DIRS[@]}"; do
    # Clean any older files containing daily discharge data
    rm ./rivdata/${DIR}/${DIR}_hires_*
    # Calculate max value of discharge in surrounding area
    LV=`sh find_riv_data_hires.sh ${lon[$DIR]} ${lat[$DIR]} 1`
    LV=`echo $LV | awk '{printf("%s",$3)}'`
    echo ${DIR}
    # Iterate over years and months
    for YEAR in $YEARS; do
    for MON in $MONTH; do
        LISTNAME=./rivdata/${DIR}/${DIR}_hires_${YEAR}${MON}.txt
            DAY=1
            DAYMAX=`htcal $YEAR $MON`
        # Iterate over days in month
        while [ $DAY -le $DAYMAX ]; do
        # Write discharge to file for each day
        DAY=`echo $DAY | awk '{printf("%2.2d",$1)}'`
        OUT=`htpoint $ARGHIRES l /media/h08user/h08spillover/riv/out/riv_out_/WFDE10YR${YEAR}${MON}${DAY}.hir ${LV}`
        OUT=`echo $OUT | awk '{printf("%3.5f",($1 / 1000))}'`
        echo ${YEAR}${MON}${DAY},${OUT} >> ${LISTNAME}
        DAY=`expr $DAY + 1`
        done
    done
    done
done
