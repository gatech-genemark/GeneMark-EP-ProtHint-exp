#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna



getColumn() {
    header1=$1
    prediction=$2
    echo "$header1"
    "../../../../bin/compute_accuracies.sh" ../../../annot/annot.gtf \
        ../../../annot/pseudo.gff3 "$prediction" $types | cut -f2
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

exclusionLevel() {
    level=$1
    cd $level
    table=$(echo -e "---------\nGene_Sn--\nGene_Sp--\nExon_Sn--\
\nExon_Sp--\nIntron_Sn\nIntron_Sp")
    appendColumn "$(getColumn ES ../../../ES/genemark.gtf)"
    appendColumn "$(getColumn Full_genes ep_full_genes/genemark.gtf)"
    appendColumn "$(getColumn All ep_all/genemark.gtf)"
    appendColumn "$(getColumn All_true ep_all_true/genemark.gtf)"
    echo "$table" > accuracy.txt
    cd ..
}

types="gene cds intron"
levels=($(ls -d ../../*_excluded | tr -d ./))

for level in "${levels[@]}"; do
    exclusionLevel $level
done

