### Plants protein sets

Download plants proteins from OrthoDB

```bash
wget https://v100.orthodb.org/download/odb10_plants_fasta.tar.gz
tar xvf odb10_plants_fasta.tar.gz
rm odb10_plants_fasta.tar.gz
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
createProteinFile arabidopsis_thaliana.txt species_excluded.fa
createProteinFile arabidopsis.txt genus_excluded.fa
createProteinFile brassicaceae.txt family_excluded.fa
createProteinFile brassicales.txt order_excluded.fa
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

Note: _Klebsormidium nitens_ is in the same phylum (_Streptophyta_) as _A.thaliana_
according to NCBI taxonomy. However, other sources put it in a different phylum
(_Charophyta_): https://www.algaebase.org/search/species/detail/?species_id=34853
Thereofore, it is in the phylum excluded list here.
