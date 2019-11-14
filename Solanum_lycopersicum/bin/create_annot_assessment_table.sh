#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create a table comparing performance against a set of genes
# which have all introns supported by RNA-Seq vs the rest.
#
# Single exon genes are excluded from this analysis
# ==============================================================


getColumn() {
    header=$1
    annotation=$2
    prediction=$3
    echo $header
    "$(dirname $0)/../../bin/compute_accuracies.sh" $annotation \
        annot/pseudo.gff3 $prediction $types | grep Sn | cut -f2
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}

getCount() {
    type=$1
    file=$2
    "$(dirname $0)/../../bin/compare_intervals_exact.pl" --f1 $file \
        --f2 $file --$type | cut -f1 | head -2 | tail -1
}


echo "GeneMark"

types="gene cds intron"

table=$(echo -e "---------\nGene_Sn--\nExon_Sn--\nIntron_Sn")

appendColumn "$(getColumn ES_A annot/A_annot.gtf ES/genemark.gtf)"
appendColumn "$(getColumn ES_B annot/B_annot.gtf ES/genemark.gtf)"
appendColumn "$(getColumn EP+_A_genus annot/A_annot.gtf genus_excluded/EP/plus/genemark.gtf)"
appendColumn "$(getColumn EP+_B_genus annot/B_annot.gtf genus_excluded/EP/plus/genemark.gtf)"
appendColumn "$(getColumn EP+_A_order annot/A_annot.gtf order_excluded/EP/plus/genemark.gtf)"
appendColumn "$(getColumn EP+_B_order annot/B_annot.gtf order_excluded/EP/plus/genemark.gtf)"
appendColumn "$(getColumn EP+_A_phylum annot/A_annot.gtf phylum_excluded/EP/plus/genemark.gtf)"
appendColumn "$(getColumn EP+_B_phylum annot/B_annot.gtf phylum_excluded/EP/plus/genemark.gtf)"

echo "$table"


echo -e "\nProtHint HC"

types="intron start stop"

table=$(echo -e "---------\nIntron_Sn\nStart_Sn-\nStop_Sn--")

appendColumn "$(getColumn ProtHint_genus_A annot/A_annot.gtf genus_excluded/evidence.gff)"
appendColumn "$(getColumn ProtHint_genus_B annot/B_annot.gtf genus_excluded/evidence.gff)"
appendColumn "$(getColumn ProtHint_order_A annot/A_annot.gtf order_excluded/evidence.gff)"
appendColumn "$(getColumn ProtHint_order_B annot/B_annot.gtf order_excluded/evidence.gff)"
appendColumn "$(getColumn ProtHint_phylum_A annot/A_annot.gtf phylum_excluded/evidence.gff)"
appendColumn "$(getColumn ProtHint_phylum_B annot/B_annot.gtf phylum_excluded/evidence.gff)"

echo "$table"


echo
echo "Genes in set A: $(getCount gene annot/A_annot.gtf)"
echo "Genes in set B: $(getCount gene annot/B_annot.gtf)"
echo "Introns in set A: $(getCount intron annot/A_annot.gtf)"
echo "Introns in set B: $(getCount intron annot/B_annot.gtf)"
