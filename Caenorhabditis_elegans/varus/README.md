## Running VARUS

VARUS was run on January 22, 2020.

```bash
../../bin/VARUS/runVARUS.pl --aligner=HISAT --readFromTable=0 --createindex=1 --latinGenus=Caenorhabditis \
    --latinSpecies=elegans --speciesGenome=../data/genome.fasta.masked --logfile=varus_log > log
cp Caenorhabditis_elegans/cumintrons.stranded.gff varus.gff
```

The output of VARUS which was used for GeneMark-ET run is included, unzip it with

```bash
gunzip varus.gff.gz
```
