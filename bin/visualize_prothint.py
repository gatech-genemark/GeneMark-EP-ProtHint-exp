#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Visualize ProtHint intron scores
# ==============================================================


import argparse
import csv
import re
import sys
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt


def getSignature(row):
    return row[0] + "_" + row[3] + "_" + row[4] + "_" + row[6]


def extractFeature(text, feature):
    regex = feature + '=([^;]+)'
    search = re.search(regex, text)
    if search:
        return search.groups()[0]
    else:
        return None


def loadAnnotation(annotFile):
    annot = set()
    for row in csv.reader(open(annotFile), delimiter='\t'):
        if (row[2].lower() == "intron"):
            annot.add(getSignature(row))
    return annot


def plotScores(annot, inputFile, outputFile, args):
    trueX = []
    trueY = []
    falseX = []
    falseY = []
    maxX = 0
    maxY = 0

    for row in csv.reader(open(inputFile), delimiter='\t'):
        if (row[2].lower() != "intron"):
            continue

        signature = getSignature(row)

        x = float(extractFeature(row[8], "al_score"))
        y = float(row[5])

        if args.ylim != -1:
            if y > args.ylim:
                continue

        if x > maxX:
            maxX = x

        if y > maxY:
            maxY = y

        if signature in annot:
            trueX.append(x)
            trueY.append(y)
        else:
            falseX.append(x)
            falseY.append(y)

    if not args.trueFirst:
        plt.plot(falseX, falseY, '.', ms=10, color='purple', alpha=args.opacity, clip_on=False)
        plt.plot(trueX, trueY, '.', ms=10, color='green', alpha=args.opacity, clip_on=False)
    else:
        plt.plot(trueX, trueY, '.', ms=10, color='green', alpha=args.opacity, clip_on=False)
        plt.plot(falseX, falseY, '.', ms=10, color='purple', alpha=args.opacity, clip_on=False)

    plt.plot([0.25, maxX], [3.5, 3.5], color='black')
    plt.plot([0.25, 0.25], [3.5, maxY], color='black')

    # Legend
    yMargin = 0
    yShift = -0.048
    plt.text(0.05, 1 + yMargin, "   TP (" + str(len(trueX)) + ")" +
             "\n   FP (" + str(len(falseX)) + ")",
             va="top", transform=plt.gca().transAxes,
             bbox=dict(facecolor='white', edgecolor='black', boxstyle='square,pad=0.75'))

    plt.plot(0.05, .989, '.', ms=10, color='green', clip_on=False,
             transform=plt.gca().transAxes, zorder=4)
    plt.plot(0.05, .989 + yShift, '.', ms=10, color='purple', clip_on=False,
             transform=plt.gca().transAxes, zorder=4)

    plt.xlabel("Intron borders alignment score (IBA)")
    plt.ylabel("Intron mapping coverage (IMC)")
    # plt.yscale('log')
    plt.box(on=None)
    if args.ylim != -1:
        plt.ylim(0, args.ylim)
    plt.xlim(0.1, maxX)
    plt.show()
    plt.savefig(outputFile, dpi=args.dpi)


def main():
    args = parseCmd()
    with open("scatter.sh", "w") as file:
        file.write("#!/usr/bin/env bash\n")
        file.write(" ".join(sys.argv) + "\n")
    annot = loadAnnotation(args.annotation)
    plotScores(annot, args.input, args.output, args)


def parseCmd():

    parser = argparse.ArgumentParser(description='Visualize prothint intron scores')

    parser.add_argument('input', metavar='prothint.gff', type=str,
                        help='ProtHint output file.')

    parser.add_argument('annotation', metavar='introns_annot.gff', type=str,
                        help='Annotated introns.')

    parser.add_argument('output', type=str,
                        help='Output figure.')

    parser.add_argument('--opacity', type=float, default=0.05,
                        help='Opacity of individual points. Default = 0.05')

    parser.add_argument('--trueFirst',  default=False, action='store_true',
                        help='First print true positives')

    parser.add_argument('--ylim', type=float, default=-1,
                        help='Limit y axis by this number. Default = No limit')

    parser.add_argument('--dpi', type=int, default=600,
                        help='DPI of the output figure. Default = 600')

    return parser.parse_args()


if __name__ == '__main__':
    main()
