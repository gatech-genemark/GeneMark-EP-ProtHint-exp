## Genome preparation


Unzip the genome before starting experiments

```bash
gunzip genome.fasta.masked.gz
```
### Genome information

* The genome was downloaded from ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/215/GCF_000001215.4_Release_6_plus_ISO1_MT/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna.gz
* Genome was _de novo_ masked for repeats with [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html). 
* Unplaced contigs and contigs of organelles were removed from the genome.
* The scrips used to process the genome are documented at [https://github.com/gatech-genemark/EukSpecies/tree/master/Drosophila_melanogaster](https://github.com/gatech-genemark/EukSpecies/tree/master/Drosophila_melanogaster)

## Preparation of proteins

### Arthropoda protein sets

Download arthropoda proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_arthropoda_fasta.tar.gz
tar xvf odb10_arthropoda_fasta.tar.gz
rm odb10_arthropoda_fasta.tar.gz
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
    cat $(ls -d arthropoda/Rawdata/* | grep -v -f ids) > $output

    # Remove dots from file
    sed -i -E "s/\.//" $output

    rm ids
}
```

Create protein databases with different levels of exclusion. Exclusion lists
correspond to species in taxonomic levels in OrthoDB v10.

```
createProteinFile drosophila_melanogaster.txt species_excluded.fa
createProteinFile sophophora.txt subgenus_excluded.fa
createProteinFile drosophila.txt family_excluded.fa
createProteinFile diptera.txt order_excluded.fa
```

### Phylum excluded protein set

Phylum excluded set requires a different procedure.

```bash
wget https://v100.orthodb.org/download/odb10_metazoa_fasta.tar.gz
tar xvf odb10_metazoa_fasta.tar.gz
rm odb10_metazoa_fasta.tar.gz
```

Exclude arthropoda from metazoa

```bash
ls metazoa/Rawdata/ | grep -v -f <(ls arthropoda/Rawdata/ | awk '{print "^"$1}') | \
    xargs -I{} bash -c 'cat metazoa/Rawdata/{} >> phylum_excluded.fa'

sed -i -E "s/\.//" phylum_excluded.fa
```
