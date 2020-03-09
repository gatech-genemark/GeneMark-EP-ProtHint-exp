#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Get a list of genes which have at least one hint in the given
# hints.gff file.
#
# ==============================================================


if [ $# -lt 3 ]; then
    echo "Usage: $0 hints.gff annotation.gff out"
    exit 1
fi

hints=$1
annot=$2
out=$3

binFolder=$(readlink -e $(dirname $0))

intronMatches=$(mktemp)
startMatches=$(mktemp)
stopMatches=$(mktemp)
allMatches=$(mktemp)
geneIds=$(mktemp)

$binFolder/compare_intervals_exact.pl --f1 $annot --f2 $hints \
    --intron --no --out $intronMatches --original 1 --shared12
$binFolder/compare_intervals_exact.pl --f1 $annot --f2 $hints \
    --start --no --out $startMatches --original 1 --shared12
$binFolder/compare_intervals_exact.pl --f1 $annot --f2 $hints \
    --stop --no --out $stopMatches --original 1 --shared12

cat $intronMatches $startMatches $stopMatches > $allMatches

grep -Po "gene_id[^;]+;" $allMatches | sed "s/gene_id //" | tr -d \" | tr -d \; > $geneIds

sort $geneIds | uniq > $out

rm $intronMatches $startMatches $stopMatches $allMatches $geneIds
