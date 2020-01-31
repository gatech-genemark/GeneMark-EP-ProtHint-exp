#!/usr/bin/env gnuplot
#
# Tomas Bruna

set datafile separator ','
unset key
set xlabel "Specificity"
set ylabel "Sensitivity"

#set mxtics 2
#set mytics 2

#set grid xtics ytics mxtics mytics lt 0 lw 1, lt rgb "#bbbbbb" lw 1

set term pdf
set output "curves.pdf"

set xtics 0,10,100
set ytics 0,10,100
set mxtics 2
set mytics 2

set xrange [0:100]
set yrange [0:100]

set style data l
set size ratio -1

width = 2

plot "eScore_25_al_score.csv" using 3:2 lw width lt rgb 'red', \
     "eScore.csv" using 3:2 dt 2 lw width lt rgb '#ff7100', \
     "al_score.csv" using 3:2 dt 2 lw width lt rgb '#812581', \
     "eScore_25_al_score.csv" using 3:($1 == 0.1 ? $2 : 1/0) title "" w p pt 2 lw 3 ps 0.75 lt rgb "black", \
     "eScore_25_al_score.csv" using 3:($1 == 25 ? $2 : 1/0) title "" w p pt 6 lw 3 ps 0.7 lt rgb "black"
