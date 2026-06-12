# RNA-seq paper candidates

These are open-access papers with public RNA-seq data and figure targets that fit a standard free-tool RNA-seq workflow: FastQC/MultiQC, Cutadapt or Trimmomatic, STAR/HISAT2 or Salmon/Kallisto, featureCounts or tximport, DESeq2/edgeR, and GO/KEGG-style enrichment.

## Best first choice: great pond snail CNS aging

- Folder: `lymnaea_stagnalis_CNS_aging/`
- PDF: `lymnaea_stagnalis_CNS_aging/paper/lymnaea_stagnalis_CNS_aging_BMCGenomics_2021.pdf`
- Paper: *Transcriptome analysis provides genome annotation and expression profiles in the central nervous system of Lymnaea stagnalis at different ages*
- Organism: great pond snail, *Lymnaea stagnalis*
- Data: NCBI BioProject `PRJNA698985`
- Why it is a good training dataset: three age groups, four biological replicates each, paired-end bulk RNA-seq, DESeq2, featureCounts, volcano plots, heatmaps, GO, and KEGG.
- First figures to recreate: Figure 1B/C/D/E for DEG overlap, volcano plots, and heatmaps; Figure 2 for GO enrichment; Figure 3 for KEGG pathway summary.
- Suggested route: Salmon/Kallisto against transcript FASTA for a fast laptop-friendly pass, or HISAT2/STAR plus featureCounts for the classic alignment/counting route.

## Strong biology choice: sea star larval regeneration

- Folder: `sea_star_larval_regeneration/`
- PDF: `sea_star_larval_regeneration/paper/sea_star_larval_regeneration_BMCBiology_2019.pdf`
- Paper: *Analysis of sea star larval regeneration reveals conserved processes of whole-body regeneration across the metazoa*
- Organism: sea star, *Patiria miniata*
- Data: GEO `GSE97230`
- Why it is a good training dataset: 18 bulk RNA-seq samples, clear regeneration time-course contrasts, trimming, genome mapping, gene counting, edgeR differential expression, hierarchical clustering, and GO enrichment.
- First figures to recreate: DEG clustering/time-course heatmaps and GO enrichment panels. The full cross-species regeneration comparison is more advanced and can be saved for later.
- Suggested route: start with the sea star-only regeneration-vs-control contrasts before attempting planaria/hydra ortholog comparisons.

## Practical applied choice: honey bee pesticide exposure

- Folder: `honey_bee_imidacloprid/`
- PDF: `honey_bee_imidacloprid/paper/honey_bee_imidacloprid_FrontiersGenetics_2021.pdf`
- Paper: *Missing Nurse Bees: Early Transcriptomic Switch From Nurse Bee to Forager Induced by Sublethal Imidacloprid*
- Organism: western honey bee, *Apis mellifera*
- Data: NCBI BioProject `PRJNA521949`
- Why it is a good training dataset: familiar organism, public raw reads, a well-annotated genome, DESeq2-based differential expression, and a biologically interpretable exposure/time design.
- First figures to recreate: PCA/expression clustering and DEG summary plots; then make your own volcano plots and enrichment plots from the DESeq2 output.
- Suggested route: use the current honey bee genome annotation, quantify with Salmon or align with HISAT2/STAR, then use DESeq2 in R.

## Optional but not downloaded: clownfish skin pigmentation

- Paper: *Comparative Transcriptome Analysis of White and Orange Skin of Clownfish Identifying Differentially Expressed Genes Underlying Pigment Expression*
- Organism: clown anemonefish, *Amphiprion ocellaris*
- Data: the paper states that data are available on request from the corresponding authors. Related public clownfish RNA-seq exists under BioProject `PRJNA482393`, but that is not clearly the same dataset.
- Note: this looks interesting and very familiar as an organism, but the publisher site returned a challenge page during scripted download, and the raw data are not directly public, so I did not include it as one of the downloaded PDFs.
