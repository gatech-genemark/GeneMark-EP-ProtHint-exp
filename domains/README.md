# Identification of protein domains in a genome

This set of scripts uses an annotation file of a given genome to identify locations of protein domains on DNA.

This is done in several steps:

1. Translation of annotation file to get annotated proteins
2. Running `rpsblast` against CDD database to get locations of domains
3. Running `rpsbproc` utility to get a non-redundant output
4. Converting `rpsbproc` output to gff format
5. Mapping protein domain coordinates to DNA domain coordinates


## Installation and dependencies

* Follow readme file at [ftp://ftp.ncbi.nlm.nih.gov/pub/mmdb/cdd/rpsbproc/README](ftp://ftp.ncbi.nlm.nih.gov/pub/mmdb/cdd/rpsbproc/README) to install `rpsbproc` and `rpsblast`
* As a result, `rpsblast` should be in the path and `data` and `db` folder should be populated.
* Bedtools needs to be installed for the subesequent analysis of which introns lie inside conserved domains.

## Running the analysis

The steps used to get domain coordinates using these scripts for specific species are located in:
`../species/domains`.

The folder also contains scripts used for the evaluation of which introns are located
within the found conserved domains.
