#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna


exclusionLevel() {
    level=$1
    mkdir $level 2> /dev/null
    cd $level
    mkdir ep_full_genes; cd ep_full_genes
    ../../../../../bin/gmes/gmes_petap.pl --verbose --seq ../../../../data/genome.fasta.masked --cores=8 --soft_mask auto --EP ../introns_full_support.gff --evidence ../introns_full_support.gff
    cd ..

    mkdir ep_all; cd ep_all
    ../../../../../bin/gmes/gmes_petap.pl --verbose --seq ../../../../data/genome.fasta.masked --cores=8 --soft_mask auto --EP ../hc_introns.gff --evidence ../hc_introns.gff
    cd ..

    mkdir ep_all_true; cd ep_all_true
    ../../../../../bin/gmes/gmes_petap.pl --verbose --seq ../../../../data/genome.fasta.masked --cores=8 --soft_mask auto --EP ../hc_introns_true.gff --evidence ../hc_introns_true.gff
    cd ..

    cd ..
}

levels=($(ls -d ../../*_excluded | tr -d ./))

for level in "${levels[@]}"; do
    exclusionLevel $level
done

