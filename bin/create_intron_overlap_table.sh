#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table for ProtHint results on different
# levels of exclusion
#
# This script needs to be run from species folder in which the results
# of ProtHint are already generated.
# ==============================================================

getTrueColumn() {
    exclusion=$1
    hints=$2
    echo $(echo $exclusion | sed "s/_excluded//")
    true=$(mktemp)
    "$(dirname $0)"/compare_intervals_exact.pl --f1 annot/annot.gtf \
        --f2 $exclusion/$hints --shared12 --intron --no --out $true --original 1 > /dev/null
    "$(dirname $0)"/computeOverlappingIntrons.sh $true
    rm $true
}

getColumn() {
    exclusion=$1
    hints=$2
    echo $(echo $exclusion | sed "s/_excluded//")
    "$(dirname $0)"/computeOverlappingIntrons.sh $exclusion/$hints
}

annotColumn() {
    echo "Annotation"
    "$(dirname $0)"/computeOverlappingIntrons.sh annot/annot.gtf
}


appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

levels=($(ls -d ./*_excluded | tr -d ./))

makeTable() {
    hints=$1
    table=""
    echo "All"
    appendColumn "$(annotColumn)"

    for level in "${levels[@]}"; do
        appendColumn "$(getColumn "$level" $hints)"
    done

    echo "$table"

    table=""
    echo "TP Only"
    appendColumn "$(annotColumn)"

    for level in "${levels[@]}"; do
        appendColumn "$(getTrueColumn "$level" $hints)"
    done

    echo "$table"

}


echo "High-Confidence overlapping introns"

makeTable evidence.gff

echo "All reported overlapping introns"

makeTable prothint.gff
