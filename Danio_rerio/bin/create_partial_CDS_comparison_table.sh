#!/usr/bin/env bash
# ==============================================================
# Tomas Bruna
#
# Create a table comparing gene and exon level sensitivity against
# different sets of annotated genes. The columns are
# * Raw annot: Raw annotation in which partial CDS are not distinguished
#   from full CDS
# * Partial CDS removed: Annotation with removed partial CDS exons. This removes
#   some genes completely and creates many incomplete transcripts and genes.
# * Complete transcripts: Complete transcripts only (no partial CDS were
#   in the transcripts)
# * Incomplete transcripts: Incomplete transcripts only (at least one partial
#   CDS was in each transcripts, they are still removed in this file)
# * Complete genes: Genes in which all transcripts are complete
# * Incomplete genes: Genes in which at least one transcript is incomplete.
#
# This script needs to be run from D. rerio species folder which
# has different annotation sets in the annot folder
# ==============================================================


getColumn() {
    header="$1"
    annot="$2"
    echo $header
    "$(dirname $0)/../../bin/compare_intervals_exact.pl" --f1 $annot \
        --f2 $prediction --cds --pseudo annot/pseudo.gff3 | head -2 | tail -1 | cut -f4
    "$(dirname $0)/../../bin/compare_intervals_exact.pl" --f1 $annot \
        --f2 $prediction --gene --pseudo annot/pseudo.gff3 | head -2 | tail -1 | cut -f4
}

appendColumn() {
    column="$1"
    table="$(paste <(echo "$table") <(echo "$column"))"
}


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 prediction.gtf"
    exit
fi

prediction="$1"

# Handle genes separately

table=$(echo -e "------\nExon_Sn\nGene_Sn")

appendColumn "$(getColumn "Raw_annot" "annot/annot_raw.gtf")"
appendColumn "$(getColumn "Partial_CDS_removed" "annot/annot.gtf")"
appendColumn "$(getColumn "Complete_transcripts" "annot/completeTranscripts.gtf")"
appendColumn "$(getColumn "Incomplete_transcripts" "annot/incompleteTranscripts.gtf")"
appendColumn "$(getColumn "Complete_genes" "annot/completeGenes.gtf")"
appendColumn "$(getColumn "Incomplete_genes" "annot/incompleteGenes.gtf")"

echo "$table"
