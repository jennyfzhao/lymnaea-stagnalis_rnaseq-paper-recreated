#!/usr/bin/env bash
# Activate the project Python environment and optional local command-line tools.

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
  echo "Create it with: python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt" >&2
  return 1 2>/dev/null || exit 1
fi

export PROJECT_ROOT
export BLASTDB="$PROJECT_ROOT/data/annotation/blastdb"
export NCBI_SETTINGS="$PROJECT_ROOT/.venv/.ncbi/user-settings.mkfg"

show_version() {
  local label="$1"
  shift
  if command -v "$1" >/dev/null 2>&1; then
    printf '%-9s %s\n' "$label:" "$("$@" 2>&1 | head -n 1)"
  else
    printf '%-9s not found on PATH\n' "$label:"
  fi
}

echo "Activated RNA-seq project environment"
echo "Project: $PROJECT_ROOT"
show_version "Python" python --version
show_version "SRA" prefetch --version
show_version "FastQC" fastqc --version
show_version "HISAT2" hisat2 --version
show_version "Samtools" samtools --version
show_version "StringTie" stringtie --version
show_version "BLAST+" blastp -version
show_version "gffread" gffread --version
