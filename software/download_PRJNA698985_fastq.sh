#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAIL_ROOT="$PROJECT_ROOT"
ACC_LIST="$SNAIL_ROOT/software/PRJNA698985_SraAccList.txt"
SRA_DIR="$SNAIL_ROOT/data/sra"
FASTQ_DIR="$SNAIL_ROOT/data/fastq"
TMP_DIR="$SNAIL_ROOT/data/tmp"

source "$PROJECT_ROOT/scripts/activate_project.sh"

mkdir -p "$SRA_DIR" "$FASTQ_DIR" "$TMP_DIR"

while IFS= read -r accession; do
  [ -n "$accession" ] || continue
  echo "==> Downloading $accession"
  prefetch "$accession" --output-directory "$SRA_DIR"
  echo "==> Converting $accession to FASTQ"
  fasterq-dump "$SRA_DIR/$accession" \
    --outdir "$FASTQ_DIR" \
    --temp "$TMP_DIR" \
    --split-files \
    --skip-technical \
    --threads 4 \
    --progress
done < "$ACC_LIST"
