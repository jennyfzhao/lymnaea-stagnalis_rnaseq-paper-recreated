# Lymnaea stagnalis CNS Aging RNA-seq Reproduction

This repository recreates and extends the *Lymnaea stagnalis* central nervous system aging RNA-seq workflow from Rosato et al. 2021, *BMC Genomics*, DOI: `10.1186/s12864-021-07946-y`.

The repository is flattened so the project folders are visible immediately:

```text
data/        compact input tables, annotation tables, and enrichment results
docs/        data-source notes, software manifest, and ordered workflow table
figures/     DESeq2, PCA, volcano, heatmap, annotation, and enrichment figures
metadata/    NCBI SRA accession list and run metadata
paper/       citation and paper-source notes
scripts/     helper scripts for annotation tables and plots
```

Large public files are not stored in GitHub: FASTQ/SRA files, SAM/BAM files, HISAT2 indexes, reference FASTA files, Pfam/KOfam databases, BLAST taxonomy databases, and TransDecoder large intermediate FASTA/GFF outputs.

## Main Results

- CNS RNA-seq samples separate by age after DESeq2 variance-stabilizing transformation, with 3-month samples separating from the 6-month and 18-month groups.
- DESeq2 retained 41,692 genes after filtering. The strongest transcriptomic shifts involve 3-month CNS samples: `6_month_vs_3_month` has 20,205 significant genes, `18_month_vs_3_month` has 18,449 significant genes, and `18_month_vs_6_month` has 889 significant genes using `padj < 0.05` and `abs(log2FoldChange) >= 1`.
- The smaller `18_month_vs_6_month` result suggests that the biggest expression transition in this dataset occurs between 3 months and later ages, rather than between 6 and 18 months.
- Pfam annotation identifies specific age-associated predicted genes with interpretable protein domains, including collagen-domain genes (`MSTRG.14013`, `MSTRG.14011`, `MSTRG.312`), a nerve-growth-factor-family gene (`MSTRG.14882`), an HSP90 chaperone gene (`MSTRG.30305`), cytochrome P450 gene `MSTRG.7692`, thioredoxin-like genes (`MSTRG.22291`, `MSTRG.21611`), and insulin/IGF/relaxin-family gene `MSTRG.21991`.
- In `18_month_vs_3_month`, GO enrichment is FDR-significant for transmembrane transporter activity (`GO:0022857`), membrane (`GO:0016020`), G protein-coupled receptor activity (`GO:0004930`), transmembrane transport (`GO:0055085`), and GPCR signaling (`GO:0007186`), pointing to age-associated changes in membrane transport and receptor signaling.
- In `18_month_vs_6_month`, the only FDR-significant GO term is extracellular matrix structural constituent (`GO:0005201`), matching the collagen-domain signal in the Pfam-annotated DE genes.
- KofamScan produced KEGG KO annotations for gene-level context, but KO enrichment did not pass FDR correction in any contrast, so KEGG plots are included as exploratory summaries rather than confirmed pathway enrichment.
- Overall, this reproduction aligns with the original Rosato et al. CNS aging paper in showing age-associated transcriptomic differences in *L. stagnalis* CNS tissue and in using predicted ORFs plus homology/domain-based annotation to interpret those changes. It should not be read as an exact numerical replication of every published table, because this repository rebuilds the workflow from public reads with its own recreated assembly, TransDecoder ORFs, Pfam/Pfam2GO annotation, KofamScan KO mapping, and enrichment thresholds.

See `docs/figures_annotations_and_findings.md` for figure-by-figure explanations, annotation-table interpretation, and the main biological conclusions.

## Data Used

The RNA-seq data are from NCBI BioProject `PRJNA698985` / SRA study `SRP304491`.

Runs used:

```text
3 months:  SRR13618140 SRR13618141 SRR13618144 SRR13618145
6 months:  SRR13618146 SRR13618148 SRR13618147 SRR13618149
18 months: SRR13618150 SRR13618142 SRR13618151 SRR13618143
```

The reference genome is NCBI Assembly `GCA_900036025.1` (`GCA_900036025.1_v1.0_genomic.fna.gz`).

See `docs/data_sources.md` for browser links, database URLs, and metadata details.

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

The software sources are listed in `docs/software_manifest.md`. The workflow table with commands, inputs, and outputs is `docs/software_workflow_table.md`. A concise fresh-computer checklist is in `docs/reproducibility_checklist.md`.

## Download Public Data

Download the SRA reads listed in `metadata/PRJNA698985_SraAccList.txt`:

```bash
JOBS=3 THREADS_PER_JOB=4 \
  scripts/download_fastq_parallel.sh \
  metadata/PRJNA698985_SraAccList.txt
```

Download the reference genome and public annotation resources:

```bash
bash scripts/download_public_resources.sh
```

## Recreate Major Outputs

Build the genome index:

```bash
mkdir -p reference
hisat2-build data/reference_genome/GCA_900036025.1_v1.0_genomic.fna reference/hisat2_i
```

Run alignment, sorting, transcript assembly, and ORF prediction following the command patterns in `docs/software_workflow_table.md`.

Recreate DESeq2 figures from the included count matrix and sample metadata:

```bash
Rscript figures/rnaseq_deseq2_figures.R
```

Recreate GO/KEGG enrichment tables and plots from the included annotation tables:

```bash
Rscript data/annotation/enrichment/run_go_kegg_enrichment_baseR.R
Rscript data/annotation/enrichment/plot_enrichment_baseR.R
```

Build Pfam-annotated DE plots after regenerating the Pfam `domtblout` file. The first command creates the Pfam-annotated DESeq2 tables for all contrasts; the loop creates the plot folder for each contrast:

```bash
python scripts/build_pfam_annotation_tables.py \
  --pfam-domtblout data/annotation/pfam/transdecoder_pfam.domtblout \
  --deseq-dir figures/deseq2_results \
  --output-dir data/annotation/pfam

for contrast in 18_month_vs_3_month 18_month_vs_6_month 6_month_vs_3_month
do
  python scripts/make_annotated_de_plots.py \
    --input "data/annotation/pfam/deseq2_annotated/${contrast}_DESeq2_results_with_pfam.csv" \
    --output-dir "figures/annotation_plots/${contrast}"
done
```

Equivalent shortcut:

```bash
bash scripts/run_pfam_annotated_plots.sh
```

The tracked annotated plot outputs are stored in:

```text
figures/annotation_plots/18_month_vs_3_month/
figures/annotation_plots/18_month_vs_6_month/
figures/annotation_plots/6_month_vs_3_month/
```
