#! /usr/local/bin/gnuplot -persist
#
# Plot alle rondetijden van alle piloten voor een gekozen race in een .png
#
# Author: Mikele Lemmens
#
# Variables
# ARG1 is het seizoen
# ARG2 is de ronde

set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 1200, 800 
set output "./plots/".ARG1.ARG2."All.png"


set title "Rondetijden seizoen ".ARG1." ronde ".ARG2
set xlabel "Lap"
set ylabel "Tijd" 

set ydata time
set timefmt "%M:%S"
set format y "%M:%.3S"

set autoscale x
set autoscale y

set colorbox vertical origin screen 0.9, 0.2 size screen 0.05, 0.6 front  noinvert bdefault
set datafile separator ","


plot for [file in system("find ./csv_files/processed/temp -name \\*.csv")] file using 2:3 notitle with lines

print "Plot successful for ".ARG1.ARG2
