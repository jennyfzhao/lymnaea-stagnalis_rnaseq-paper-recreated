# Figures, Annotations, and Project Findings

This file explains what each figure and annotation output is meant to show, what can be inferred from it, and the main biological points of the project.

## Major Project Points

- This project reproduces and extends a public *Lymnaea stagnalis* central nervous system aging RNA-seq analysis using 12 SRA runs from NCBI BioProject `PRJNA698985`: four 3-month samples, four 6-month samples, and four 18-month samples.
- After DESeq2 filtering, 41,692 genes were retained for differential-expression analysis.
- The largest expression shifts are in the comparisons involving 3-month CNS samples:
  - `6_month_vs_3_month`: 20,205 significant genes.
  - `18_month_vs_3_month`: 18,449 significant genes.
  - `18_month_vs_6_month`: 889 significant genes.
- This suggests that the major transcriptomic difference in these data is between young 3-month CNS tissue and the later 6- and 18-month stages, while 6-month and 18-month CNS samples are much more similar to each other.
- Pfam annotation adds biological meaning to predicted ORFs by identifying conserved protein domains in differentially expressed genes.
- Specific Pfam-supported predicted genes include collagen-domain genes (`MSTRG.14013`, `MSTRG.14011`, `MSTRG.312`), a nerve-growth-factor-family gene (`MSTRG.14882`), a cytochrome P450 gene (`MSTRG.7692`), HSP90/stress-response gene (`MSTRG.30305`), thioredoxin/redox genes (`MSTRG.22291`, `MSTRG.21611`), and an insulin/IGF/relaxin-family gene (`MSTRG.21991`).
- GO enrichment gives functional categories associated with the significant genes. FDR-significant GO enrichment was found for `18_month_vs_3_month` and `18_month_vs_6_month`; the `6_month_vs_3_month` GO plot is shown as top terms by raw p-value because it did not pass the FDR threshold.
- KEGG KO annotations were generated with KofamScan, but the KO enrichment outputs did not pass FDR correction. These KEGG plots should be treated as exploratory rather than strong enrichment evidence.
- The biological value of the project is that it turns public CNS aging RNA-seq data from a non-model mollusc into a reproducible workflow with differential-expression results, protein-domain annotations, GO categories, KEGG KO mappings, and clear figures.
- Compared with Rosato et al. 2021, this reproduction supports the same broad conclusion that *L. stagnalis* CNS aging is associated with measurable transcriptomic differences. It is not expected to match the paper's exact gene counts or annotation tables one-for-one, because the analysis here rebuilds the workflow from public data using recreated StringTie/TransDecoder predictions, Pfam/Pfam2GO-derived GO annotation, KofamScan KO annotation, and this repository's DE/enrichment thresholds.

## DESeq2 And Sample-Level Figures

| Figure or folder | Purpose | Main finding |
| --- | --- | --- |
| `figures/pca/PCA_vst_DESeq2.png` | Shows sample relationships after DESeq2 variance-stabilizing transformation. This is the preferred PCA because VST reduces the effect of count-size differences. | The 3-month samples separate from the 6-month and 18-month samples, supporting an age-associated expression structure in the CNS data. |
| `figures/pca/PCA_log2_raw_counts.png` | Shows PCA on log2-transformed raw counts as a simpler comparison to the VST PCA. | It provides a second view of sample separation, but the VST PCA is the stronger version to interpret. |
| `figures/pca/PCA_coordinates.csv` and `figures/pca/PCA_log2_raw_counts_coordinates.csv` | Store the plotted PCA coordinates for each sample. | These files make the PCA figures reproducible and allow the sample positions to be checked directly. |
| `figures/heatmaps/sample_distance_heatmap.png` | Shows pairwise sample similarity based on transformed expression values. | Samples group by age-related expression profiles, consistent with the PCA results. |
| `figures/heatmaps/top_50_variable_genes_heatmap.png` | Shows expression patterns for the 50 most variable genes. | The most variable genes show strong age-associated expression differences, especially between 3-month samples and later ages. |
| `figures/heatmaps/top_2000_variable_genes_heatmap.png` | Shows broader expression patterns across the 2,000 most variable genes. | The large-scale expression structure is not limited to a small number of genes; many genes contribute to age-group differences. |
| `figures/volcano_plots/6_month_vs_3_month_volcano.png` | Shows effect size and adjusted significance for 6-month versus 3-month genes. | This comparison has the largest number of significant genes, suggesting a strong expression shift from 3 to 6 months. |
| `figures/volcano_plots/18_month_vs_3_month_volcano.png` | Shows effect size and adjusted significance for 18-month versus 3-month genes. | This comparison also has a large number of significant genes, showing that 18-month CNS expression remains very different from 3-month CNS expression. |
| `figures/volcano_plots/18_month_vs_6_month_volcano.png` | Shows effect size and adjusted significance for 18-month versus 6-month genes. | This comparison has far fewer significant genes, suggesting that 6-month and 18-month samples are more similar to each other than either is to 3-month samples. |
| `figures/deseq2_results/analysis_summary.txt` | Summarizes sample matching, DESeq2 filtering, and significant-gene counts. | This is the compact text record of the differential-expression analysis and supports the significance counts reported above. |

## Pfam Annotation Figures

Pfam annotation connects predicted proteins to conserved domains. The Pfam-annotated plots use significant genes defined by `padj < 0.05` and `abs(log2FoldChange) >= 1`.

| Figure or folder | Purpose | Main finding |
| --- | --- | --- |
| `figures/annotation_plots/6_month_vs_3_month/volcano_with_pfam_annotation.png` | Shows which significant DE genes also have Pfam domain annotations. | Many significant genes in this large contrast have domain support, giving interpretable protein-level context to the expression changes. |
| `figures/annotation_plots/6_month_vs_3_month/top_pfam_domains_by_direction.png` | Shows the most common Pfam domains among up- and down-regulated genes. | Up-regulated genes most often include `7tm_1` receptor domains (97 genes), `Pkinase` domains (82), `Ank_2` repeats (61), `zf-H2C2_2` zinc-finger domains (52), `MFS_1` transporter domains (45), `PK_Tyr_Ser-Thr` kinase domains (42), `RVT_1` reverse-transcriptase-like domains (37), and `fn3` domains (35). Down-regulated genes include `Pkinase` (15), `7tm_1` (10), `RRM_1` RNA-recognition motifs (9), `p450` (9), `zf-H2C2_2` (9), and `AIG1` (9). |
| `figures/annotation_plots/6_month_vs_3_month/top_annotated_de_genes_log2fc.png` | Highlights annotated significant genes with large fold changes. | Specific examples include `MSTRG.7871` up-regulated with a von Willebrand factor type D domain, `MSTRG.30305` up-regulated with HSP90/chaperone domains, `MSTRG.14882` up-regulated with a nerve growth factor family domain, and `MSTRG.14013`/`MSTRG.14011` down-regulated with collagen domains. |
| `figures/annotation_plots/6_month_vs_3_month/summary.txt` | Counts significant genes and Pfam-supported significant genes. | There are 12,360 up-regulated genes, 7,845 down-regulated genes, and 5,732 significant genes with Pfam annotation. |
| `figures/annotation_plots/18_month_vs_3_month/volcano_with_pfam_annotation.png` | Shows which 18-month versus 3-month DE genes have Pfam domains. | The large young-versus-old contrast contains thousands of domain-annotated significant genes. |
| `figures/annotation_plots/18_month_vs_3_month/top_pfam_domains_by_direction.png` | Shows the most common Pfam domains by direction of expression change. | Up-regulated genes most often include `7tm_1` receptor domains (98 genes), `Pkinase` domains (73), `Ank_2` repeats (58), `zf-H2C2_2` zinc-finger domains (50), `MFS_1` transporter domains (46), `PK_Tyr_Ser-Thr` kinase domains (37), `p450` domains (29), and `fn3` domains (29). Down-regulated genes include `Pkinase` (17), `7tm_1` (12), `Peptidase_S10` (12), `AIG1` (12), `EGF_CA` (10), `RRM_1` (9), `PARP` (9), and `Fibrinogen_C` (9). |
| `figures/annotation_plots/18_month_vs_3_month/top_annotated_de_genes_log2fc.png` | Highlights annotated genes with strong fold changes. | Specific examples include down-regulated collagen-domain genes (`MSTRG.14013`, `MSTRG.312`, `MSTRG.14011`), down-regulated cytochrome P450 gene `MSTRG.7692`, up-regulated nerve-growth-factor-family gene `MSTRG.14882`, up-regulated von Willebrand factor type D domain gene `MSTRG.7871`, and up-regulated insulin/IGF/relaxin-family gene `MSTRG.21991`. |
| `figures/annotation_plots/18_month_vs_3_month/summary.txt` | Counts significant genes and Pfam-supported significant genes. | There are 11,127 up-regulated genes, 7,322 down-regulated genes, and 5,195 significant genes with Pfam annotation. |
| `figures/annotation_plots/18_month_vs_6_month/volcano_with_pfam_annotation.png` | Shows Pfam-supported DE genes in the smaller later-age contrast. | Much fewer genes change between 18 and 6 months, and only 249 significant genes have Pfam annotation. |
| `figures/annotation_plots/18_month_vs_6_month/top_pfam_domains_by_direction.png` | Shows common domains among the smaller set of significant annotated genes. | Up-regulated genes include a small number of `Glyco_hydro_9` glycosyl hydrolase domains (3), `p450` domains (3), `PIRC1_2` domains (2), `7tm_1` receptor domains (2), and `Galactosyl_T` glycosyltransferase domains (2). Down-regulated genes include `Collagen` (12), `p450` (7), `7tm_1` (6), `CUB` (5), `Peptidase_S10` (5), `fn3` (5), `VWA` (5), and `ApeC` (5). |
| `figures/annotation_plots/18_month_vs_6_month/top_annotated_de_genes_log2fc.png` | Highlights the largest annotated later-age changes. | Specific examples include strongly down-regulated `MSTRG.4485` with a Deltex C-terminal domain, down-regulated `MSTRG.33180` with a GPCR-like `7tm_1` receptor domain, down-regulated collagen-domain gene `MSTRG.312`, down-regulated zinc-binding gene `MSTRG.15182`, down-regulated interferon-induced-family gene `MSTRG.21494`, and up-regulated glycosyl hydrolase gene `MSTRG.30025`. |
| `figures/annotation_plots/18_month_vs_6_month/summary.txt` | Counts significant genes and Pfam-supported significant genes. | There are 267 up-regulated genes, 622 down-regulated genes, and 249 significant genes with Pfam annotation. |

## Specific Predicted Genes Highlighted By Pfam

The gene IDs below are predicted gene/transcript assembly IDs, not curated gene symbols. The function is inferred from the strongest Pfam domain hit, so these should be described as domain-based functional predictions.

### 6 Month vs 3 Month

| Predicted gene | Direction | log2FC | adjusted p-value | Pfam domain | Inferred function |
| --- | --- | ---: | ---: | --- | --- |
| `MSTRG.7871` | Up | 2.46 | 5.54e-179 | `VWD` | von Willebrand factor type D domain; extracellular or matrix-associated protein interaction. |
| `MSTRG.14013` | Down | -3.75 | 1.38e-87 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.17505` | Up | 4.53 | 1.70e-85 | `VIT` | vault protein inter-alpha-trypsin domain; protein-interaction or extracellular-associated domain. |
| `MSTRG.30305` | Up | 3.68 | 4.83e-85 | `HSP90` | Hsp90 chaperone; protein folding and stress-response regulation. |
| `MSTRG.7869` | Up | 6.34 | 4.44e-78 | `Vitellogenin_N` | lipoprotein amino-terminal region; lipid transport/storage-related domain. |
| `MSTRG.14882` | Up | 4.13 | 4.77e-78 | `NGF` | nerve growth factor family; neurotrophic or growth-factor-like signaling. |
| `MSTRG.22291` | Up | 2.81 | 1.09e-75 | `Thioredoxin` | redox regulation and oxidative-stress-associated protein function. |
| `MSTRG.21991` | Up | 2.41 | 2.20e-72 | `Insulin` | insulin/IGF/relaxin-family peptide; growth, metabolic, or peptide-hormone signaling. |
| `MSTRG.14011` | Down | -3.23 | 2.92e-72 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.21611` | Up | 4.36 | 7.93e-72 | `TXNDC16_2nd` | thioredoxin-like domain; redox or protein-folding-related function. |

### 18 Month vs 3 Month

| Predicted gene | Direction | log2FC | adjusted p-value | Pfam domain | Inferred function |
| --- | --- | ---: | ---: | --- | --- |
| `MSTRG.14013` | Down | -4.99 | 4.60e-156 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.312` | Down | -3.55 | 6.16e-142 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.14882` | Up | 5.38 | 3.16e-133 | `NGF` | nerve growth factor family; neurotrophic or growth-factor-like signaling. |
| `MSTRG.14011` | Down | -4.33 | 4.97e-130 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.7692` | Down | -4.48 | 9.20e-112 | `p450` | cytochrome P450; oxidative metabolism, detoxification, or steroid/lipid metabolism. |
| `MSTRG.7871` | Up | 1.93 | 9.90e-110 | `VWD` | von Willebrand factor type D domain; extracellular or matrix-associated protein interaction. |
| `MSTRG.4958` | Down | -2.06 | 7.08e-107 | `Ig_3` | immunoglobulin-like domain; cell-surface, adhesion, or recognition-related function. |
| `MSTRG.21991` | Up | 2.81 | 1.56e-98 | `Insulin` | insulin/IGF/relaxin-family peptide; growth, metabolic, or peptide-hormone signaling. |
| `MSTRG.20665` | Down | -2.66 | 6.64e-98 | `Cu-oxidase_3` | multicopper oxidase; oxidative enzyme activity. |
| `MSTRG.26700` | Down | -2.48 | 8.44e-95 | `Pro_isomerase` | cyclophilin-type peptidyl-prolyl isomerase; protein folding/isomerization. |

### 18 Month vs 6 Month

| Predicted gene | Direction | log2FC | adjusted p-value | Pfam domain | Inferred function |
| --- | --- | ---: | ---: | --- | --- |
| `MSTRG.4485` | Down | -12.66 | 3.10e-29 | `DTC` | Deltex C-terminal domain; signaling or ubiquitin-regulatory protein family. |
| `MSTRG.33180` | Down | -1.80 | 1.35e-24 | `7tm_1` | rhodopsin-family 7-transmembrane receptor; GPCR-like signaling. |
| `MSTRG.312` | Down | -1.44 | 1.32e-21 | `COLFI` | fibrillar collagen C-terminal domain; extracellular matrix/collagen structural function. |
| `MSTRG.15182` | Down | -1.32 | 4.58e-19 | `Zn_ribbon_3CxxC` | zinc-binding domain; nucleic-acid or protein interaction/regulation. |
| `MSTRG.21494` | Down | -2.07 | 1.53e-18 | `Ifi-6-16` | interferon-induced 6-16 family domain; stress/immune-associated annotation. |
| `MSTRG.17390` | Down | -1.73 | 2.98e-18 | `DUF8357` | domain of unknown function; significant expression change but unclear function. |
| `MSTRG.30025` | Up | 1.99 | 3.29e-18 | `Glyco_hydro_9` | glycosyl hydrolase family 9; carbohydrate/glycosidic-bond hydrolysis. |
| `MSTRG.28462` | Down | -1.33 | 2.59e-16 | `Pkinase` | protein kinase domain; phosphorylation-based signaling. |
| `MSTRG.23795` | Down | -1.20 | 4.09e-16 | `Cyclase` | putative cyclase; signaling molecule production or cyclic-nucleotide-related activity. |
| `MSTRG.20665` | Down | -1.09 | 5.78e-15 | `Cu-oxidase_3` | multicopper oxidase; oxidative enzyme activity. |

## Pfam Annotation Quality Figures

| Figure | Purpose | Main finding |
| --- | --- | --- |
| `data/annotation/pfam/visualizations/top_20_pfam_domains.png` | Shows the most frequent Pfam domains across the predicted protein annotations. | The predicted ORFs contain many recognizable conserved domains, meaning the annotation step produced useful protein-domain information. |
| `data/annotation/pfam/visualizations/top_genes_by_pfam_hit_count.png` | Shows genes with the largest number of Pfam hits. | Some predicted genes contain multiple conserved domains, which can indicate larger or multi-domain proteins. |
| `data/annotation/pfam/visualizations/domain_score_distribution.png` | Shows the distribution of Pfam domain scores. | The score distribution helps evaluate confidence in the domain matches. |
| `data/annotation/pfam/visualizations/domain_significance_distribution.png` | Shows the distribution of Pfam domain significance values. | Many matches have strong significance values, supporting the usefulness of the Pfam annotation set. |
| `data/annotation/pfam/visualizations/protein_length_vs_domain_score.png` | Compares predicted protein length with Pfam score. | This is a quality-control view for checking whether domain scores behave reasonably across proteins of different lengths. |

## GO And KEGG Enrichment Figures

| Figure | Purpose | Main finding |
| --- | --- | --- |
| `figures/enrichment/18_month_vs_3_month_GO_fdr_significant.png` | Shows GO terms enriched among significant genes in the 18-month versus 3-month comparison. | This is the strongest GO result. FDR-significant terms include transmembrane transporter activity, membrane, G protein-coupled receptor activity, transmembrane transport, and GPCR signaling. |
| `figures/enrichment/18_month_vs_6_month_GO_fdr_significant.png` | Shows GO terms enriched among significant genes in the 18-month versus 6-month comparison. | Only extracellular matrix structural constituent is FDR-significant, which fits the collagen-domain genes seen in the Pfam results. |
| `figures/enrichment/6_month_vs_3_month_GO_top_by_pvalue_not_fdr_significant.png` | Shows the top GO terms by raw p-value for 6-month versus 3-month genes. | The top raw-p-value terms include transmembrane transporter activity, DNA replication regulation, GPCR activity, and ligand-gated ion channel activity, but none pass FDR correction. |
| `figures/enrichment/18_month_vs_3_month_KEGG_KO_top_by_pvalue_not_fdr_significant.png` | Shows top KEGG KO terms by raw p-value for 18-month versus 3-month genes. | KO terms were mapped, but no KEGG KO terms passed FDR correction; treat this figure as exploratory. The top raw-p-value KO is `K26203`. |
| `figures/enrichment/18_month_vs_6_month_KEGG_KO_top_by_pvalue_not_fdr_significant.png` | Shows top KEGG KO terms by raw p-value for 18-month versus 6-month genes. | KO enrichment is not FDR-significant in this contrast. The top raw-p-value KO is `K28113`, but its adjusted p-value is 1. |
| `figures/enrichment/6_month_vs_3_month_KEGG_KO_top_by_pvalue_not_fdr_significant.png` | Shows top KEGG KO terms by raw p-value for 6-month versus 3-month genes. | As with the other KO plots, the result is exploratory because adjusted p-values did not support significant KO enrichment. The top raw-p-value KO is `K26203`. |

### Specific GO Enrichment Results

These values come from `data/annotation/enrichment/*_GO_enrichment.csv`. The `sig_with_term` column reports how many significant DE genes carry that GO term; `universe_with_term` reports how many genes in the tested background carry it.

#### 18 Month vs 3 Month

| GO term | Term name | sig_with_term / sig_total | universe_with_term / universe_total | p-value | adjusted p-value | Interpretation |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `GO:0022857` | transmembrane transporter activity | 152 / 18,449 | 245 / 41,599 | 1.79e-08 | 3.77e-05 | Strongest term; points to transporter-related genes among old-vs-young DE genes. |
| `GO:0016020` | membrane | 1,024 / 18,449 | 2,104 / 41,599 | 2.44e-05 | 0.0257 | Many DE genes encode membrane-associated proteins. |
| `GO:0004930` | G protein-coupled receptor activity | 175 / 18,449 | 317 / 41,599 | 6.32e-05 | 0.0341 | Receptor/signaling genes are enriched. |
| `GO:0055085` | transmembrane transport | 253 / 18,449 | 476 / 41,599 | 6.49e-05 | 0.0341 | Transport processes are enriched. |
| `GO:0007186` | G protein-coupled receptor signaling pathway | 197 / 18,449 | 364 / 41,599 | 1.07e-04 | 0.0451 | GPCR signaling is enriched. |

This supports a specific biological interpretation: the 18-month versus 3-month CNS difference is not only broad differential expression; it is enriched for membrane, transporter, and receptor-signaling functions.

#### 18 Month vs 6 Month

| GO term | Term name | sig_with_term / sig_total | universe_with_term / universe_total | p-value | adjusted p-value | Interpretation |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `GO:0005201` | extracellular matrix structural constituent | 5 / 889 | 11 / 35,149 | 4.17e-06 | 0.00869 | The only FDR-significant GO term; fits down-regulated collagen-domain genes such as `MSTRG.312`. |
| `GO:0016705` | oxidoreductase activity, acting on paired donors, with incorporation or reduction of molecular oxygen | 10 / 889 | 93 / 35,149 | 1.24e-04 | 0.129 | Raw p-value signal, but not FDR-significant. |
| `GO:0004497` | monooxygenase activity | 10 / 889 | 108 / 35,149 | 4.23e-04 | 0.294 | Raw p-value signal, but not FDR-significant. |
| `GO:0005506` | iron ion binding | 13 / 889 | 177 / 35,149 | 6.06e-04 | 0.316 | Raw p-value signal, but not FDR-significant. |

This suggests a narrower later-age signal than the 3-month contrasts. The supported FDR-significant point is extracellular-matrix structural activity.

#### 6 Month vs 3 Month

| GO term | Term name | sig_with_term / sig_total | universe_with_term / universe_total | p-value | adjusted p-value | Interpretation |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `GO:0022857` | transmembrane transporter activity | 151 / 20,205 | 245 / 41,599 | 2.56e-05 | 0.0538 | Very close to FDR significance, but still above 0.05. |
| `GO:0006275` | regulation of DNA replication | 25 / 20,205 | 30 / 41,599 | 8.91e-05 | 0.0938 | Raw p-value signal, but not FDR-significant. |
| `GO:0003993` | acid phosphatase activity | 47 / 20,205 | 69 / 41,599 | 8.03e-04 | 0.496 | Exploratory only. |
| `GO:0004930` | G protein-coupled receptor activity | 182 / 20,205 | 317 / 41,599 | 9.42e-04 | 0.496 | Exploratory only, but directionally consistent with common `7tm_1` domains. |
| `GO:0005230` | extracellular ligand-gated ion channel activity | 25 / 20,205 | 33 / 41,599 | 1.35e-03 | 0.567 | Exploratory only. |
| `GO:0015276` | ligand-gated ion channel activity | 27 / 20,205 | 37 / 41,599 | 2.24e-03 | 0.672 | Exploratory only. |

This contrast has the most DE genes, but the GO enrichment test is more conservative after multiple-testing correction. It is fair to say that transporter/receptor/ion-channel terms appear among the top raw-p-value terms, but not that they are FDR-significant.

### Specific KEGG KO Enrichment Results

These values come from `data/annotation/enrichment/*_KEGG_KO_enrichment.csv`. KOfamScan produced KO assignments, but no KO term passes FDR correction in these enrichment tests.

| Contrast | Top raw-p-value KO terms | Interpretation |
| --- | --- | --- |
| `18_month_vs_3_month` | `K26203` (6 / 18,449 significant genes; p = 0.00761; adjusted p = 1), `K01937`, `K23883`, `K00569`, `K00856` | KO IDs are available for gene-level context, but enrichment is not statistically supported after correction. |
| `18_month_vs_6_month` | `K28113` (2 / 889 significant genes; p = 0.000639; adjusted p = 1), `K01179`, `K27391`, `K00456`, `K00726` | The small DE set creates some low raw p-values, but adjusted p-values remain non-significant. |
| `6_month_vs_3_month` | `K26203` (6 / 20,205 significant genes; p = 0.0131; adjusted p = 1), `K12373`, `K01937`, `K23883`, `K01202` | Use these as exploratory KO labels only; do not describe them as enriched pathways. |

## Annotation Tables

| File or folder | What it contains | How to interpret it |
| --- | --- | --- |
| `data/annotation/blastp_refseq9/lymnaea_transdecoder_vs_refseq9.blastp.tsv` | BLASTP hits against NCBI RefSeq proteins from nine mollusc or related species selected to match the paper's homology-search logic. | This file has 328 tabular BLASTP hit rows and provides homology support for predicted ORFs, but it is not the main source of GO or KEGG enrichment in this repository. |
| `data/annotation/pfam/protein_pfam_domains.tsv` | Protein-level Pfam domain hits parsed from HMMER/Pfam output. | This is the main conserved-domain annotation table, with 52,912 domain-hit rows. |
| `data/annotation/pfam/gene_pfam_summary.tsv` | Gene-level Pfam summaries collapsed from protein-level domain hits. | This table has 12,695 gene-level Pfam summary rows and makes it easier to join Pfam annotations to DESeq2 genes. |
| `data/annotation/pfam/deseq2_annotated/` | DESeq2 result tables with Pfam columns added for each age contrast. | These files connect expression changes to conserved protein-domain evidence. |
| `data/annotation/go_pfam2go/lymnaea_protein_go_pfam2go.tsv` | GO annotations inferred from Pfam-to-GO mappings. | This file has 67,728 protein-to-GO rows. These GO terms are computational predictions based on conserved domains, not direct experimental validation. |
| `data/annotation/kofam/lymnaea_kofam.mapper.tsv` | KEGG KO assignments from KofamScan. | This file has 43,828 protein-level KOfam mapper rows. These assignments support KO mapping and exploratory KEGG enrichment. |
| `data/annotation/enrichment/gene_to_go.tsv` | Gene-to-GO mapping used for GO enrichment. | This file has 39,268 gene-to-GO rows and is the background annotation file for GO overrepresentation testing. |
| `data/annotation/enrichment/gene_to_kegg_ko.tsv` | Gene-to-KEGG-KO mapping used for KO enrichment. | This file has 6,008 gene-to-KO rows and is the background annotation file for KEGG KO overrepresentation testing. |
| `data/annotation/enrichment/*_DESeq2_with_GO_KEGG.csv` | DESeq2 results with GO and KEGG KO annotations joined in. | These are the most useful tables for connecting a specific DE gene to annotation evidence. |
| `data/annotation/enrichment/*_GO_enrichment.csv` | GO enrichment test results for each contrast. | Use `padj < 0.05` as the stronger evidence threshold. |
| `data/annotation/enrichment/*_KEGG_KO_enrichment.csv` | KEGG KO enrichment test results for each contrast. | All current KO adjusted p-values are non-significant, so these are exploratory. |

## Biological Interpretation

The main biological pattern is that CNS gene expression changes strongly between 3 months and later ages. The 6-month and 18-month samples are much closer to each other than either is to 3-month samples, which suggests that the largest transcriptomic transition captured here may occur before or around the 6-month stage.

The 3-month-to-later-age contrasts repeatedly highlight signaling and membrane-related domains. The most common up-regulated Pfam domains in both `6_month_vs_3_month` and `18_month_vs_3_month` include `7tm_1` GPCR-like receptor domains, `Pkinase` domains, ankyrin repeats, zinc-finger domains, `MFS_1` transporter domains, and protein kinase domains. This fits the significant GO enrichment in `18_month_vs_3_month` for transmembrane transporter activity, membrane, GPCR activity, transmembrane transport, and GPCR signaling.

Several specific predicted genes are useful examples for explaining the biology. `MSTRG.14882` is strongly up-regulated in both 6-month and 18-month comparisons against 3-month samples and carries an `NGF` nerve-growth-factor-family domain, suggesting a neurotrophic or growth-factor-like signaling candidate. `MSTRG.21991` is also up-regulated in both 3-month contrasts and carries an insulin/IGF/relaxin-family domain, suggesting peptide-hormone or growth/metabolic signaling. `MSTRG.30305`, an HSP90-domain gene, is up-regulated in `6_month_vs_3_month`, suggesting chaperone/stress-response involvement. `MSTRG.22291` and `MSTRG.21611` carry thioredoxin-like domains and are up-regulated in `6_month_vs_3_month`, suggesting redox-related changes.

Extracellular matrix and structural annotations are another recurring result, but their direction differs by gene and contrast. Collagen-domain genes `MSTRG.14013`, `MSTRG.14011`, and `MSTRG.312` are down-regulated in the 3-month contrasts, and `MSTRG.312` remains down-regulated in `18_month_vs_6_month`. The only FDR-significant GO term in `18_month_vs_6_month` is extracellular matrix structural constituent (`GO:0005201`), so the later-age comparison should be discussed mainly as a smaller extracellular-matrix-related signal.

Metabolism and oxidative/stress-associated annotations also appear. `MSTRG.7692`, a cytochrome P450-domain gene, is down-regulated in `18_month_vs_3_month` and `18_month_vs_6_month`, suggesting age-associated differences in oxidative metabolism or detoxification-like functions. `MSTRG.20665`, a multicopper oxidase-domain gene, is down-regulated in both `18_month_vs_3_month` and `18_month_vs_6_month`. `MSTRG.26700`, a cyclophilin-type peptidyl-prolyl isomerase-domain gene, is down-regulated in `18_month_vs_3_month`, suggesting changes in protein-folding/isomerization functions.

The GO enrichment results give the strongest functional interpretation. The 18-month versus 3-month comparison has FDR-significant enrichment for membrane, transporter, receptor, and signaling-related GO categories. The 18-month versus 6-month comparison has far fewer DE genes, but its significant GO enrichment suggests a possible extracellular matrix-related later-age signal. The 6-month versus 3-month contrast has the largest number of DE genes, but its enrichment terms do not pass FDR correction, so its GO patterns should be described as exploratory despite strong differential expression.

The KEGG KO results should be presented carefully. KofamScan successfully produced KO assignments, but the enrichment tests did not identify FDR-significant KO terms. This means the KO annotations are useful for gene-level context, but the KEGG enrichment plots should be framed as exploratory summaries rather than confirmed pathway-level findings.

## Important Caveats

- These annotations are computational predictions based on transcript assembly, predicted ORFs, homology, conserved domains, Pfam-to-GO mappings, and KOfam profiles.
- A predicted domain or GO term does not prove the exact function of a gene in *L. stagnalis*.
- The KEGG KO enrichment plots are not FDR-significant and should not be overinterpreted.
- The clearest supported conclusions are the age-associated expression separation, the large DE shift involving 3-month samples, the presence of thousands of Pfam-supported DE genes, and the FDR-significant GO categories in selected contrasts.
