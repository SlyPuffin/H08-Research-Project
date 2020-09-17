#!/bin/bash
#source ~/.bashrc
#########################################################
# Created by: Daniel Voss, 2019-11-06
# Compute coefficients for each defined location
# Gather and process results into a spreadsheet
#########################################################
 
# Observation stations to process
DIRS=(tachino kunikane ooshima fuichiba itaba kamioda tatsuno kamigawara yamazakidaini funamachi magari juunisho kyouguchi tanigawa hirohara gunkoubashi mushuu ginbashi kamikema besshobashi manganji homare kamae furukawadaini nakama inagawabashi miyai minamitahara nishikumon higashikurisu fukuno)
# Years to process
YEARS="1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006"
# Months to process
MONTH="01 02 03 04 05 06 07 08 09 10 11 12"
# Resolutions to process
RESOLUTIONS="hyo 2nd hires"
 
# Start years for each observation station
declare -A startyear=(
[minamitahara]=1995
[mushuu]=1995
[ginbashi]=1995
[gunkoubashi]=1995
[inagawabashi]=1995
[kamikema]=1995
[funamachi]=1995
[itaba]=1995
[ooshima]=1995
[kunikane]=1995
[tanigawa]=1995
[furukawadaini]=2000
[manganji]=1995
[besshobashi]=1995
[magari]=1995
[yamazakidaini]=1995
[tatsuno]=1995
[kamigawara]=1995
[higashikurisu]=1995
[homare]=1995
[kamae]=1995
[nishikumon]=1995
[fukuno]=1995
[kyouguchi]=1995
[kamioda]=1995
[fuichiba]=1995
[tachino]=1995
[nakama]=1998
[juunisho]=1995
[hirohara]=1995
[miyai]=1995
)
# Year range for each observation station
declare -A yrange=(
[minamitahara]=12
[mushuu]=12
[ginbashi]=12
[gunkoubashi]=12
[inagawabashi]=12
[kamikema]=12
[funamachi]=10
[itaba]=10
[ooshima]=10
[kunikane]=10
[tanigawa]=10
[furukawadaini]=5
[manganji]=10
[besshobashi]=10
[magari]=10
[yamazakidaini]=10
[tatsuno]=10
[kamigawara]=10
[higashikurisu]=10
[homare]=10
[kamae]=10
[nishikumon]=10
[fukuno]=10
[kyouguchi]=12
[kamioda]=12
[fuichiba]=12
[tachino]=12
[nakama]=9
[juunisho]=12
[hirohara]=11
[miyai]=12
)
# Latitude value for each observation station
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
# Longitude value for each observation station
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
 
# Output file name
OUTPUT=./station_compilation.csv
# Spreadsheet header
echo "name,lat,lon,hyln,hyobmn,hysmmn,hyobmx,hysmmx,hymrsr,hydrsr,hymnse,hydnse,hympb,hydpb,2nln,2nobmn,2nsmmn,2nobmx,2nsmmx,2nmrsr,2ndrsr,2nmnse,2ndnse,2nmpb,2ndpb,hiln,hiobmn,hismmn,hiobmx,hismmx,himrsr,hidrsr,himnse,hidnse,himpb,hidpb" >> ${OUTPUT}
 
# Iterate over directories
for DIR in "${DIRS[@]}"; do
    echo ${DIR}
    # Write out station name, latitude, and longitude
    WRITE=`echo ${DIR},${lat[$DIR]},${lon[$DIR]}`
    echo ${startyear[$DIR]}
    echo ${yrange[$DIR]}
    # Iterate over each resolution
    for REZ in $RESOLUTIONS; do
    # Compute coefficients and write to file
        OUT=`python compute_coefficients_batch.py ./${DIR}/${DIR}_obs_ ./${DIR}/${DIR}_${REZ}_ ${startyear[$DIR]} ${yrange[$DIR]}`
        WRITE=`echo ${WRITE},${OUT}`
    done
    echo ${WRITE} >> ${OUTPUT}
done
