# Neurospora crassa

### GeneMark-ES

Run GeneMark-ES

```bash
cd ES
../../bin/ProtHint/dependencies/GeneMarkES/bin/gmes_petap.pl --verbose --seq \
    ../data/genome.fasta.masked --max_intergenic 20000 --cores=8 --fungus --ES > log
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
bin/EP_batch.sh genus_excluded order_excluded phylum_excluded
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
