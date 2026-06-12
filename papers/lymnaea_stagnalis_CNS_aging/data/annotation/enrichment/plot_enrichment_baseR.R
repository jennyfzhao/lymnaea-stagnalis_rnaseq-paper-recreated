snail <- "/Users/jennyfzhao/Work/task/2026-06-03_rnaseq/papers/lymnaea_stagnalis_CNS_aging"
enrich_dir <- file.path(snail, "data/annotation/enrichment")
fig_dir <- file.path(snail, "figures/enrichment")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

plot_file <- function(file, top_n = 20) {
  df <- read.csv(file, stringsAsFactors = FALSE)
  if (nrow(df) == 0) return(NULL)

  contrast <- unique(df$contrast)[1]
  ontology <- unique(df$ontology)[1]

  sig <- df[!is.na(df$padj) & df$padj < 0.05, ]
  if (nrow(sig) == 0) {
    sig <- df[order(df$pvalue), ][1:min(top_n, nrow(df)), ]
    suffix <- "top_by_pvalue_not_fdr_significant"
  } else {
    sig <- sig[order(sig$padj, sig$pvalue), ][1:min(top_n, nrow(sig)), ]
    suffix <- "fdr_significant"
  }

  sig$minus_log10_padj <- -log10(sig$padj)
  sig$gene_ratio <- sig$sig_with_term / sig$sig_total
  labels <- sig$term

  out_png <- file.path(fig_dir, paste0(contrast, "_", ontology, "_", suffix, ".png"))
  out_pdf <- file.path(fig_dir, paste0(contrast, "_", ontology, "_", suffix, ".pdf"))

  make_plot <- function() {
    old_mar <- par("mar")
    par(mar = c(5, 10, 4, 2))
    x <- rev(sig$minus_log10_padj)
    names(x) <- rev(labels)
    barplot(
      x,
      horiz = TRUE,
      las = 1,
      col = "#4C78A8",
      xlab = "-log10(FDR)",
      main = paste(contrast, ontology)
    )
    par(mar = old_mar)
  }

  png(out_png, width = 1800, height = 1200, res = 180)
  make_plot()
  dev.off()

  pdf(out_pdf, width = 10, height = 7)
  make_plot()
  dev.off()
}

files <- list.files(enrich_dir, pattern = "_enrichment\\.csv$", full.names = TRUE)
invisible(lapply(files, plot_file))
