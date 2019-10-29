#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Determine how many true positive introns in introns.gff file
# are within conserved domains
# ==============================================================

if [ $# -lt 3 ]; then
    echo "Usage: $0 annot_introns.gtf annot_domain_introns.gff introns.gff"
    exit 1
fi

annot=$1
annot_domains=$2
hints=$3

res="$("$(dirname $0)"/../../bin/compare_intervals_exact.pl --f1 $annot --f2 $annot_domains \
    --f3 $hints --intron --no)"

insideDomains=$(echo "$res" | cut -f2 | head -2 | tail -1)
outsideDomains=$(echo "$res" | cut -f3 | head -4 | tail -1)
allTrue=$(bc <<< "$insideDomains + $outsideDomains")
percent=$(bc -l <<< "100 * $insideDomains / $allTrue")

echo -e "All_True\tIn_Domains\t%"
printf "%d\t%d\t%.2f\n" $allTrue $insideDomains $percent
