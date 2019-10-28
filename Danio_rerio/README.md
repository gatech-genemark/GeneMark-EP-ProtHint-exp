# Danio rerio

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq \
    ../data/genome.fasta.masked --max_intergenic 50000 --cores=8 --soft_mask 50 --ES > log
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

Generate start filtering table

```bash
../bin/create_start_filtering_table.sh genus_excluded > accuracy_tables/start_filtering.tsv
```

### GeneMark-EP/EP+

Run GeneMark-EP/EP+ for all levels

```bash
bin/EP_batch.sh genus_excluded order_excluded phylum_excluded
```


### Evaluating effects of hints in the plus mode

Run GeneMark-EP+ with introns only and with starts/stops only in the plus mode.

```bash
cd genus_excluded/EP

# Introns only
mkdir plus_introns_only; cd plus_introns_only
grep Intron ../../evidence.gff > evidence.gff
../../../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --max_intergenic 50000 --ep_score 4,0.25 --cores=8 --soft_mask 50 --EP ../../prothint.gff --evidence evidence.gff > log
cd ..

# Starts/stops only
mkdir plus_starts_stops_only; cd plus_starts_stops_only
grep -P "start_codon|stop_codon" ../../evidence.gff > evidence.gff
../../../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq ../../../data/genome.fasta.masked \
    --max_intergenic 50000 --ep_score 4,0.25 --cores=8 --soft_mask 50 --EP ../../prothint.gff --evidence evidence.gff > log
cd ../../..
```
