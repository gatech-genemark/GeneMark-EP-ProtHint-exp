#!/usr/bin/env bash
#
# Tomas Bruna
# Create a combined Sn-Sp curve for ProtHint introns
# The curve combined IMC score and IBA score. First, IMC
# curve is plotted and at IMC=4, the curve switches to IBA


if [ $# -lt 3 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 annot.gtf pseudo.gff3 prothint.gff"
    exit
fi

introns=introns.gff
introns_4=introns_cov_4.gff
annot=$1
pseudo=$2
prothint=$3
binFolder=$(readlink -e $(dirname $0))

# Data Generation

grep -P "\t[Ii]ntron\t" $3 | grep gt_ag > $introns

$binFolder/generateROC.sh $introns $annot $pseudo coverage.csv 1 4 1

$binFolder/filter_gff.sh $introns 4 > $introns_4
$binFolder/generateROC.sh $introns_4 $annot $pseudo coverage_4_al_score.csv 0.1 1 0.01 al_score

# Combine scores

cat <(cat coverage.csv) <(tail -n+2 coverage_4_al_score.csv) > tmp; mv tmp combined.csv
