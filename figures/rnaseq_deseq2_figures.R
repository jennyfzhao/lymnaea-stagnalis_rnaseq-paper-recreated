#!/usr/bin/env Rscript

# RNA-seq downstream analysis for Lymnaea stagnalis CNS aging samples.
# Place/run this script from:
# figures
#
# Input files are auto-detected from the script location or current working
# directory, so this can be run from RStudio even if the working directory is
# the project root rather than this figures folder.
#
# Outputs are written under:
# ./deseq2_results
# ./pca
# ./heatmaps
# ./volcano_plots

required_packages <- c("DESeq2", "ggplot2", "pheatmap")

# Plot-saving behavior:
#   NA    = show each plot in R/RStudio and ask whether to save it
#   TRUE  = show each plot and save automatically
#   FALSE = show each plot only
SAVE_PLOTS <- NA

check_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) > 0) {
    stop(
      "Missing required R package(s): ", paste(missing, collapse = ", "), "\n\n",
      "Install them first with:\n",
      "install.packages(c(\"BiocManager\", \"ggplot2\", \"pheatmap\"), repos = \"https://cloud.r-project.org\")\n",
      "BiocManager::install(\"DESeq2\")\n",
      call. = FALSE
    )
  }
}

get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)

  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
  }

  if (
    requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()
  ) {
    active_path <- rstudioapi::getActiveDocumentContext()$path
    if (!is.null(active_path) && nzchar(active_path)) {
      return(dirname(normalizePath(active_path)))
    }
  }

  normalizePath(getwd())
}

setup_paths <- function() {
  script_dir <- get_script_dir()
  paper_dir <- find_paper_dir(script_dir)
  figures_dir <- file.path(paper_dir, "figures")

  if (!dir.exists(figures_dir)) {
    dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
  }

  setwd(figures_dir)

  paths <- list(
    paper_dir = paper_dir,
    figures_dir = figures_dir,
    count_matrix = file.path(paper_dir, "data", "expression_matrices", "gene_count_matrix.csv"),
    metadata = file.path(paper_dir, "data", "sample_metadata.tsv"),
    results_dir = file.path(figures_dir, "deseq2_results"),
    pca_dir = file.path(figures_dir, "pca"),
    heatmap_dir = file.path(figures_dir, "heatmaps"),
    volcano_dir = file.path(figures_dir, "volcano_plots")
  )

  for (dir_path in c(paths$results_dir, paths$pca_dir, paths$heatmap_dir, paths$volcano_dir)) {
    dir.create(dir_path, showWarnings = FALSE, recursive = TRUE)
  }

  if (!file.exists(paths$count_matrix)) {
    stop("Cannot find count matrix at: ", paths$count_matrix, call. = FALSE)
  }

  if (!file.exists(paths$metadata)) {
    stop("Cannot find sample metadata at: ", paths$metadata, call. = FALSE)
  }

  paths
}

find_paper_dir <- function(script_dir) {
  starting_points <- unique(normalizePath(
    c(script_dir, getwd()),
    winslash = "/",
    mustWork = FALSE
  ))

  candidate_dirs <- character()

  for (start_dir in starting_points) {
    current_dir <- start_dir

    repeat {
      candidate_dirs <- c(candidate_dirs, current_dir)

      parent_dir <- dirname(current_dir)
      if (identical(parent_dir, current_dir)) {
        break
      }
      current_dir <- parent_dir
    }
  }

  candidate_dirs <- unique(candidate_dirs)

  for (candidate_dir in candidate_dirs) {
    count_matrix <- file.path(candidate_dir, "data", "expression_matrices", "gene_count_matrix.csv")
    metadata <- file.path(candidate_dir, "data", "sample_metadata.tsv")

    if (file.exists(count_matrix) && file.exists(metadata)) {
      return(normalizePath(candidate_dir, winslash = "/", mustWork = TRUE))
    }
  }

  stop(
    "Could not locate the snail paper data folder.\n\n",
    "I looked for both of these files together:\n",
    "data/expression_matrices/gene_count_matrix.csv\n",
    "data/sample_metadata.tsv\n\n",
    "Open this script from the project folder or move it back under:\n",
    "figures",
    call. = FALSE
  )
}

load_and_align_data <- function(count_matrix_path, metadata_path) {
  counts_raw <- read.csv(count_matrix_path, check.names = FALSE)
  metadata <- read.delim(metadata_path, check.names = FALSE, stringsAsFactors = FALSE)

  required_metadata_columns <- c("run_accession", "sample_name", "age_months", "replicate")
  missing_metadata_columns <- setdiff(required_metadata_columns, colnames(metadata))

  if (length(missing_metadata_columns) > 0) {
    stop(
      "Metadata is missing required column(s): ",
      paste(missing_metadata_columns, collapse = ", "),
      call. = FALSE
    )
  }

  if (!"gene_id" %in% colnames(counts_raw)) {
    stop("Count matrix must contain a 'gene_id' column.", call. = FALSE)
  }

  if (anyDuplicated(counts_raw$gene_id) > 0) {
    stop("Count matrix contains duplicated gene_id values.", call. = FALSE)
  }

  rownames(counts_raw) <- counts_raw$gene_id
  counts <- counts_raw[, setdiff(colnames(counts_raw), "gene_id"), drop = FALSE]
  counts <- as.matrix(counts)
  storage.mode(counts) <- "numeric"

  count_samples <- colnames(counts)
  metadata_samples <- metadata$run_accession

  samples_missing_from_metadata <- setdiff(count_samples, metadata_samples)
  metadata_missing_from_counts <- setdiff(metadata_samples, count_samples)

  if (length(samples_missing_from_metadata) > 0 || length(metadata_missing_from_counts) > 0) {
    stop(
      "Count matrix and metadata samples do not match.\n",
      "In counts but not metadata: ", paste(samples_missing_from_metadata, collapse = ", "), "\n",
      "In metadata but not counts: ", paste(metadata_missing_from_counts, collapse = ", "),
      call. = FALSE
    )
  }

  metadata <- metadata[match(count_samples, metadata$run_accession), ]
  rownames(metadata) <- metadata$run_accession

  metadata$age_months <- as.character(metadata$age_months)
  metadata$age_group <- factor(
    paste0(metadata$age_months, "_month"),
    levels = c("3_month", "6_month", "18_month")
  )
  metadata$replicate <- as.integer(metadata$replicate)
  metadata$plot_label <- paste0(metadata$age_months, "mo_rep", metadata$replicate)

  if (any(is.na(metadata$age_group))) {
    stop("Metadata contains age_months values outside expected groups: 3, 6, 18.", call. = FALSE)
  }

  if (!identical(colnames(counts), rownames(metadata))) {
    stop("Internal alignment failed: count columns do not match metadata row names.", call. = FALSE)
  }

  list(counts = counts, metadata = metadata)
}

run_deseq2 <- function(counts, metadata, min_count = 10, min_samples = 3) {
  suppressPackageStartupMessages(library(DESeq2))

  counts <- round(counts)
  dds <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = metadata,
    design = ~ age_group
  )

  keep <- rowSums(counts(dds) >= min_count) >= min_samples
  dds <- dds[keep, ]

  dds <- DESeq(dds)
  vsd <- vst(dds, blind = FALSE)

  list(dds = dds, vsd = vsd)
}

save_deseq2_tables <- function(dds, results_dir) {
  comparisons <- list(
    "6_month_vs_3_month" = c("age_group", "6_month", "3_month"),
    "18_month_vs_3_month" = c("age_group", "18_month", "3_month"),
    "18_month_vs_6_month" = c("age_group", "18_month", "6_month")
  )

  result_tables <- list()

  for (comparison_name in names(comparisons)) {
    res <- results(dds, contrast = comparisons[[comparison_name]])
    res <- res[order(res$padj), ]

    res_df <- as.data.frame(res)
    res_df$gene_id <- rownames(res_df)
    res_df <- res_df[, c("gene_id", setdiff(colnames(res_df), "gene_id"))]

    out_csv <- file.path(results_dir, paste0(comparison_name, "_DESeq2_results.csv"))
    write.csv(res_df, out_csv, row.names = FALSE)

    result_tables[[comparison_name]] <- res_df
  }

  result_tables
}

save_normalized_tables <- function(dds, vsd, metadata, results_dir) {
  normalized_counts <- as.data.frame(counts(dds, normalized = TRUE))
  normalized_counts$gene_id <- rownames(normalized_counts)
  normalized_counts <- normalized_counts[, c("gene_id", rownames(metadata))]

  vst_matrix <- as.data.frame(assay(vsd))
  vst_matrix$gene_id <- rownames(vst_matrix)
  vst_matrix <- vst_matrix[, c("gene_id", rownames(metadata))]

  write.csv(
    normalized_counts,
    file.path(results_dir, "normalized_counts_DESeq2.csv"),
    row.names = FALSE
  )

  write.csv(
    vst_matrix,
    file.path(results_dir, "vst_expression_matrix.csv"),
    row.names = FALSE
  )
}

ask_to_save_plot <- function(plot_name) {
  if (identical(SAVE_PLOTS, TRUE)) {
    return(TRUE)
  }

  if (identical(SAVE_PLOTS, FALSE) || !interactive()) {
    return(FALSE)
  }

  answer <- readline(paste0("Save ", plot_name, "? Type y or n, then press Enter: "))
  tolower(trimws(answer)) %in% c("y", "yes")
}

save_ggplot_if_requested <- function(plot_object, plot_name, out_prefix, width, height, dpi = 300) {
  print(plot_object)

  if (ask_to_save_plot(plot_name)) {
    ggsave(paste0(out_prefix, ".png"), plot_object, width = width, height = height, dpi = dpi)
    ggsave(paste0(out_prefix, ".pdf"), plot_object, width = width, height = height)
    message("Saved: ", out_prefix, ".png and .pdf")
  } else {
    message("Not saved: ", plot_name)
  }
}

save_pheatmap_if_requested <- function(heatmap_object, plot_name, out_prefix, width, height, dpi = 300) {
  grid::grid.newpage()
  grid::grid.draw(heatmap_object$gtable)

  if (ask_to_save_plot(plot_name)) {
    png(paste0(out_prefix, ".png"), width = width, height = height, units = "in", res = dpi)
    grid::grid.draw(heatmap_object$gtable)
    dev.off()

    pdf(paste0(out_prefix, ".pdf"), width = width, height = height)
    grid::grid.draw(heatmap_object$gtable)
    dev.off()

    message("Saved: ", out_prefix, ".png and .pdf")
  } else {
    message("Not saved: ", plot_name)
  }
}

get_sample_order <- function(metadata) {
  rownames(metadata)[order(metadata$age_group, metadata$replicate)]
}

plot_pca_log2_counts <- function(counts, metadata, pca_dir) {
  suppressPackageStartupMessages(library(ggplot2))

  sample_order <- get_sample_order(metadata)
  log2_counts <- log2(counts[, sample_order, drop = FALSE] + 1)
  pca <- prcomp(t(log2_counts), center = TRUE, scale. = FALSE)
  percent_var <- round(100 * (pca$sdev^2 / sum(pca$sdev^2)), 2)

  pca_data <- data.frame(
    run_accession = rownames(pca$x),
    PC1 = pca$x[, 1],
    PC2 = pca$x[, 2],
    stringsAsFactors = FALSE
  )
  pca_data$plot_label <- metadata[pca_data$run_accession, "plot_label"]
  pca_data$age_group <- metadata[pca_data$run_accession, "age_group"]

  p <- ggplot(pca_data, aes(x = PC1, y = PC2, color = age_group, shape = age_group, label = plot_label)) +
    geom_point(size = 3.5) +
    geom_text(vjust = -0.9, size = 3, show.legend = FALSE) +
    scale_color_manual(values = c("3_month" = "#2878B5", "6_month" = "#4AA564", "18_month" = "#C44E52")) +
    labs(
      title = "PCA of log2 raw gene counts",
      x = paste0("PC1: ", percent_var[1], "% variance"),
      y = paste0("PC2: ", percent_var[2], "% variance"),
      color = "Age group"
    ) +
    theme_classic(base_size = 12) +
    theme(
      aspect.ratio = 0.8,
      legend.position = "right"
    )

  save_ggplot_if_requested(
    plot_object = p,
    plot_name = "PCA of log2 raw counts",
    out_prefix = file.path(pca_dir, "PCA_log2_raw_counts"),
    width = 7.5,
    height = 5.5
  )

  write.csv(pca_data, file.path(pca_dir, "PCA_log2_raw_counts_coordinates.csv"), row.names = FALSE)

  invisible(p)
}

plot_sample_distance_heatmap <- function(vsd, metadata, heatmap_dir) {
  suppressPackageStartupMessages(library(pheatmap))

  sample_order <- get_sample_order(metadata)
  sample_dist <- dist(t(assay(vsd)[, sample_order, drop = FALSE]))
  sample_dist_matrix <- as.matrix(sample_dist)

  display_names <- metadata[colnames(sample_dist_matrix), "plot_label"]
  rownames(sample_dist_matrix) <- display_names
  colnames(sample_dist_matrix) <- display_names

  annotation_col <- data.frame(
    age_group = metadata[colnames(assay(vsd)), "age_group"],
    row.names = display_names
  )

  heatmap_object <- pheatmap(
    sample_dist_matrix,
    annotation_col = annotation_col,
    annotation_row = annotation_col,
    main = "Sample-to-sample distance",
    silent = TRUE,
    border_color = NA
  )

  save_pheatmap_if_requested(
    heatmap_object = heatmap_object,
    plot_name = "sample distance heatmap",
    out_prefix = file.path(heatmap_dir, "sample_distance_heatmap"),
    width = 7,
    height = 6
  )

  write.csv(
    sample_dist_matrix,
    file.path(heatmap_dir, "sample_distance_matrix.csv")
  )
}

plot_top_variable_gene_heatmap <- function(vsd, metadata, heatmap_dir, top_n = 2000) {
  suppressPackageStartupMessages(library(pheatmap))

  sample_order <- get_sample_order(metadata)
  vst_mat <- assay(vsd)[, sample_order, drop = FALSE]
  gene_variances <- apply(vst_mat, 1, var)
  top_genes <- names(sort(gene_variances, decreasing = TRUE))[seq_len(min(top_n, length(gene_variances)))]

  heatmap_mat <- vst_mat[top_genes, , drop = FALSE]
  heatmap_mat <- t(scale(t(heatmap_mat)))
  heatmap_mat[is.na(heatmap_mat)] <- 0

  colnames(heatmap_mat) <- metadata[colnames(heatmap_mat), "plot_label"]

  heatmap_object <- pheatmap(
    heatmap_mat,
    cluster_rows = TRUE,
    cluster_cols = FALSE,
    treeheight_row = 70,
    treeheight_col = 0,
    show_rownames = FALSE,
    show_colnames = TRUE,
    border_color = NA,
    color = colorRampPalette(c("#2166AC", "white", "#B2182B"))(101),
    main = paste("Top", length(top_genes), "most variable genes"),
    silent = TRUE
  )

  save_pheatmap_if_requested(
    heatmap_object = heatmap_object,
    plot_name = paste("top", length(top_genes), "variable gene heatmap"),
    out_prefix = file.path(heatmap_dir, paste0("top_", length(top_genes), "_variable_genes_heatmap")),
    width = 8.5,
    height = 10.5
  )

  write.csv(
    data.frame(gene_id = top_genes, variance = gene_variances[top_genes]),
    file.path(heatmap_dir, paste0("top_", length(top_genes), "_variable_genes.csv")),
    row.names = FALSE
  )
}

plot_volcano <- function(
  results_df,
  comparison_name,
  volcano_dir,
  padj_cutoff = 0.05,
  log2fc_cutoff = 1
) {
  suppressPackageStartupMessages(library(ggplot2))

  plot_df <- results_df
  plot_df$padj_plot <- plot_df$padj
  plot_df$padj_plot[is.na(plot_df$padj_plot)] <- 1
  plot_df$minus_log10_padj <- -log10(pmax(plot_df$padj_plot, .Machine$double.xmin))

  plot_df$significance <- "Not significant"
  plot_df$significance[
    !is.na(plot_df$padj) &
      plot_df$padj < padj_cutoff &
      plot_df$log2FoldChange >= log2fc_cutoff
  ] <- "Up"
  plot_df$significance[
    !is.na(plot_df$padj) &
      plot_df$padj < padj_cutoff &
      plot_df$log2FoldChange <= -log2fc_cutoff
  ] <- "Down"

  plot_df$significance <- factor(plot_df$significance, levels = c("Down", "Not significant", "Up"))

  max_abs_fc <- max(abs(plot_df$log2FoldChange[is.finite(plot_df$log2FoldChange)]), na.rm = TRUE)
  x_limit <- ceiling(max(4, min(max_abs_fc, 20)))

  p <- ggplot(plot_df, aes(x = log2FoldChange, y = minus_log10_padj, color = significance)) +
    geom_point(alpha = 0.6, size = 0.9) +
    geom_vline(xintercept = c(-log2fc_cutoff, log2fc_cutoff), linetype = "dashed", linewidth = 0.3) +
    geom_hline(yintercept = -log10(padj_cutoff), linetype = "dashed", linewidth = 0.3) +
    scale_color_manual(values = c("Down" = "#2878B5", "Not significant" = "grey70", "Up" = "#C44E52")) +
    coord_cartesian(xlim = c(-x_limit, x_limit)) +
    labs(
      title = gsub("_", " ", comparison_name),
      x = "log2 fold change",
      y = "-log10 adjusted p-value",
      color = "Result"
    ) +
    theme_classic(base_size = 12) +
    theme(
      aspect.ratio = 0.48,
      legend.position = "right"
    )

  save_ggplot_if_requested(
    plot_object = p,
    plot_name = paste("volcano plot:", comparison_name),
    out_prefix = file.path(volcano_dir, paste0(comparison_name, "_volcano")),
    width = 10,
    height = 5
  )

  sig_df <- plot_df[
    !is.na(plot_df$padj) &
      plot_df$padj < padj_cutoff &
      abs(plot_df$log2FoldChange) >= log2fc_cutoff,
  ]
  sig_df <- sig_df[order(sig_df$padj), ]

  write.csv(
    sig_df,
    file.path(volcano_dir, paste0(comparison_name, "_significant_genes.csv")),
    row.names = FALSE
  )

  invisible(p)
}

plot_all_volcanoes <- function(result_tables, volcano_dir, padj_cutoff = 0.05, log2fc_cutoff = 1) {
  for (comparison_name in names(result_tables)) {
    plot_volcano(
      results_df = result_tables[[comparison_name]],
      comparison_name = comparison_name,
      volcano_dir = volcano_dir,
      padj_cutoff = padj_cutoff,
      log2fc_cutoff = log2fc_cutoff
    )
  }
}

write_analysis_summary <- function(counts, metadata, dds, result_tables, results_dir) {
  summary_path <- file.path(results_dir, "analysis_summary.txt")

  sink(summary_path)
  cat("Lymnaea stagnalis CNS aging RNA-seq analysis summary\n")
  cat("Generated:", format(Sys.time()), "\n\n")

  cat("Input count matrix dimensions before DESeq2 filtering:\n")
  cat("Genes:", nrow(counts), "\n")
  cat("Samples:", ncol(counts), "\n\n")

  cat("Samples aligned to metadata:\n")
  print(metadata[, c("run_accession", "sample_name", "age_group", "replicate", "plot_label")])
  cat("\n")

  cat("Genes retained after DESeq2 filtering:\n")
  cat(nrow(dds), "\n\n")

  cat("Differential expression result counts using padj < 0.05 and abs(log2FC) >= 1:\n")
  for (comparison_name in names(result_tables)) {
    res <- result_tables[[comparison_name]]
    sig <- res[!is.na(res$padj) & res$padj < 0.05 & abs(res$log2FoldChange) >= 1, ]
    cat(comparison_name, ":", nrow(sig), "significant genes\n")
  }

  sink()
}

main <- function() {
  check_packages(required_packages)
  paths <- setup_paths()

  inputs <- load_and_align_data(
    count_matrix_path = paths$count_matrix,
    metadata_path = paths$metadata
  )

  deseq_objects <- run_deseq2(
    counts = inputs$counts,
    metadata = inputs$metadata,
    min_count = 10,
    min_samples = 3
  )

  result_tables <- save_deseq2_tables(
    dds = deseq_objects$dds,
    results_dir = paths$results_dir
  )

  save_normalized_tables(
    dds = deseq_objects$dds,
    vsd = deseq_objects$vsd,
    metadata = inputs$metadata,
    results_dir = paths$results_dir
  )

  plot_pca_log2_counts(
    counts = inputs$counts,
    metadata = inputs$metadata,
    pca_dir = paths$pca_dir
  )

  plot_sample_distance_heatmap(
    vsd = deseq_objects$vsd,
    metadata = inputs$metadata,
    heatmap_dir = paths$heatmap_dir
  )

  plot_top_variable_gene_heatmap(
    vsd = deseq_objects$vsd,
    metadata = inputs$metadata,
    heatmap_dir = paths$heatmap_dir,
    top_n = 2000
  )

  plot_all_volcanoes(
    result_tables = result_tables,
    volcano_dir = paths$volcano_dir,
    padj_cutoff = 0.05,
    log2fc_cutoff = 1
  )

  write_analysis_summary(
    counts = inputs$counts,
    metadata = inputs$metadata,
    dds = deseq_objects$dds,
    result_tables = result_tables,
    results_dir = paths$results_dir
  )

  message("Done. Outputs written under: ", normalizePath(paths$figures_dir))
}

main()
