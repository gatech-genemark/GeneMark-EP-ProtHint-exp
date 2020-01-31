#!/bin/bash
# ==============================================================
# Tomas Bruna
#
# Collect general statistics about annotation and count the number
# of different non-canonical (with respect to genemark.hmm) events
#
# TODO in enrich_gff first:
#   * Report frameshifts
#   * Gene boundaries (merge overlapping alternative transcripts) to
#     calculate gene overlaps
#   * Print intron splice site dinucleotides
#   * Print start and stop nucleotides
#   * Stop codon readthrough
#
# ==============================================================

if [ ! "$#" -eq 1 ]; then
    echo "Usage: $0 annot.gtf"
    exit
fi

annot=$1
LC_NUMERIC="en_US.UTF-8"

countGenes() {
    echo "Gene count: $(grep -Po "gene_id[^;]+;" $annot | sort | uniq | wc -l)"
}

countTranscripts() {
    echo "Transcript count: $(grep -Po "transcript_id[^;]+;" $annot | sort | uniq | wc -l)"
}

countUniqueTranscripts() {
    echo -n "Unique protein coding transcript count: "
    $(dirname $0)/compare_intervals_exact.pl --f1 $annot --f2 $annot --v --gene | \
        grep -A1 "After removal" | tail -1 | grep -Po "[0-9]+$"
}

countMultiSingle() {
    grep -P "Single" $annot   | grep -Po "gene_id[^;]+;" | sort | uniq > single_genes
    grep -P "Initial|Internal|Terminal" $annot | grep -Po "gene_id[^;]+;" | sort | uniq > multi_genes
    both=$(comm -12 <(sort single_genes) <(sort multi_genes) | wc -l)

    echo "Single-exon genes: $(($(cat single_genes | wc -l) - both))"
    echo "Multi-exon genes: $(($(cat multi_genes | wc -l) - both))"
    echo "Genes with both multi and single exon transcripts: $both"

    rm multi_genes single_genes
}

intronsPerGene() {
    transcripts=$(grep -Po "transcript_id[^;]+;" $annot | sort | uniq | wc -l)
    multiTranscripts=$(grep -P "Initial|Internal|Terminal" $annot | grep -Po "transcript_id[^;]+;" | sort | uniq | wc -l)
    introns=$(grep -P "\t[Ii]ntron\t" $annot | wc -l)

    printf "Introns per transcript: %.2f\n" $(bc -l <<< "$introns/$transcripts")
    printf "Introns per multi-exon transcript: %.2f\n" $(bc -l <<< "$introns/$multiTranscripts")
}

transcriptsPerGene() {
    out="$($(dirname $0)/compare_intervals_exact.pl --f1 $annot --f2 $annot --v --gene)"

    uniqueTranscripts="$(echo "$out" | grep -A1 "After removal" | tail -1 | grep -Po "[0-9]+$")"
    genes=$(grep -Po "gene_id[^;]+;" $annot | sort | uniq | wc -l)
    transcripts=$(grep -Po "transcript_id[^;]+;" $annot | sort | uniq | wc -l)
    singleTrGenes="$(echo "$out" | grep -A1 "transc-per-gene hist" | tail -1 | grep "^# 1" | grep -Po "[0-9]+$")"

    printf "Transcripts per gene: %.2f\n" $(bc -l <<< "$transcripts/$genes")
    printf "Unique protein coding transcripts per gene: %.2f\n" $(bc -l <<< "$uniqueTranscripts/$genes")
    printf "Unique protein coding transcripts per multi-protein gene: %.2f\n" \
        $(bc -l <<< "($uniqueTranscripts - $singleTrGenes) / ($genes - $singleTrGenes)")
}


splitStartsStops() {
    splitStarts=$(grep -P "\tstart_codon\t" $annot | grep "1_2" | cut -f1,4,5,7 | sort | uniq | wc -l)
    splitStops=$(grep -P "\tstop_codon\t" $annot | grep "2_2" | cut -f1,4,5,7 | sort | uniq | wc -l)

    normalStarts=$(grep -P "\tstart_codon\t" $annot | grep "1_1" |  cut -f1,4,5,7 | sort | uniq | wc -l)
    normalStops=$(grep -P "\tstop_codon\t" $annot | grep "1_1" |  cut -f1,4,5,7 | sort | uniq | wc -l)

    printf "Number of split starts: %d/%d (%.2f%%)\n" $splitStarts $((normalStarts + splitStarts)) \
           $(bc -l <<< "$splitStarts / ($normalStarts + $splitStarts) * 100")
    printf "Number of split stops: %d/%d (%.2f%%)\n" $splitStops $((normalStops + splitStops)) \
           $(bc -l <<< "$splitStops / ($normalStops + $splitStops) * 100")
}

countLongIntrons() {
    LIMIT=10000
    longIntrons=$(grep -P "\t[Ii]ntron\t" $annot | awk -v limit="$LIMIT" '{if ($5-$4 + 1 > limit) print}' | cut -f1,4,5,7 | sort | uniq | wc -l)
    allIntrons=$(grep -P "\t[Ii]ntron\t" $annot | cut -f1,4,5,7 | sort | uniq | wc -l)

    printf "Number of introns longer than %d: %d/%d (%.2f%%)\n" $LIMIT $longIntrons $allIntrons $(bc -l <<< "$longIntrons / $allIntrons * 100")
}


compareAgainstLongestIsoforms() {
    $(dirname $0)/print_longest_isoform.py $annot > longest.gtf
    echo -n "Percentage of CDS in longest isoforms (Longest isoform exon level Sn): "
    $(dirname $0)/compare_intervals_exact.pl --f1 $annot --f2 longest.gtf | tail -n +2 | head -1 | cut -f4
    rm longest.gtf
}

countMergedCDS() {
    grep -P "\tCDS\t" $annot | awk 'BEGIN{OFS = "\t"}{print $1, $4 - 1, $5, $7, $8}' |  sort -k1,1 -k2,2n -k3,3n |  uniq | cut -f1-3 > unique_CDS.bed
    mergedExons=$(bedtools merge -i unique_CDS.bed | wc -l)
    allExons=$(cat unique_CDS.bed | wc -l )
    printf "Number of CDS regions lost during merging of overlapping segments: %d/%d (%.2f%%)\n" $((allExons - mergedExons)) $allExons $(bc -l <<< "($allExons - $mergedExons) / $allExons * 100")
    printf "Number of CDS regions remaining after merging of overlapping segments: %d/%d (%.2f%%)\n" $mergedExons $allExons $(bc -l <<< "$mergedExons / $allExons * 100")
    rm unique_CDS.bed
}

countNonOverlapingCDS() {
    # Count the number of CDS segments which are not overlapped by any other CDS segments
    # CDS segments are first collapsed -> identical CDS segments do not create overlap on themselves
    grep -P "\tCDS\t" $annot | awk 'BEGIN{OFS = "\t"}{print $1, $4 - 1, $5, $7, $8}' |  sort -k1,1 -k2,2n -k3,3n |  uniq | cut -f1-3 > unique_CDS.bed
    # Prepare coordinate file
    maxCoordinate=$(awk 'BEGIN{max = 0} {if ($3 > max) max = $3} END{print max}' unique_CDS.bed)
    cut -f1  unique_CDS.bed | uniq > chroms
    paste <(cut -f1  unique_CDS.bed | uniq) <(yes $maxCoordinate | head -n $(cat chroms | wc -l)) > coordinates
    # Get regions with coverage exactly one
    bedtools genomecov -i unique_CDS.bed -g coordinates -bg | grep "1$" | cut -f1-3 > non_overlaps.bed
    # Find out which of such regions match original CDS exons
    noOverlap=$(comm -12 <(sort non_overlaps.bed) <(sort unique_CDS.bed)  | wc -l)
    allExons=$(cat unique_CDS.bed | wc -l )
    printf "Number of CDS regions involved in an overlap: %d/%d (%.2f%%)\n" $((allExons - noOverlap)) $allExons $(bc -l <<< "($allExons - $noOverlap) / $allExons * 100")
    printf "Number of CDS regions which are not involved in any overlap: %d/%d (%.2f%%)\n" $noOverlap $allExons $(bc -l <<< "$noOverlap / $allExons * 100")

    rm chroms unique_CDS.bed coordinates non_overlaps.bed
}


echo "================================="
echo "General statistics"
echo "================================="
countGenes
countTranscripts
countUniqueTranscripts
countMultiSingle
intronsPerGene
transcriptsPerGene
echo "================================="
echo "Non-canonical Events"
echo "================================="
splitStartsStops
countLongIntrons
compareAgainstLongestIsoforms
echo "---"
countMergedCDS
echo "---"
countNonOverlapingCDS
