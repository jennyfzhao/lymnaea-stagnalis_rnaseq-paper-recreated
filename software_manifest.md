# Software Manifest

This project keeps reusable software inside the project directory so analyses are easier to reproduce.

## Active Environment

- Python virtual environment: `.venv/`
- Activation script: `scripts/activate_project.sh`
- Local command-line tools: `.venv/tools/`

Activate everything with:

```bash
source scripts/activate_project.sh
```

## Installed Tools

| Tool | Version | Location | Notes |
| --- | --- | --- | --- |
| SRA Toolkit | 3.4.1 | `.venv/tools/sratoolkit` | Provides `prefetch`, `fasterq-dump`, `fastq-dump`, and related utilities. |
| FastQC | 0.12.1 | `.venv/tools/FastQC` | Generates HTML and ZIP quality-control reports from FASTQ files. |
| HISAT2 | 2.2.1 | `.venv/tools/hisat2` | Splice-aware aligner for RNA-seq reads; provides `hisat2`, `hisat2-build`, and `hisat2-inspect`. |
| Samtools | 1.23.1 | `.venv/tools/samtools-env` | Converts, sorts, indexes, and summarizes SAM/BAM/CRAM alignment files. |
| StringTie | 3.0.3 | `.venv/tools/stringtie` | Assembles and quantifies transcripts from coordinate-sorted RNA-seq BAM alignments. |
| NCBI BLAST+ | 2.17.0+ | `.venv/tools/blast` | Provides `blastp`, `makeblastdb`, `update_blastdb.pl`, and related BLAST command-line tools. |
| NCBI BLAST taxdb | current download | `papers/lymnaea_stagnalis_CNS_aging/data/annotation/blastdb` | Provides taxonomy lookups for BLAST output fields such as `staxids` and `sscinames`. |
| Annotation environment | local conda env | `.venv/tools/annotation-env` | Protein annotation tools installed with project-local micromamba. |
| gffread | 0.12.9 | `.venv/tools/annotation-env/bin/gffread` | Extracts transcript FASTA sequences from GTF/GFF plus genome FASTA. |
| TransDecoder | 6.0.0 | `.venv/tools/annotation-env/bin/TransDecoder.*` | Predicts coding regions and protein sequences from transcript FASTA files. |
| Eclipse Temurin Java Runtime | 21.0.11+10 | `.venv/tools/java` | Project-local Java runtime used by FastQC. |

## Common SRA Commands

Download an SRA run:

```bash
prefetch SRR_ACCESSION --output-directory data/raw
```

Convert an SRA run to FASTQ:

```bash
fasterq-dump data/raw/SRR_ACCESSION --outdir data/raw --threads 4
```

Replace `SRR_ACCESSION` with the actual run accession, such as `SRR12345678`.

## Common FastQC Commands

Generate an HTML report for one FASTQ file:

```bash
fastqc data/raw/sample.fastq.gz --outdir results
```

Generate reports for all gzipped FASTQ files in `data/raw`:

```bash
fastqc data/raw/*.fastq.gz --outdir results --threads 4
```

## Common HISAT2 Commands

Build a HISAT2 genome index from a reference genome FASTA:

```bash
hisat2-build reference/genome.fna.gz reference/hisat2_index/genome
```

Align paired-end reads to a HISAT2 index:

```bash
hisat2 -x reference/hisat2_index/genome \
  -1 sample_1.fastq.gz \
  -2 sample_2.fastq.gz \
  -S sample.sam \
  --threads 4
```

## Common Samtools Commands

Convert SAM to BAM:

```bash
samtools view -@ 4 -bS sample.sam > sample.bam
```

Sort BAM:

```bash
samtools sort -@ 4 -o sample.sorted.bam sample.bam
```

Index sorted BAM:

```bash
samtools index sample.sorted.bam
```

## Common StringTie Commands

Estimate transcript abundances for one coordinate-sorted BAM file using a reference annotation:

```bash
stringtie sample.sorted.bam \
  -G reference/annotation.gtf \
  -e -B \
  -p 4 \
  -o sample/stringtie.gtf
```

## Common Protein Annotation Commands

Extract transcript sequences from a merged GTF and genome FASTA:

```bash
gffread papers/lymnaea_stagnalis_CNS_aging/data/stringtie/stringtie_merged.gtf \
  -g papers/lymnaea_stagnalis_CNS_aging/data/reference_genome/GCA_900036025.1_v1.0_genomic.fna.gz \
  -w papers/lymnaea_stagnalis_CNS_aging/data/annotation/transcripts.fa
```

Predict proteins from transcript sequences:

```bash
TransDecoder.LongOrfs \
  -t papers/lymnaea_stagnalis_CNS_aging/data/annotation/transcripts.fa \
  -O papers/lymnaea_stagnalis_CNS_aging/data/annotation

TransDecoder.Predict \
  -t papers/lymnaea_stagnalis_CNS_aging/data/annotation/transcripts.fa \
  -O papers/lymnaea_stagnalis_CNS_aging/data/annotation
```

Integrate BLASTP and Pfam evidence into predicted ORF annotation:

```bash
TransDecoder.Predict \
  -t papers/lymnaea_stagnalis_CNS_aging/data/annotation/transcripts.fa \
  -O papers/lymnaea_stagnalis_CNS_aging/data/annotation \
  --retain_blastp_hits papers/lymnaea_stagnalis_CNS_aging/data/annotation/blastp_refseq9/lymnaea_transdecoder_vs_refseq9.blastp.tsv \
  --retain_pfam_hits papers/lymnaea_stagnalis_CNS_aging/data/annotation/pfam/transdecoder_pfam.domtblout
```
