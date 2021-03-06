## Genome preparation

Unzip the genome before starting experiments

```bash
gunzip genome.fasta.masked.gz
```
### Genome information

* The genome was downloaded from ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/035/GCF_000002035.6_GRCz11/GCF_000002035.6_GRCz11_genomic.fna.gz
* The masking from GCF_000002035.6 was kept
* Unplaced contigs and contigs of organelles were removed from the genome.
* The scrips used to process the genome are documented at https://github.com/gatech-genemark/EukSpecies-EP/tree/master/Danio_rerio

## Preparation of proteins

### Chordata protein sets

Download vertebrata proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_vertebrata_fasta.tar.gz
tar xvf odb10_vertebrata_fasta.tar.gz
rm odb10_vertebrata_fasta.tar.gz
```

Download metazoa proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_metazoa_fasta.tar.gz
tar xvf odb10_metazoa_fasta.tar.gz
rm odb10_metazoa_fasta.tar.gz
```

Add missing chordata to vertebrata from metazoa and rename to chordata

```bash
# Branchiostoma belcheri
cp metazoa/Rawdata/7741_0.fs vertebrate/Rawdata/
# Branchiostoma floridae
cp metazoa/Rawdata/7739_0.fs vertebrate/Rawdata/
# Ciona intestinalis
cp metazoa/Rawdata/7719_0.fs vertebrate/Rawdata/
mv vertebrate chordata
```

Function for creating a single fasta file with plant proteins, excluding
species supplied in a list.

```bash
createProteinFile() {
    excluded=$1
    output=$2

    # Get NCBI ids of species in excluded list
    grep -f <(paste <(yes $'\n'| head -n $(cat $excluded | wc -l)) \
        $excluded <(yes $'\n'| head -n $(cat $excluded | wc -l))) \
        ../../OrthoDB/odb10v0_species.tab | cut -f2 | sed "s/_0//" > ids

    # Create protein file with everything else
    cat $(ls -d chordata/Rawdata/* | grep -v -f ids) > $output

    # Remove dots from file
    sed -i -E "s/\.//" $output

    rm ids
}
```

Create protein databases with different levels of exclusion. Exclusion lists
correspond to species in taxonomic levels in OrthoDB v10.

```bash
createProteinFile danio_rerio.txt genus_excluded.fa
createProteinFile cypriniformes.txt order_excluded.fa
```

### Phylum excluded protein set

For phylum excluded case, it is simpler to specify which species to include
rather than exclude


Exclude chordata from metazoa

```bash
ls metazoa/Rawdata/ | grep -v -f <(ls chordata/Rawdata/ | awk '{print "^"$1}' | \
    sed "s/.fs/_0.fs/" | sed "s/_0_0/_0/") | \
    xargs -I{} bash -c 'cat metazoa/Rawdata/{} >> phylum_excluded.fa'

sed -i -E "s/\.//" phylum_excluded.fa
```

