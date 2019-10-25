#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Interface for visualizign EP+ results with different intron IBA
# thresholds
#
# If a file with accuracy is already found in visualization folder,
# accuracy is not recomputed, only visualization is refreshed.
#
# This script should be run from species/X_excluded/EP folder in which
# folder intron_plus_thresholds is already present
# ==============================================================

rootFolder=visualization
FOLDERS=(0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5)
VALID_TYPES=(cds start stop initial internal terminal single multi gene singlegene multigene intron)
ES=../../../ES
ANNOT=../../../annot/annot.gtf
PSEUDO=../../../annot/pseudo.gff3

if [ "$#" -eq 1 ]; then
    x1=0
    x2=100
    y1=0
    y2=100
elif [ ! "$#" -eq 5 ]; then
    echo "Usage: $0 type [xmin xmax ymin ymax]"
    echo -n "Valid types are: "
    echo "${VALID_TYPES[*]}"
    exit
else
    x1=$2
    x2=$3
    y1=$4
    y2=$5
fi

binFolder=$(readlink -e $(dirname $0))
type="$1"
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
        if [ -f "$folder/genemark.gtf" ]; then
            $(dirname $0)/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $folder/genemark.gtf --pseudo $PSEUDO |\
            cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/$folder.${type}.acc
        fi
    fi
}

for folder in "${FOLDERS[@]}"
do
    getAcc "$folder"
done

if [ ! -f "$rootFolder/ep.${type}.acc" ]; then
    $(dirname $0)/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 ../train/genemark.gtf --pseudo $PSEUDO |\
    cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/ep.${type}.acc
fi

if [ ! -f "$rootFolder/es.${type}.acc" ]; then
    $(dirname $0)/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $ES/genemark.gtf --pseudo $PSEUDO |\
    cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/es.${type}.acc
fi

cd $rootFolder

gnuplot -e "species='$title';type='$type';x1='$x1';x2='$x2';y1='$y1';y2='$y2';" $binFolder/visualize_Intron_EP+_thresholds.gp

convert -transparent white -density 600 ${type}.pdf -quality 100 ${type}.png

cd ..