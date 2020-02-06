# Danio rerio

### Data preparation

Prior to running the experiments, follow the instructions in `data` and `annot`
folders to prepare input and annotation files.

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/gmes/gmes_petap.pl --verbose --seq \
    ../data/genome.fasta.masked --cores=8 --soft_mask auto --ES > log
cd ..
```

### GeneMark-ET

Run GeneMark-ET to compare protein results against RNA-Seq. RNA-Seq was sampled
and aligned by VARUS, see the `varus` folder for details.

```bash
mkdir ET; cd ET
../../bin/gmes/gmes_petap.pl --verbose  --seq ../data/genome.fasta.masked \
    --cores=8 --soft_mask auto --ET ../varus/varus.gff > log
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
../bin/EP_batch.sh genus_excluded order_excluded phylum_excluded
```

Make GeneMark-ES/EP/EP+ accuracy table. Gene level sensitivity is computed against the set
of complete genes, this requires some additonal manipulations (which is still easier than
writing a special script for this table)

```bash
../bin/create_EP_accuracy_table.sh > accuracy_tables/all.gtf
# Temporarily replace annot file with complete genes only annotation
mv annot/annot.gtf annot/annot_copy
# Repeat computation
cp -P annot/completeGenes.gtf annot/annot.gtf
../bin/create_EP_accuracy_table.sh > accuracy_tables/complete.gtf
# Combine accuracy tables
cat <(head -3 accuracy_tables/complete.gtf) <(tail -n +4 accuracy_tables/all.gtf) > \
    accuracy_tables/es_ep_ep+_accuracy.tsv
rm accuracy_tables/complete.gtf accuracy_tables/all.gtf
# Put annotation back
mv  annot/annot_copy annot/annot.gtf
```

Visualize EP+ results. A script which is D. rerio specific is used
here because gene level Sn is compared against a set of complete genes only.

```bash
./bin/visualize_EP+_results.sh annot/annot.gtf annot/completeGenes.gtf EP+_results_visualization cds 40 70 60 90
./bin/visualize_EP+_results.sh annot/annot.gtf annot/completeGenes.gtf EP+_results_visualization gene 0 40 0 40
./bin/visualize_EP+_results.sh annot/appris.gtf annot/appris_completeGenes.gtf EP+_results_visualization/APPRIS cds 30 60 50 80
./bin/visualize_EP+_results.sh annot/appris.gtf annot/appris_completeGenes.gtf EP+_results_visualization/APPRIS gene 0 40 0 40
```

Create a table comparing gene and exon level sensitivity against different sets
of annotated genes. The columns in the table are:

* Raw annot: Raw annotation in which partial CDS are not distinguished
  from full CDS
* Partial CDS removed: Annotation with removed partial CDS. This removes
  some genes completely and creates many incomplete transcipts and genes.
* Complete transcripts: Complete transcripts only (no partial CDS were
  in these transcripts)
* Incomplete transcripts: Incomplete transcripts only (at least one partial
  CDS was in each transcript, they are still removed in this file)
* Complete genes: Genes in which all transcripts are complete
* Incomplete genes: Genes in which at least one transcript is incomplete.

```bash
./bin/create_partial_CDS_comparison_table.sh genus_excluded/EP/plus/genemark.gtf > \
    accuracy_tables/partial_CDS_comparison.tsv
```

### Annotation Statistics

Collect statistics about annotation. Treat partial CDS as regular CDS for
this computation.

```bash
sed "s/CDS_partial/CDS/"  annot/annot.gtf > tmp
../bin/analyze_annot.sh tmp > accuracy_tables/annotation_stats.txt
rm tmp
```

### Evaluating effects of hints in the plus mode

Run GeneMark-EP+ with introns only and with starts/stops only in the plus mode.

```bash
cd genus_excluded/EP

# Introns only
mkdir plus_introns_only; cd plus_introns_only
grep Intron ../../evidence.gff > evidence.gff
../../../../bin/ProtHint/dependencies/gmes/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --cores=8 --soft_mask auto --EP ../../prothint.gff --evidence evidence.gff > log
cd ..

# Starts/stops only
mkdir plus_starts_stops_only; cd plus_starts_stops_only
grep -P "start_codon|stop_codon" ../../evidence.gff > evidence.gff
../../../../bin/ProtHint/dependencies/gmes/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --cores=8 --soft_mask auto --EP ../../prothint.gff --evidence evidence.gff > log
cd ../../..
```

Create a table with numbers of merged and split genes in ES, EP and EP+ with different
hints sets.

```bash
../bin/create_merging_splitting_table.sh genus_excluded 10000 > accuracy_tables/merging_splitting.tsv
```

Accuracy table for EP+ with different hints sets. A script which is D. rerio specific is used
here because gene level Sn is compared against a set of complete genes only.

```bash
./bin/create_plus_evidence_comparison_table.sh genus_excluded > accuracy_tables/ep+_evidence_comparison.tsv
```

### Analysis of introns in conserved domains

The analysis of how many mapped ProtHint introns are located within regions coding for conserved protein domains
is documented in the `domains` folder.

### Second Iteration

Test the effect of a second iteration of ProtHint and EP+ using seeds from first
iteration of GeneMark-EP+ instead of GeneMark-ES.

```bash
../bin/ProtHint/bin/prothint.py data/genome.fasta.masked data/genus_excluded.fa --geneMarkGtf \
    genus_excluded/EP/plus/genemark.gtf --workdir extra_runs/genus_excluded_iter_2 \
    --maxProteinsPerSeed 25 > logs/genus_excluded_iter_2_log
cd extra_runs/family_excluded
mkdir -p EP/plus; cd EP/plus
../../../../../bin/ProtHint/dependencies/gmes/gmes_petap.pl --verbose --seq \
    ../../../../data/genome.fasta.masked --max_intergenic 50000 --ep_score 4,0.25 --cores=8 \
    --soft_mask 50 --EP ../../prothint.gff --evidence ../../evidence.gff > log
cd ../../../..
```
