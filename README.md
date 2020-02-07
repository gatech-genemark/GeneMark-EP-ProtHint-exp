# Experiments for ProtHint and GeneMark-EP/EP+ projects

Tomas Bruna, Alexandre Lomsadze, Mark Borodovsky

Georgia Institute of Technology, Atlanta, Georgia, USA

Reference: [_GeneMark-EP and -EP+: automatic eukaryotic gene prediction supported by spliced aligned proteins_](https://www.biorxiv.org/content/10.1101/2019.12.31.891218v1)


## Overview

This repository contains documentation of experiments, data and results for
ProtHint and GeneMark-EP/EP+ projects.

## Program Versions

All experiments in this folder were run with GeneMark-ES/EP/ET version `5.57_lic` and ProtHint version
`v2.3.0`. To reproduce the experiments, install these versions of the programs into
`bin/gmes` and `bin/ProtHint` folders.

Versions of DIAMOND and Spaln within ProtHint were `0.9.24` and `2.3.3d`, respectively.

* GeneMark suite is available at: http://topaz.gatech.edu/GeneMark/license_download.cgi
* ProtHint is available at: https://github.com/gatech-genemark/ProtHint/releases

## Example of a full run

To run the entire GeneMark-EP+ pipeline with a single command, use:

    cd full_run_example
    ../bin/gmes/gmes_petap.pl --seq ../Drosophila_melanogaster/data/genome.fasta.masked \
        --EP --dbep ../Drosophila_melanogaster/data/family_excluded.fa --verbose --cores=16
        
Follow the instructions in `Drosophila_melanogaster/data` folder to prepare genome and protein data.

If the matching version of GeneMark-EP+ was used, the result should match the result
stored in `full_run_example/expected_genemark.gtf`. You can verify the match with:

    ./bin/compare_intervals_exact.pl --f1 full_run_example/expected_genemark.gtf --f2 \
        full_run_example/genemark.gtf --verbose

The percentage of unique CDS in either of the results should be < 0.05%. Minor fluctuations are
possible, depending on the hardware.

The example uses D. melanogaster with proteins from species outside of the same
taxonomical family.

In the rest of the experiments, GeneMark-ES, ProtHint, and GeneMark-EP+ are run separately
to evaluate different aspects of the programs. However, all results in
`species/{}_excluded/EP/plus` can be reproduced with the same single command which was
used to generate the result in `full_run_example` folder.

## Folder structure

The core folder structure for all tested species looks as follows:

    .
    ├── bin                                   # Scripts for result generation and analysis
    ├── OrthoDB                               # Info about OrthoDB species/proteins
    ├── domains                               # Scripts and data for conserved domain analysis
    ├── full_run_example                      # Example of a full GeneMark-EP+ run
    ├── species_1                             # A test species
    │   ├── annot                             # Annotation folder
    │   │   ├── annot.gtf                     # Processed annotation
    │   │   ├── pseudo.gff3                   # Coordinates of pseudogenic regions
    │   ├── data                              # Folder with softmasked genome and input proteins
    │   │   ├── genome.fasta.masked           # Softmasked genome
    │   │   ├── {}_excluded.fa                # Input proteins with {} taxonomical level excluded
    │   ├── bin                               # Scripts specific for this species
    │   ├── ES                                # GeneMark-ES run
    │   ├── ET                                # GeneMark-ET run
    │   ├── varus                             # VARUS run
    │   ├── {}_excluded                       # Results at a certain protein exclusion level {}
    │   │   ├── prothint.gff                  # All reported ProtHint hints
    │   │   ├── evidence.gff                  # High-Confidence ProtHint hints
    │   │   ├── cmd.log                       # Command used to run this ProtHint run
    │   │   ├── graphs                        # Visualizations relevant to this ProtHint run
    │   │   ├── EP                            # Results of GeneMark-EP/EP+
    │   │   │    ├── train                    # GeneMark-EP run
    │   │   │    ├── plus                     # GeneMark-EP+ run
    │   ├── extra_runs                        # Folder with additional ProtHint/EP runs (if any)
    │   ├── accuracy_tables                   # Tables with experiment results
    │   ├── EP+_results_visualization         # Figures visualizing EP+ results
    │   ├── README.md                         # Readme with species specific information
    ├── species_2                             # Another test species
    ├── ...
    ├── species_n                             # Another test species
    └


Specific ProtHint/GeneMark-EP folders may contain extra folders with
additional experiments. In such cases, the experiments are documented within
the species README file.
