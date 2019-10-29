# Tomas Bruna
#
# Plot IBA Sn-Sp curves

set datafile separator ','
unset key
set xlabel "Specificity"
set ylabel "Sensitivity"

set term pdf
set output "curves.pdf"

set mxtics 2
set mytics 2

set grid xtics ytics mxtics mytics lt 0 lw 1, lt rgb "#bbbbbb" lw 1

set xrange [80:95]
set yrange [45:65]

set xtics 0,5,100
set ytics 0,5,100
set mxtics 2
set mytics 2
set style data l
set size ratio -1

width=2
pointSize=0.9

plot "box.csv" using 3:2 lw width lt rgb '#f89441', \
     "linear.csv" using 3:2 lw width lt rgb "#0072bd", \
     "linear.csv" using 3:($1 == 0.25 ? $2 : 1/0) title "" w p pt 1 lw 3 ps pointSize lt rgb "black", \
     "box.csv" using 3:($1 == 0.25 ? $2 : 1/0) title "" w p pt 1 lw 3 ps pointSize lt rgb "black"
