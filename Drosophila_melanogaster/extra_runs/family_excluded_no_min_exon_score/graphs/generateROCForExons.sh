#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# This script generates sensitivity-specificity table and curve
# for changing exon alignment score thresholds
#
# Usage ./generateROC input_file.gff annot_introns.gff out.csv pseudo.gff
# ==============================================================

if [ $# -lt 4 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 input_file.gff annot_introns.gff out.csv pseudo.gff"
    exit
fi

binFolder=$(dirname $0)/../../../../bin

echo -e "Threshold,Sensitivity,Specificity" > $3

min=-20
increment=5
max=250

# Generate csv file
temp=x
temp2=y
for i in `LC_ALL=C seq $min $increment $max`; do
    $binFolder/filter_gff.sh $1 $i "LeScore"> $temp
    $binFolder/filter_gff.sh $temp $i "ReScore"> $temp2
    if [[ $(wc -l $temp2 | cut -f1 -d" ") -lt 50 ]]; then
        break
    fi
    echo -en "$i" >> $3
    $binFolder/compare_intervals_exact.pl\
    --f1 $2\
    --pseudo $4\
    --f2 $temp2 --intron --no | cut  -f 4 | tr "\n" "," | sed -e "s/,$/\n/" >> $3
done
rm $temp
rm $temp2
