#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

mkdir -p \
  data/sra \
  data/fastq \
  data/aligned/logs \
  data/reference_genome \
  data/stringtie \
  data/fastqc-results \
  data/annotation/blastdb \
  data/annotation/pfam \
  data/annotation/kofam \
  reference

echo "Python venv is ready at .venv"
echo "For bioinformatics tools, create the conda/mamba environment with:"
echo "  micromamba create -f environment.yml"
