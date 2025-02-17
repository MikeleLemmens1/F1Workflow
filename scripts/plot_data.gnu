#! /usr/local/bin/gnuplot -persist
#
# Plot live rondetijden van een gekozen piloot voor een gekozen race in een .png
#
# Author: Mikele Lemmens
#
# Variables
# ARG1 is de piloot
# ARG2 is het seizoen
# ARG3 is de ronde

set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 1200, 800 
set output "./plots/".ARG2.ARG3.ARG1.".png"

set title "Rondetijden seizoen ".ARG2." ronde ".ARG3
set xlabel "Lap"
set ylabel "Tijd" 

set ydata time
set timefmt "%M:%S"
set format y "%M:%.3S"

set autoscale x
set autoscale y

set colorbox vertical origin screen 0.9, 0.2 size screen 0.05, 0.6 front  noinvert bdefault
set datafile separator ","

plot "./csv_files/processed/".ARG2.ARG3.ARG1.".csv" using 1:2 with lines title ARG1
print "Plot successful for ".ARG2.ARG3.ARG1