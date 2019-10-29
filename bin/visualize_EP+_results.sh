#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Interface for visualizign EP+ results on different taxonomical distances
#
# If a file with accuracy is already found in EP_visualization folder,
# accuracy is not recomputed, only visualization is refreshed.
# ==============================================================

#rootFolder=EP_plus_results_visualization
FOLDERS=(species_excluded subgenus_excluded genus_excluded   \
      family_excluded order_excluded phylum_excluded)
VALID_TYPES=(cds start stop initial internal terminal single multi gene singlegene multigene intron)
ES=ES
PSEUDO=annot/pseudo.gff3

if [ "$#" -eq 3 ]; then
    x1=0
    x2=100
    y1=0
    y2=100
elif [ ! "$#" -eq 7 ]; then
    echo "Usage: $0 annot.gtf outputFolder type [xmin xmax ymin ymax]"
    echo -n "Valid types are: "
    echo "${VALID_TYPES[*]}"
    exit
else
    x1=$4
    x2=$5
    y1=$6
    y2=$7
fi

binFolder=$(readlink -e $(dirname $0))
ANNOT="$1"
rootFolder="$2"
type="$3"

found=0
for validType in "${VALID_TYPES[@]}"
do
    if [ $type == $validType ]; then
        found=1
    fi
done

if [ $found -eq 0 ]; then
    echo -n "Type $type is not valid. Valid types are: "
    echo "${VALID_TYPES[*]}"
    exit 1
fi

title=$(basename "$(pwd)" | tr _ " ")
mkdir $rootFolder 2>/dev/null

echo "$0 $type $x1 $x2 $y1 $y2" > $rootFolder/${type}.args

comparisonFlags=""
if [ $type == "start" ] || [ $type == "stop" ] || [ $type == "intron" ]; then
    comparisonFlags="$type --no"
else
    comparisonFlags=$type
fi


getAcc() {
    folder=$1
    if [ ! -f "$rootFolder/$folder.${type}.acc" ]; then
        if [ -f "$folder/EP/plus/genemark.gtf" ]; then
            $(dirname $0)/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $folder/EP/plus/genemark.gtf --pseudo $PSEUDO |\
            cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/$folder.${type}.acc
        fi
    fi
}

for folder in "${FOLDERS[@]}"
do
    getAcc "$folder"
done

if [ ! -f "$rootFolder/es.${type}.acc" ]; then
    $(dirname $0)/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $ES/genemark.gtf --pseudo $PSEUDO |\
    cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/es.${type}.acc
fi

cd $rootFolder

gnuplot -e "species='$title';type='$type';x1='$x1';x2='$x2';y1='$y1';y2='$y2';" $binFolder/visualize_EP+_results.gp

convert -transparent white -density 600 ${type}.pdf -quality 100 ${type}.png
