#! /bin/bash
#
# Script genereer_live_data
#
# Genereert live data alsof een race lopende is.
#
# Author: Mikele Lemmens
#
set -o errexit
set -o nounset
set -o pipefail

# Zoek de id's van de meest recente race

liveRaceId=$(tail -1 ./csv_files/raw/races.csv | cut --fields=1 --delimiter=',')
liveSeasonId=$(tail -1 ./csv_files/raw/races.csv | cut --fields=2 --delimiter=',')
liveRoundId=$(tail -1 ./csv_files/raw/races.csv | cut --fields=3 --delimiter=',')

bash ./scripts/toon_rondetijd_alle_piloten.sh "$liveRaceId" "$liveSeasonId" "$liveRoundId"

if test -f ./csv_files/processed/liveTiming.csv
then
    rm ./csv_files/processed/liveTiming.csv
fi


if test -d "./csv_files/processed/live" 
then
	rm -r ./csv_files/processed/live
    
fi
mkdir ./csv_files/processed/live

# Om de id's van het huidige seizoen en ronde te kunnen gebruiken in main.sh heb ik deze waarden
# opgeslagen in een metafile

echo "${liveSeasonId},${liveRoundId}" > ./plots/livemeta.txt

# Iedere seconde wordt een regel uit de gesorteerde laptimes in de live timing gevoegd.
# Dit bootst een race na (alsof er om de seconde iemand de start/finish passeert).
# Iedere keer dat deze file wordt geüpdatete zorgt de binnenste loop ervoor dat de nieuwe rondetijd
# wordt bijgevoegd in de file van de juiste piloot

while read -r line
do  
  echo "$line" >> ./csv_files/processed/liveTiming.csv
  
  while read -r p; do
    awk --field-separator , --assign driverId="$p" '
      BEGIN { print "driver,lap,time" }
      {
          if($1 == driverId)
          {
              print $1","$2","$3

          }
      }' ./csv_files/processed/liveTiming.csv > ./csv_files/processed/live/"$liveSeasonId$liveRoundId$p".csv
  done < ./csv_files/processed/"$liveSeasonId"Drivers.csv
  
  sleep 1

done < ./csv_files/processed/"$liveSeasonId$liveRoundId"AllSorted.csv



