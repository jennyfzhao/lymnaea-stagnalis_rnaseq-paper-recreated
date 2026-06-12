# Snail RNA-seq Project Pipeline Table

Project: *Lymnaea stagnalis* CNS aging RNA-seq reproduction  
Local folder: `papers/lymnaea_stagnalis_CNS_aging`  
Public accession: `PRJNA698985`  
Study design from local run metadata: paired-end RNA-seq, Illumina NovaSeq 6000, 150 bp reads from 12 runs: four 3-month CNS samples, four 6-month CNS samples, and four 18-month CNS samples.

Paper source used for methods: Rosato et al. 2021, BMC Genomics, "Transcriptome analysis provides genome annotation and expression profiles in the central nervous system of *Lymnaea stagnalis* at different ages" ([full text](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-021-07946-y), DOI: `10.1186/s12864-021-07946-y`).

## Paper-Specific Pipeline vs. Generic RNA-seq Pipeline

This table is the clearest way to separate what the paper explicitly did from what a generic teaching/reproduction pipeline usually adds.

| Pipeline area | What the snail paper specifically reports | Generic RNA-seq step? | Did this local project do it yet? | Notes for reproduction |
|---|---|---|---|---|
| Biological design | Young 3-month, adult 6-month, and old 18-month snails; 4 biological replicates per age; each replicate pooled CNS from 10 snails. | Yes, experimental design/sample sheet. | Metadata is present in `PRJNA698985_runinfo.csv`; local FASTQ names map to 3, 6, and 18 month samples. | Keep `condition` as `3month`, `6month`, `18month`; use four replicates per condition in DESeq2. |
| RNA extraction / wet lab | RNeasy Mini Kit, Nanodrop concentration check, TURBO DNA-free gDNA removal. | Wet-lab upstream step. | Not done locally; already completed by the original authors before sequencing. | Mentioned for context only; local analysis starts from public SRA reads. |
| Library construction | PolyA enrichment by Novogene; Illumina NovaSeq 6000; paired-end 150 bp; insert size 250-300 bp. | Yes. | Reflected in SRA metadata: `PAIRED`, `Illumina NovaSeq 6000`, average read length 300 for paired reads. | Use paired-end commands throughout. |
| Download raw reads | Paper archived reads under BioProject `PRJNA698985`; it does not describe SRA download commands. | Yes for reproduction. | Yes, `.sra` files exist for 12 accessions. | This is a local reproduction step, not a paper-method step. |
| Convert SRA to FASTQ | Not described in the paper methods. | Yes for reproduction from SRA. | Yes, paired FASTQ files exist for 12 accessions. | This is needed because HISAT2 and FastQC operate on FASTQ, not SRA archives. |
| FastQC read QC | The paper methods do not mention FastQC. | Yes, commonly included before alignment. | Partial: FastQC reports exist for `SRR13618150_1` and `SRR13618150_2`. | Include FastQC in the local workflow so the reproduction can document read quality even though the paper did not report it. |
| Adapter/quality trimming | The paper does not report Cutadapt, Trimmomatic, or a separate trimming step. It reports HISAT2 soft clipping to exclude low-quality bases at read ends. | Often yes, depending on FastQC results. | Not seen locally. | Do not claim the paper trimmed reads with Cutadapt/Trimmomatic. Add trimming only if FastQC shows adapters/poor tails; otherwise HISAT2 soft clipping is the paper-matching route. |
| Genome alignment | HISAT2 to *L. stagnalis* genome assembly v1.0 `GCA_900036025.1`; HISAT2 soft clipping enabled. | Yes. | Partial: HISAT2 index exists; SAM alignments exist for 3 runs. | The exact local SAM header records HISAT2 2.2.1 and `--threads 4`. |
| Alignment rate | Paper reports 55.6-69.1 million reads per sample and about 74% average mapping to the reference genome. | Yes, alignment QC. | HISAT2 summary files are referenced in commands but not currently present in `data/aligned/logs`. | Re-run or preserve `--summary-file` outputs for every sample. |
| Transcript assembly | StringTie assembled transcripts from aligned reads. | Common in genome-guided transcriptome projects, but not required for a simple count-only DESeq2 workflow. | Not seen locally. | Needed to reproduce paper annotation/transcript assembly outputs. |
| Expression abundance | Paper quantified transcript abundance as FPKM and presented TPM in figures for between-sample comparability. | Yes for expression-summary figures; raw counts still needed for DESeq2. | Not seen locally. | Use StringTie abundance tables for TPM/FPKM-style heatmaps if reproducing the paper closely. |
| ORF/CDS prediction | TransDecoder v5.5.0 retrieved CDS and amino acid sequences from assembled transcripts/merged StringTie annotation. | Annotation-specific, not part of minimal generic DE pipeline. | Not seen locally. | Needed only if reproducing the paper's genome annotation resource, protein annotation, Pfam/GO/KEGG steps from scratch. |
| Protein homology annotation | BLASTP against NCBI RefSeq amino acid sequences from nine molluscan species. | Annotation-specific. | Not seen locally. | Paper species: *Biomphalaria glabrata*, *Aplysia californica*, *Lottia gigantea*, *Pomacea canaliculata*, *Octopus bimaculoides*, *Octopus vulgaris*, *Crassostrea virginica*, *Crassostrea gigas*, *Mizuhopecten yessoensis*. |
| Pfam domain annotation | HMMER3 `hmmscan` searched inferred amino acid sequences for Pfam domains. | Annotation-specific. | Not seen locally. | Integrated with BLASTP results into TransDecoder ORF annotations. |
| GO/KEGG annotation | Blast2GO on predicted proteins at least 100 amino acids; reference protein database `refseq_protein v5`; GO version 2020.06. | Common for interpretation, but databases/tools vary. | Not seen locally. | Paper parameters: e-value `1.0E-3`, top 20 BLAST hits, word size `6`, HSP length cutoff `33`. |
| Read counting | featureCounts from Subread v1.5.0 generated raw read counts. | Yes for DESeq2. | Not seen locally. | Requires a GTF/GFF annotation and sorted BAM files. |
| Differential expression | DESeq2 on raw featureCounts counts. | Yes. | Not seen locally; plotting code is included below but needs count tables first. | Paper pairwise comparisons: young vs adult, young vs old, adult vs old. DEG threshold: FDR-adjusted p value `< 0.05` and `abs(log2 fold change) > 1`. |
| DEG counts reported by paper | Young vs adult: 20,141; young vs old: 18,394; adult vs old: 3,108; shared across all comparisons: 455. | Results target. | Not reproduced locally yet. | These are useful check numbers once DESeq2 is run. |
| PCA/correlation | Paper reports PCA and pairwise Pearson correlations of expression profiles; PC1 explains 68.12%, PC2 explains 7%. | Yes. | Plotting code included below; not run yet. | Paper text describes PCA using expression abundance/log2 count style summaries; exact plotting script was not provided. |
| Venn/volcano/heatmap | Paper Fig. 1 includes DEG Venn, volcano plots, heatmaps of top DE genes and top 2000 high-variance genes. | Yes for reporting. | Plotting code included below; not run yet. | Paper thresholds: FDR `< 0.05`, `abs(log2 fold change) > 1`; heatmap uses top 100 genes from each pairwise comparison collapsed to 143 unique genes, plus top 2000 high-variance genes. |
| GO enrichment | Fisher exact test with FDR correction; plotted with R/ggplot2. | Yes for interpretation. | Plotting code included below; enrichment table not present yet. | Paper used DEG sets from all pairwise overlap and each pairwise comparison. |
| KEGG enrichment / pathway plot | Blast2GO loaded KEGG pathways; top 20 KEGG pathways shown by number of annotated sequences; enrichment used Fisher exact test plus FDR correction. | Yes for interpretation. | Plotting code included below; KEGG table not present yet. | Paper reports 1,159 transcripts/genes associated with KEGG pathways. |
| qPCR validation | RT-qPCR validation for selected genes; SuperScript IV VILO, SYBR Green, QuantStudio 5; normalized to beta-tubulin; ANOVA and Tukey HSD. | Validation step, not usually reproduced from public RNA-seq alone. | Not possible from current local sequencing files. | Mention as a paper validation step, but skip in computational reproduction unless wet-lab qPCR data are available. |

| Step | Software | Why this software is used | What it takes as input | Command / coding to run | Specific parameters used or recommended | What it outputs |
|---|---|---|---|---|---|---|
| 1. Activate project environment | Bash activation script, local `.venv` | Makes the project-local tools available without relying on system installs. The manifest says SRA Toolkit, FastQC, HISAT2, and Java live under `.venv/tools`. | Existing project folder with `.venv` and `scripts/activate_project.sh`. | `source scripts/activate_project.sh` | No analysis parameters. The script adds SRA Toolkit, FastQC, HISAT2, and Java to `PATH`. | Terminal confirms versions for Python, SRA Toolkit, FastQC, and HISAT2. |
| 2. Define sample list and sample groups | SRA RunInfo CSV, text accession lists | Keeps the analysis reproducible by linking each FASTQ pair to an age group and biological replicate. | `papers/lymnaea_stagnalis_CNS_aging/software/PRJNA698985_runinfo.csv` and `PRJNA698985_SraAccList.txt`. | Accession list already present:<br>`SRR13618150 SRR13618142 SRR13618151 SRR13618143` = 18 month<br>`SRR13618140 SRR13618141 SRR13618144 SRR13618145` = 3 month<br>`SRR13618146 SRR13618148 SRR13618147 SRR13618149` = 6 month | Important metadata fields: `LibraryStrategy=RNA-Seq`, `LibrarySource=TRANSCRIPTOMIC`, `LibrarySelection=RANDOM`, `LibraryLayout=PAIRED`, `avgLength=300`, `Platform=ILLUMINA`, `Model=Illumina NovaSeq 6000`. | Sample sheet for downstream DESeq2, for example columns `sample`, `run`, `condition`, `replicate`. |
| 3. Download SRA files | SRA Toolkit `prefetch` | Downloads raw sequencing run archives from NCBI SRA while preserving accession structure. | SRA accessions from `PRJNA698985_SraAccList.txt`. Requires network and enough disk space. Each run is roughly 4.9-6.2 GB as SRA and much larger after FASTQ/SAM conversion. | Single-run script:<br>`papers/lymnaea_stagnalis_CNS_aging/software/download_PRJNA698985_fastq.sh`<br><br>Parallel command from the README:<br>`JOBS=3 THREADS_PER_JOB=4 papers/lymnaea_stagnalis_CNS_aging/software/download_fastq_parallel.sh papers/lymnaea_stagnalis_CNS_aging/software/PRJNA698985_SraAccList.txt` | `prefetch "$accession" --output-directory "$SRA_DIR"`.<br>Default `SRA_DIR=papers/lymnaea_stagnalis_CNS_aging/data/sra`.<br>Parallel script parameter: `JOBS=3` means 3 SRA runs at a time. | `.sra` files, one folder per accession, such as `data/sra/SRR13618140/SRR13618140.sra`. |
| 4. Convert SRA to paired FASTQ | SRA Toolkit `fasterq-dump` | Converts compressed SRA archives into normal FASTQ files that QC and aligners can read. | `.sra` files from step 3. Requires large temporary storage. | Done inside both download scripts:<br>`fasterq-dump "$SRA_DIR/$accession" --outdir "$FASTQ_DIR" --temp "$run_tmp" --split-files --skip-technical --threads "$THREADS_PER_JOB" --progress` | `--split-files` writes paired reads as `_1.fastq` and `_2.fastq`.<br>`--skip-technical` removes technical reads.<br>`--threads 4` by default through `THREADS_PER_JOB=4`.<br>`--progress` prints progress.<br>Default `FASTQ_DIR=papers/lymnaea_stagnalis_CNS_aging/data/fastq`. | Paired FASTQ files such as `data/fastq/SRR13618140_1.fastq` and `data/fastq/SRR13618140_2.fastq`. |
| 5. Raw-read quality control | FastQC 0.12.1, Java 21 | Checks whether raw reads have good base quality, unusual GC content, adapter contamination, overrepresented sequences, or sequence length problems before alignment. This is a generic/local reproducibility step; the Rosato et al. paper methods do not mention FastQC. | FASTQ files from step 4. | One pair:<br>`fastqc papers/lymnaea_stagnalis_CNS_aging/data/fastq/SRR13618150_1.fastq papers/lymnaea_stagnalis_CNS_aging/data/fastq/SRR13618150_2.fastq --outdir papers/lymnaea_stagnalis_CNS_aging/data/fastqc-results --threads 2`<br><br>All FASTQ files:<br>`fastqc papers/lymnaea_stagnalis_CNS_aging/data/fastq/*.fastq --outdir papers/lymnaea_stagnalis_CNS_aging/data/fastqc-results --threads 4` | `--outdir` sends reports to `data/fastqc-results`.<br>`--threads 4` parallelizes file processing.<br>Project already contains FastQC outputs for `SRR13618150_1` and `SRR13618150_2`. | For each FASTQ: `<sample>_fastqc.html` and `<sample>_fastqc.zip`. HTML is human-readable; ZIP contains machine-readable QC tables. |
| 6. Optional trimming if QC shows adapters or poor tails | Cutadapt or Trimmomatic, recommended but not currently installed in the project manifest | Removes adapter sequence or low-quality ends if FastQC reports contamination or low-quality tails. The paper did not report a separate trimming program; it specifically reports HISAT2 soft clipping to exclude low-quality bases at both read ends. | Raw FASTQ files and adapter choice. | Example Cutadapt command if installed:<br>`cutadapt -j 4 -q 20,20 -m 30 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o data/trimmed/SRR13618140_1.trim.fastq -p data/trimmed/SRR13618140_2.trim.fastq data/fastq/SRR13618140_1.fastq data/fastq/SRR13618140_2.fastq` | `-j 4` uses 4 threads.<br>`-q 20,20` trims low-quality bases from both read ends at Q20.<br>`-m 30` discards reads shorter than 30 bp.<br>`-a/-A` are Illumina paired-end adapter sequences.<br>Only run this if QC supports it. To match the paper most closely, skip separate trimming unless FastQC indicates it is needed. | Trimmed FASTQ pairs in `data/trimmed`, plus trimming logs. If trimming is skipped, use raw FASTQ for alignment. |
| 7. Get reference genome | NCBI genome FASTA already present locally | Alignment requires the reference genome sequence. The folder already contains the *L. stagnalis* genome FASTA. | `data/reference_genome/GCA_900036025.1_v1.0_genomic.fna` or `.fna.gz`. | Existing file:<br>`papers/lymnaea_stagnalis_CNS_aging/data/reference_genome/GCA_900036025.1_v1.0_genomic.fna` | No command parameters if already downloaded. If using `.gz`, most tools can read it directly or you can decompress with `gunzip -k`. | Reference FASTA used to build the HISAT2 index. |
| 8. Build splice-aware genome index | HISAT2 2.2.1 `hisat2-build` | HISAT2 needs an indexed reference to align RNA-seq reads quickly. HISAT2 is splice-aware, so it is appropriate for eukaryotic RNA-seq genome alignment. | Reference genome FASTA from step 7. | Recommended command matching local index prefix:<br>`hisat2-build papers/lymnaea_stagnalis_CNS_aging/data/reference_genome/GCA_900036025.1_v1.0_genomic.fna papers/lymnaea_stagnalis_CNS_aging/reference/hisat2_i` | Index basename is `papers/lymnaea_stagnalis_CNS_aging/reference/hisat2_i`.<br>The local folder already contains `hisat2_i.1.ht2` through `hisat2_i.8.ht2`. | HISAT2 index files `hisat2_i.*.ht2`. |
| 9. Align paired reads to the genome | HISAT2 2.2.1 | Maps each read pair to the reference genome. The SAM records are the bridge between FASTQ reads and genomic features/counting. This matches the paper, which aligned reads to *L. stagnalis* assembly v1.0 `GCA_900036025.1` with HISAT2 and enabled soft clipping for low-quality read ends. | Paired FASTQ files and HISAT2 index. | Exact command recorded in the local `SRR13618140.sam` header:<br>`hisat2 -x papers/lymnaea_stagnalis_CNS_aging/reference/hisat2_i -S papers/lymnaea_stagnalis_CNS_aging/data/aligned/SRR13618140.sam --threads 4 --summary-file papers/lymnaea_stagnalis_CNS_aging/data/aligned/logs/SRR13618140_hisat2_summary.txt -1 papers/lymnaea_stagnalis_CNS_aging/data/fastq/SRR13618140_1.fastq -2 papers/lymnaea_stagnalis_CNS_aging/data/fastq/SRR13618140_2.fastq` | `-x` points to the index basename.<br>`-1/-2` give mate 1 and mate 2 FASTQ files.<br>`-S` writes SAM output.<br>`--threads 4` uses 4 CPU threads.<br>`--summary-file` writes alignment summary metrics.<br>The SAM header also records internal HISAT2 wrapper settings `--sp 2,1` and `--read-lengths 150`.<br>Paper target: about 74% average mapping. | SAM alignment files such as `data/aligned/SRR13618140.sam`. The project currently has SAM files for `SRR13618140`, `SRR13618141`, and `SRR13618142`. |
| 10. Convert, sort, and index alignments | SAMtools, recommended but not currently installed in the project manifest | SAM files are very large. BAM is compressed; sorted/indexed BAM is the standard input for counting, genome browsers, and many QC tools. | SAM files from step 9. | Example command if SAMtools is installed:<br>`samtools sort -@ 4 -o papers/lymnaea_stagnalis_CNS_aging/data/aligned/SRR13618140.sorted.bam papers/lymnaea_stagnalis_CNS_aging/data/aligned/SRR13618140.sam`<br>`samtools index papers/lymnaea_stagnalis_CNS_aging/data/aligned/SRR13618140.sorted.bam` | `sort -@ 4` uses 4 threads.<br>`-o` names the sorted BAM output.<br>After confirming BAMs are valid, large SAM files can be archived or removed only if desired. | `*.sorted.bam` and `*.sorted.bam.bai`. |
| 11. Assemble transcripts and estimate expression, paper route | StringTie, reported in the paper | The paper used StringTie to assemble transcripts from aligned reads. It quantified expression as FPKM and presented TPM in figures for between-sample comparability. This is useful for transcript discovery/annotation and expression summaries. | Sorted BAM files, reference annotation if available. | Example reference-guided command:<br>`stringtie data/aligned/SRR13618140.sorted.bam -p 4 -G reference/annotation.gtf -o data/stringtie/SRR13618140.gtf -A data/stringtie/SRR13618140.gene_abund.tsv` | `-p 4` uses 4 threads.<br>`-G annotation.gtf` guides assembly with known genes if an annotation is available.<br>`-o` writes assembled transcripts.<br>`-A` writes gene abundance table.<br>The local folder does not currently include StringTie or a GTF annotation. | Per-sample transcript GTF and abundance tables with FPKM/TPM-like values. Paper-level target: 61,994 transcripts from 42,478 genes, with 37,661 coding sequences at least 100 amino acids long. |
| 11A. Merge transcript assemblies, paper annotation route | StringTie merge | Creates one merged annotation file across all samples. The paper used a merged StringTie annotation as the basis for TransDecoder CDS/protein prediction. | Per-sample StringTie GTF files. | Example command:<br>`ls data/stringtie/*.gtf > data/stringtie/mergelist.txt`<br>`stringtie --merge -p 4 -G reference/annotation.gtf -o data/stringtie/stringtie_merged.gtf data/stringtie/mergelist.txt` | `--merge` combines transcript structures across samples.<br>`-p 4` uses 4 threads.<br>`-G` is optional but recommended if a reference annotation exists.<br>Not currently completed locally. | Merged transcript annotation, e.g. `stringtie_merged.gtf`. |
| 11B. Predict CDS and proteins, paper annotation route | TransDecoder v5.5.0 | The paper used TransDecoder to retrieve CDS and amino acid sequences for assembled transcripts. This turns transcript models into predicted proteins for BLAST/Pfam/GO/KEGG annotation. | Merged StringTie transcript FASTA/GTF. | Typical TransDecoder command sequence:<br>`TransDecoder.LongOrfs -t data/stringtie/merged_transcripts.fa`<br>`TransDecoder.Predict -t data/stringtie/merged_transcripts.fa` | Paper-reported version: `TransDecoder v5.5.0`.<br>Paper downstream filter: protein sequences with at least 100 amino acids for GO/KEGG annotation.<br>Not currently completed locally. | Predicted CDS FASTA and peptide FASTA, such as `merged_transcripts.fa.transdecoder.cds` and `.pep`. |
| 11C. Protein homology annotation, paper annotation route | BLASTP | Finds homologs for predicted snail proteins by comparing them with related species. The paper used this as one of two annotation methods. | TransDecoder predicted protein FASTA and protein databases from related species. | Example command pattern:<br>`blastp -query data/transdecoder/lymnaea.pep -db reference/refseq_mollusc_proteins -out results/annotation/blastp_mollusca.tsv -evalue 1e-3 -outfmt 6 -num_threads 4 -max_target_seqs 20` | Paper species set: *Biomphalaria glabrata*, *Aplysia californica*, *Lottia gigantea*, *Pomacea canaliculata*, *Octopus bimaculoides*, *Octopus vulgaris*, *Crassostrea virginica*, *Crassostrea gigas*, *Mizuhopecten yessoensis*.<br>For Blast2GO homology searches, the paper reports e-value `1.0E-3`, top 20 hits, word size `6`, HSP cutoff `33`. | BLAST tabular annotations linking predicted snail proteins to homologous proteins. |
| 11D. Pfam domain annotation, paper annotation route | HMMER3 `hmmscan`, Pfam | Identifies conserved protein domains, complementing sequence-similarity annotation from BLASTP. | Predicted protein FASTA and Pfam HMM database. | Example command pattern:<br>`hmmscan --cpu 4 --domtblout results/annotation/pfam.domtblout reference/Pfam-A.hmm data/transdecoder/lymnaea.pep` | Paper-reported tool: HMMER3 `hmmscan`.<br>Domain results were integrated with BLASTP results into TransDecoder ORF annotations.<br>Not currently completed locally. | Pfam domain table, usually `*.domtblout`, plus integrated protein annotations. |
| 11E. GO and KEGG annotation, paper annotation route | Blast2GO | Assigns GO terms and KEGG pathway labels to predicted proteins. This creates the annotation needed for the paper's GO and KEGG enrichment figures. | Predicted proteins at least 100 amino acids and homology/search results. | GUI or CLI workflow depends on Blast2GO installation. Paper-level settings to mirror:<br>`database=refseq_protein v5`<br>`evalue=1.0E-3`<br>`top_hits=20`<br>`word_size=6`<br>`hsp_length_cutoff=33`<br>`GO_version=2020.06` | Homology search scope: Mollusca phylum plus *C. elegans*, *D. melanogaster*, and *H. sapiens*.<br>Enrichment method: Fisher exact test plus FDR correction, `FDR < 0.05`.<br>Plotting: R `ggplot2` according to the paper. | Gene-to-GO table, gene-to-KEGG table, GO enrichment results, KEGG enrichment results. |
| 12. Count reads per gene | Subread `featureCounts`, reported in project notes from the paper | DESeq2 requires raw integer counts per gene, not FPKM/TPM. featureCounts counts how many aligned fragments overlap each annotated gene. | Sorted BAM files and a gene annotation GTF/GFF. | Example paired-end command:<br>`featureCounts -T 4 -p --countReadPairs -s 0 -a reference/annotation.gtf -o data/counts/gene_counts.txt data/aligned/*.sorted.bam` | `-T 4` uses 4 threads.<br>`-p` says data are paired-end.<br>`--countReadPairs` counts fragments/read pairs.<br>`-s 0` means unstranded; confirm with library prep if strandedness is known.<br>`-a` provides GTF/GFF annotation.<br>`-o` writes count table.<br>The local folder does not currently contain a GTF/GFF annotation or featureCounts binary. | `gene_counts.txt` with raw counts and assignment summary files. |
| 13. Differential expression | R, DESeq2 | Tests which genes change expression among 3-month, 6-month, and 18-month CNS samples while modeling biological replicate variation. | Raw count matrix from featureCounts and a sample metadata table. | <details><summary>R code for DESeq2 contrasts</summary><pre><code class="language-r">library(DESeq2)

counts <- read.delim("papers/lymnaea_stagnalis_CNS_aging/data/counts/gene_counts.matrix.tsv",
                     row.names = 1, check.names = FALSE)
samples <- read.csv("papers/lymnaea_stagnalis_CNS_aging/data/counts/sample_metadata.csv",
                    row.names = 1)
samples$condition <- factor(samples$condition, levels = c("3month", "6month", "18month"))
counts <- counts[, rownames(samples)]

dds <- DESeqDataSetFromMatrix(countData = round(as.matrix(counts)),
                              colData = samples,
                              design = ~ condition)
dds <- dds[rowSums(counts(dds)) >= 10, ]
dds <- DESeq(dds)

res_6_vs_3 <- lfcShrink(dds, contrast = c("condition", "6month", "3month"),
                        type = "ashr")
res_18_vs_3 <- lfcShrink(dds, contrast = c("condition", "18month", "3month"),
                         type = "ashr")
res_18_vs_6 <- lfcShrink(dds, contrast = c("condition", "18month", "6month"),
                         type = "ashr")

dir.create("papers/lymnaea_stagnalis_CNS_aging/results/deseq2",
           recursive = TRUE, showWarnings = FALSE)
write.csv(as.data.frame(res_6_vs_3),
          "papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_6month_vs_3month.csv")
write.csv(as.data.frame(res_18_vs_3),
          "papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_3month.csv")
write.csv(as.data.frame(res_18_vs_6),
          "papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_6month.csv")
</code></pre></details> | Design formula: `~ condition`.<br>Reference level: `3month`.<br>Filtering: keep genes with total count `>= 10`.<br>Common DEG threshold for plots: adjusted p value `padj < 0.05`; optionally combine with `abs(log2FoldChange) >= 1` for large-effect DEG plots.<br>`lfcShrink(..., type="ashr")` requires the R package `ashr`. | DESeq2 result CSVs for each contrast, including `baseMean`, `log2FoldChange`, `lfcSE`, `pvalue`, and `padj`. |
| 14. PCA / sample clustering graph | R, DESeq2, ggplot2 | Checks whether biological replicates group by age and whether any sample is an outlier before interpreting DEGs. | DESeq2 object from step 13. | <details><summary>R code for PCA graph</summary><pre><code class="language-r">library(DESeq2)
library(ggplot2)

vsd <- vst(dds, blind = FALSE)
pca_data <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percent_var <- round(100 * attr(pca_data, "percentVar"))

p <- ggplot(pca_data, aes(PC1, PC2, color = condition, label = name)) +
  geom_point(size = 3) +
  geom_text(vjust = -0.8, size = 3) +
  xlab(paste0("PC1: ", percent_var[1], "% variance")) +
  ylab(paste0("PC2: ", percent_var[2], "% variance")) +
  theme_classic(base_size = 12)

ggsave("papers/lymnaea_stagnalis_CNS_aging/figures/PCA_by_age.png",
       p, width = 6, height = 5, dpi = 300)
</code></pre></details> | `vst(dds, blind=FALSE)` uses the design-aware variance-stabilizing transform.<br>`plotPCA(..., intgroup="condition")` colors points by age group.<br>`ggsave(..., dpi=300)` creates publication-ready PNG. | `figures/PCA_by_age.png`. |
| 15. Volcano plot graph | R, ggplot2, ggrepel | Recreates the paper-style DEG volcano plots: effect size on the x-axis and statistical significance on the y-axis. | DESeq2 result CSV from step 13. | <details><summary>R code for volcano plot</summary><pre><code class="language-r">library(ggplot2)
library(ggrepel)

res <- read.csv("papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_3month.csv",
                row.names = 1)
res$gene <- rownames(res)
res$minus_log10_padj <- -log10(res$padj)
res$status <- "not significant"
res$status[!is.na(res$padj) & res$padj < 0.05 & res$log2FoldChange >= 1] <- "up"
res$status[!is.na(res$padj) & res$padj < 0.05 & res$log2FoldChange <= -1] <- "down"

label_genes <- res[order(res$padj), ][1:10, ]

p <- ggplot(res, aes(log2FoldChange, minus_log10_padj, color = status)) +
  geom_point(alpha = 0.55, size = 1.2, na.rm = TRUE) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", linewidth = 0.3) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", linewidth = 0.3) +
  geom_text_repel(data = label_genes, aes(label = gene), size = 3, max.overlaps = 20) +
  scale_color_manual(values = c("down" = "#2b6cb0", "not significant" = "grey70", "up" = "#c53030")) +
  labs(x = "log2 fold change", y = "-log10 adjusted p value", color = NULL) +
  theme_classic(base_size = 12)

ggsave("papers/lymnaea_stagnalis_CNS_aging/figures/volcano_18month_vs_3month.png",
       p, width = 6, height = 5, dpi = 300)
</code></pre></details> | Significance line: `padj < 0.05`.<br>Effect-size lines: `log2FoldChange <= -1` and `>= 1`.<br>Top 10 genes by `padj` are labeled.<br>Colors separate up, down, and nonsignificant genes. | `figures/volcano_18month_vs_3month.png`. Repeat with other DESeq2 CSVs for other contrasts. |
| 16. DEG overlap graph | R, VennDiagram or ggVennDiagram | Shows which differentially expressed genes are shared among age comparisons, matching the paper target of DEG overlap. | DESeq2 result CSVs from step 13. | <details><summary>R code for DEG overlap</summary><pre><code class="language-r">library(ggVennDiagram)
library(ggplot2)

read_deg <- function(path) {
  x <- read.csv(path, row.names = 1)
  rownames(x)[!is.na(x$padj) & x$padj < 0.05 & abs(x$log2FoldChange) >= 1]
}

deg_sets <- list(
  "6 vs 3 months" = read_deg("papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_6month_vs_3month.csv"),
  "18 vs 3 months" = read_deg("papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_3month.csv"),
  "18 vs 6 months" = read_deg("papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_6month.csv")
)

p <- ggVennDiagram(deg_sets, label_alpha = 0) +
  scale_fill_gradient(low = "white", high = "#4c78a8") +
  theme_void()

ggsave("papers/lymnaea_stagnalis_CNS_aging/figures/DEG_overlap_venn.png",
       p, width = 6, height = 5, dpi = 300)
</code></pre></details> | DEG definition in this code: `padj < 0.05` and `abs(log2FoldChange) >= 1`.<br>Package needed: `ggVennDiagram`. | `figures/DEG_overlap_venn.png`. |
| 17. Heatmap graph | R, DESeq2, pheatmap | Shows expression patterns for the strongest DEGs across all samples and whether samples cluster by age. | DESeq2 object from step 13 and one result table. | <details><summary>R code for DEG heatmap</summary><pre><code class="language-r">library(DESeq2)
library(pheatmap)

vsd <- vst(dds, blind = FALSE)
res <- read.csv("papers/lymnaea_stagnalis_CNS_aging/results/deseq2/DESeq2_18month_vs_3month.csv",
                row.names = 1)
top_genes <- rownames(res[order(res$padj), ])[1:50]

mat <- assay(vsd)[top_genes, ]
mat <- mat - rowMeans(mat)
ann <- as.data.frame(colData(vsd)[, "condition", drop = FALSE])

pheatmap(mat,
         annotation_col = ann,
         show_rownames = FALSE,
         fontsize_col = 8,
         clustering_distance_rows = "correlation",
         clustering_distance_cols = "correlation",
         filename = "papers/lymnaea_stagnalis_CNS_aging/figures/top50_DEG_heatmap.png",
         width = 7,
         height = 8)
</code></pre></details> | Uses top 50 genes by adjusted p value.<br>Rows are centered by subtracting each gene mean.<br>Correlation distance clusters genes and samples by expression shape. | `figures/top50_DEG_heatmap.png`. |
| 18. GO enrichment graph | R, clusterProfiler or topGO; ggplot2 for plotting | Summarizes biological processes enriched among DEGs, matching the paper target of GO enrichment. The exact annotation files are not yet in the local folder. | DEG gene list from DESeq2 and a gene-to-GO annotation table. | <details><summary>R code for GO dot plot from an enrichment table</summary><pre><code class="language-r">library(ggplot2)

go <- read.csv("papers/lymnaea_stagnalis_CNS_aging/results/enrichment/GO_enrichment.csv")
go <- go[order(go$padj), ]
go <- head(go, 20)
go$term <- factor(go$term, levels = rev(go$term))

p <- ggplot(go, aes(x = gene_ratio, y = term, size = gene_count, color = padj)) +
  geom_point() +
  scale_color_gradient(low = "#c53030", high = "#2b6cb0", trans = "reverse") +
  labs(x = "Gene ratio", y = NULL, size = "Gene count", color = "Adjusted p") +
  theme_classic(base_size = 11)

ggsave("papers/lymnaea_stagnalis_CNS_aging/figures/GO_enrichment_dotplot.png",
       p, width = 7, height = 5.5, dpi = 300)
</code></pre></details> | Enrichment threshold usually `padj < 0.05` after FDR correction.<br>Expected input columns for this plotting code: `term`, `gene_ratio`, `gene_count`, `padj`.<br>Paper notes mention Fisher exact test with FDR; clusterProfiler/topGO are practical R implementations. | GO enrichment table plus `figures/GO_enrichment_dotplot.png`. |
| 19. KEGG enrichment graph | R, ggplot2 | Summarizes pathway-level changes among DEGs, matching the paper target of KEGG summaries. | KEGG enrichment result table from DEG list. | <details><summary>R code for KEGG bar plot</summary><pre><code class="language-r">library(ggplot2)

kegg <- read.csv("papers/lymnaea_stagnalis_CNS_aging/results/enrichment/KEGG_enrichment.csv")
kegg <- kegg[order(kegg$padj), ]
kegg <- head(kegg, 15)
kegg$pathway <- factor(kegg$pathway, levels = rev(kegg$pathway))

p <- ggplot(kegg, aes(x = pathway, y = gene_count, fill = padj)) +
  geom_col(width = 0.75) +
  coord_flip() +
  scale_fill_gradient(low = "#c53030", high = "#2b6cb0", trans = "reverse") +
  labs(x = NULL, y = "DEG count", fill = "Adjusted p") +
  theme_classic(base_size = 11)

ggsave("papers/lymnaea_stagnalis_CNS_aging/figures/KEGG_enrichment_barplot.png",
       p, width = 7, height = 5, dpi = 300)
</code></pre></details> | Expected input columns for this plotting code: `pathway`, `gene_count`, `padj`.<br>Plot uses top 15 pathways by adjusted p value. | KEGG enrichment table plus `figures/KEGG_enrichment_barplot.png`. |
| 20. Final figure organization | Markdown, PNG/PDF exports | Keeps recreated panels easy to compare against the paper. | All generated figures and result tables. | Suggested folder creation:<br>`mkdir -p papers/lymnaea_stagnalis_CNS_aging/figures papers/lymnaea_stagnalis_CNS_aging/results/deseq2 papers/lymnaea_stagnalis_CNS_aging/results/enrichment` | Figure export standard used in graph code: `dpi=300`, widths around 6-7 inches, heights around 5-8 inches. | Recreated figure panels under `papers/lymnaea_stagnalis_CNS_aging/figures/` and analysis tables under `results/`. |

## Current Local Completion Status

| Item | Present in this folder now? | Evidence |
|---|---|---|
| SRA accessions and run metadata | Yes | `papers/lymnaea_stagnalis_CNS_aging/software/PRJNA698985_SraAccList.txt`, `PRJNA698985_runinfo.csv` |
| SRA downloads | Yes for 12 listed runs | `papers/lymnaea_stagnalis_CNS_aging/data/sra/SRR*/SRR*.sra` |
| FASTQ conversion | Yes for 12 listed runs | `papers/lymnaea_stagnalis_CNS_aging/data/fastq/SRR*_1.fastq` and `SRR*_2.fastq` |
| FastQC reports | Partial | Reports exist for `SRR13618150_1` and `SRR13618150_2` |
| Reference genome FASTA | Yes | `papers/lymnaea_stagnalis_CNS_aging/data/reference_genome/GCA_900036025.1_v1.0_genomic.fna` |
| HISAT2 index | Yes | `papers/lymnaea_stagnalis_CNS_aging/reference/hisat2_i.*.ht2` |
| HISAT2 alignments | Partial | SAM files exist for `SRR13618140`, `SRR13618141`, and `SRR13618142` |
| Sorted BAM files | Not seen | No `*.bam` files found in `data/aligned` |
| Gene annotation GTF/GFF | Not seen | Needed before featureCounts/StringTie can complete gene-level analysis |
| Count matrix | Not seen | Needed before DESeq2 and graph code can run |
| R plotting scripts | Not seen | Plotting code is provided above and can be copied into R scripts once count/enrichment tables exist |
