#!/usr/bin/env bash
#
# Tomas Bruna
# Generate scatter plots and Sn-Sp curves for ProtHint introns

introns=$(dirname $0)/introns.gff
introns_4=$(dirname $0)/introns_cov_4.gff
annot=$(dirname $0)/../../annot/annot.gtf
pseudo=$(dirname $0)/../../annot/pseudo.gff3
binFolder=$(dirname $0)/../../../bin

# Data Generation

# Generate Sn-Sp curves and scatterplots only for canonical gt-ag introns because high-confidence
# intron set only contains gt-ag introns (it is one of the filtering criteria)
grep -P "\t[Ii]ntron\t" $(dirname $0)/../prothint.gff | grep gt_ag > $introns

$binFolder/generateROC.sh $introns $annot $pseudo $(dirname $0)/coverage.csv 1 100 1
$binFolder/generateROC.sh $introns $annot $pseudo $(dirname $0)/al_score.csv 0.1 1 0.01 al_score

$binFolder/filter_gff.sh $introns 4 > $introns_4
$binFolder/generateROC.sh $introns_4 $annot $pseudo $(dirname $0)/coverage_4_al_score.csv 0.1 1 0.01 al_score

# Combine scores
cat <(head -5 coverage.csv) <(tail -n+2 coverage_4_al_score.csv) > tmp; mv tmp coverage_4_al_score.csv

# Sn-Sp Curves
gnuplot plotCurves.gp

# Scatter Plot
$binFolder/visualize_prothint.py  $introns \
    $(dirname $0)/../../annot/annot.gtf $(dirname $0)/scatter.png \
    --opacity 0.045 --ylim 25 --trueFirst --dpi 600
