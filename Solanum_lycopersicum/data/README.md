## Genome preparation

Unzip the genome before starting experiments

```bash
gunzip *.gz
cat genome.fasta.masked_* > genome.fasta.masked
rm genome.fasta.masked_*
```
### Genome information

* The genome was downloaded from ftp://ftp.solgenomics.net/tomato_genome/assembly/build_4.00/S_lycopersicum_chromosomes.4.00.fa
* Genome was _de novo_ masked for repeats with [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html).
* Unplaced contigs and contigs of organelles were removed from the genome.
* The scrips used to process the genome are documented at https://github.com/gatech-genemark/EukSpecies/tree/master/Solanum_lycopersicum

## Preparation of proteins

### Plants protein sets

Download plants proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_plants_fasta.tar.gz
tar xvf odb10_plants_fasta.tar.gz
rm odb10_plants_fasta.tar.gz
```

Function for creating a single fasta file with arthropda proteins, excluding
species supplied in a list.

```bash
createProteinFile() {
    excluded=$1
    output=$2

    # Get NCBI ids of species in excluded list
    grep -f <(paste <(yes $'\n'| head -n $(cat $excluded | wc -l)) \
        $excluded <(yes $'\n'| head -n $(cat $excluded | wc -l))) \
        ../../OrthoDB/odb10v0_species.tab | cut -f2 > ids

    # Create protein file with everything else
    cat $(ls -d plants/Rawdata/* | grep -v -f ids) > $output

    # Remove dots from file
    sed -i -E "s/\.//" $output

    rm ids
}
```

Create protein databases with different levels of exclusion. Exclusion lists
correspond to species in taxonomic levels in OrthoDB v10.

```bash
createProteinFile solanum.txt genus_excluded.fa
createProteinFile solanales.txt order_excluded.fa
```

For phylum excluded case, it is simpler to specify which species to include
rather than exclude

```bash
excluded=chlorophyta.txt
output=phylum_excluded.fa

# Get NCBI ids of species in excluded list
grep -f <(paste <(yes $'\n'| head -n $(cat $excluded | wc -l)) \
    $excluded <(yes $'\n'| head -n $(cat $excluded | wc -l))) \
    ../../OrthoDB/odb10v0_species.tab | cut -f2 > ids

# Create protein file with everything else
cat $(ls -d plants/Rawdata/* | grep -f ids) > $output

# Remove dots from file
sed -i -E "s/\.//" $output

rm ids
```
