# Drosophila melanogaster

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
../bin/create_start_filtering_table.sh family_excluded > accuracy_tables/start_filtering.tsv
```

### GeneMark-EP/EP+

Run GeneMark-EP/EP+ for all levels

```bash
bin/EP_batch.sh species_excluded subgenus_excluded family_excluded order_excluded phylum_excluded
```


### Extra run with no min exon score

Run ProtHint on family-excluded level without filtering out introns bordered by exons with
exon score < 25. This is done to generate a Sn-Sp curve for exon score. Figure with this curve
as well as scripts used to generate it are in `extra_runs/family_excluded_no_min_exon_score/graphs`
folder.

```bash
../bin/ProtHint/bin/prothint.py data/genome.fasta.masked data/family_excluded.fa \
    --geneMarkGtf ES/genemark.gtf --workdir extra_runs/family_excluded_no_min_exon_score \
    --maxProteinsPerSeed 25 --minExonScore -1000 > logs/family_excluded_no_min_exon_score_log
```

Generate Sn-Sp figure

```bash
cd extra_runs/family_excluded_no_min_exon_score/graphs
./generateFigure.sh
cd ../../..
```

### Evaluating effects of hints in the plus mode

Run GeneMark-EP+ with introns only and with starts/stops only in the plus mode.

```bash
cd family_excluded/EP

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

### Analysis of introns in conserved domains

The analysis of how many mapped ProtHint introns are located within regions coding for conserved protein domains
is documented in the `domains` folder.
