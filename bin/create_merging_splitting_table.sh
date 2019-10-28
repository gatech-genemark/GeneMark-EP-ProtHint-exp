#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create a table with numbers of merged and split genes for results
# of ES,EP and EP+
#
# This script needs to be run from species folder in which the results
# of ES/EP/EP+ are already generated.
# ==============================================================

getSplitsMerges() {
    name=$1
    prediction="$2/genemark.gtf"
    echo "$name"
    "$(dirname $0)/count_merging_splitting.py" --annot annot/annot.gtf \
        --pred "$prediction" --splitIntrons "$maxIntronLen" --splitTranscript | \
        grep -P "split genes|merged genes" | grep -o -P "[0-9]+" | tac
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 prothint_folder max_intron_len"
    exit
fi

prothintFolder="$1"
maxIntronLen="$2"

echo $prothintFolder

table="$(echo -en "mode\nmerged\nsplit")"

appendColumn "$(getSplitsMerges "ES" "ES")"
appendColumn "$(getSplitsMerges "EP" "$prothintFolder/EP/train/")"
appendColumn "$(getSplitsMerges "EP+_introns" "$prothintFolder/EP/plus_introns_only/")"
appendColumn "$(getSplitsMerges "ES+_start_stops" "$prothintFolder/EP/plus_starts_stops_only/")"
appendColumn "$(getSplitsMerges "EP+" "$prothintFolder/EP/plus/")"

echo "$table"
