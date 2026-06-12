# Software Manifest

This file lists the public sources for software used in the final workflow and how to install them from a clean checkout.

The easiest reproducible setup is:

```bash
bash scripts/setup_python_venv.sh
micromamba create -f environment.yml
micromamba activate lymnaea-rnaseq
```

| Software/resource | Public source | Install route used for a fresh checkout | Purpose in this project |
| --- | --- | --- | --- |
| Python virtual environment | Python standard library `venv` | `bash scripts/setup_python_venv.sh` | Runs custom Python scripts and installs `requirements.txt`. |
| SRA Toolkit | https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit | `environment.yml` via bioconda, or NCBI binary downloads | Downloads public SRA runs and converts them to FASTQ with `prefetch` and `fasterq-dump`. |
| FastQC | https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ | `environment.yml` via bioconda, or Babraham FastQC download | Quality control reports for FASTQ files. |
| HISAT2 | https://github.com/DaehwanKimLab/hisat2/releases | `environment.yml` via bioconda | Builds the genome index and aligns paired RNA-seq reads. |
| Samtools | https://www.htslib.org/download/ | `environment.yml` via bioconda | Sorts and indexes SAM/BAM alignment files. |
| StringTie | https://github.com/gpertea/stringtie/releases | `environment.yml` via bioconda | Assembles transcripts and estimates abundance from sorted BAM files. |
| gffread | https://github.com/gpertea/gffread | `environment.yml` via bioconda | Extracts transcript FASTA from GTF/GFF and genome FASTA. |
| TransDecoder | https://github.com/TransDecoder/TransDecoder/releases | `environment.yml` via bioconda | Predicts coding ORFs and protein FASTA sequences. |
| NCBI BLAST+ | https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ | `environment.yml` via bioconda, or NCBI BLAST+ binaries | Runs BLASTP against remote NCBI RefSeq protein sequences. |
| NCBI BLAST taxdb | https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz | `curl` download into `data/annotation/blastdb/` | Enables BLAST taxonomy output fields. |
| HMMER | http://eddylab.org/software/hmmer/ | `environment.yml` via bioconda | Searches predicted proteins against Pfam-A HMMs. |
| Pfam-A | https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz | `curl`, `gunzip`, then `hmmpress` | Protein-domain database for `hmmscan`. |
| Pfam2GO | https://current.geneontology.org/ontology/external2go/pfam2go | `curl` download into `data/annotation/go_pfam2go/` | Maps Pfam domains to Gene Ontology terms. |
| KofamScan | https://github.com/takaram/kofam_scan | `git clone` into `software/kofam_scan` | Assigns KEGG Orthology identifiers to predicted proteins. |
| KEGG KOfam data | https://www.genome.jp/ftp/db/kofam/ | `curl` download of `ko_list.gz` and `profiles.tar.gz` | HMM profiles and thresholds used by KofamScan. |
| R / DESeq2 / ggplot2 / pheatmap | Bioconductor and CRAN through conda/bioconda | `environment.yml` | Differential expression analysis and figure generation. |
