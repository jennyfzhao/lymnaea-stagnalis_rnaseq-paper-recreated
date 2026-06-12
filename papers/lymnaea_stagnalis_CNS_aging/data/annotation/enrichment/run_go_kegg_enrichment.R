suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

snail <- "/Users/jennyfzhao/Work/task/2026-06-03_rnaseq/papers/lymnaea_stagnalis_CNS_aging"

go_file <- file.path(snail, "data/annotation/go_pfam2go/lymnaea_protein_go_pfam2go.tsv")
ko_file <- file.path(snail, "data/annotation/kofam/lymnaea_kofam.mapper.tsv")
de_dir <- file.path(snail, "figures/deseq2_results")
out_dir <- file.path(snail, "data/annotation/enrichment")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

protein_to_gene <- function(x) sub("\\.[0-9]+\\.p[0-9]+$", "", x)

go <- read_tsv(go_file, col_names = c("protein_id", "term"), show_col_types = FALSE) %>%
  mutate(gene_id = protein_to_gene(protein_id)) %>%
  distinct(gene_id, term)

ko <- read_tsv(ko_file, col_names = c("protein_id", "term"), show_col_types = FALSE) %>%
  filter(!is.na(term), term != "") %>%
  mutate(gene_id = protein_to_gene(protein_id)) %>%
  distinct(gene_id, term)

write_tsv(go, file.path(out_dir, "gene_to_go.tsv"))
write_tsv(ko, file.path(out_dir, "gene_to_kegg_ko.tsv"))

run_enrichment <- function(de, annot, contrast, label) {
  universe <- de %>% filter(!is.na(padj)) %>% pull(gene_id) %>% unique()
  sig <- de %>%
    filter(!is.na(padj), padj < 0.05, abs(log2FoldChange) > 1) %>%
    pull(gene_id) %>%
    unique()

  annot_u <- annot %>% filter(gene_id %in% universe)
  terms <- sort(unique(annot_u$term))

  res <- lapply(terms, function(term) {
    term_genes <- unique(annot_u$gene_id[annot_u$term == term])
    a <- sum(sig %in% term_genes)
    b <- length(sig) - a
    c <- sum(setdiff(universe, sig) %in% term_genes)
    d <- length(universe) - length(sig) - c

    p <- fisher.test(matrix(c(a, b, c, d), nrow = 2), alternative = "greater")$p.value

    data.frame(
      contrast = contrast,
      ontology = label,
      term = term,
      sig_with_term = a,
      sig_total = length(sig),
      universe_with_term = length(term_genes),
      universe_total = length(universe),
      pvalue = p
    )
  }) %>% bind_rows()

  res %>%
    mutate(padj = p.adjust(pvalue, method = "BH")) %>%
    arrange(padj, pvalue)
}

de_files <- list.files(de_dir, pattern = "_DESeq2_results\\.csv$", full.names = TRUE)

for (de_file in de_files) {
  contrast <- basename(de_file) %>% sub("_DESeq2_results\\.csv$", "", .)
  de <- read_csv(de_file, show_col_types = FALSE)

  go_res <- run_enrichment(de, go, contrast, "GO")
  ko_res <- run_enrichment(de, ko, contrast, "KEGG_KO")

  write_csv(go_res, file.path(out_dir, paste0(contrast, "_GO_enrichment.csv")))
  write_csv(ko_res, file.path(out_dir, paste0(contrast, "_KEGG_KO_enrichment.csv")))

  annotated <- de %>%
    left_join(go %>% group_by(gene_id) %>% summarise(GO_terms = paste(sort(unique(term)), collapse = ";"), .groups = "drop"), by = "gene_id") %>%
    left_join(ko %>% group_by(gene_id) %>% summarise(KEGG_KO = paste(sort(unique(term)), collapse = ";"), .groups = "drop"), by = "gene_id")

  write_csv(annotated, file.path(out_dir, paste0(contrast, "_DESeq2_with_GO_KEGG.csv")))
}
