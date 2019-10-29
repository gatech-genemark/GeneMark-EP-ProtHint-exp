#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Parse output of bedtools intersect between introns and domains and print only
# introns which are from the same gene as the protein domain they overlap.
# The input is coming from a results of "bedtools intersect -a introns.gff -b
# domains.gff -s -wa -wb > output"
# ==============================================================


import argparse
import csv
import re


def extractFeatureGtf(text, feature):
    regex = feature + ' "([^"]+)"'
    return re.search(regex, text).groups()[0]


def extractFeatureGff(text, feature):
    regex = feature + '=([^;]+);'
    return re.search(regex, text).groups()[0]


def printMatching(input):

    for row in csv.reader(open(input), delimiter='\t'):
        intronParent = extractFeatureGtf(row[8], "gene_id")
        domainParent = extractFeatureGff(row[17], "prot")
        if intronParent == domainParent:
            print("\t".join(row[0:9]))


def main():
    args = parseCmd()
    printMatching(args.input)


def parseCmd():

    parser = argparse.ArgumentParser(description='Parse output of bedtools \
                                     intersect between introns and domains and \
                                     print only introns which are from the same \
                                     gene as the protein domain they overlap.\
                                     The input is coming from a results of \"bedtools \
                                     intersect -a introns.gff -b domains.gff -s \
                                     -wa -wb > output\"')

    parser.add_argument('input',
                        help='Input file, output of bedtools intersect')

    return parser.parse_args()


if __name__ == '__main__':
    main()
