#!/usr/bin/env python3
"""Build gene-level Pfam annotation tables and annotated DESeq2 CSVs."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


def gene_id_from_protein(protein_id: str) -> str:
    parts = protein_id.split(".")
    if len(parts) >= 2 and parts[0] == "MSTRG":
        return ".".join(parts[:2])
    return protein_id.rsplit(".", 1)[0]


def transcript_id_from_protein(protein_id: str) -> str:
    return protein_id.rsplit(".p", 1)[0]


def parse_domtblout(path: Path, max_domain_ievalue: float) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    with path.open() as handle:
        for line in handle:
            if not line.strip() or line.startswith("#"):
                continue
            fields = line.rstrip("\n").split(maxsplit=22)
            if len(fields) < 23:
                continue

            domain_ievalue = float(fields[12])
            if domain_ievalue > max_domain_ievalue:
                continue

            protein_id = fields[3]
            rows.append(
                {
                    "gene_id": gene_id_from_protein(protein_id),
                    "transcript_id": transcript_id_from_protein(protein_id),
                    "protein_id": protein_id,
                    "pfam_name": fields[0],
                    "pfam_accession": fields[1],
                    "target_length": fields[2],
                    "protein_length": fields[5],
                    "full_evalue": fields[6],
                    "full_score": fields[7],
                    "domain_number": fields[9],
                    "domain_count": fields[10],
                    "domain_cevalue": fields[11],
                    "domain_ievalue": fields[12],
                    "domain_score": fields[13],
                    "hmm_from": fields[15],
                    "hmm_to": fields[16],
                    "ali_from": fields[17],
                    "ali_to": fields[18],
                    "env_from": fields[19],
                    "env_to": fields[20],
                    "accuracy": fields[21],
                    "description": fields[22],
                }
            )
    rows.sort(key=lambda row: (row["gene_id"], float(row["domain_ievalue"]), -float(row["domain_score"])))
    return rows


def unique_join(values: list[str]) -> str:
    seen: set[str] = set()
    out: list[str] = []
    for value in values:
        if value and value not in seen:
            out.append(value)
            seen.add(value)
    return ";".join(out)


def summarize_by_gene(domain_rows: list[dict[str, str]]) -> dict[str, dict[str, str]]:
    grouped: dict[str, list[dict[str, str]]] = {}
    for row in domain_rows:
        grouped.setdefault(row["gene_id"], []).append(row)

    summaries: dict[str, dict[str, str]] = {}
    for gene_id, rows in grouped.items():
        rows.sort(key=lambda row: (float(row["domain_ievalue"]), -float(row["domain_score"])))
        top = rows[0]
        summaries[gene_id] = {
            "gene_id": gene_id,
            "pfam_domain_count": str(len(rows)),
            "top_pfam_name": top["pfam_name"],
            "top_pfam_accession": top["pfam_accession"],
            "top_pfam_ievalue": top["domain_ievalue"],
            "top_pfam_description": top["description"],
            "pfam_domains": unique_join([row["pfam_name"] for row in rows]),
            "pfam_accessions": unique_join([row["pfam_accession"] for row in rows]),
            "pfam_descriptions": unique_join([row["description"] for row in rows]),
            "pfam_proteins": unique_join([row["protein_id"] for row in rows]),
        }
    return summaries


def write_tsv(path: Path, rows: list[dict[str, str]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t", extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def annotate_csv(input_csv: Path, output_csv: Path, summaries: dict[str, dict[str, str]]) -> None:
    output_csv.parent.mkdir(parents=True, exist_ok=True)
    added_fields = [
        "pfam_domain_count",
        "top_pfam_name",
        "top_pfam_accession",
        "top_pfam_ievalue",
        "top_pfam_description",
        "pfam_domains",
        "pfam_accessions",
        "pfam_descriptions",
        "pfam_proteins",
    ]

    with input_csv.open(newline="") as in_handle, output_csv.open("w", newline="") as out_handle:
        reader = csv.DictReader(in_handle)
        fieldnames = list(reader.fieldnames or [])
        writer = csv.DictWriter(out_handle, fieldnames=fieldnames + added_fields)
        writer.writeheader()
        for row in reader:
            summary = summaries.get(row.get("gene_id", ""), {})
            for field in added_fields:
                row[field] = summary.get(field, "0" if field == "pfam_domain_count" else "")
            writer.writerow(row)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--domtblout", required=True, type=Path)
    parser.add_argument("--deseq-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--max-domain-ievalue", default=1e-5, type=float)
    args = parser.parse_args()

    domain_rows = parse_domtblout(args.domtblout, args.max_domain_ievalue)

    domain_fields = [
        "gene_id",
        "transcript_id",
        "protein_id",
        "pfam_name",
        "pfam_accession",
        "target_length",
        "protein_length",
        "full_evalue",
        "full_score",
        "domain_number",
        "domain_count",
        "domain_cevalue",
        "domain_ievalue",
        "domain_score",
        "hmm_from",
        "hmm_to",
        "ali_from",
        "ali_to",
        "env_from",
        "env_to",
        "accuracy",
        "description",
    ]
    write_tsv(args.output_dir / "protein_pfam_domains.tsv", domain_rows, domain_fields)

    summaries = summarize_by_gene(domain_rows)
    summary_rows = [summaries[gene_id] for gene_id in sorted(summaries)]
    summary_fields = [
        "gene_id",
        "pfam_domain_count",
        "top_pfam_name",
        "top_pfam_accession",
        "top_pfam_ievalue",
        "top_pfam_description",
        "pfam_domains",
        "pfam_accessions",
        "pfam_descriptions",
        "pfam_proteins",
    ]
    write_tsv(args.output_dir / "gene_pfam_summary.tsv", summary_rows, summary_fields)

    annotated_dir = args.output_dir / "deseq2_annotated"
    for input_csv in sorted(args.deseq_dir.glob("*_DESeq2_results.csv")):
        annotate_csv(input_csv, annotated_dir / f"{input_csv.stem}_with_pfam.csv", summaries)

    print(f"Significant Pfam domain rows: {len(domain_rows)}")
    print(f"Genes with Pfam annotation: {len(summaries)}")
    print(f"Wrote outputs to: {args.output_dir}")


if __name__ == "__main__":
    main()
