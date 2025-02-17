#!/bin/bash
#
# Script toon_rondetijd_alle_piloten
# 
# Toont alle rondetijden van alle piloten voor 1 specifieke race
# ARGS: raceId season round
# 
# Author: Mikele Lemmens

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# Overbodige check van aantal argumenten indien oproep altijd via toon_rondetijden gebeurt

if [ "$#" -ne "3" ]; then
    echo "Expected 3 arguments, got $#" >> ./logs/main_logs.txt
    exit 2
fi

raceId=$1
season=$2
round=$3

# Maak een csv van alle laptimes voor alle piloten voor een race

awk --field-separator , --assign raceId="$raceId" '
    BEGIN { print "driver,lap,time" }
    {
    if($1 == raceId) 
    {
     print $2","$3","$5
      
    }
}' ./csv_files/raw/lap_times.csv | tr --delete '"' >  ./csv_files/processed/"$season$round"All.csv

# Genereer een csv per piloot om een grafiek van alle piloten te kunnen maken
# Sla al deze csv's op in een tijdelijke map. Oude data wordt verwijderd
# Doe dit enerzijds met de data uit de map temp met alle rondetijden (voor een eenmalige raceanalyse)
# Doe dit anderzijds met de livedata voor live analyse

if test -d "./csv_files/processed/temp" 
then
	rm --recursive ./csv_files/processed/temp
    
fi
mkdir ./csv_files/processed/temp

# Voorbereiding livedata: eerst sorteren op lap (col2 - numeriek) en dan op laptime (col3)
# Dit zorgt ervoor dat de tijden in racevolgorde staan
# De driverId's worden gefilterd om per driver een file te kunnen maken om vervolgens te plotten

sort --field-separator=',' --key=2n --key=3 ./csv_files/processed/"$season$round"All.csv > ./csv_files/processed/"$season$round"AllSorted.csv
cut --fields=1 --delimiter=',' ./csv_files/processed/"$season$round"AllSorted.csv | sort --numeric | uniq > ./csv_files/processed/"$season"Drivers.csv

while read -r p; do
  awk --field-separator , --assign driverId="$p" '
    BEGIN { print "driver,lap,time" }
    {
        if($1 == driverId)
        {
            print $1","$2","$3
            
        }
    }' ./csv_files/processed/"$season$round"All.csv > ./csv_files/processed/temp/"$season$round$p".csv
done < ./csv_files/processed/"$season"Drivers.csv

# Live analyse: gebruikt als input een file die in realtime wordt aangevuld
# Alle laptimes worden bijgehouden per piloot in de map csv_files/processed/live

if test -f ./csv_files/processed/temp/"$season$round"driver.csv
then
    rm ./csv_files/processed/temp/"$season$round"driver.csv
fi
cp --recursive ./plots /var/www/datalinux

