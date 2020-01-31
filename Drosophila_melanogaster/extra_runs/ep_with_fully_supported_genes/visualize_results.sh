#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Interface for visualizign EP+ results with different sets of HC
# introns
#
# ==============================================================

rootFolder=visualization
FOLDERS=(ep_full_genes ep_all  ep_all_true)
VALID_TYPES=(cds start stop initial internal terminal single multi gene singlegene multigene intron)
ES=../../ES
ANNOT=../../annot/annot.gtf
PSEUDO=../../annot/pseudo.gff3

if [ "$#" -eq 2 ]; then
    x1=0
    x2=100
    y1=0
    y2=100
elif [ ! "$#" -eq 6 ]; then
    echo "Usage: $0 type exclusion_folder [xmin xmax ymin ymax]"
    echo -n "Valid types are: "
    echo "${VALID_TYPES[*]}"
    exit
else
    x1=$3
    x2=$4
    y1=$5
    y2=$6
fi

binFolder=$(readlink -e $(dirname $0))
type="$1"
exclusionFolder="$2"
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
    if [ ! -f "$rootFolder/$exclusionFolder.$folder.${type}.acc" ]; then
        if [ -f "$exclusionFolder/$folder/genemark.gtf" ]; then
            ../../../bin/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $exclusionFolder/$folder/genemark.gtf --pseudo $PSEUDO |\
            cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/$exclusionFolder.$folder.${type}.acc
        fi
    fi
}

for folder in "${FOLDERS[@]}"
do
    getAcc "$folder"
done

if [ ! -f "$rootFolder/es.${type}.acc" ]; then
    ../../../bin/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $ES/genemark.gtf --pseudo $PSEUDO |\
    cut -f4 | tail -3 |  tr "\n" "," | sed -e "s/,$/\n/" > $rootFolder/es.${type}.acc
fi

cd $rootFolder

gnuplot -e "species='$title';excl='$exclusionFolder';type='$type';x1='$x1';x2='$x2';y1='$y1';y2='$y2';" $binFolder/visualize_results.gp

convert -transparent white -density 600 $exclusionFolder.${type}.pdf -quality 100 $exclusionFolder.${type}.png

cd ..
