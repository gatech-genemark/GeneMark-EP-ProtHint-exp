#!/bin/bash

# Tomas Bruna
#
# Run a batch of EPs (train only and plus) for the list of specified
# ProtHint folders.
#
# The genome is assumed to be in data/genome.fasta.masked

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 prothint1 prothint2 ..."
    exit
fi

binDir=$(dirname "$0")
genome=$(readlink -e "data/genome.fasta.masked")

GMES=$(readlink -e "${binDir}/gmes/gmes_petap.pl")

EP_ARGS="--verbose \
    --seq $genome \
    --cores=8 --soft_mask auto \
    --EP ../../prothint.gff"

runEP() {
    cd "$1"
    mkdir EP; cd EP
    mkdir train plus

    cd train
    $GMES $EP_ARGS > log
    cd ..

    cd plus
    $GMES $EP_ARGS --evidence ../../evidence.gff > log
    cd ..

    cd ..; cd ..
}


for folder in "$@"
do
    runEP "$folder"
done
