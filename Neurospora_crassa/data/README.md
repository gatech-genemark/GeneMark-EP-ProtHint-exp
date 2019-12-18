## Genome preparation

Unzip the genome before starting experiments

```bash
gunzip genome.fasta.masked.gz
```
### Genome information

* The genome was downloaded from ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/182/925/GCF_000182925.2_NC12/GCF_000182925.2_NC12_genomic.fna.gz
* Genome was _de novo_ masked for repeats with [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html).
* Unplaced contigs and contigs of organelles were removed from the genome.
* The scrips used to process the genome are documented at https://github.com/gatech-genemark/EukSpecies/tree/master/Neurospora_crassa

## Preparation of proteins

### Fungal protein sets

Download fungal proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_fungi_fasta.tar.gz
tar xvf odb10_fungi_fasta.tar.gz
rm odb10_fungi_fasta.tar.gz
```

Function for creating a single fasta file with fungi proteins, excluding
species supplied in a list.

```bash
createProteinFile() {
    excluded=$1
    output=$2

    # Get NCBI ids of species in excluded list
    grep -f <(paste <(yes $'\n'| head -n $(cat $excluded | wc -l)) \
        $excluded <(yes $'\n'| head -n $(cat $excluded | wc -l))) \
        ../../OrthoDB/odb10v0_species.tab | cut -f2 | sed  "s/^/\//" | \
        sed "s/_/\./" > ids

    # Create protein file with everything else
    cat $(ls -d fungi/Rawdata/* | grep -v -f ids) > $output

    rm ids
}
```

Create protein databases with different levels of exclusion. Exclusion lists
correspond to species in taxonomic levels in OrthoDB v10.

```bash
createProteinFile neurospora.txt genus_excluded.fa
createProteinFile sordariales.txt order_excluded.fa
```



For phylum excluded case, it is simpler to specify which species to include
rather than exclude

```bash
included=no_ascomycota.txt
output=phylum_excluded.fa

# Get NCBI ids of species in included list
grep -f <(paste <(yes $'\n'| head -n $(cat $included | wc -l)) \
    $included <(yes $'\n'| head -n $(cat $included | wc -l))) \
    ../../OrthoDB/odb10v0_species.tab | cut -f2 | sed  "s/^/\//" | \
    sed "s/_/\./" > ids

# Create protein file with everything else
cat $(ls -d fungi/Rawdata/* | grep -f ids) > $output

rm ids
```
