#!/usr/bin/env python3
"""
scripts/audit_exp02.py — Comprehensive Raw Data Audit & Statistical Analysis for EXP-20261016-02

Performs independent statistical evaluation:
- Audits schemas, row counts, byte accounting, operations counts, checksum determinism.
- Computes Type 7 quartiles (Min, Q1, Median, Q3, Max, Range, IQR) for ns/op.
- Computes median total elapsed seconds and derived step_time (ns).
- Computes intra-tier MLP speedup relative to C=1: S(C) = Median(C=1) / Median(C).
- Compares verification re-tests against primary sweep.
"""

import csv
import sys
from pathlib import Path
import numpy as np

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-02-primary.csv")
VERIFICATION_CSV = Path("lab-notebook/raw/EXP-20261016-02-verification.csv")
SWEEP_LOG = Path("lab-notebook/raw/EXP-20261016-02-sweep.log")

EXPECTED_COLUMNS = [
    "mode", "elements", "working_set_bytes", "work_count", "chains",
    "repeat", "seconds", "operations", "ns_per_operation", "nominal_bytes", "checksum"
]

def format_size(bytes_sz: int) -> str:
    if bytes_sz < 1048576:
        return f"{bytes_sz // 1024} KiB"
    return f"{bytes_sz // 1048576} MiB"

def audit_dataset(csv_path: Path, expected_rows: int, label: str):
    print("=" * 125)
    print(f"AUDITING: {label} ({csv_path})")
    print("=" * 125)

    if not csv_path.exists():
        print(f"ERROR: {csv_path} does not exist!")
        sys.exit(1)

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        columns = reader.fieldnames
        rows = list(reader)

    print(f"Header columns ({len(columns)}): {columns}")
    assert columns == EXPECTED_COLUMNS, f"Column mismatch! Expected {EXPECTED_COLUMNS}, got {columns}"
    print(f"Row count: {len(rows)} (expected: {expected_rows}) -> {'MATCH' if len(rows) == expected_rows else 'MISMATCH'}")
    assert len(rows) == expected_rows, f"Expected {expected_rows} rows, found {len(rows)}"

    # Group by (bytes, chains)
    grouped = {}
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

        assert mode == "chains", f"Row {i}: unexpected mode {mode}"
        assert bytes_sz == elements * 8, f"Row {i}: byte accounting mismatch {bytes_sz} != {elements} * 8"
        assert work_count == 2000000, f"Row {i}: unexpected work_count {work_count}"
        assert operations == float(work_count * chains), f"Row {i}: operations mismatch {operations} != {work_count * chains}"
        assert nominal_bytes == operations * 8.0, f"Row {i}: nominal_bytes mismatch"

        expected_ns_per_op = (seconds * 1e9) / operations
        assert abs(ns_per_op - expected_ns_per_op) < 1e-4, f"Row {i}: ns_per_op discrepancy: {ns_per_op} vs {expected_ns_per_op}"

        key = (bytes_sz, chains)
        if key not in grouped:
            grouped[key] = []
        grouped[key].append({
            "rep": rep,
            "seconds": seconds,
            "ns_per_op": ns_per_op,
            "checksum": checksum,
            "elements": elements
        })

    print("All row-level schema, operation count, and byte accounting assertions passed.\n")

    summary_stats = {}
    for key in sorted(grouped.keys()):
        bsz, chains = key
        items = grouped[key]
        h_sz = format_size(bsz)
        elems = items[0]["elements"]
        n_reps = len(items)

        csums = {item["checksum"] for item in items}
        csum_val = items[0]["checksum"]
        csum_ok = (len(csums) == 1)

        raw_ns = [item["ns_per_op"] for item in items]
        raw_secs = [item["seconds"] for item in items]
        sorted_ns = sorted(raw_ns)
        sorted_secs = sorted(raw_secs)

        mn = sorted_ns[0]
        q1 = sorted_ns[1]
        med = sorted_ns[2]
        q3 = sorted_ns[3]
        mx = sorted_ns[4]
        rng = mx - mn
        iqr = q3 - q1

        med_secs = sorted_secs[2]
        # step_time in ns = (seconds * 1e9) / work_count = ns_per_op * chains
        step_time_ns = med * chains

        summary_stats[key] = {
            "tier_size": h_sz,
            "bytes": bsz,
            "elements": elems,
            "chains": chains,
            "n": n_reps,
            "median_ns": med,
            "min_ns": mn,
            "q1_ns": q1,
            "q3_ns": q3,
            "max_ns": mx,
            "range_ns": rng,
            "iqr_ns": iqr,
            "median_secs": med_secs,
            "step_time_ns": step_time_ns,
            "checksum": csum_val,
            "csum_ok": csum_ok,
            "raw_ns": raw_ns,
            "raw_secs": raw_secs
        }

    return summary_stats

def print_table(stats, title, baseline_c1=None):
    print("=" * 145)
    print(title)
    print("=" * 145)
    headers = [
        "Tier", "Bytes", "C", "N",
        "Median (ns/op)", "Min (ns/op)", "Max (ns/op)", "IQR (ns/op)",
        "Speedup vs C=1", "Median Total (s)", "Derived Step Time (ns)", "Checksum", "Csum OK?"
    ]
    print(f"{headers[0]:>12s} | {headers[1]:>8s} | {headers[2]:>2s} | {headers[3]:>2s} | "
          f"{headers[4]:>14s} | {headers[5]:>11s} | {headers[6]:>11s} | {headers[7]:>11s} | "
          f"{headers[8]:>14s} | {headers[9]:>16s} | {headers[10]:>22s} | {headers[11]:>10s} | {headers[12]:>8s}")
    print("-" * 155)

    for key in sorted(stats.keys()):
        d = stats[key]
        bsz, c = key
        
        # Calculate speedup relative to C=1 within the same tier
        base_med = baseline_c1[bsz] if baseline_c1 else stats[(bsz, 1)]["median_ns"]
        speedup = base_med / d["median_ns"]

        print(f"{d['tier_size']:>12s} | {d['bytes']:8d} | {d['chains']:2d} | {d['n']:2d} | "
              f"{d['median_ns']:14.4f} | {d['min_ns']:11.4f} | {d['max_ns']:11.4f} | {d['iqr_ns']:11.4f} | "
              f"{speedup:14.2f}x | {d['median_secs']:16.6f} | {d['step_time_ns']:22.4f} | {d['checksum']:10d} | {str(d['csum_ok']):>8s}")

def main():
    primary_stats = audit_dataset(PRIMARY_CSV, 75, "PRIMARY MULTI-CHAIN SWEEP (75 rows)")
    
    # Store C=1 baselines for each tier
    baseline_c1 = {
        bsz: primary_stats[(bsz, 1)]["median_ns"]
        for bsz in [32768, 1048576, 67108864]
    }

    print()
    print_table(primary_stats, "EXP-20261016-02 PRIMARY SWEEP DESCRIPTIVE RESULTS (15 CONFIGURATIONS)")

    verification_stats = audit_dataset(VERIFICATION_CSV, 10, "POST-SWEEP VERIFICATION (10 rows)")
    print()
    print_table(verification_stats, "EXP-20261016-02 POST-SWEEP VERIFICATION RESULTS (2 CONFIGURATIONS)", baseline_c1)

    # Verification comparison
    print("\n" + "=" * 125)
    print("VERIFICATION HYSTERESIS & REPEATABILITY CHECK")
    print("=" * 125)
    verif_pairs = [
        ("Small Tier (32 KiB, C=1)", (32768, 1)),
        ("Large Tier (64 MiB, C=4)", (67108864, 4))
    ]
    for name, key in verif_pairs:
        p_med = primary_stats[key]["median_ns"]
        v_med = verification_stats[key]["median_ns"]
        diff = abs(p_med - v_med)
        pct = (diff / p_med) * 100.0
        p_csum = primary_stats[key]["checksum"]
        v_csum = verification_stats[key]["checksum"]
        print(f"{name:>25s}: Primary Median = {p_med:8.4f} ns/op | Verification Median = {v_med:8.4f} ns/op | "
              f"Abs Diff = {diff:7.4f} ns/op ({pct:5.2f}%) | Checksum Match = {p_csum == v_csum} ({p_csum})")

if __name__ == "__main__":
    main()
