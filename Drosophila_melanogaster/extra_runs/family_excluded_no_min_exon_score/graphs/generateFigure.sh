#!/bin/bash
#
# Tomas Bruna
# Generate data for Sn-Sp curve showing effect of changing threshold for
# exon score and intron borders alignment score with raw Spaln output.

annot=$(dirname $0)/../../../annot/annot.gtf
pseudo=$(dirname $0)/../../../annot/pseudo.gff3
input=$(dirname $0)/introns.gff
binFolder=$(dirname $0)/../../../../bin

grep -P "\t[Ii]ntron\t" $(dirname $0)/../Spaln/spaln.gff > $input

# This script is terribly inefficient which is fine -- it is only used here
$(dirname $0)/generateROCForExons.sh $input $annot eScore.csv $pseudo

$binFolder/filter_gff.sh $input 25 LeScore > y
$binFolder/filter_gff.sh y 25 ReScore > eScore_25.gff

$binFolder/generateROC.sh eScore_25.gff $annot $pseudo eScore_25_al_score.csv 0 1 0.01 al_score
$binFolder/generateROC.sh $input $annot $pseudo al_score.csv 0 1 0.01 al_score

rm y

# Cut off tails with little data
head -51 al_score.csv > tmp; mv tmp al_score.csv
head -51 eScore_25_al_score.csv > tmp; mv tmp eScore_25_al_score.csv

# Create data for combined curve
cat <(head -11 eScore.csv) <(tail -n+2 eScore_25_al_score.csv) > tmp; mv tmp eScore_25_al_score.csv

# Plot
gnuplot plotCurves.gp
