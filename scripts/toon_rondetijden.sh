#!/bin/bash
#
# Script: Toon_rondetijden
# 
# Toont alle rondetijden van 1 piloot voor een gekozen race
# ARGS: {OPTION|driver} season round
# Indien de optie -a wordt meegegeven ipv de piloot worden alle piloten getoond
#
# Author: Mikele Lemmens

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#
# Variables
#

driver=$1;
season=$2;
round=$3;

#
# Option
#

optie=

if [ "$1" == "-a" ]; then
    getopts "a" optie
fi

if [ "$#" -ne "3" ]; then
    echo "Expected 3 arguments, got $#" >> ./logs/main_logs.txt
    exit 2
fi

# Zoek naar de juiste ID's in races.csv om laptimes te filteren
# Een gebruiker definieert een race adhv het seizoen en rondenummer (bv. 2011 5)
# Een piloot wordt gedefinieerd door door de achternaam (bv. "Alonso")

raceId=$(awk --field-separator , --assign year="$season" --assign round="$round" '{
    if($2 == year && $3 == round)
    {
        print $1
    }
}' ./csv_files/raw/races.csv)

# Vul een lege string in als de driver niet wordt gevonden
# Vermijd zoeken als '-a' is meegegeven als optie

driverId=""

if [ "$driver" != "-a" ]; then
    driverId=$(< './csv_files/raw/drivers.csv' grep "$driver" | cut --fields=1 --delimiter=',' || echo "")
fi

# Roept ander script op als je alle piloten wil krijgen (bij invoer optie -a seizoen ronde)
# GNUPlot geeft een melding wanneer het plotten geslaagd is, maar ik krijg deze niet in de logs

if [ "$optie" = "a" ]; then
    bash ./scripts/toon_rondetijd_alle_piloten.sh "$raceId" "$season" "$round"
    gnuplot -c ./scripts/plot_data_all.gnu "$season" "$round"
    exit 
fi

# ERROR handling: wanneer foute invoer wordt meegegeven stopt het programma en worden fouten gelogd

test -z "$raceId" && echo "Fout bij het opzoeken van de race" >> ./logs/main_logs.txt && exit
test -z "$driverId" && echo "Fout bij het opzoeken van de driver" >> ./logs/main_logs.txt && exit

# Schrijf een overzicht van de query in de logs, STDOUT mag niet worden getoond

tee --append ./logs/main_logs.txt >/dev/null << _EOF_ 
driver = $driver
driverId = $driverId
season = $season
round = $round
raceId = $raceId
_EOF_


# Maak een csv van de rondetijden van de gewenste piloot voor de gewenste race

awk --field-separator , --assign driverId="$driverId" --assign raceId="$raceId" '
    BEGIN { print "lap,time" }
    {
    if($2 == driverId && $1 == raceId) 
    {
     print $3","$5
      
    }
}' ./csv_files/raw/lap_times.csv | tr --delete '"' >  ./csv_files/processed/"$season$round$driver".csv

# Plot de laptimes naar een png-file
# Ook deze functie geeft een melding weer dat ik niet naar de logs krijg

gnuplot -c ./scripts/plot_data.gnu "$driver" "$season" "$round"

# Kopieer de plots naar de webroot

cp --recursive ./plots /var/www/datalinux

exit
