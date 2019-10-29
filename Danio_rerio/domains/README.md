## Get coordinates of protein domains on genomic level

Take CDS regions from APPRIS annotation and translate them to proteins.

```bash
grep "CDS" ../annot/appris.gtf | sed "s/CDS_partial/CDS/" > appris_cds.gtf
../../bin/ProtHint/bin/proteins_from_gtf.pl --annot appris_cds.gtf \
    --seq ../data/genome.fasta.masked --out annot_proteins.faa
```

Run `rpsblast` against the annotated proteins

```bash
../../domains/bin/run_rpsblast.sh annot_proteins.faa workfolder 16
# Wait for all jobs to finish
cat workfolder/*.asn > protein_domains.asn
```

Create a non-redundant output

```bash
../../domains/rpsbproc -i protein_domains.asn -o protein_domains.out -e 0.01 -m rep -t doms
```

Convert the output to gff

```bash
../../domains/bin/rpsbproc2gff.py protein_domains.out > protein_domains.gff
```

Convert coordinates from protein level to genome level

```bash
sort -k1,1 -k4,4n -k5,5n appris_cds.gtf > appris_cds_sorted.gtf
../../domains/bin/protein2dna.py protein_domains.gff appris_cds_sorted.gtf > protein_domains_genomic.gff
```

## Analyze the overlap of domains with introns

Get a set of annotated APPRIS introns which are located within conserved domains

```bash
../../domains/bin/getDomainIntrons.sh ../annot/appris.gtf \
    protein_domains_genomic.gff > appris_domain_introns.gff
```

How many annotated APPRIS introns are inside domains

```bash
echo -e "All_APPRIS_Introns\tIn_domains\t%" > ../accuracy_tables/appris_domain_introns.tsv
../../bin/compare_intervals_exact.pl --f1 ../annot/appris.gtf \
    --f2 appris_domain_introns.gff --intron --no | head -2 | \
    tail -1 | cut -f1,2,4 >> ../accuracy_tables/appris_domain_introns.tsv
```

How many true positive (matching APPRIS) introns (All and High-Confidence) are
in and outside of domains.

```bash
printRow() {
    exclusion=$1
    type=$2
    output=$3
    paste <(echo $exclusion) <(../../domains/bin/intronDomainOverlap.sh \
        ../annot/appris.gtf appris_domain_introns.gff \
        ../$exclusion/$type | tail -1) >> $output
}

createHintsTable() {
    type=$1
    output=$2
    echo "# Introns matching APPRIS introns" > $output
    echo -e "Exlusion\tAll\tIn_Domains\t%" >> $output
    printRow genus_excluded $type $output
    printRow order_excluded $type $output
    printRow phylum_excluded $type $output
}

createHintsTable evidence.gff ../accuracy_tables/high_confidence_domain_introns.tsv
createHintsTable prothint.gff ../accuracy_tables/all_reported_domain_introns.tsv
```
