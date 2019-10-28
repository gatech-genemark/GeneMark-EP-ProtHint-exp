#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table for ES, EP and EP+ results on different
# levels of exclusion
#
# The script needs to be run from a species folder
# ==============================================================

getColumn() {
    header=$1
    prediction="$2"
    echo "$header"
    "$(dirname $0)/compute_accuracies.sh" annot/annot.gtf \
        annot/pseudo.gff3 "$prediction" start | cut -f2
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

smc_4=$(mktemp)
"$(dirname $0)"/ProtHint/bin/print_high_confidence.py --startCoverage 4 \
    --startOverlap 99999 "$prothintFolder/prothint.gff" > "$smc_4"

echo $prothintFolder
table=$(echo -e "--------\nStart_Sn\nStart_Sp")

appendColumn "$(getColumn "All_reported" "$prothintFolder/prothint.gff")"
appendColumn "$(getColumn "SMC>4" "$smc_4")"
appendColumn "$(getColumn "SMC>4;Overlap=0" "$prothintFolder/evidence.gff")"

rm "$smc_4"

echo "$table"
