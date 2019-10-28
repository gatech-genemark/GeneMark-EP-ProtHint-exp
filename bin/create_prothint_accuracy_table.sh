#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table for ProtHint results on different
# levels of exclusion
#
# This script needs to be run from species folder in which the results
# of ProtHint are already generated.
# ==============================================================


getColumn() {
    exclusion=$1
    echo -en "$(echo $exclusion | sed "s/_excluded//")\t.\n"
    "$(dirname $0)/prothint_accuracy.sh" annot/annot.gtf annot/pseudo.gff3 $exclusion | \
        cut -f2,3
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

table=$(echo -e "---------\n---------\nIntron_Sn\nIntron_Sp\nStart_Sn\
-\nStart_Sp-\nStop_Sn--\nStop_Sp--")

levels=($(ls -d ./*_excluded | tr -d ./))

for level in "${levels[@]}"; do
    appendColumn "$(getColumn "$level")"
done

echo "$table"
