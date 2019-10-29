#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table for ES, EP and EP+ results on different
# levels of exclusion
#
# This script needs to be run from a species folder in which the results
# of ES/EP/EP+ are already generated.
# ==============================================================

getColumn() {
    header1=$1
    header2=$2
    prediction=$3
    echo "$header1"
    echo "$header2"
    "$(dirname $0)/compute_accuracies.sh" annot/annot.gtf \
        annot/pseudo.gff3 "$prediction" $types | cut -f2
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

exclusionLevel() {
    exclusion=$1
    header=$(echo -n $exclusion | sed "s/_excluded//")
    appendColumn "$(getColumn $header EP $exclusion/EP/train/genemark.gtf)"
    appendColumn "$(getColumn $header EP+ $exclusion/EP/plus/genemark.gtf)"
}

types="gene cds intron"

table=$(echo -e "---------\n---------\nGene_Sn--\nGene_Sp--\nExon_Sn--\
\nExon_Sp--\nIntron_Sn\nIntron_Sp")

appendColumn "$(getColumn none ES ES/genemark.gtf)"

levels=($(ls -d ./*_excluded | tr -d ./))

for level in "${levels[@]}"; do
    exclusionLevel $level
done

echo "$table"