# Reproducibility Checklist

This repository is designed so a new user can clone it, recreate the compact analysis outputs from tracked files, and optionally rerun the large upstream RNA-seq workflow after downloading public data.

## Included in Git

- NCBI SRA metadata and accession list: `metadata/`
- Sample metadata and compact count matrices: `data/sample_metadata.tsv` and `data/expression_matrices/`
- Compact annotation and enrichment result tables: `data/annotation/`
- Display-ready PNG figures and supporting CSV summaries: `figures/`
- Public software environment definition: `environment.yml`
- Python package definition: `requirements.txt`
- Reusable scripts: `scripts/`

## Intentionally Not Included

These files are public, large, or regenerated and are therefore ignored:

- SRA/FASTQ files
- SAM/BAM/BAI alignment files
- HISAT2 indexes
- Reference genome FASTA files
- Pfam-A HMM database files
- KOfam profile database files
- BLAST taxonomy database files
- TransDecoder large FASTA/GFF/intermediate output files
- Duplicate PDF figure exports

## Fresh-Computer Reproduction

1. Clone the repository.
2. Create the Python environment:

   ```bash
   bash scripts/setup_python_venv.sh
   source scripts/activate_project.sh
   ```

3. Create and activate the bioinformatics environment:

   ```bash
   micromamba create -f environment.yml
   micromamba activate lymnaea-rnaseq
   ```

4. Download public RNA-seq reads:

   ```bash
   JOBS=3 THREADS_PER_JOB=4 \
     scripts/download_fastq_parallel.sh \
     metadata/PRJNA698985_SraAccList.txt
   ```

5. Download public reference and annotation resources:

   ```bash
   bash scripts/download_public_resources.sh
   ```

6. Recreate compact downstream outputs from tracked tables:

   ```bash
   Rscript figures/rnaseq_deseq2_figures.R
   Rscript data/annotation/enrichment/run_go_kegg_enrichment_baseR.R
   Rscript data/annotation/enrichment/plot_enrichment_baseR.R
   bash scripts/run_pfam_annotated_plots.sh
   ```

The full upstream alignment, assembly, ORF prediction, BLASTP, Pfam, and KofamScan command patterns are documented in `docs/software_workflow_table.md`.
