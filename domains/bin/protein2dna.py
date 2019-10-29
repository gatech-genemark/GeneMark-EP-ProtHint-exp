#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Transform coordinates of protein domains on protein level to their genomic
# coordinates on DNA
# ==============================================================


import argparse
import csv
import re


def extractFeature(text, feature):
    regex = feature + ' "([^"]+)"'
    return re.search(regex, text).groups()[0]


def loadGenes(annotation):
    genes = {}

    for row in csv.reader(open(annotation), delimiter='\t'):

        if row[2] != "CDS":
            continue

        gene = extractFeature(row[8], "gene_id")

        if gene not in genes:
            genes[gene] = []

        genes[gene].append(row)

    return genes


def transformProteinCoordinate(genes, geneId, protCoordinate, codonStart):
    """Transform protein coordinate to genomic DNA
    Args:
        genes (dict): CDS regions of all annotated genes
        geneId (string): GeneId of the gene which codes for the protein
        protCoordinate (int): Coordinate on the protein level
        start (bool): Whether start or end of codon should be returned
    """

    strand = genes[geneId][0][6]

    # Translate protein position to mRNA position
    mRNACoordinate = 0
    if codonStart:
        mRNACoordinate = protCoordinate * 3 - 2
    else:
        mRNACoordinate = protCoordinate * 3

    # How much of mRNA was covered so far by CDS regions
    mRNACovered = 0

    # Order of looping through CDS segments, reverse for negative strand
    order = []
    if strand == "+":
        order = range(0, len(genes[geneId]))
    elif strand == "-":
        order = range(len(genes[geneId]) - 1, -1, -1)

    for i in order:
        cds = genes[geneId][i]
        cdsLenght = int(cds[4]) - int(cds[3]) + 1
        # Can the mRNA coordinate be found within this CDS or do we need
        # to keep looking in the next one?
        if mRNACoordinate <= mRNACovered + cdsLenght:
            if strand == "+":
                # -1 is there because mRNACoordinate is 1-indexed
                return int(cds[3]) + mRNACoordinate - mRNACovered - 1
            elif strand == "-":
                return int(cds[4]) - (mRNACoordinate - mRNACovered - 1)
        else:
            mRNACovered += cdsLenght


def transformDomainCoordinates(genes, proteinDomains):
    for row in csv.reader(open(proteinDomains), delimiter='\t'):
        begin = transformProteinCoordinate(genes, row[0], int(row[3]), True)
        end = transformProteinCoordinate(genes, row[0], int(row[4]), False)

        if begin > end:
            tmp = begin
            begin = end
            end = tmp
        contig = genes[row[0]][0][0]
        strand = genes[row[0]][0][6]

        print("\t".join([contig, row[1], row[2], str(begin), str(end), row[5],
              strand, ".", row[8] + "prot=" + row[0] + ";"]))


def main():
    args = parseCmd()
    genes = loadGenes(args.annotation)
    transformDomainCoordinates(genes, args.proteinDomains)


def parseCmd():

    parser = argparse.ArgumentParser(description='Transform coordinates of \
                                     protein domains on protein level to their \
                                     genomic coordinates on DNA')

    parser.add_argument('proteinDomains', metavar='protein_domains.gff',
                        help='Protein domains with protein-level coordinates')

    parser.add_argument('annotation', metavar='annotation.gtf',
                        help='Annotation file which was originaly used to \
                        create the protein sequences in which protein \
                        domains were identified. Must be sorted by coordinates.')

    return parser.parse_args()


if __name__ == '__main__':
    main()
