#!/bin/bash

# Tomas Bruna
#
# Run prediction steps of EP+ with introns filtered by
# different al-score thresholds

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 prothint1 prothint2 ..."
    exit
fi

binDir=$(dirname "$0")
genome=$(readlink -e "${binDir}/../data/genome.fasta.masked")
GMES=$(readlink -e "${binDir}/../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl")
HCPrinter=$(readlink -e "${binDir}/../../bin/ProtHint/bin/print_high_confidence.py")

EP_plus() {
    $GMES --cores=8 --verbose --seq $genome \
        --max_intergenic 50000 --soft_mask 1000 --EP ../../../prothint.gff \
        --evidence evidence.gff --predict_with ../../train/output/gmhmm.mod
}

predict_run() {
    threshold=$1

    if [ -d $threshold ]; then
	   return
    fi

    mkdir $threshold
    cd $threshold

    # Starts and stops are eliminated by scores > 1
    $HCPrinter ../../../prothint.gff --startScore 10 --stopScore 10 \
        --intronCoverage 4 --intronAlignment $threshold > evidence.gff

    EP_plus

    cd ..
}

test_thresholds() {
    cd "$1"
    cd EP
    mkdir intron_plus_thresholds
    cd intron_plus_thresholds

    predict_run 0.1
    predict_run 0.15
    predict_run 0.2
    predict_run 0.25
    predict_run 0.3
    predict_run 0.35
    predict_run 0.4

    cd ../../..
}

for folder in "$@"
do
    test_thresholds "$folder"
done
