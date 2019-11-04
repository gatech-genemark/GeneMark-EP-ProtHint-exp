#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Compute Sn/Sp of intron overlaps in a file against annotation
#
# ==============================================================

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 annot.gff introns.gff"
    exit
fi

annot=$1
hints=$2

true=$(mktemp)
"$(dirname $0)"/compare_intervals_exact.pl --f1 $annot \
    --f2 $hints --shared12 --intron --no --out $true --original 1 > /dev/null

annotOverlaps=$("$(dirname $0)"/computeOverlappingIntrons.sh $annot)
hintsOverlaps=$("$(dirname $0)"/computeOverlappingIntrons.sh $hints)
trueOverlaps=$("$(dirname $0)"/computeOverlappingIntrons.sh $true)
falseOverlaps=$(bc <<< "$hintsOverlaps - $trueOverlaps")

rm $true

sn=$(bc -l <<< "100 * $trueOverlaps / $annotOverlaps")
sp=$(bc -l <<< "100 * $trueOverlaps / $hintsOverlaps")


echo -e "Annot overlaps\t$annotOverlaps"
printf "Overlap Sn\t%.2f\t(%d TP)\nOverlap Sp\t%.2f\t(%d FP)\n" \
    $sn $trueOverlaps $sp $falseOverlaps
