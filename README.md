# Lymnaea stagnalis CNS Aging RNA-seq Reproduction

This repository documents a reproduction and extension of the *Lymnaea stagnalis*
central nervous system aging RNA-seq analysis from Rosato et al. 2021
(*BMC Genomics*, DOI: `10.1186/s12864-021-07946-y`).

The project follows the paper's reported workflow where possible, then adds an
open-source annotation route for GO and KEGG-style interpretation when Blast2GO
licensing was not practical.

## What This Project Contains

- RNA-seq project notes and reproduction plan.
- Scripts for local software activation, Pfam table building, and annotated DE plots.
- DESeq2 result tables, selected annotation summary tables, and publication-style figures.
- GO annotation from Pfam2GO and KEGG KO annotation from KofamScan.
- A GitHub Pages site in `docs/` explaining the workflow and major findings.

Large raw data and regenerated databases are intentionally excluded from Git:
FASTQ/SRA files, SAM/BAM files, reference genome indexes, Pfam/KOfam databases,
BLAST taxonomy databases, and the local `.venv/`.

## Main Findings

- Age-group RNA-seq samples separate in PCA space after variance-stabilizing transformation.
- Differential expression is strongest in old-vs-young CNS comparisons.
- Protein-domain annotation highlights transport, signaling, and membrane-associated terms.
- GO enrichment identifies several FDR-significant functional categories.
- KofamScan produced KEGG KO annotations, but KO-level enrichment was treated as exploratory
  when terms were not FDR-significant.

## Reproducibility

Activate the local project environment:

```bash
source scripts/activate_project.sh
```

After activation, tools installed inside `.venv/` are available on `PATH`.

See `software_manifest.md` for installed software and example commands.

Project-specific files live under:

```text
papers/lymnaea_stagnalis_CNS_aging/
```

The portfolio site lives under:

```text
docs/
```
