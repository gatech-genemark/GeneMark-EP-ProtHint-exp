#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create a table with number of intron overlaps in prothint results
#
# This script needs to be run from species folder in which the results
# of ProtHint are already generated.
# ==============================================================


printOverlaps() {
    file=$1
    overlaps=$("$(dirname $0)"/computeOverlappingIntrons.sh $file)
    combinedIntrons=$(mktemp)
    introns=$(mktemp)
    grep "[Ii]ntron" $file | awk '{OFS="\t"} {$6="."; print}' > $introns
    "$(dirname $0)"/ProtHint/bin/combine_gff_records.pl --in_gff $introns --out_gff $combinedIntrons
    all=$(cat $combinedIntrons | wc -l)
    percent=$(bc -l <<< "($overlaps / $all) * 100")
    printf "%d / %d (%.2f%%)\n" $overlaps $all $percent
    rm $introns $combinedIntrons
}

getTrueColumn() {
    exclusion=$1
    hints=$2
    echo $(echo $exclusion | sed "s/_excluded//")
    true=$(mktemp)
    "$(dirname $0)"/compare_intervals_exact.pl --f1 annot/annot.gtf \
        --f2 $exclusion/$hints --shared12 --intron --no --out $true --original 1 > /dev/null
    printOverlaps $true
    rm $true
}

getColumn() {
    exclusion=$1
    hints=$2
    echo $(echo $exclusion | sed "s/_excluded//")
    printOverlaps $exclusion/$hints
}

annotColumn() {
    echo "Annotation"
    printOverlaps annot/annot.gtf
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
