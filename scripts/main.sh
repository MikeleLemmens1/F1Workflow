#!/bin/bash
#
# Script Analyseer F1-data
#
# Toont de laptimes van 1 piloot voor een gegeven race
# Toont de laptimes van alle piloten voor een gegeven race
# Haalt live data op en analyseert deze voor een lopende race
# 
# Author: Mikele Lemmens

set -o errexit
set -o nounset
set -o pipefail

piloot="Alonso"
seizoen=2011
ronde=5

# 1. Haal de meest recente data op uit de API
#    Wacht 5 seconden om genoeg tijd te geven aan het downloaden en uitpakken

bash ./scripts/refresh_data.sh

sleep 5

# 2. Toon de laptimes voor een gewenste piloot voor een gewenste race

bash ./scripts/toon_rondetijden.sh $piloot $seizoen $ronde

sleep 2

# 3. Toon de laptimes van alle piloten voor een gegeven race
#    Hierin kan je kiezen tussen het vorige script met een optie, of toon_rondetijd_alle_piloten met het raceId als ARG1

bash ./scripts/toon_rondetijden.sh -a $seizoen $ronde

sleep 2

# 4. Beschouw de laatste race als gaande (dus de race met het hoogste id). 
#    Deze info heb ik gekopieerd in livemeta.txt.
#    liveTiming.csv wordt iedere seconde ververst om te imiteren dat er een laptime wordt geregistreerd telkens een driver
#    over de streep komt. 

bash ./scripts/genereer_live_data.sh &

cat << _EOF_



##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##

"AND IT'S LIGHTS OUT AND AWAY WE GO"

##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##



_EOF_

# Eventjes wachten tot er al enkele piloten hun eerste ronde hebben afgewerkt

sleep 25

seizoen=$(cut --fields=1 --delimiter=',' ./plots/livemeta.txt)
ronde=$(cut --fields=2 --delimiter=',' ./plots/livemeta.txt)

# De counter heeft weinig betekenis, deze kan je instellen ifv hoe lang het analyseren moet duren.
# Iedere 5 seconden wordt een plot gemaakt van alle .csv's die worden gemaakt door het script 'genereer_live_data'
# Alle plots worden meteen gekopieerd naar mijn webroot zodat mijn website de grafiek kan tonen

teller=0
while [ "$teller" -lt 100 ]
do
   gnuplot -c ./scripts/plot_data_live.gnu "$seizoen" "$ronde"
   cp --recursive ./plots /var/www/datalinux
   sleep 5
   teller=$((teller + 1))
done
