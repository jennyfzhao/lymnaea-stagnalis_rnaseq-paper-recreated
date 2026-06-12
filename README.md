# Lymnaea stagnalis CNS Aging RNA-seq Reproduction

This repository recreates and extends the *Lymnaea stagnalis* central nervous system aging RNA-seq workflow from Rosato et al. 2021, *BMC Genomics*, DOI: `10.1186/s12864-021-07946-y`.

The repository is flattened so the project folders are visible immediately:

```text
data/        compact input tables, annotation tables, and enrichment results
figures/     DESeq2, PCA, volcano, heatmap, annotation, and enrichment figures
paper/       citation and paper-source notes
scripts/     helper scripts for annotation tables and plots
software/    SRA accession lists, run metadata, and download helpers
```

Large public files are not stored in GitHub: FASTQ/SRA files, SAM/BAM files, HISAT2 indexes, reference FASTA files, Pfam/KOfam databases, BLAST taxonomy databases, and TransDecoder large intermediate FASTA/GFF outputs.

## Main Results

- Age-group RNA-seq samples separate in PCA space after variance-stabilizing transformation.
- Differential expression is strongest in the 18-month vs 3-month CNS comparison.
- Pfam annotation adds interpretable protein-domain context to differentially expressed genes.
- GO enrichment identifies FDR-significant functional categories.
- KofamScan produced KEGG KO annotations; KO-level enrichment is included as exploratory output.

## Data Used

The RNA-seq data are from NCBI BioProject `PRJNA698985` / SRA study `SRP304491`.

Runs used:

```text
3 months:  SRR13618140 SRR13618141 SRR13618144 SRR13618145
6 months:  SRR13618146 SRR13618148 SRR13618147 SRR13618149
18 months: SRR13618150 SRR13618142 SRR13618151 SRR13618143
```

The reference genome is NCBI Assembly `GCA_900036025.1` (`GCA_900036025.1_v1.0_genomic.fna.gz`).

See `DATA_SOURCES.md` for browser links, database URLs, and metadata details.

## From-Scratch Setup

Clone the repository and enter it:

```bash
git clone https://github.com/jennyfzhao/lymnaea-stagnalis_rnaseq-paper-recreated.git
cd lymnaea-stagnalis_rnaseq-paper-recreated
```

Create the Python virtual environment used by the custom scripts:

```bash
bash scripts/setup_python_venv.sh
source scripts/activate_project.sh
```

Install the bioinformatics tools from public conda/bioconda channels:

```bash
# Install micromamba first if needed:
# https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html

micromamba create -f environment.yml
micromamba activate lymnaea-rnaseq
```

The software sources are listed in `software_manifest.md`. The workflow table with commands, inputs, and outputs is `software_workflow_table.md`.

## Download Public Data

Download the SRA reads listed in `software/PRJNA698985_SraAccList.txt`:

```bash
JOBS=3 THREADS_PER_JOB=4 \
  software/download_fastq_parallel.sh \
  software/PRJNA698985_SraAccList.txt
```

Download the reference genome:

```bash
mkdir -p data/reference_genome
curl -L \
  https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/900/036/025/GCA_900036025.1_v1.0/GCA_900036025.1_v1.0_genomic.fna.gz \
  -o data/reference_genome/GCA_900036025.1_v1.0_genomic.fna.gz
gunzip -k data/reference_genome/GCA_900036025.1_v1.0_genomic.fna.gz
```

Download annotation databases:

```bash
mkdir -p data/annotation/blastdb data/annotation/pfam data/annotation/go_pfam2go data/annotation/kofam software

curl -L https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz \
  -o data/annotation/blastdb/taxdb.tar.gz
tar -xzf data/annotation/blastdb/taxdb.tar.gz -C data/annotation/blastdb

curl -L https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz \
  -o data/annotation/pfam/Pfam-A.hmm.gz
gunzip -k data/annotation/pfam/Pfam-A.hmm.gz
hmmpress data/annotation/pfam/Pfam-A.hmm

curl -L https://current.geneontology.org/ontology/external2go/pfam2go \
  -o data/annotation/go_pfam2go/pfam2go

curl -L https://www.genome.jp/ftp/db/kofam/ko_list.gz \
  -o data/annotation/kofam/ko_list.gz
gunzip -k data/annotation/kofam/ko_list.gz

curl -L https://www.genome.jp/ftp/db/kofam/profiles.tar.gz \
  -o data/annotation/kofam/profiles.tar.gz
tar -xzf data/annotation/kofam/profiles.tar.gz -C data/annotation/kofam

git clone https://github.com/takaram/kofam_scan software/kofam_scan
```

## Recreate Major Outputs

Build the genome index:

```bash
mkdir -p reference
hisat2-build data/reference_genome/GCA_900036025.1_v1.0_genomic.fna reference/hisat2_i
```

Run alignment, sorting, transcript assembly, and ORF prediction following the command patterns in `software_workflow_table.md`.

Recreate DESeq2 figures from the included count matrix and sample metadata:

```bash
Rscript figures/rnaseq_deseq2_figures.R
```

Recreate GO/KEGG enrichment tables and plots from the included annotation tables:

```bash
Rscript data/annotation/enrichment/run_go_kegg_enrichment_baseR.R
Rscript data/annotation/enrichment/plot_enrichment_baseR.R
```

Build Pfam-annotated DE plots after regenerating the Pfam `domtblout` file:

```bash
python scripts/build_pfam_annotation_tables.py \
  --pfam-domtblout data/annotation/pfam/transdecoder_pfam.domtblout \
  --deseq-dir figures/deseq2_results \
  --output-dir data/annotation/pfam

python scripts/make_annotated_de_plots.py \
  --input data/annotation/pfam/deseq2_annotated/18_month_vs_3_month_DESeq2_results_with_pfam.csv \
  --output-dir figures/annotation_plots/18_month_vs_3_month
```
