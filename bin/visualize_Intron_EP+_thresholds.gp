# Tomas Bruna
#
# Visualize EP+ results with introns filtered by different IBA
# thresholds

set datafile separator ','
set key outside bottom center
set key spacing 1.5
unset key
set xlabel "Specificity"
set ylabel "Sensitivity"

set mxtics 2
set mytics 2

set grid xtics ytics mxtics mytics lt 0 lw 1, lt rgb "#bbbbbb" lw 1


set term pdf
set style data lp

set output type.".pdf"

set size ratio -1

set xrange [x1:x2]
set yrange [y1:y2]

# Colors: http://colorbrewer2.org/#type=qualitative&scheme=Set1&n=7

t01c = "#984ea3"
t02c = "#377eb8"
t025c = "#e41a1c"
t03c = "#4daf4a"
t04c = "#ff7100"

t01s = 4
t02s = 10
t025s = 2
t03s = 6
t04s = 8

pointWidth = 3
pointSize = 1

plot "es.".type.".acc" using 2:1 title "Ep" w p pt 1 lw pointWidth ps pointSize + 0.2 lt rgb "black", \
     "ep.".type.".acc" using 2:1 title "Ep" w p pt 12 lw pointWidth ps pointSize lt rgb "black", \
     "0.1.".type.".acc" using 2:1 title "0.1" w p pt t01s lw pointWidth ps pointSize - 0.05 lt rgb t01c, \
     "0.2.".type.".acc" using 2:1 title "0.2" w p pt t02s lw pointWidth ps pointSize lt rgb t02c, \
     "0.3.".type.".acc" using 2:1  title "0.3" w p pt t03s lw pointWidth ps pointSize - 0.1 lt rgb t03c, \
     "0.4.".type.".acc" using 2:1 title "0.4" w p pt t04s lw pointWidth ps pointSize lt rgb t04c, \
     "0.25.".type.".acc" using 2:1 title "0.25" w p pt t025s lw pointWidth ps pointSize lt rgb t025c
