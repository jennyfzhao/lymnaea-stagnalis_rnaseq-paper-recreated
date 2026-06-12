args <- commandArgs(trailingOnly = FALSE)
script_file <- sub("--file=", "", args[grep("^--file=", args)])
if (length(script_file) == 0) {
  script_file <- "data/annotation/enrichment/plot_enrichment_baseR.R"
}
enrich_dir <- dirname(normalizePath(script_file, mustWork = FALSE))
snail <- normalizePath(file.path(enrich_dir, "../../.."), mustWork = FALSE)
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
  tmp_png <- tempfile(tmpdir = fig_dir, fileext = ".png")
  tmp_pdf <- tempfile(tmpdir = fig_dir, fileext = ".pdf")

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

  png_args <- list(filename = tmp_png, width = 1800, height = 1200, res = 180)
  if (capabilities("cairo")) {
    png_args$type <- "cairo"
  }
  current_device <- dev.cur()
  png_opened <- tryCatch(
    {
      do.call(png, png_args)
      !identical(dev.cur(), current_device)
    },
    error = function(e) {
      warning("Skipping PNG output for ", basename(out_png), ": ", conditionMessage(e))
      FALSE
    }
  )
  if (png_opened) {
    make_plot()
    dev.off()
    file.rename(tmp_png, out_png)
  }

  pdf_opened <- tryCatch(
    {
      pdf(tmp_pdf, width = 10, height = 7)
      TRUE
    },
    error = function(e) {
      warning("Skipping PDF output for ", basename(out_pdf), ": ", conditionMessage(e))
      FALSE
    }
  )
  if (pdf_opened) {
    make_plot()
    dev.off()
    file.rename(tmp_pdf, out_pdf)
  }
}

files <- list.files(enrich_dir, pattern = "_enrichment\\.csv$", full.names = TRUE)
invisible(lapply(files, plot_file))
