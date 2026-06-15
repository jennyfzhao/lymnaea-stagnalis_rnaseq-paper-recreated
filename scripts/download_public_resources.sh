#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

mkdir -p \
  data/reference_genome \
  data/annotation/blastdb \
  data/annotation/pfam \
  data/annotation/go_pfam2go \
  data/annotation/kofam \
  tools

echo "==> Downloading Lymnaea stagnalis reference genome"
curl -L \
  https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/900/036/025/GCA_900036025.1_v1.0/GCA_900036025.1_v1.0_genomic.fna.gz \
  -o data/reference_genome/GCA_900036025.1_v1.0_genomic.fna.gz
gzip -dc data/reference_genome/GCA_900036025.1_v1.0_genomic.fna.gz \
  > data/reference_genome/GCA_900036025.1_v1.0_genomic.fna

echo "==> Downloading NCBI BLAST taxonomy database"
curl -L https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz \
  -o data/annotation/blastdb/taxdb.tar.gz
tar -xzf data/annotation/blastdb/taxdb.tar.gz -C data/annotation/blastdb

echo "==> Downloading and indexing Pfam-A"
curl -L https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz \
  -o data/annotation/pfam/Pfam-A.hmm.gz
gzip -dc data/annotation/pfam/Pfam-A.hmm.gz \
  > data/annotation/pfam/Pfam-A.hmm
hmmpress data/annotation/pfam/Pfam-A.hmm

echo "==> Downloading Pfam2GO mapping"
curl -L https://current.geneontology.org/ontology/external2go/pfam2go \
  -o data/annotation/go_pfam2go/pfam2go

echo "==> Downloading KEGG KOfam files"
curl -L https://www.genome.jp/ftp/db/kofam/ko_list.gz \
  -o data/annotation/kofam/ko_list.gz
gzip -dc data/annotation/kofam/ko_list.gz \
  > data/annotation/kofam/ko_list

curl -L https://www.genome.jp/ftp/db/kofam/profiles.tar.gz \
  -o data/annotation/kofam/profiles.tar.gz
tar -xzf data/annotation/kofam/profiles.tar.gz -C data/annotation/kofam

if [ ! -d tools/kofam_scan/.git ]; then
  echo "==> Cloning KofamScan"
  git clone https://github.com/takaram/kofam_scan tools/kofam_scan
else
  echo "==> KofamScan already exists at tools/kofam_scan"
fi

echo "Public reference and annotation resources are ready."
