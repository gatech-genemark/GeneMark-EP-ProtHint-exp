#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Print unique protein coding transcripts in a sorted input gtf file
# ==============================================================


import argparse
import csv
import re


def extractFeatureGtf(text, feature):
    regex = feature + ' "([^"]+)"'
    return re.search(regex, text).groups()[0]


def cdsSignature(row):
    return row[0] + "_" + row[3] + "_" + row[4] + "_" + row[6]


def loadTranscripts(input):
    transcriptSignatures = {}
    for row in csv.reader(open(input), delimiter='\t'):
        if row[2] != "CDS":
            continue
        id = extractFeatureGtf(row[8], "transcript_id")

        if id not in transcriptSignatures:
            transcriptSignatures[id] = cdsSignature(row)
        else:
            transcriptSignatures[id] += cdsSignature(row)
    return transcriptSignatures


def selectUnique(transcriptSignatures):
    usedSignatures = set()
    uniqueTranscripts = set()
    for id in transcriptSignatures:
        signature = transcriptSignatures[id]
        if signature not in usedSignatures:
            uniqueTranscripts.add(id)
            usedSignatures.add(signature)
    return uniqueTranscripts


def printUnique(uniqueTranscripts, input):
    for row in csv.reader(open(input), delimiter='\t'):
        id = extractFeatureGtf(row[8], "transcript_id")
        if id in uniqueTranscripts:
            print("\t".join(row))


def main():
    args = parseCmd()
    transcriptSignatures = loadTranscripts(args.input)
    uniqueTranscripts = selectUnique(transcriptSignatures)
    printUnique(uniqueTranscripts, args.input)


def parseCmd():

    parser = argparse.ArgumentParser(description='Print unique protein coding \
                                     transcripts in a sorted input gtf file')

    parser.add_argument('input', metavar='input.gtf', type=str,
                        help='File with genes')

    return parser.parse_args()


if __name__ == '__main__':
    main()
