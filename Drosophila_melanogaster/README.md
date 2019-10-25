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
../bin/ProtHint/bin/prothint.py data/genome.fasta.masked data/family_excluded.fa --geneMarkGtf ES/genemark.gtf --workdir extra_runs/family_excluded_no_min_exon_score --maxProteinsPerSeed 25 --minExonScore -1000 > logs/family_excluded_no_min_exon_score_log
```

Generate Sn-Sp figure

```bash
cd extra_runs/family_excluded_no_min_exon_score/graphs
./generateFigure.sh
cd ../../..
```
