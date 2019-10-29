#!/bin/bash
#
# Tomas Bruna
# Generate data for Sn-Sp curve comparing IBA score computed
# with linear and box kernels

annot=$(dirname $0)/../../../annot/annot.gtf
pseudo=$(dirname $0)/../../../annot/pseudo.gff3
binFolder=$(dirname $0)/../../../../bin

grep -P "\t[Ii]ntron\t" $(dirname $0)/../prothint.gff > box.gff
grep -P "\t[Ii]ntron\t" $(dirname $0)/../../../family_excluded/prothint.gff > linear.gff

$binFolder/generateROC.sh box.gff $annot $pseudo box.csv 0.1 1 0.01 al_score
$binFolder/generateROC.sh linear.gff $annot $pseudo linear.csv 0.1 1 0.01 al_score

# Plot
gnuplot plotCurves.gp
