# Lymnaea stagnalis CNS aging

- Paper PDF: `paper/lymnaea_stagnalis_CNS_aging_BMCGenomics_2021.pdf`
- Data accession: NCBI BioProject `PRJNA698985`
- Put downloaded FASTQ/reference/count files in `data/`.
- Put environment files, install notes, or helper scripts in `software/`.
- Put recreated plots and exported figure panels in `figures/`.

Good first targets: Figure 1 volcano plots, DEG overlap, heatmaps; Figure 2 GO enrichment; Figure 3 KEGG summary.

## Download FASTQ files

Use the parallel SRA downloader from the project root:

```bash
source scripts/activate_project.sh

JOBS=3 THREADS_PER_JOB=4 \
  papers/lymnaea_stagnalis_CNS_aging/software/download_fastq_parallel.sh \
  SRR13618150 SRR13618151 SRR13618152
```

By default, this downloads SRA files to `papers/lymnaea_stagnalis_CNS_aging/data/sra`
and FASTQ files to `papers/lymnaea_stagnalis_CNS_aging/data/fastq`.
You can also pass a text file with one accession per line, such as
`papers/lymnaea_stagnalis_CNS_aging/software/PRJNA698985_SraAccList.txt`.
