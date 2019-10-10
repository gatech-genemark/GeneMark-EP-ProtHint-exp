#!/usr/bin/env python
# ==============================================================
# Tomas Bruna
# Copyright 2019, Georgia Institute of Technology, USA
#
# Visualize results of the compare intervals script as a Venn diagram
# ==============================================================


import argparse
import os
import subprocess
import matplotlib as mpl
import csv
from StringIO import StringIO
mpl.use('Agg')
import matplotlib.pyplot as plt
from matplotlib_venn import venn2
from matplotlib_venn import venn3
from matplotlib_venn import venn3_circles


binDir = os.path.abspath(os.path.dirname(__file__)) + "/"


def twoWay(args):
    command = "compare_intervals_exact.pl --f1 " + args.f1 + " --f2 " + \
             args.f2 + " --" + args.mode
    compareResult = subprocess.check_output(binDir + command, shell=True)

    intersect = 0
    unique1 = 0
    unique2 = 0

    f = StringIO(compareResult)
    reader = csv.reader(f, delimiter='\t')
    for i, row in enumerate(reader):
        if i == 1:
            intersect = int(row[1])
            unique1 = int(row[2])
        if i == 2:
            unique2 = int(row[2])

    print(compareResult)

    if not args.hidef2:
        v = venn2(subsets=(unique1, unique2, intersect),
                  set_labels=(args.f1Label, args.f2Label))
    else:
        v = venn2(subsets=(unique1, 0, intersect),
                  set_labels=(args.f1Label, args.f2Label))
        v.get_patch_by_id('01').set_color('white')
        v.get_label_by_id('01').set_text('')

    plt.show()
    plt.savefig(args.out, dpi=args.dpi)


def threeWay(args):
    command = "compare_intervals_exact.pl --f1 " + args.f1 + " --f2 " + \
             args.f2 + " --f3 " + args.f3 + " --" + args.mode
    compareResult = subprocess.check_output(binDir + command, shell=True)

    intersect = 0
    unique1 = 0
    unique2 = 0
    unique3 = 0
    shared12 = 0
    shared13 = 0
    shared23 = 0

    f = StringIO(compareResult)
    reader = csv.reader(f, delimiter='\t')
    for i, row in enumerate(reader):
        if i == 1:
            intersect = int(row[1])
            shared12 = int(row[3])
            shared13 = int(row[4])
            unique1 = int(row[5])
        if i == 2:
            shared23 = int(row[4])
            unique2 = int(row[5])
        if i == 3:
            unique3 = int(row[5])

    print(compareResult)
    venn3(subsets=(unique1, unique2, shared12, unique3,
                   shared13, shared23, intersect),
          set_labels=(args.f1Label, args.f2Label, args.f3Label))
    venn3_circles(subsets=(unique1, unique2, shared12, unique3,
                  shared13, shared23, intersect),
                  linestyle='dashed', linewidth=1, color="grey")

    plt.show()
    plt.savefig(args.out, dpi=args.dpi)


def main():
    args = parseCmd()
    plt.title(args.title)

    if args.f3 is None:
        twoWay(args)
    else:
        threeWay(args)


def parseCmd():

    parser = argparse.ArgumentParser(description='Visualize results of the compare \
                                     intervals script as a Venn diagram')

    parser.add_argument('mode', type=str,
                        help='What should be compared (intron, gene, etc.)')

    parser.add_argument('--out', type=str, required=True,
                        help='Name of the file with output figure')

    parser.add_argument('--hidef2',  default=False, action='store_true',
                        help='Do not show unique part of f2')

    parser.add_argument('--f1', type=str, required=True,
                        help='First file in the gff/gtf format. Mandatory')

    parser.add_argument('--f1Label', type=str,
                        help='Label of the first file')

    parser.add_argument('--f2', type=str, required=True,
                        help='Second file in the gff/gtf format. Mandatory.')

    parser.add_argument('--f2Label', type=str,
                        help='Label of the second file')

    parser.add_argument('--f3', type=str,
                        help='Third file in the gff/gtf format. Optional.')

    parser.add_argument('--f3Label', type=str,
                        help='Label of the third file')

    parser.add_argument('--title', type=str,
                        help='Title of the graph')

    parser.add_argument('--dpi', type=int, default=600,
                        help='DPI of the output figure. Default = 600.')

    args = parser.parse_args()

    if args.f1Label is None:
        args.f1Label = args.f1

    if args.f2Label is None:
        args.f2Label = args.f2

    if args.f3Label is None:
        args.f3Label = args.f3

    if args.title is None:
        args.title = args.mode

    if args.mode == "intron":
        args.mode = "intron --no"

    return args


if __name__ == '__main__':
    main()
