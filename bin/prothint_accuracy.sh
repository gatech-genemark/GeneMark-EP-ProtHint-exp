#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create accuracy table for a single prothint folder
# ==============================================================


parseCompare() {
    output=$1
    acc=$(cut -f4 <<< "$output" | tail -2)
    echo "$acc"
}

compare () {
    label="$1"
    flags="$2"
    hints="$(parseCompare "$($compare --f1 "$annot" --f2 prothint.gff $flags)")"
    evidence="$(parseCompare "$($compare --f1 "$annot" --f2 evidence.gff $flags)")"
    paste <(echo -e "${label}_Sn\n${label}_Sp") <(echo "$hints") <(echo "$evidence") -d"\t"
}

binDir="$(readlink -e $(dirname "$0"))"

if [ "$#" -eq 2 ]; then
    folder=$2
    compare="$binDir/compare_intervals_exact.pl"
elif  [ "$#" -eq 3 ]; then
    folder=$3
    pseudo=$(readlink -e "$2")
    compare="$binDir/compare_intervals_exact.pl --pseudo $pseudo"
else
    echo "Usage: $0 annot.gtf [pseudogenes] protHintFolder"
    exit
fi

annot=$(readlink -e "$1")

cd "$folder"

# Backward compatibility
if [ ! -f prothint.gff ]; then
    ln -s hints.gff prothint.gff
fi

echo -e "Hint\tAll\tHC"
compare "Intron" "--intron --no"
compare "Start" "--start --no"
compare "Stop" "--stop --no"
