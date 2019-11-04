#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Compute how many introns overlap in a gff file
# ==============================================================

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 features.gff"
    exit
fi

features="$1"

findMax() {
     awk 'BEGIN {max = 0} {if ($5 > max) max = $5} END {print max}' < $features
}

prepareGenomeFile() {
    chroms="$(grep ">" $genome | tr -d ">")"
    chromNum=$(echo "$chroms" | wc -l)
    max=$(findMax)
    paste <(echo "$chroms") <(yes "1" | head -n $chromNum) \
        <(yes "$max" | head -n $chromNum) > $genomeFile
}

introns=$(mktemp)

grep "[Ii]ntron" $features | awk '{OFS="\t"} {$6="."; print}' > $introns

combinedIntrons=$(mktemp)

"$(dirname $0)"/ProtHint/bin/combine_gff_records.pl --in_gff $introns --out_gff $combinedIntrons

all=$(cat $combinedIntrons | wc -l)
merged=$(bedtools merge -s -i $combinedIntrons  | wc -l)
overlapping=$(bc <<< "$all-$merged")

percent=$(bc -l <<< "($overlapping / $all) * 100")


printf "%d / %d (%.2f%%)\n" $overlapping $all $percent

