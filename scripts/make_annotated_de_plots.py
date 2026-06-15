#!/usr/bin/env python3
"""Create plots and tables from Pfam-annotated DESeq2 results."""

from __future__ import annotations

import argparse
import csv
import math
import os
from collections import Counter
from pathlib import Path

if "MPLCONFIGDIR" not in os.environ:
    mpl_cache = Path.cwd() / ".cache" / "matplotlib"
    mpl_cache.mkdir(parents=True, exist_ok=True)
    os.environ["MPLCONFIGDIR"] = str(mpl_cache)

import matplotlib.pyplot as plt


def parse_float(value: str) -> float:
    if value in {"", "NA", "NaN", "nan"}:
        return float("nan")
    return float(value)


def classify(row: dict[str, str], padj_cutoff: float, lfc_cutoff: float) -> str:
    padj = parse_float(row["padj"])
    lfc = parse_float(row["log2FoldChange"])
    if math.isnan(padj) or math.isnan(lfc):
        return "Not significant"
    if padj < padj_cutoff and lfc >= lfc_cutoff:
        return "Up"
    if padj < padj_cutoff and lfc <= -lfc_cutoff:
        return "Down"
    return "Not significant"


def read_rows(path: Path, padj_cutoff: float, lfc_cutoff: float) -> list[dict[str, str]]:
    rows = []
    with path.open(newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            row["log2FoldChange_float"] = parse_float(row["log2FoldChange"])
            row["padj_float"] = parse_float(row["padj"])
            row["minus_log10_padj"] = -math.log10(max(row["padj_float"], 1e-300)) if not math.isnan(row["padj_float"]) else float("nan")
            row["result"] = classify(row, padj_cutoff, lfc_cutoff)
            row["has_pfam"] = row.get("pfam_domain_count", "0") not in {"", "0"}
            rows.append(row)
    return rows


def write_csv(path: Path, rows: list[dict[str, str]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def plot_volcano(rows: list[dict[str, str]], output: Path, contrast_label: str, lfc_cutoff: float, padj_cutoff: float) -> None:
    colors = {"Up": "#c43c45", "Down": "#2f70b7", "Not significant": "#bdbdbd"}
    order = ["Not significant", "Down", "Up"]

    fig, ax = plt.subplots(figsize=(10, 5))
    for result in order:
        subset = [row for row in rows if row["result"] == result]
        ax.scatter(
            [row["log2FoldChange_float"] for row in subset],
            [row["minus_log10_padj"] for row in subset],
            s=8,
            alpha=0.45 if result == "Not significant" else 0.65,
            color=colors[result],
            label=f"{result} ({len(subset):,})",
            linewidths=0,
        )

    annotated = [row for row in rows if row["result"] != "Not significant" and row["has_pfam"]]
    ax.scatter(
        [row["log2FoldChange_float"] for row in annotated],
        [row["minus_log10_padj"] for row in annotated],
        s=12,
        facecolors="none",
        edgecolors="black",
        linewidths=0.25,
        label=f"Significant + Pfam ({len(annotated):,})",
    )

    ax.axvline(-lfc_cutoff, color="black", linestyle="--", linewidth=1)
    ax.axvline(lfc_cutoff, color="black", linestyle="--", linewidth=1)
    ax.axhline(-math.log10(padj_cutoff), color="black", linestyle="--", linewidth=1)
    ax.set_xlabel("log2 fold change")
    ax.set_ylabel("-log10 adjusted p-value")
    ax.set_title(f"{contrast_label} volcano plot with Pfam annotation")
    ax.legend(frameon=False, markerscale=2)
    fig.tight_layout()
    fig.savefig(output)
    plt.close(fig)


def plot_top_pfam_by_direction(rows: list[dict[str, str]], output: Path, contrast_label: str, top_n: int = 15) -> None:
    counts = {"Up": Counter(), "Down": Counter()}
    for row in rows:
        if row["result"] in counts and row["has_pfam"]:
            counts[row["result"]][row["top_pfam_name"]] += 1

    labels = [name for name, _ in (counts["Up"] + counts["Down"]).most_common(top_n)]
    up_values = [counts["Up"][label] for label in labels]
    down_values = [counts["Down"][label] for label in labels]
    y = list(range(len(labels)))

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.barh(y, down_values, color="#2f70b7", label="Down")
    ax.barh(y, up_values, left=down_values, color="#c43c45", label="Up")
    ax.set_yticks(y)
    ax.set_yticklabels(labels)
    ax.invert_yaxis()
    ax.set_xlabel("Number of significant genes")
    ax.set_title(f"{contrast_label}: top Pfam domains among significant DE genes")
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(output)
    plt.close(fig)


def plot_top_annotated_genes(rows: list[dict[str, str]], output: Path, contrast_label: str, top_n: int = 20) -> None:
    candidates = [row for row in rows if row["result"] != "Not significant" and row["has_pfam"]]
    candidates.sort(key=lambda row: row["padj_float"])
    top = candidates[:top_n]
    labels = [f"{row['gene_id']}\\n{row['top_pfam_name']}" for row in top]
    values = [row["log2FoldChange_float"] for row in top]
    colors = ["#c43c45" if value > 0 else "#2f70b7" for value in values]

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.barh(range(len(top)), values, color=colors)
    ax.set_yticks(range(len(top)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.invert_yaxis()
    ax.axvline(0, color="black", linewidth=1)
    ax.set_xlabel("log2 fold change")
    ax.set_title(f"{contrast_label}: top significant Pfam-annotated DE genes")
    fig.tight_layout()
    fig.savefig(output)
    plt.close(fig)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--padj-cutoff", type=float, default=0.05)
    parser.add_argument("--lfc-cutoff", type=float, default=1.0)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    rows = read_rows(args.input, args.padj_cutoff, args.lfc_cutoff)
    contrast_label = args.output_dir.name.replace("_", " ")

    significant_annotated = [
        row for row in rows if row["result"] != "Not significant" and row["has_pfam"]
    ]
    significant_annotated.sort(key=lambda row: row["padj_float"])

    table_fields = [
        "gene_id",
        "baseMean",
        "log2FoldChange",
        "padj",
        "result",
        "pfam_domain_count",
        "top_pfam_name",
        "top_pfam_accession",
        "top_pfam_ievalue",
        "top_pfam_description",
        "pfam_domains",
    ]
    write_csv(
        args.output_dir / "top_significant_annotated_genes.csv",
        significant_annotated[:100],
        table_fields,
    )

    domain_rows = []
    for direction in ["Up", "Down"]:
        counter = Counter(
            row["top_pfam_name"]
            for row in rows
            if row["result"] == direction and row["has_pfam"]
        )
        for domain, count in counter.most_common():
            domain_rows.append({"direction": direction, "top_pfam_name": domain, "gene_count": count})
    write_csv(args.output_dir / "pfam_domain_counts_by_direction.csv", domain_rows, ["direction", "top_pfam_name", "gene_count"])

    plot_volcano(rows, args.output_dir / "volcano_with_pfam_annotation.png", contrast_label, args.lfc_cutoff, args.padj_cutoff)
    plot_top_pfam_by_direction(rows, args.output_dir / "top_pfam_domains_by_direction.png", contrast_label)
    plot_top_annotated_genes(rows, args.output_dir / "top_annotated_de_genes_log2fc.png", contrast_label)

    counts = Counter(row["result"] for row in rows)
    with (args.output_dir / "summary.txt").open("w") as handle:
        handle.write(f"Input: {args.input}\n")
        handle.write(f"padj cutoff: {args.padj_cutoff}\n")
        handle.write(f"log2 fold-change cutoff: {args.lfc_cutoff}\n")
        handle.write(f"Up: {counts['Up']}\n")
        handle.write(f"Down: {counts['Down']}\n")
        handle.write(f"Not significant: {counts['Not significant']}\n")
        handle.write(f"Significant genes with Pfam annotation: {len(significant_annotated)}\n")

    print(f"Wrote tables and plots to {args.output_dir}")


if __name__ == "__main__":
    main()
