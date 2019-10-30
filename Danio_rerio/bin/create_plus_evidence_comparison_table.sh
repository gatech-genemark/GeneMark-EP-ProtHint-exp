#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create an accuracy table comparing GeneMark-EP+ results with
# different types of evidence
#
# This script needs to be run from species folder in which the results
# of EP+ with different evidences are already generated.
#
# This is a modification of the general script: Gene sensitivity
# is computed against the set of complete genes.
# ==============================================================


getGeneColumn() {
    prediction="$1/genemark.gtf"
    "$(dirname $0)/../../bin/compare_intervals_exact.pl" --f1 annot/completeGenes.gtf \
        --f2 $prediction --gene --pseudo annot/pseudo.gff3 | head -2 | tail -1 | cut -f4 | tr "\n" "/"
    "$(dirname $0)/../../bin/compare_intervals_exact.pl" --f1 annot/annot.gtf \
        --f2 $prediction --gene --pseudo annot/pseudo.gff3 | head -3 | tail -1 | cut -f4
}

getColumn() {
    header=$1
    prediction="$2/genemark.gtf"
    "$(dirname $0)/../../bin/compute_accuracies.sh" annot/annot.gtf \
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

# Handle genes separately

echo -en "-----------\tES\tEP\tEP+_introns\tES+_start_stops\tEP+\n"

table="Gene_Sn/Sp----"

appendColumn "$(getGeneColumn "ES")"
appendColumn "$(getGeneColumn "$prothintFolder/EP/train/")"
appendColumn "$(getGeneColumn "$prothintFolder/EP/plus_introns_only/")"
appendColumn "$(getGeneColumn "$prothintFolder/EP/plus_starts_stops_only/")"
appendColumn "$(getGeneColumn "$prothintFolder/EP/plus/")"

echo "$table"

# The rest is normal

types="cds initial internal terminal single intron start stop"

table=$(echo -e "Exon_Sn/Sp----\nInitial_Sn/Sp-\
\nInternal_Sn/Sp\nTerminal_Sn/Sp\nSingle_Sn/Sp--\nIntron_Sn/Sp--\nStart_Sn/Sp---\
\nStop_Sn/Sp----")

appendColumn "$(getColumn "ES" "ES")"
appendColumn "$(getColumn "EP" "$prothintFolder/EP/train/")"
appendColumn "$(getColumn "EP+_introns" "$prothintFolder/EP/plus_introns_only/")"
appendColumn "$(getColumn "ES+_start_stops" "$prothintFolder/EP/plus_starts_stops_only/")"
appendColumn "$(getColumn "EP+" "$prothintFolder/EP/plus/")"

echo "$table"
