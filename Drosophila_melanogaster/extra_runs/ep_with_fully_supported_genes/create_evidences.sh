#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# For each exclusion level, create sets of HC introns,
# HC introns which fully support an annotated gens, and
# HC introns which are true
#
# ==============================================================

exclusionLevel() {
    level=$1
    mkdir $level 2> /dev/null
    cd $level
    grep Intron ../../../$level/evidence.gff > hc_introns.gff
    ../../../../bin/select_by_introns.pl --in_gtf ../../../annot/annot.gtf --in_introns hc_introns.gff --out_gtf annot_genes_full_HC_support.gff --v --no_phase
    ../../../../bin/compare_intervals_exact.pl --f1 annot_genes_full_HC_support.gff --f2 hc_introns.gff --intron --no --shared12 --out introns_full_support.gff --original 2
    tail -n +2 introns_full_support.gff > tmp; mv tmp introns_full_support.gff

    ../../../../bin/compare_intervals_exact.pl --f1 ../../../annot/annot.gtf --f2 hc_introns.gff --intron --no --shared12 --out hc_introns_true.gff --original 2
    tail -n +2 hc_introns_true.gff > tmp; mv tmp hc_introns_true.gff

    full=$(cat introns_full_support.gff | wc -l)
    all=$(cat hc_introns.gff | wc -l)
    echo $level > ratio.txt
    printf "%d/%d %.2f%%\n" $full $all $(bc -l <<< "100 * $full / $all") >> ratio.txt
    cd ..
}

levels=($(ls -d ../../*_excluded | tr -d ./))

for level in "${levels[@]}"; do
    exclusionLevel $level
done

