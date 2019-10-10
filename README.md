# Overview

This repository contains documentation of experiments, data and results for
ProtHint and GeneMark-EP/EP+ projects.

## Folder structure

The core folder structure for all tested species looks as follows:

    .
    ├── bin                                   # Scripts for result generation and analysis
    ├── species_1                             # A test species
    │   ├── annot                             # Annotation folder
    │   │   ├── annot.gtf                     # Processed annotation
    │   │   ├── pseudo.gff3                   # Coordinates of pseudogenic regions
    │   ├── data                              # Folder with softmasked genome and input proteins
    │   │   ├── genome.fasta                  # Softmasked genome
    │   │   ├── proteins_no_X                 # Input proteins with X taxonomical level excluded
    │   ├── bin                               # Scripts specific for this species
    │   ├── ESm                               # Results of a GeneMark-ES run
    │   ├── level_X_excluded                  # Results at a certain protein exclusion level X
    │   │   ├── prothint.gff                  # All reported ProtHint hints
    │   │   ├── evidence.gff                  # High-Confidence ProtHint hints
    │   │   ├── cmd.log                       # Command used to run this ProtHint run
    │   │   ├── graphs                        # Visualizations relevant to this ProtHint run
    │   │   ├── EP                            # Results of GeneMark-EP/EP+
    │   │   │    ├── train                    # GeneMark-EP run
    │   │   │    ├── plus                     # GeneMark-EP+ run
    │   ├── extra_runs                        # Folder with additional ProtHint/EP runs (if any)
    │   ├── EP_plus_results_visualization     # Figures visualizing EP+ results
    │   ├── EP_annot                          # Runs of EP and EP+ which use hints from annotation
    │   ├── README.md                         # Readme with species specific information
    ├── species_2                             # Another test species
    ├── ...
    ├── species_n                             # Another test species
    └


Specific ProtHint/GeneMark-EP folders may contain extra folders with
additional experiments. In such cases, the experiments are documented within
those folders.
