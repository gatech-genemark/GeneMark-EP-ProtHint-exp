#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Count cases of gene merging and gene splitting
# ==============================================================


import argparse
import csv
import re
import subprocess
import shutil
import tempfile
import os


class Gene:

    def __init__(self, start, end, strand, chrom):

        self.start = start
        self.end = end
        self.strand = strand
        self.chrom = chrom

    def updateCoordinates(self, start, end):
        if self.start > start:
            self.start = start
        if self.end < end:
            self.end = end


def getSignature(row):
    return row[0] + "_" + row[3] + "_" + row[4] + "_" + row[6]


def extractFeature(text, feature):
    regex = feature + ' "([^;]+)";'
    search = re.search(regex, text)
    if search:
        return search.groups()[0]
    else:
        return None


def assignUniqueIds(input, output, strandPosition):
    """Assign unique ids to all entries in input and save
    result to output
    """
    input.seek(0)
    i = 0
    for row in csv.reader(input, delimiter='\t'):
        output.write("\t".join([row[0], row[1], row[2], str(i), ".", row[strandPosition]]) + "\n")
        i += 1
    output.flush()


def detectGenes(gtfFile, outputFile, transcripts=False):
    """Save coding gene segments based on CDS borders

    Args:
        gtfFile: Input gtf file
        outputFile: Output with genes only
        transcripts: Report separate segment for each transcript
                     in a gene.
    """
    label = "gene_id"
    if transcripts:
        label = "transcript_id"
    genes = {}
    for row in csv.reader(open(gtfFile), delimiter='\t'):
        gene = extractFeature(row[8], label)
        if gene not in genes:
            genes[gene] = Gene(int(row[3]), int(row[4]), row[6], row[0])
        else:
            genes[gene].updateCoordinates(int(row[3]), int(row[4]))

    for id, gene in genes.items():
        outputFile.write("\t".join([gene.chrom, str(gene.start), str(gene.end),
                         id, ".", gene.strand]) + "\n")

    outputFile.flush()


def countOverlaps(query, target, outputRegions, splitting=False):
    """Count how many times any segment from target file overlaps
    a segment from query file more than once.
    Strand matters.
    Two outpus are returned:
    1. any number of overlaps counts as one.
    2. n overlaps contribute n - 1 to the count.
    """

    intersectResult = tempfile.NamedTemporaryFile(delete=False)
    subprocess.call("bedtools intersect -a " + query.name +
                    " -b " + target.name + " -wb > " + intersectResult.name, shell=True)

    encouteredQueries = set()
    encouteredQueriesMulti = set()
    overlapCounter = 0
    for row in csv.reader(intersectResult, delimiter='\t'):
        queryStrand = row[5]
        queryId = row[3]
        targetStrand = row[11]

        # All queries are on forward strand in gene splitting
        # input, skip this check for gene splitting. Still, the
        # split targets are required to be on the same strand
        # (relative to each other) to count as splitting
        if not splitting and queryStrand != targetStrand:
            continue

        if (queryId + targetStrand) not in encouteredQueries:
            encouteredQueries.add(queryId + targetStrand)
        else:
            encouteredQueriesMulti.add(queryId + targetStrand)
            overlapCounter += 1
    intersectResult.close()

    if outputRegions:
        output = open(outputRegions, "w")
        for row in csv.reader(open(intersectResult.name), delimiter='\t'):
            targetStrand = row[11]
            queryId = row[3]
            if (queryId + targetStrand) in encouteredQueriesMulti:
                output.write("\t".join(row) + "\n")
        output.close()

    os.remove(intersectResult.name)
    return len(encouteredQueriesMulti), overlapCounter


def mergeAnnotation(mergedAnnot):
    """Merge overlapping annotation genes into one (when on same strand)
    otherwise they create a false impression of gene merging.
    """
    sortedBed = tempfile.NamedTemporaryFile(dir=".")
    mergedBed = tempfile.NamedTemporaryFile(dir=".")
    subprocess.call("sort -k1,1 -k2,2n " + mergedAnnot.name + " > " + sortedBed.name, shell=True)
    subprocess.call("bedtools merge -s -i " + sortedBed.name + " > " + mergedBed.name, shell=True)

    uniqueIds = tempfile.NamedTemporaryFile(dir=".")
    assignUniqueIds(mergedBed, uniqueIds, 3)

    shutil.copy(uniqueIds.name, mergedAnnot.name)

    sortedBed.close()
    mergedBed.close()
    uniqueIds.close()


def splitIntrons(splitAnnot, annot, intronLength):
    """Extract introns longer than intronLength from annotation
    and split gene segments in splitAnnot at positions of
    the long introns
    """
    longIntrons = tempfile.NamedTemporaryFile(dir=".")
    for row in csv.reader(open(annot), delimiter='\t'):
        if row[2] == "intron" or row[2] == "Intron":
            if int(row[4]) - int(row[3]) + 1 > intronLength:
                longIntrons.write("\t".join([row[0], row[3], row[4], ".", ".", row[6]]) + "\n")
    longIntrons.flush()

    tempOut = tempfile.NamedTemporaryFile(dir=".")
    subprocess.call("bedtools subtract -s -a " + splitAnnot.name + " -b " +
                    longIntrons.name + " > " + tempOut.name, shell=True)

    uniqueIds = tempfile.NamedTemporaryFile(dir=".")
    assignUniqueIds(tempOut, uniqueIds, 5)

    shutil.copy(uniqueIds.name, splitAnnot.name)
    tempOut.close()
    uniqueIds.close()


def makeGenomeFile(splitAnnot, genomeFile):
    splitAnnot.seek(0)
    chroms = {}
    for row in csv.reader(splitAnnot, delimiter='\t'):
        chrom = row[0]
        end = int(row[2])
        if chrom not in chroms:
            chroms[chrom] = end
        else:
            if end > chroms[chrom]:
                chroms[chrom] = end

    for chrom in chroms:
        genomeFile.write("\t".join([chrom, str(chroms[chrom])]) + "\n")
    genomeFile.flush()


def splitOverlaps(splitAnnot, annot):
    """Split segments where they overlap (change in coverage). This removes
    a portion of splits which are reported due to the fact that genemark.hmm
    cannot predict overlapping genes: In an attempt to predict a gene
    inside an intron, gene is often split, this is, however, not a
    case of gene splitting we would like to report. The gene inside
    and intron can be on both strands, therefore, strand information is
    ignored and lost during this procedure, all segments are put on the
    forward strand.
    """
    genomeFile = tempfile.NamedTemporaryFile(dir=".")
    makeGenomeFile(splitAnnot, genomeFile)
    sortedSplitAnnot = tempfile.NamedTemporaryFile(dir=".")
    coverageResult = tempfile.NamedTemporaryFile(dir=".")

    subprocess.call("sort -k1,1 " + splitAnnot.name + " > " + sortedSplitAnnot.name, shell=True)
    subprocess.call("bedtools genomecov -i " + sortedSplitAnnot.name +
                    " -g " + genomeFile.name + " -bg > " + coverageResult.name, shell=True)

    tempOutIds = tempfile.NamedTemporaryFile(dir=".")
    i = 0
    for row in csv.reader(coverageResult, delimiter='\t'):
        tempOutIds.write("\t".join([row[0], row[1], row[2], str(i), ".", "+"]) + "\n")
        i += 1
    tempOutIds.flush()

    shutil.copy(tempOutIds.name, splitAnnot.name)
    genomeFile.close()
    sortedSplitAnnot.close()
    coverageResult.close()
    tempOutIds.close()


def splitAnnotation(splitAnnot, args):
    if (args.splitIntrons):
        splitIntrons(splitAnnot, args.annot, args.splitIntrons)

    if not args.dontSplitOverlaps:
        splitOverlaps(splitAnnot, args.annot)


def main():
    args = parseCmd()
    annotGenes = tempfile.NamedTemporaryFile(dir=".")
    predGenes = tempfile.NamedTemporaryFile(dir=".")

    splitAnnotGenes = tempfile.NamedTemporaryFile(dir=".")
    mergedAnnotGenes = tempfile.NamedTemporaryFile(dir=".")

    detectGenes(args.annot, splitAnnotGenes, args.splitTranscripts)
    detectGenes(args.annot, mergedAnnotGenes)
    detectGenes(args.pred, predGenes)

    splitAnnotation(splitAnnotGenes, args)
    splitGenes, splits = countOverlaps(splitAnnotGenes, predGenes, args.splitRegions, True)

    mergeAnnotation(mergedAnnotGenes)
    mergedGenes, merges = countOverlaps(predGenes, mergedAnnotGenes, args.mergedRegions)

    print("Number of split genes: " + str(splitGenes))
    print("Number of splits (Gene can be split multiple times): " + str(splits))
    print("--")
    print("Number of merged genes (in prediction): " + str(mergedGenes))
    print("Number of merges (multiple annotated genes can be merged into 1 prediction): " + str(merges))

    annotGenes.close()
    predGenes.close()
    mergedAnnotGenes.close()
    splitAnnotGenes.close()


def parseCmd():

    parser = argparse.ArgumentParser(description='Count cases of gene merging and gene splitting.')

    parser.add_argument('--annot', required=True,
                        help='Enriched annotation file in gtf format')

    parser.add_argument('--pred', required=True,
                        help='Prediction file in gtf format')

    parser.add_argument('--splitIntrons', type=int,
                        help='Split genes at introns longer than SPLITINTRONS.\
                        Genes split due to long introns are not counted as cases\
                        of gene splitting.')

    parser.add_argument('--splitRegions', type=str,
                        help='Save regions involved in gene splitting into this file')

    parser.add_argument('--mergedRegions', type=str,
                        help='Save regions involved in gene merging into this file')

    parser.add_argument('--splitTranscripts', default=False, action='store_true',
                        help='Split overlapping transcripts from the same gene \
                              into multiple segments. Only affects gene splitting\
                              computation.')

    parser.add_argument('--dontSplitOverlaps', default=False, action='store_true',
                        help='Do not split overlapping genes into multiple segments \
                              when calculating gene splitting. Does not work together \
                              with --splitTranscripts.')

    args = parser.parse_args()

    if args.splitTranscripts:
        args.dontSplitOverlaps = False

    return args


if __name__ == '__main__':
    main()
