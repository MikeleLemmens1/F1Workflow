#!/bin/bash
#
# Script refresh_data
#
# Ververst de rauwe data en maakt de mappenstructuur voor de rest van de pipeline aan
# De dataset wordt gedownload in de map die je kan instellen in outputPath
# Na het uitpakken krijgt je bron een timestamp
# De uitpaklocatie is hard gecodeerd (./csv_files/raw) - Deze bestanden worden niet gewijzigd
#
# Author: Mikele Lemmens

set -o errexit
set -o nounset
set -o pipefail

outputPath="./"
timestamp=$(date +%Y%m%d%H%M%S)


# Download de data als zipfile

if test -d ./csv_data.zip
then 
  rm --recursive ./csv_data.zip
fi

# -s negeert de progress meter

# curl -s ergast.com/downloads/f1db_csv.zip --output "./csv_data.zip"
curl -s ergast.com/downloads/f1db_csv.zip --output "${outputPath}csv_data.zip"


# Verwijder oude bestanden
# Pak de bestanden uit in de map ./csv_files/raw
# Maak een map aan voor de verwerkte datafiles (processed en plots)
# 

if test -d ./csv_files
then 
  rm --recursive ./csv_files
fi

if test -d "./plots" 
then
	rm --recursive ./plots
    
fi

mkdir ./plots
mkdir ./csv_files
mkdir ./logs

unzip "${outputPath}csv_data.zip" -d ./csv_files/raw >> ./logs/main_logs.txt
mkdir "./csv_files/processed"

# Plak een timestamp aan de zipfile

mv "${outputPath}csv_data.zip" "${outputPath}csv_data.zip${timestamp}"


# Test of de data goed zijn uitgepakt, log een eventuele foutmelding

cd ./csv_files/raw || echo "Fout bij het uitpakken van de files" >> ./logs/main_logs.txt


exit



