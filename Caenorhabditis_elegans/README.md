# Caenorhabditis elegans

### Data preparation

Prior to running the experiments, follow the instructions in `data` and `annot`
folders to prepare input and annotation files.

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/GeneMarkES/bin/gmes_petap.pl --verbose --seq \
    ../data/genome.fasta.masked --cores=8 --soft_mask auto --ES > log
cd ..
```

### GeneMark-ET

Run GeneMark-ET to compare protein results against RNA-Seq

```bash
mkdir ET; cd ET
../../bin/GeneMarkES/bin/gmes_petap.pl --verbose  --seq ../data/genome.fasta.masked \
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

Make ProtHint accuracy table.

```bash
../bin/create_prothint_accuracy_table.sh > accuracy_tables/prothint_accuracy.tsv
```

Generate start filtering table

```bash
../bin/create_start_filtering_table.sh family_excluded > accuracy_tables/start_filtering.tsv
```

### GeneMark-EP/EP+

Run GeneMark-EP/EP+ for all levels

```bash
../bin/EP_batch.sh species_excluded family_excluded phylum_excluded
```

Make GeneMark-ES/EP/EP+ accuracy table

```bash
../bin/create_EP_accuracy_table.sh > accuracy_tables/es_ep_ep+_accuracy.tsv
```

Visualize EP+ results

```bash
../bin/visualize_EP+_results.sh annot/annot.gtf EP+_results_visualization cds 65 95 65 95
../bin/visualize_EP+_results.sh annot/annot.gtf EP+_results_visualization gene 37.5 77.5 37.5 77.5
../bin/visualize_EP+_results.sh annot/appris.gtf EP+_results_visualization/APPRIS cds 65 95 65 95
../bin/visualize_EP+_results.sh annot/appris.gtf EP+_results_visualization/APPRIS gene 35 75 35 75
```


### Annotation Statistics

Collect statistics about annotation.

```bash
../bin/analyze_annot.sh annot/annot.gtf > accuracy_tables/annotation_stats.txt
```

### Evaluating effects of hints in the plus mode

Run GeneMark-EP+ with introns only and with starts/stops only in the plus mode.

```bash
cd family_excluded/EP

# Introns only
mkdir plus_introns_only; cd plus_introns_only
grep Intron ../../evidence.gff > evidence.gff
../../../../bin/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --cores=8 --soft_mask auto --EP ../../prothint.gff --evidence evidence.gff > log
cd ..

# Starts/stops only
mkdir plus_starts_stops_only; cd plus_starts_stops_only
grep -P "start_codon|stop_codon" ../../evidence.gff > evidence.gff
../../../../bin/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --cores=8 --soft_mask auto --EP ../../prothint.gff --evidence evidence.gff > log
cd ../../..
```

Create a table with numbers of merged and split genes in ES, EP and EP+ with different
hints sets.

```bash
../bin/create_merging_splitting_table.sh family_excluded 10000 > accuracy_tables/merging_splitting.tsv
```

Accuracy table for EP+ with different hints sets.

```bash
../bin/create_plus_evidence_comparison_table.sh family_excluded > accuracy_tables/ep+_evidence_comparison.tsv
```

### Analysis of introns in conserved domains

The analysis of how many mapped ProtHint introns are located within regions coding for conserved protein domains
is documented in the `domains` folder.
