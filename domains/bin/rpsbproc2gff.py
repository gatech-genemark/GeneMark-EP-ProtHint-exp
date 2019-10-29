#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Convert rpsbproc output to gff
# ==============================================================


import argparse
import csv


def processQuery(csvReader, proteinID):
    line = next(csvReader)[0]
    if line == "ENDQUERY":
        return
    assert (line == "DOMAINS"), 'Error: corrupted rpsbproc output. ' \
                                'Expected "DOMAINS", got ' + line
    for row in csvReader:
        if row[0] == "ENDDOMAINS":
            break

        print("\t".join([proteinID, "CDD", row[2], row[4], row[5], row[7],
                         ".", ".", "accession=" + row[8] + ";name="
                         + row[9] + ";"]))

    line = next(csvReader)[0]
    assert (line == "ENDQUERY"), 'Error: corrupted rpsbproc output. ' \
                                 'Expected "ENDQUERY", got ' + line


def convert(rpsbrocOut):
    csvReader = csv.reader(open(rpsbrocOut), delimiter='\t')
    for row in csvReader:
        if len(row) > 0 and row[0] == "QUERY":
            processQuery(csvReader, row[4])


def main():
    args = parseCmd()
    convert(args.rpsbprocOut)


def parseCmd():

    parser = argparse.ArgumentParser(description='Convert rpsbproc output to gff')

    parser.add_argument('rpsbprocOut', metavar='rpsbroc.out',
                        help='rpsbroc output file')

    return parser.parse_args()


if __name__ == '__main__':
    main()
