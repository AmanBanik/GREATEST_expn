#!/usr/bin/env python3
"""
scripts/audit_exp01.py — Comprehensive Raw Data Audit for EXP-20261016-01

This script independently audits the raw CSV outputs of EXP-20261016-01:
- Recomputes exact descriptive statistics (Min, Q1, Median, Q3, Max, Range, IQR)
  under NumPy Type 7 / R default linear interpolation quantile convention.
- Audits schemas, row counts, units, operations, and byte counts.
- Verifies checksum consistency across repetitions.
- Evaluates temporal patterns across repetitions (rep 0..4).
- Compares primary sweep to verification re-test.
"""

import csv
import sys
from pathlib import Path
import numpy as np

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-01-primary.csv")
VERIFICATION_CSV = Path("lab-notebook/raw/EXP-20261016-01-verification.csv")
SWEEP_LOG = Path("lab-notebook/raw/EXP-20261016-01-sweep.log")

EXPECTED_COLUMNS = [
    "mode", "elements", "working_set_bytes", "work_count", "chains",
    "repeat", "seconds", "operations", "ns_per_operation", "nominal_bytes", "checksum"
]

def format_size(bytes_sz: int) -> str:
    if bytes_sz < 1048576:
        return f"{bytes_sz // 1024} KiB"
    return f"{bytes_sz // 1048576} MiB"

def audit_file(csv_path: Path, expected_rows: int, label: str):
    print("=" * 110)
    print(f"AUDITING: {label}")
    print(f"Path: {csv_path}")
    print("=" * 110)

    if not csv_path.exists():
        print(f"ERROR: File does not exist: {csv_path}")
        sys.exit(1)

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        columns = reader.fieldnames
        rows = list(reader)

    print(f"Header columns ({len(columns)}): {columns}")
    assert columns == EXPECTED_COLUMNS, f"Column mismatch! Expected {EXPECTED_COLUMNS}, got {columns}"
    print(f"Row count: {len(rows)} (expected: {expected_rows}) -> {'MATCH' if len(rows) == expected_rows else 'MISMATCH'}")
    assert len(rows) == expected_rows, f"Expected {expected_rows} rows, found {len(rows)}"

    # Audit individual rows
    by_size = {}
    for i, r in enumerate(rows):
        mode = r["mode"]
        elements = int(r["elements"])
        bytes_sz = int(r["working_set_bytes"])
        work_count = int(r["work_count"])
        chains = int(r["chains"])
        rep = int(r["repeat"])
        seconds = float(r["seconds"])
        operations = float(r["operations"])
        ns_per_op = float(r["ns_per_operation"])
        nominal_bytes = float(r["nominal_bytes"])
        checksum = int(r["checksum"])

        assert mode == "chase", f"Row {i}: unexpected mode {mode}"
        assert bytes_sz == elements * 8, f"Row {i}: byte accounting mismatch {bytes_sz} != {elements} * 8"
        assert chains == 1, f"Row {i}: unexpected chains {chains}"
        assert work_count == 2000000, f"Row {i}: unexpected work_count {work_count}"
        assert operations == 2000000.0, f"Row {i}: unexpected operations {operations}"
        assert nominal_bytes == 2000000.0 * 8.0, f"Row {i}: unexpected nominal_bytes {nominal_bytes}"

        # Verify derived ns_per_operation from seconds
        expected_ns_per_op = (seconds * 1e9) / operations
        # Float rounding tolerance
        assert abs(ns_per_op - expected_ns_per_op) < 1e-4, f"Row {i}: ns_per_op discrepancy: {ns_per_op} vs {expected_ns_per_op}"

        if bytes_sz not in by_size:
            by_size[bytes_sz] = []
        by_size[bytes_sz].append({
            "rep": rep,
            "seconds": seconds,
            "ns_per_op": ns_per_op,
            "checksum": checksum,
            "elements": elements
        })

    print("All row-level schema, operation count, and byte accounting assertions passed.\n")

    # Recompute statistics and print table
    headers = [
        "Size", "Bytes", "Elements", "N",
        "Median (ns/op)", "Min (ns/op)", "Q1 (ns/op)", "Q3 (ns/op)",
        "Max (ns/op)", "Range (ns/op)", "IQR (ns/op)", "Checksum", "Csum OK?"
    ]
    print(f"{headers[0]:>8s} | {headers[1]:>8s} | {headers[2]:>8s} | {headers[3]:>2s} | "
          f"{headers[4]:>14s} | {headers[5]:>11s} | {headers[6]:>10s} | {headers[7]:>10s} | "
          f"{headers[8]:>11s} | {headers[9]:>13s} | {headers[10]:>11s} | {headers[11]:>8s} | {headers[12]:>8s}")
    print("-" * 145)

    stats_summary = {}

    for bsz in sorted(by_size.keys()):
        items = by_size[bsz]
        h_sz = format_size(bsz)
        elems = items[0]["elements"]
        n_reps = len(items)

        # Ensure repetitions are 0..n_reps-1 in order
        for exp_rep, item in enumerate(items):
            assert item["rep"] == exp_rep, f"Repetition order mismatch: expected {exp_rep}, got {item['rep']}"

        csums = {item["checksum"] for item in items}
        csum_val = items[0]["checksum"]
        csum_ok = (len(csums) == 1)

        raw_ns = [item["ns_per_op"] for item in items]
        sorted_ns = sorted(raw_ns)

        # Type 7 quantile linear interpolation (NumPy default method="linear")
        # For N=5:
        # Min = sorted_ns[0]
        # Q1  = sorted_ns[1] (index 4 * 0.25 = 1.0)
        # Med = sorted_ns[2] (index 4 * 0.50 = 2.0)
        # Q3  = sorted_ns[3] (index 4 * 0.75 = 3.0)
        # Max = sorted_ns[4] (index 4 * 1.00 = 4.0)
        mn = sorted_ns[0]
        q1 = sorted_ns[1]
        med = sorted_ns[2]
        q3 = sorted_ns[3]
        mx = sorted_ns[4]
        rng = mx - mn
        iqr = q3 - q1

        # Check against numpy
        np_q1 = float(np.percentile(raw_ns, 25, method="linear"))
        np_med = float(np.percentile(raw_ns, 50, method="linear"))
        np_q3 = float(np.percentile(raw_ns, 75, method="linear"))
        assert abs(q1 - np_q1) < 1e-9
        assert abs(med - np_med) < 1e-9
        assert abs(q3 - np_q3) < 1e-9

        stats_summary[bsz] = {
            "h_sz": h_sz,
            "elements": elems,
            "bytes": bsz,
            "n": n_reps,
            "median": med,
            "min": mn,
            "q1": q1,
            "q3": q3,
            "max": mx,
            "range": rng,
            "iqr": iqr,
            "checksum": csum_val,
            "csum_ok": csum_ok,
            "raw_ns": raw_ns
        }

        print(f"{h_sz:>8s} | {bsz:8d} | {elems:8d} | {n_reps:2d} | "
              f"{med:14.4f} | {mn:11.4f} | {q1:10.4f} | {q3:10.4f} | "
              f"{mx:11.4f} | {rng:13.4f} | {iqr:11.4f} | {csum_val:8d} | {str(csum_ok):>8s}")

    print("\nRepetition Sequence Audit (Time-Order Inspection):")
    print(f"{'Size':>8s} | {'Rep 0 (ns/op)':>13s} | {'Rep 1 (ns/op)':>13s} | {'Rep 2 (ns/op)':>13s} | {'Rep 3 (ns/op)':>13s} | {'Rep 4 (ns/op)':>13s}")
    print("-" * 85)
    for bsz in sorted(by_size.keys()):
        h_sz = format_size(bsz)
        raw_ns = stats_summary[bsz]["raw_ns"]
        row_str = " | ".join(f"{v:13.4f}" for v in raw_ns)
        print(f"{h_sz:>8s} | {row_str}")

    print()
    return stats_summary

def main():
    print("AUDIT SCRIPT RUNNING: Independent verification of EXP-20261016-01\n")
    primary_stats = audit_file(PRIMARY_CSV, 65, "PRIMARY ASCENDING SWEEP (65 rows)")
    verification_stats = audit_file(VERIFICATION_CSV, 10, "POST-SWEEP VERIFICATION (10 rows)")

    # Compare primary vs verification
    print("=" * 110)
    print("REPLICABILITY AUDIT: PRIMARY VS VERIFICATION")
    print("=" * 110)
    for bsz in sorted(verification_stats.keys()):
        h_sz = format_size(bsz)
        p_med = primary_stats[bsz]["median"]
        v_med = verification_stats[bsz]["median"]
        diff = abs(p_med - v_med)
        pct_diff = (diff / p_med) * 100.0
        p_csum = primary_stats[bsz]["checksum"]
        v_csum = verification_stats[bsz]["checksum"]
        print(f"Configuration {h_sz:>7s}: Primary Median = {p_med:8.4f} ns/op | Verification Median = {v_med:8.4f} ns/op | "
              f"Abs Diff = {diff:7.4f} ns/op ({pct_diff:5.2f}%) | "
              f"Checksum Match = {p_csum == v_csum} ({p_csum})")

if __name__ == "__main__":
    main()
