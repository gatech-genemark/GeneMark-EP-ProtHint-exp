#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Run rpsblast in parallel
# ==============================================================

if [ $# -lt 3 ]; then
    echo "Usage: $0 proteins.faa work_folder num_threads"
    exit 1
fi

input=$1
workFolder=$2
threads=$3
export binDir=$(readlink -f "$(dirname $0)")

mkdir "$workFolder"

cp "$input" "$workFolder"
cd "$workFolder"

$binDir/../../bin/ProtHint/dependencies/probuild --split_fasta \
    --seq "$input" --split_numfile $threads

# Run for each split
ls | grep -P "_[0-9]+$" | xargs -I{} bash -c 'nohup rpsblast -query {} \
    -db ${binDir}/../db/Cdd -evalue 0.01 -outfmt 11 -out {}.asn > {}.log &'
