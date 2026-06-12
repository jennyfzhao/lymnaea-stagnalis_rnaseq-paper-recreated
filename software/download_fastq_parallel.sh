#!/usr/bin/env bash
set -euo pipefail

# Download and convert multiple SRA runs in parallel.
#
# Usage examples:
#   source scripts/activate_project.sh
#   software/download_fastq_parallel.sh SRR123 SRR456 SRR789
#
#   JOBS=4 THREADS_PER_JOB=2 \
#     software/download_fastq_parallel.sh \
#     software/PRJNA698985_SraAccList.txt

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAIL_ROOT="$PROJECT_ROOT"

SRA_DIR="${SRA_DIR:-$SNAIL_ROOT/data/sra}"
FASTQ_DIR="${FASTQ_DIR:-$SNAIL_ROOT/data/fastq}"
TMP_DIR="${TMP_DIR:-$SNAIL_ROOT/data/tmp}"
JOBS="${JOBS:-3}"
THREADS_PER_JOB="${THREADS_PER_JOB:-4}"

if ! command -v prefetch >/dev/null 2>&1 || ! command -v fasterq-dump >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/scripts/activate_project.sh"
fi

mkdir -p "$SRA_DIR" "$FASTQ_DIR" "$TMP_DIR"

if [ "$#" -eq 0 ]; then
  cat >&2 <<EOF
Usage:
  $0 SRR123 SRR456 SRR789
  $0 path/to/SraAccList.txt

Optional settings:
  JOBS=3              number of SRA runs to process in parallel
  THREADS_PER_JOB=4   fasterq-dump threads per SRA run
  SRA_DIR=$SRA_DIR
  FASTQ_DIR=$FASTQ_DIR
  TMP_DIR=$TMP_DIR
EOF
  exit 2
fi

ACCESSION_FILE="$(mktemp "$TMP_DIR/accessions.XXXXXX")"
cleanup() {
  rm -f "$ACCESSION_FILE"
}
trap cleanup EXIT

if [ "$#" -eq 1 ] && [ -f "$1" ]; then
  sed '/^[[:space:]]*$/d; /^[[:space:]]*#/d' "$1" > "$ACCESSION_FILE"
else
  printf '%s\n' "$@" > "$ACCESSION_FILE"
fi

run_one() {
  local accession="$1"
  local run_tmp="$TMP_DIR/$accession"

  mkdir -p "$run_tmp"

  echo "==> [$accession] prefetch to $SRA_DIR"
  prefetch "$accession" --output-directory "$SRA_DIR"

  echo "==> [$accession] fasterq-dump to $FASTQ_DIR"
  fasterq-dump "$SRA_DIR/$accession" \
    --outdir "$FASTQ_DIR" \
    --temp "$run_tmp" \
    --split-files \
    --skip-technical \
    --threads "$THREADS_PER_JOB" \
    --progress

  echo "==> [$accession] done"
}

export SRA_DIR FASTQ_DIR TMP_DIR THREADS_PER_JOB
export -f run_one

echo "Downloading FASTQ files to: $FASTQ_DIR"
echo "Keeping prefetched SRA files in: $SRA_DIR"
echo "Parallel SRA jobs: $JOBS"
echo "fasterq-dump threads per job: $THREADS_PER_JOB"

xargs -n 1 -P "$JOBS" bash -c 'run_one "$@"' _ < "$ACCESSION_FILE"
