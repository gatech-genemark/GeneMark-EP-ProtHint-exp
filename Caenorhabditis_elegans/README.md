# Caenorhabditis elegans

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

### GeneMark-EP/EP+

Run GeneMark-EP/EP+ for all levels

```bash
bin/EP_batch.sh species_excluded family_excluded phylum_excluded
```
