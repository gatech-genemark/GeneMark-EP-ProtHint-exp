#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Get a set of annotated introns which are located within conserved domains
# ==============================================================

if [ $# -lt 2 ]; then
    echo "Usage: $0 annot_introns.gtf domains.gff"
    exit 1
fi

annot=$1
domains=$2

apprisIntrons=$(mktemp)
intersectOut=$(mktemp)
tmpOut=$(mktemp)
tmpOut2=$(mktemp)

grep -P "\t[Ii]ntron\t" $annot > $apprisIntrons
bedtools intersect -a $apprisIntrons -b $domains -s -wa -wb > $intersectOut

# Only count overlaps within the same gene -- this removes a few 
# overlaps caused by genes inside introns

"$(dirname $0)"/printMatchingIntrons.py $intersectOut > $tmpOut
"$(dirname $0)"/../../bin/ProtHint/bin/combine_gff_records.pl --in_gff $tmpOut --out_gff $tmpOut2
cat $tmpOut2

rm $apprisIntrons $intersectOut $tmpOut $tmpOut2
