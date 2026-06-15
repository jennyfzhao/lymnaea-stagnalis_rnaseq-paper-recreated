# Data Sources

This project uses public *Lymnaea stagnalis* CNS aging RNA-seq data and public annotation databases.

## RNA-seq Reads

- NCBI BioProject: `PRJNA698985`
- NCBI SRA study: `SRP304491`
- Organism: *Lymnaea stagnalis*
- Tissue/source: central nervous system samples
- Library strategy/source/selection: RNA-Seq, transcriptomic, random
- Layout/platform: paired-end Illumina NovaSeq 6000
- Local metadata files:
  - `metadata/PRJNA698985_runinfo.csv`
  - `metadata/PRJNA698985_SraAccList.txt`
  - `data/sample_metadata.tsv`

The SRA runs used here are:

| Age group | Runs |
| --- | --- |
| 3 months | `SRR13618140`, `SRR13618141`, `SRR13618144`, `SRR13618145` |
| 6 months | `SRR13618146`, `SRR13618148`, `SRR13618147`, `SRR13618149` |
| 18 months | `SRR13618150`, `SRR13618142`, `SRR13618151`, `SRR13618143` |

NCBI browser links:

- BioProject: https://www.ncbi.nlm.nih.gov/bioproject/PRJNA698985
- SRA run selector export pattern: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA698985

## Reference Genome

- Assembly accession: `GCA_900036025.1`
- Assembly name used locally: `GCA_900036025.1_v1.0`
- Organism: *Lymnaea stagnalis*
- Download URL:
  `https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/900/036/025/GCA_900036025.1_v1.0/GCA_900036025.1_v1.0_genomic.fna.gz`

The genome FASTA is intentionally not stored in Git because it is a large public file.

## Annotation Databases

- NCBI RefSeq protein remote BLAST database: `refseq_protein`
- NCBI BLAST taxonomy database:
  `https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz`
- Pfam-A HMM database:
  `https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz`
- Pfam2GO mapping:
  `https://current.geneontology.org/ontology/external2go/pfam2go`
- KEGG KOfam files:
  - `https://www.genome.jp/ftp/db/kofam/ko_list.gz`
  - `https://www.genome.jp/ftp/db/kofam/profiles.tar.gz`
- KofamScan source:
  `https://github.com/takaram/kofam_scan`
