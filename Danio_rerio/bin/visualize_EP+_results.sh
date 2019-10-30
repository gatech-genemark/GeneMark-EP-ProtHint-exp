#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Interface for visualizign EP+ results on different taxonomical distances
#
# If a file with accuracy is already found in EP_visualization folder,
# accuracy is not recomputed, only visualization is refreshed.
#
# This is a D. rerio specific version which computes gene level
# Sn against a set of complete genes only.
# ==============================================================

#rootFolder=EP_plus_results_visualization
FOLDERS=(species_excluded subgenus_excluded genus_excluded   \
      family_excluded order_excluded phylum_excluded)
VALID_TYPES=(cds start stop initial internal terminal single multi gene singlegene multigene intron)
ES=ES
PSEUDO=annot/pseudo.gff3

if [ "$#" -eq 4 ]; then
    x1=0
    x2=100
    y1=0
    y2=100
elif [ ! "$#" -eq 8 ]; then
    echo "Usage: $0 annot.gtf completeGenes.gtf outputFolder type [xmin xmax ymin ymax]"
    echo -n "Valid types are: "
    echo "${VALID_TYPES[*]}"
    exit
else
    x1=$5
    x2=$6
    y1=$7
    y2=$8
fi

binFolder=$(readlink -e "$(dirname $0)/../../bin")
ANNOT="$1"
COMPLETE_ANNOT="$2"
rootFolder="$3"
type="$4"


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
            $binFolder/compare_intervals_exact.pl --$comparisonFlags --f1 $COMPLETE_ANNOT --f2 $folder/EP/plus/genemark.gtf --pseudo $PSEUDO |\
                head -2 | tail -1 | cut -f4 | tr "\n" "," > $rootFolder/$folder.${type}.acc
            $binFolder/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $folder/EP/plus/genemark.gtf --pseudo $PSEUDO |\
                head -3 | tail -1 | cut -f4 >> $rootFolder/$folder.${type}.acc
        fi
    fi
}

for folder in "${FOLDERS[@]}"
do
    getAcc "$folder"
done

if [ ! -f "$rootFolder/es.${type}.acc" ]; then
    $binFolder/compare_intervals_exact.pl --$comparisonFlags --f1 $COMPLETE_ANNOT --f2 $ES/genemark.gtf --pseudo $PSEUDO |\
        head -2 | tail -1 | cut -f4 | tr "\n" "," > $rootFolder/es.${type}.acc
    $binFolder/compare_intervals_exact.pl --$comparisonFlags --f1 $ANNOT --f2 $ES/genemark.gtf --pseudo $PSEUDO |\
        head -3 | tail -1 | cut -f4 >> $rootFolder/es.${type}.acc
fi

cd $rootFolder

gnuplot -e "species='$title';type='$type';x1='$x1';x2='$x2';y1='$y1';y2='$y2';" $binFolder/visualize_EP+_results.gp

convert -transparent white -density 600 ${type}.pdf -quality 100 ${type}.png
