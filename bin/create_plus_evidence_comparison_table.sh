#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table comparing GeneMark-EP+ results with
# different types of evidence
#
# This script needs to be run from species folder in which the results
# of EP+ with different evidences are already generated.
# ==============================================================


getColumn() {
    header=$1
    prediction="$2/genemark.gtf"
    echo "$header"
    "$(dirname $0)/compute_accuracies.sh" annot/annot.gtf \
        annot/pseudo.gff3 "$prediction" $types | cut -f2 | \
        awk '{if (NR%2 == 1) {printf "%.2f/", $0} else {printf "%.2f\n", $0}}'
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 prothint_folder"
    exit
fi

prothintFolder="$1"

echo $prothintFolder

types="gene cds initial internal terminal single intron start stop"


table=$(echo -e "-----------\nGene_Sn/Sp----\nExon_Sn/Sp----\nInitial_Sn/Sp-\
\nInternal_Sn/Sp\nTerminal_Sn/Sp\nSingle_Sn/Sp--\nIntron_Sn/Sp--\nStart_Sn/Sp---\
\nStop_Sn/Sp----")

appendColumn "$(getColumn "ES" "ES")"
appendColumn "$(getColumn "EP" "$prothintFolder/EP/train/")"
appendColumn "$(getColumn "EP+_introns" "$prothintFolder/EP/plus_introns_only/")"
appendColumn "$(getColumn "ES+_start_stops" "$prothintFolder/EP/plus_starts_stops_only/")"
appendColumn "$(getColumn "EP+" "$prothintFolder/EP/plus/")"

echo "$table"
