snail <- "/Users/jennyfzhao/Work/task/2026-06-03_rnaseq/papers/lymnaea_stagnalis_CNS_aging"

go_file <- file.path(snail, "data/annotation/go_pfam2go/lymnaea_protein_go_pfam2go.tsv")
ko_file <- file.path(snail, "data/annotation/kofam/lymnaea_kofam.mapper.tsv")
de_dir <- file.path(snail, "figures/deseq2_results")
out_dir <- file.path(snail, "data/annotation/enrichment")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

protein_to_gene <- function(x) sub("\\.[0-9]+\\.p[0-9]+$", "", x)

go <- read.table(go_file, sep="\t", header=FALSE, quote="", comment.char="", stringsAsFactors=FALSE)
colnames(go) <- c("protein_id", "term")
go$gene_id <- protein_to_gene(go$protein_id)
go <- unique(go[, c("gene_id", "term")])

ko <- read.table(ko_file, sep="\t", header=FALSE, quote="", comment.char="", fill=TRUE, stringsAsFactors=FALSE)
colnames(ko)[1:2] <- c("protein_id", "term")
ko <- ko[!is.na(ko$term) & ko$term != "", c("protein_id", "term")]
ko$gene_id <- protein_to_gene(ko$protein_id)
ko <- unique(ko[, c("gene_id", "term")])

write.table(go, file.path(out_dir, "gene_to_go.tsv"), sep="\t", quote=FALSE, row.names=FALSE)
write.table(ko, file.path(out_dir, "gene_to_kegg_ko.tsv"), sep="\t", quote=FALSE, row.names=FALSE)

collapse_terms <- function(df, term_col_name) {
  split_terms <- split(df$term, df$gene_id)
  data.frame(
    gene_id = names(split_terms),
    value = vapply(split_terms, function(x) paste(sort(unique(x)), collapse=";"), character(1)),
    stringsAsFactors = FALSE
  ) |>
    setNames(c("gene_id", term_col_name))
}

run_enrichment <- function(de, annot, contrast, label) {
  universe <- unique(de$gene_id[!is.na(de$padj)])
  sig <- unique(de$gene_id[!is.na(de$padj) & de$padj < 0.05 & abs(de$log2FoldChange) > 1])

  annot_u <- annot[annot$gene_id %in% universe, ]
  terms <- sort(unique(annot_u$term))

  rows <- lapply(terms, function(term) {
    term_genes <- unique(annot_u$gene_id[annot_u$term == term])
    a <- sum(sig %in% term_genes)
    b <- length(sig) - a
    c <- sum(setdiff(universe, sig) %in% term_genes)
    d <- length(universe) - length(sig) - c

    p <- fisher.test(matrix(c(a, b, c, d), nrow=2), alternative="greater")$p.value

    data.frame(
      contrast = contrast,
      ontology = label,
      term = term,
      sig_with_term = a,
      sig_total = length(sig),
      universe_with_term = length(term_genes),
      universe_total = length(universe),
      pvalue = p,
      stringsAsFactors = FALSE
    )
  })

  res <- do.call(rbind, rows)
  if (is.null(res) || nrow(res) == 0) {
    return(data.frame())
  }

  res$padj <- p.adjust(res$pvalue, method="BH")
  res <- res[order(res$padj, res$pvalue), ]
  res
}

de_files <- list.files(de_dir, pattern="_DESeq2_results\\.csv$", full.names=TRUE)

go_wide <- collapse_terms(go, "GO_terms")
ko_wide <- collapse_terms(ko, "KEGG_KO")

for (de_file in de_files) {
  contrast <- sub("_DESeq2_results\\.csv$", "", basename(de_file))
  de <- read.csv(de_file, stringsAsFactors=FALSE, check.names=FALSE)

  go_res <- run_enrichment(de, go, contrast, "GO")
  ko_res <- run_enrichment(de, ko, contrast, "KEGG_KO")

  write.csv(go_res, file.path(out_dir, paste0(contrast, "_GO_enrichment.csv")), row.names=FALSE)
  write.csv(ko_res, file.path(out_dir, paste0(contrast, "_KEGG_KO_enrichment.csv")), row.names=FALSE)

  annotated <- merge(de, go_wide, by="gene_id", all.x=TRUE)
  annotated <- merge(annotated, ko_wide, by="gene_id", all.x=TRUE)

  write.csv(annotated, file.path(out_dir, paste0(contrast, "_DESeq2_with_GO_KEGG.csv")), row.names=FALSE)
}
