#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# This script generates sensitivity-specificity table
# for changing alignment score thresholds
#
# If no score is specified, 6th column is used by default
#
# Usage ./generateROC input_file.gff annot_introns.gff pseudo.gff out.csv min max increment [score]
# ==============================================================

increment=0.01

if [ $# -lt 6 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 input_file.gff annot_introns.gff pseudo.gff out.csv min max increment [score]"
    exit
fi


input=$1
annot=$2
pseudo=$3
output=$4
min=$5
max=$6
increment=$7
score=$8


echo -e "Threshold,Sensitivity,Specificity" > "$output"


prev=$(mktemp)
current=$(mktemp)

cp $input $prev

for i in $(LC_ALL=C seq $min $increment $max); do
    "$(dirname $0)/filter_gff.sh" $prev $i $score > $current
    if [[ $(wc -l $current | cut -f1 -d" ") -lt 50 ]]; then
        mv $current $prev
        break
    fi
    echo -en "$i" >> $output
    "$(dirname $0)/compare_intervals_exact.pl"\
    --f1 $2\
    --pseudo $pseudo\
    --f2 $current --intron --no | cut  -f 4 | tr "\n" "," | sed -e "s/,$/\n/" >> $output
    mv $current $prev
done

rm $prev
