#!/usr/bin/env bash
# Activate the project Python environment and local command-line tools.

if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  SCRIPT_PATH="${(%):-%x}"
else
  SCRIPT_PATH="$0"
fi

PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"

if [ -f "$PROJECT_ROOT/.venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.venv/bin/activate"
else
  echo "Missing Python virtual environment at $PROJECT_ROOT/.venv" >&2
  echo "Create it with: python3 -m venv .venv" >&2
  return 1 2>/dev/null || exit 1
fi

export PROJECT_ROOT
export JAVA_HOME="$PROJECT_ROOT/.venv/tools/java"
export HISAT2_HOME="$PROJECT_ROOT/.venv/tools/hisat2"
export SAMTOOLS_HOME="$PROJECT_ROOT/.venv/tools/samtools-env"
export STRINGTIE_HOME="$PROJECT_ROOT/.venv/tools/stringtie"
export BLAST_HOME="$PROJECT_ROOT/.venv/tools/blast"
export ANNOTATION_ENV="$PROJECT_ROOT/.venv/tools/annotation-env"
export EGGNOG_DATA_DIR="$PROJECT_ROOT/papers/lymnaea_stagnalis_CNS_aging/data/annotation/eggnog_data"
export BLASTDB="$PROJECT_ROOT/papers/lymnaea_stagnalis_CNS_aging/data/annotation/blastdb"
export PATH="$BLAST_HOME/bin:$STRINGTIE_HOME/bin:$SAMTOOLS_HOME/bin:$HISAT2_HOME/bin:$PROJECT_ROOT/.venv/tools/FastQC:$PROJECT_ROOT/.venv/tools/sratoolkit/bin:$JAVA_HOME/bin:$PATH:$ANNOTATION_ENV/bin"
export NCBI_SETTINGS="$PROJECT_ROOT/.venv/.ncbi/user-settings.mkfg"

echo "Activated RNA-seq project environment"
echo "Project: $PROJECT_ROOT"
echo "Python:  $(python --version 2>&1)"
echo "SRA:     $(prefetch --version 2>&1)"
echo "FastQC:  $(fastqc --version 2>&1)"
echo "HISAT2:  $(hisat2 --version 2>&1 | head -n 1)"
echo "Samtools: $(samtools --version 2>&1 | head -n 1)"
echo "StringTie: $(stringtie --version 2>&1)"
echo "BLAST+:  $(blastp -version 2>&1 | head -n 1)"
echo "gffread: $(gffread --version 2>&1)"
echo "DIAMOND: $(diamond version 2>&1)"
echo "eggNOG-mapper: $(emapper.py --version 2>&1 | tail -n 1)"
