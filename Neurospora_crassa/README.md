# Neurospora crassa

### Data preparation

Prior to running the experiments, follow the instructions in `data` and `annot`
folders to prepare input and annotation files.

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/gmes/gmes_petap.pl --verbose --fungus --seq \
    ../data/genome.fasta.masked --cores=8 --soft_mask 0 --ES > log
cd ..
```

### GeneMark-ET

Run GeneMark-ET to compare protein results against RNA-Seq. RNA-Seq was sampled
and aligned by VARUS, see the `varus` folder for details.

```bash
mkdir ET; cd ET
../../bin/gmes/gmes_petap.pl --verbose --fungus --seq \
    ../data/genome.fasta.masked --cores=8 --soft_mask 0 --ET ../varus/varus.gff > log
cd ..
```

### ProtHint

Run ProtHint on all exclusion levels. Follow readme in `data` folder to
prepare protein data.

```bash
ls data | grep "\.fa$" | sed "s/\.fa//" | xargs -I{} bash -c '../bin/ProtHint/bin/prothint.py \
    data/genome.fasta.masked data/{}.fa --geneMarkGtf ES/genemark.gtf --workdir {} 2> logs/{}_log'
```

Make ProtHint accuracy table

```bash
../bin/create_prothint_accuracy_table.sh > accuracy_tables/prothint_accuracy.tsv
```


Generate start filtering table

```bash
../bin/create_start_filtering_table.sh genus_excluded > accuracy_tables/start_filtering.tsv
```

### GeneMark-EP/EP+

Run GeneMark-EP/EP+ for all levels

```bash
../bin/EP_batch_fungus.sh genus_excluded order_excluded phylum_excluded
```

Make GeneMark-ES/EP/EP+ accuracy table

```bash
../bin/create_EP_accuracy_table.sh > accuracy_tables/es_ep_ep+_accuracy.tsv
```

Visualize EP+ results

```bash
../bin/visualize_EP+_results.sh annot/annot.gtf EP+_results_visualization cds 65 95 65 95
../bin/visualize_EP+_results.sh annot/annot.gtf EP+_results_visualization gene 37.5 77.5 37.5 77.5
```

### Annotation Statistics

Collect statistics about annotation.

```bash
../bin/analyze_annot.sh annot/annot.gtf > accuracy_tables/annotation_stats.txt
```

### Visualize intron scores

Visualize scores of TP and FP introns as a scatter plot. Generate Sn-Sp curves for
filtering introns with IBA score, IMC scores and a combination of the two. Results are
saved in `genus_excluded/graphs` folder.

```bash
cd genus_excluded/graphs
./generateFigures.sh
cd ../..
```

### Experiments with different intron thresholds

Run prediction step of GeneMark-EP+ with introns filtered by different IBA thresholds
The results of this experiment are visualized in folder `X_excluded/EP/intron_plus_thresholds/visualization`

```bash
../bin/test_intron_thresholds_fungus.sh genus_excluded order_excluded phylum_excluded
```

Visualize the Sn-Sp of EP+ results

```bash
echo -n "genus_excluded order_excluded phylum_excluded" | xargs -I {} -d " " bash -c 'cd {}/EP/intron_plus_thresholds; \
    ../../../../bin/visualize_Intron_EP+_thresholds.sh gene 62.5 82.5 55 75; cd ../../'
```

Generate data for combined Sn-Sn curves of introns and plot the curves

```bash
# Generate data
echo -n "genus_excluded order_excluded phylum_excluded" | xargs -I {} -d " " bash -c 'cd {}/EP/intron_plus_thresholds/visualization; \
    ../../../../../bin/combinedROC.sh ../../../../annot/annot.gtf ../../../../annot/pseudo.gff3 ../../../prothint.gff'
# Visualize
echo -n "genus_excluded order_excluded phylum_excluded" | xargs -I {} -d " " bash -c 'cd {}/EP/intron_plus_thresholds/visualization; \
    ./curve.sh'
```

Create scatter plots which visualize scores of TP and FP introns.
```bash
echo -n "genus_excluded order_excluded phylum_excluded" | xargs -I {} -d " " bash -c 'cd {}/EP/intron_plus_thresholds/visualization; \
    ./scatter.sh'
```

### Evaluating effects of hints in the plus mode

Run GeneMark-EP+ with introns only and with starts/stops only in the plus mode.

```bash
cd genus_excluded/EP

# Introns only
mkdir plus_introns_only; cd plus_introns_only
grep Intron ../../evidence.gff > evidence.gff
../../../../bin/gmes/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --cores=8 --fungus --soft_mask 0 --EP ../../prothint.gff --evidence evidence.gff > log
cd ..

# Starts/stops only
mkdir plus_starts_stops_only; cd plus_starts_stops_only
grep -P "start_codon|stop_codon" ../../evidence.gff > evidence.gff
../../../../bin/gmes/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --soft_mask 0 --cores=8 --fungus --EP ../../prothint.gff --evidence evidence.gff > log
cd ../../..
```


Create a table with numbers of merged and split genes in ES, EP and EP+ with different
hints sets.

```bash
../bin/create_merging_splitting_table.sh genus_excluded 3000 > accuracy_tables/merging_splitting.tsv
```

Accuracy table for EP+ with different hints sets.

```bash
../bin/create_plus_evidence_comparison_table.sh genus_excluded > accuracy_tables/ep+_evidence_comparison.tsv
```
