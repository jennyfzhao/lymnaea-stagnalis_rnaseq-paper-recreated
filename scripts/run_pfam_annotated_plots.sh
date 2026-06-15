#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

for contrast in 18_month_vs_3_month 18_month_vs_6_month 6_month_vs_3_month
do
  python scripts/make_annotated_de_plots.py \
    --input "data/annotation/pfam/deseq2_annotated/${contrast}_DESeq2_results_with_pfam.csv" \
    --output-dir "figures/annotation_plots/${contrast}"
done
