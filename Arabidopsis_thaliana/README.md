# Arabidopsis thaliana

### Data preparation

Prior to running the experiments, follow the instructions in `data` and `annot`
folders to prepare input and annotation files.

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq \
    ../data/genome.fasta.masked --max_intergenic 50000 --cores=8 --soft_mask 1000 --ES > log
cd ..
```

### ProtHint

Run ProtHint on all exclusion levels. Follow readme in `data` folder to
prepare protein data.

```bash
ls data | grep "\.fa$" | sed "s/\.fa//" | xargs -I{} bash -c '../bin/ProtHint/bin/prothint.py \
    data/genome.fasta.masked data/{}.fa --geneMarkGtf ES/genemark.gtf --workdir {} \
    --maxProteinsPerSeed 25 2> logs/{}_log'
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
bin/EP_batch.sh species_excluded genus_excluded family_excluded order_excluded phylum_excluded
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

Collect statistics about annotation

```bash
../bin/analyze_annot.sh annot/annot.gtf > accuracy_tables/annotation_stats.txt
```

### Extra run with no min exon score

Run ProtHint on family-excluded level without filtering out introns bordered by exons with
exon score < 25. This is done to generate a Sn-Sp curve for exon score. Figure with this curve
as well as scripts used to generate it are in `extra_runs/phylum_excluded_no_min_exon_score/graphs`
folder.

```bash
../bin/ProtHint/bin/prothint.py data/genome.fasta.masked data/phylum_excluded.fa \
    --geneMarkGtf ES/genemark.gtf --workdir extra_runs/phylum_excluded_no_min_exon_score \
    --maxProteinsPerSeed 25 --minExonScore -1000 > logs/phylum_excluded_no_min_exon_score_log
```

Generate Sn-Sp figure

```bash
cd extra_runs/phylum_excluded_no_min_exon_score/graphs
./generateFigure.sh
cd ../../..
```


### Experiments with different intron thresholds

Run prediction step of GeneMark-EP+ with introns filtered by different IBA thresholds
The results of this experiment are visualized in folder `X_excluded/EP/intron_plus_thresholds/visualization`

```bash
bin/test_intron_thresholds.sh genus_excluded order_excluded phylum_excluded
```

Visualize the Sn-Sp of EP+ results

```bash
echo -n "genus_excluded order_excluded phylum_excluded" | xargs -I {} -d " " bash -c 'cd {}/EP/intron_plus_thresholds; \
    ../../../../bin/visualize_Intron_EP+_thresholds.sh gene 45 65 45 65; cd ../../'
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
../../../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --max_intergenic 50000 --ep_score 4,0.25 --cores=8 --soft_mask 1000 --EP ../../prothint.gff --evidence evidence.gff > log
cd ..

# Starts/stops only
mkdir plus_starts_stops_only; cd plus_starts_stops_only
grep -P "start_codon|stop_codon" ../../evidence.gff > evidence.gff
../../../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --max_intergenic 50000 --ep_score 4,0.25 --cores=8 --soft_mask 1000 --EP ../../prothint.gff --evidence evidence.gff > log
cd ../../..
```

Create a table with numbers of merged and split genes in ES, EP and EP+ with different
hints sets.

```bash
../bin/create_merging_splitting_table.sh genus_excluded 10000 > accuracy_tables/merging_splitting.tsv
```

Accuracy table for EP+ with different hints sets.

```
../bin/create_plus_evidence_comparison_table.sh genus_excluded > accuracy_tables/ep+_evidence_comparison.tsv
```
