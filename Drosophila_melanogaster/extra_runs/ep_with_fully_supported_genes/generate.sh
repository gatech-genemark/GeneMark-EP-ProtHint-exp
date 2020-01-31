#!/bin/bash
# ==============================================================
# Tomas Bruna
# Copyright 2020, Georgia Institute of Technology, USA
#
# Compare GeneMark-EP+ runs with conserved and all introns
# ==============================================================

./create_evidences.sh
./run_genemark.sh
./create_acc_table.sh
ls -d *_excluded | xargs -I {} bash -c './visualize_results.sh cds {} 70 80 65 75'
