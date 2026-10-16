#!/usr/bin/env python3
"""
scripts/audit_exp03.py — Comprehensive Raw Data Audit & Statistical Analysis for EXP-20261016-03

Performs strictly read-only audit and hypothesis evaluation on already-existing EXP-03 evidence:
- Never executes benchmarks or modifies raw files.
- Audits schemas, 100-row count, byte accounting, operations count, and checksum regression values.
- Validates deterministic row-to-schedule mapping (100 rows -> 20 schedule steps -> 5 blocks).
- Computes NumPy Type 7 quartiles (Min, Q1, Median, Q3, Max, Range, IQR) for each (block, config) and overall.
- Evaluates H7: Kernel equivalence percentage difference (Delta_kernel with chase denominator).
- Evaluates H8: Between-block dispersion (spread, range, CV, max drift) as a descriptive comparison.
- Evaluates H9: Within-block MLP speedup S_B = Median(64M, C=1)_B / Median(64M, C=4)_B > 3.00x across all 5 blocks.
- Verifies source/binary hashes and sweep log execution traces.
- Labels all timing as amortized wall-clock time per pointer operation; never physical load latency.
"""

import argparse
import csv
import hashlib
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple
import numpy as np

# --- Paths & Hashes ---
PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-03-run2-primary.csv")
SWEEP_LOG = Path("lab-notebook/raw/EXP-20261016-03-run2-sweep.log")
BINARY_PATH = Path("./memory_lab").resolve()
SOURCE_PATH = Path("src/memory_lab.cpp").resolve()

EXPECTED_SRC_SHA = "b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b"
EXPECTED_BIN_SHA = "9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0"

EXPECTED_COLUMNS = [
    "mode", "elements", "working_set_bytes", "work_count", "chains",
    "repeat", "seconds", "operations", "ns_per_operation", "nominal_bytes", "checksum"
]

# Fixed 20-step schedule definition from Section 6
SCHEDULE: List[Dict[str, Any]] = [
    {"global_step": 1,  "block": 1, "block_step": 1, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 2,  "block": 1, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 3,  "block": 1, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 1, "expected_checksum": 8253441},
    {"global_step": 4,  "block": 1, "block_step": 4, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},

    {"global_step": 5,  "block": 2, "block_step": 1, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 6,  "block": 2, "block_step": 2, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 7,  "block": 2, "block_step": 3, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 8,  "block": 2, "block_step": 4, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 1, "expected_checksum": 8253441},

    {"global_step": 9,  "block": 3, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 10, "block": 3, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 11, "block": 3, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 1, "expected_checksum": 8253441},
    {"global_step": 12, "block": 3, "block_step": 4, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},

    {"global_step": 13, "block": 4, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 14, "block": 4, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 15, "block": 4, "block_step": 3, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 16, "block": 4, "block_step": 4, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 1, "expected_checksum": 8253441},

    {"global_step": 17, "block": 5, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
    {"global_step": 18, "block": 5, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 19, "block": 5, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "chains": 1, "expected_checksum": 8253441},
    {"global_step": 20, "block": 5, "block_step": 4, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "chains": 1, "expected_checksum": 1923},
]


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def compute_quartiles(data: List[float]) -> Dict[str, float]:
    arr = np.array(data, dtype=float)
    q1 = float(np.percentile(arr, 25, method="linear"))
    med = float(np.percentile(arr, 50, method="linear"))
    q3 = float(np.percentile(arr, 75, method="linear"))
    mn = float(np.min(arr))
    mx = float(np.max(arr))
    return {
        "min": mn,
        "q1": q1,
        "median": med,
        "q3": q3,
        "max": mx,
        "range": mx - mn,
        "iqr": q3 - q1,
    }


def audit_exp03_dataset(csv_path: Path, log_path: Path) -> Dict[str, Any]:
    """
    Parses and audits EXP-03 raw dataset strictly without modification.
    Returns structured analysis dictionary or raises AssertionError.
    """
    print("=" * 110)
    print(f"AUDITING EXP-20261016-03 RAW DATA: {csv_path}")
    print("=" * 110)

    if not csv_path.exists():
        raise FileNotFoundError(f"Primary CSV does not exist: {csv_path}")
    if not log_path.exists():
        raise FileNotFoundError(f"Sweep log does not exist: {log_path}")

    # 1. Inspect CSV Headers & Row Count
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        columns = reader.fieldnames
        rows = list(reader)

    print(f"Header columns ({len(columns) if columns else 0}): {columns}")
    assert columns == EXPECTED_COLUMNS, f"Column mismatch!\nExpected: {EXPECTED_COLUMNS}\nFound:    {columns}"
    print(f"Total raw data rows: {len(rows)} (Expected: 100)")
    assert len(rows) == 100, f"Row count mismatch! Expected exactly 100 rows, found {len(rows)}."

    # 2. Field-by-Field Validation & Row-to-Schedule Mapping
    parsed_rows: List[Dict[str, Any]] = []
    block_config_data: Dict[Tuple[int, str], List[float]] = {}
    config_all_data: Dict[str, List[float]] = {
        "Config 1": [],
        "Config 2": [],
        "Config 3": [],
        "Config 4": [],
    }

    for i, r in enumerate(rows):
        # Deterministic schedule mapping
        step_idx = (i // 5) + 1  # 1..20
        rep_idx = i % 5          # 0..4
        expected_step = SCHEDULE[step_idx - 1]

        mode = r["mode"]
        elements = int(r["elements"])
        ws_bytes = int(r["working_set_bytes"])
        work_count = int(r["work_count"])
        chains = int(r["chains"])
        rep = int(r["repeat"])
        sec = float(r["seconds"])
        ops = float(r["operations"])
        ns_per_op = float(r["ns_per_operation"])
        nom_bytes = float(r["nominal_bytes"])
        checksum = int(r["checksum"])

        # Integrity assertions
        assert rep == rep_idx, f"Row {i}: rep index mismatch {rep} != {rep_idx}"
        assert mode == expected_step["mode"], f"Row {i} (Step {step_idx}): mode {mode} != expected {expected_step['mode']}"
        assert elements == expected_step["elements"], f"Row {i}: elements {elements} != expected {expected_step['elements']}"
        assert ws_bytes == elements * 8, f"Row {i}: byte accounting mismatch {ws_bytes} != {elements * 8}"
        assert work_count == expected_step["work"], f"Row {i}: work_count {work_count} != {expected_step['work']}"
        assert chains == expected_step["chains"], f"Row {i}: chains {chains} != {expected_step['chains']}"
        assert sec > 0.0, f"Row {i}: non-positive elapsed seconds {sec}"

        expected_ops = float(work_count * chains)
        assert ops == expected_ops, f"Row {i}: operations mismatch {ops} != {expected_ops}"
        assert nom_bytes == ops * 8.0, f"Row {i}: nominal_bytes mismatch"

        derived_ns_per_op = (sec * 1e9) / ops
        assert abs(ns_per_op - derived_ns_per_op) < 1e-4, f"Row {i}: ns_per_op mismatch: {ns_per_op} vs {derived_ns_per_op}"

        # Regression checksum validation
        assert checksum == expected_step["expected_checksum"], (
            f"Row {i} (Step {step_idx}): Checksum mismatch! Expected {expected_step['expected_checksum']}, got {checksum}"
        )

        b = expected_step["block"]
        cid = expected_step["config_id"]
        key = (b, cid)
        if key not in block_config_data:
            block_config_data[key] = []
        block_config_data[key].append(ns_per_op)
        config_all_data[cid].append(ns_per_op)

        parsed_rows.append({
            "row_idx": i,
            "global_step": step_idx,
            "block": b,
            "block_step": expected_step["block_step"],
            "config_id": cid,
            "tier": expected_step["tier"],
            "mode": mode,
            "chains": chains,
            "rep": rep,
            "seconds": sec,
            "ns_per_op": ns_per_op,
            "checksum": checksum,
        })

    print("All 100 rows successfully verified against schema and deterministic 20-step schedule.")
    print("Checksum regression values 100% verified across all rows.")

    # 3. Block-Level Statistics
    print("\n" + "-" * 110)
    print("BLOCK-LEVEL SUMMARY STATISTICS (Amortized ns/op, NumPy Type 7 Quartiles):")
    print("-" * 110)
    print(f"{'Block':<8} {'Config':<10} {'Tier':<10} {'Mode':<8} {'C':<4} {'Min':>8} {'Q1':>8} {'Median':>8} {'Q3':>8} {'Max':>8} {'IQR':>8}")
    print("-" * 110)

    block_medians: Dict[Tuple[int, str], float] = {}

    for b in range(1, 6):
        for cid in ["Config 1", "Config 2", "Config 3", "Config 4"]:
            data = block_config_data[(b, cid)]
            assert len(data) == 5, f"Block {b} {cid} has {len(data)} observations, expected 5."
            q = compute_quartiles(data)
            block_medians[(b, cid)] = q["median"]

            # Lookup step details
            step_meta = [s for s in SCHEDULE if s["block"] == b and s["config_id"] == cid][0]
            print(
                f"Block {b:<2} {cid:<10} {step_meta['tier']:<10} {step_meta['mode']:<8} "
                f"{step_meta['chains']:<4} {q['min']:8.4f} {q['q1']:8.4f} {q['median']:8.4f} "
                f"{q['q3']:8.4f} {q['max']:8.4f} {q['iqr']:8.4f}"
            )

    # 4. Overall Per-Configuration Statistics
    print("\n" + "-" * 110)
    print("OVERALL PER-CONFIGURATION SUMMARY (N=25 timed repetitions per configuration):")
    print("-" * 110)
    print(f"{'Config':<10} {'Tier':<10} {'Mode':<8} {'C':<4} {'Min':>8} {'Q1':>8} {'Median':>8} {'Q3':>8} {'Max':>8} {'IQR':>8}")
    print("-" * 110)

    overall_stats: Dict[str, Dict[str, float]] = {}
    for cid in ["Config 1", "Config 2", "Config 3", "Config 4"]:
        data = config_all_data[cid]
        assert len(data) == 25, f"{cid} has {len(data)} total rows, expected 25."
        q = compute_quartiles(data)
        overall_stats[cid] = q
        step_meta = [s for s in SCHEDULE if s["config_id"] == cid][0]
        print(
            f"{cid:<10} {step_meta['tier']:<10} {step_meta['mode']:<8} {step_meta['chains']:<4} "
            f"{q['min']:8.4f} {q['q1']:8.4f} {q['median']:8.4f} {q['q3']:8.4f} {q['max']:8.4f} {q['iqr']:8.4f}"
        )

    # 5. Evaluate H7: Kernel Equivalence Heuristic
    print("\n" + "=" * 110)
    print("HYPOTHESIS EVALUATION — H7: KERNEL EQUIVALENCE HEURISTIC (32 KiB)")
    print("=" * 110)

    med_chase = overall_stats["Config 1"]["median"]
    med_chains_c1 = overall_stats["Config 2"]["median"]
    delta_kernel = ((med_chains_c1 - med_chase) / med_chase) * 100.0

    print(f"Overall Median 32 KiB chase:       {med_chase:.4f} ns/op (denominator)")
    print(f"Overall Median 32 KiB chains(C=1): {med_chains_c1:.4f} ns/op")
    print(f"Delta_kernel = (chains_C1 - chase) / chase = {delta_kernel:+.2f}%")
    print("Equivalence Criterion: -5.0% <= Delta_kernel <= +5.0%")

    h7_supported = (-5.0 <= delta_kernel <= 5.0)
    print(f"H7 Result: {'SUPPORTED (Practical Equivalence)' if h7_supported else 'NOT SUPPORTED (Overhead Detected)'}")
    print(
        "Note: Descriptive heuristic check across 5 blocks (N=25 each). "
        "Does not constitute formal statistical equivalence or inferential proof of zero overhead."
    )

    # 6. Evaluate H8: Between-Block Dispersion
    print("\n" + "=" * 110)
    print("HYPOTHESIS EVALUATION — H8: LAUNCH-TO-LAUNCH VARIABILITY & DISPERSION")
    print("=" * 110)
    print(f"{'Config':<10} {'Tier':<10} {'Mode':<8} {'C':<4} {'Spread (ns)':>12} {'Block Range':>22} {'Mean Med':>10} {'Std Med':>10} {'CV (%)':>10} {'Max Drift (%)':>14}")
    print("-" * 110)

    h8_summaries: Dict[str, Dict[str, float]] = {}
    for cid in ["Config 1", "Config 2", "Config 3", "Config 4"]:
        b_meds = [block_medians[(b, cid)] for b in range(1, 6)]
        min_med = min(b_meds)
        max_med = max(b_meds)
        spread = max_med - min_med
        mu_med = float(np.mean(b_meds))
        sigma_med = float(np.std(b_meds, ddof=1))
        cv_med = (sigma_med / mu_med) * 100.0 if mu_med > 0 else 0.0
        max_drift = ((max_med - min_med) / min_med) * 100.0 if min_med > 0 else 0.0

        h8_summaries[cid] = {
            "spread": spread,
            "min_med": min_med,
            "max_med": max_med,
            "mean": mu_med,
            "std": sigma_med,
            "cv": cv_med,
            "max_drift": max_drift,
        }

        step_meta = [s for s in SCHEDULE if s["config_id"] == cid][0]
        range_str = f"[{min_med:.4f}, {max_med:.4f}]"
        print(
            f"{cid:<10} {step_meta['tier']:<10} {step_meta['mode']:<8} {step_meta['chains']:<4} "
            f"{spread:12.4f} {range_str:>22} {mu_med:10.4f} {sigma_med:10.4f} {cv_med:9.2f}% {max_drift:13.2f}%"
        )

    print("\nDescriptive Context:")
    print("  EXP-02 Verification Drift Baselines: +40.22% (32 KiB C=1), +37.07% (64 MiB C=4).")
    print("  Guardrail: EXP-02 and EXP-03 have structurally different experimental designs.")
    print("  Comparing dispersion is an informative descriptive observation, NOT causal proof.")

    # 7. Evaluate H9: Within-Block MLP Speedup
    print("\n" + "=" * 110)
    print("HYPOTHESIS EVALUATION — H9: WITHIN-BLOCK MLP SPEEDUP (64 MiB, C=1 vs C=4)")
    print("=" * 110)
    print(f"{'Block':<8} {'64M C=1 Median (ns)':>20} {'64M C=4 Median (ns)':>20} {'Within-Block Speedup (S_B)':>28} {'Criterion (> 3.00x)':>22}")
    print("-" * 110)

    h9_speedups: Dict[int, float] = {}
    h9_all_pass = True

    for b in range(1, 6):
        med_c1 = block_medians[(b, "Config 3")]
        med_c4 = block_medians[(b, "Config 4")]
        sb = med_c1 / med_c4
        h9_speedups[b] = sb
        passes = (sb > 3.00)
        if not passes:
            h9_all_pass = False
        print(f"Block {b:<2} {med_c1:20.4f} {med_c4:20.4f} {sb:28.4f}x {'PASS' if passes else 'FAIL':>22}")

    print("-" * 110)
    print(f"H9 Result: {'SUPPORTED (All blocks S_B > 3.00x)' if h9_all_pass else 'FALSIFIED (At least one block <= 3.00x)'}")
    print(
        "Clarification: Speedup reflects amortized time per pointer operation under concurrent memory access. "
        "It does not represent individual physical DRAM load latency (which remains unmeasured)."
    )

    # 8. Check Sweep Log Execution Trace
    with open(log_path, "r", encoding="utf-8") as f:
        log_text = f.read()

    assert "=== EXP-20261016-03 SWEEP EXECUTION LOG ===" in log_text, "Missing execution start marker in log."
    assert "POST_EXEC_HASHES_VERIFIED: PASS" in log_text, "Missing post-execution hash verification pass marker in log."
    assert "DISK_CSV_VALIDATION: PASS" in log_text, "Missing disk CSV validation pass marker in log."
    assert "=== SWEEP EXECUTION COMPLETED SUCCESSFULLY ===" in log_text, "Missing completion marker in log."
    assert "TOTAL_ROWS_COMMITTED: 100" in log_text, "Log does not record 100 committed rows."

    print("\n" + "=" * 110)
    print("AUDIT RESULT: ALL DATA VALIDATION & PROVENANCE CHECKS PASSED.")
    print("=" * 110)

    return {
        "h7": {"supported": h7_supported, "delta_kernel": delta_kernel},
        "h8": h8_summaries,
        "h9": {"supported": h9_all_pass, "speedups": h9_speedups},
        "overall_stats": overall_stats,
    }


def run_self_tests() -> None:
    """
    Unit test harness using synthetic fixtures to verify:
    - Normal audit on valid 100-row fixture.
    - Detection of malformed row counts (e.g. 99 rows).
    - Detection of checksum divergence.
    - Detection of column header mismatches.
    - Detection of H9 speedup failure (S_B <= 3.00x).
    - Detection of incorrect elements values (e.g. 2048 instead of 4096).
    - Detection of incorrect repeat indices (e.g. 3 instead of 0).
    - Detection of accidental substitution between 64 MiB C=1 and C=4 checksums.
    """
    import tempfile

    print("Running EXP-03 Audit Script Self-Tests (synthetic fixtures)...")

    # Verify per-configuration regression checksum expectations
    for s in SCHEDULE:
        if s["config_id"] in ("Config 1", "Config 2"):
            assert s["expected_checksum"] == 1923, "Config 1/2 checksum must be 1923"
        elif s["config_id"] == "Config 3":
            assert s["expected_checksum"] == 8253441, "Config 3 checksum must be 8253441"
        elif s["config_id"] == "Config 4":
            assert s["expected_checksum"] == 14274912, "Config 4 checksum must be 14274912"
    assert (
        [s for s in SCHEDULE if s["config_id"] == "Config 3"][0]["expected_checksum"]
        != [s for s in SCHEDULE if s["config_id"] == "Config 4"][0]["expected_checksum"]
    ), "Config 3 (C=1) and Config 4 (C=4) checksums must be strictly distinct!"

    def make_synthetic_csv(
        path: Path,
        row_count=100,
        chk_override=None,
        speedup_override=None,
        bad_header=False,
        elements_override=None,
        repeat_override=None,
        config_chk_override=None,
    ):
        with open(path, "w", encoding="utf-8") as f:
            if bad_header:
                f.write("wrong,header,columns\n")
            else:
                f.write(
                    "mode,elements,working_set_bytes,work_count,chains,repeat,"
                    "seconds,operations,ns_per_operation,nominal_bytes,checksum\n"
                )

            for i in range(row_count):
                step_idx = (i // 5) + 1
                rep_idx = i % 5
                step = SCHEDULE[step_idx - 1]
                if config_chk_override and step["config_id"] in config_chk_override:
                    chk = config_chk_override[step["config_id"]]
                elif chk_override is not None:
                    chk = chk_override
                else:
                    chk = step["expected_checksum"]
                elems = elements_override if (elements_override is not None and i == 0) else step["elements"]
                rep = repeat_override if (repeat_override is not None and i == 0) else rep_idx

                # Base timings to simulate plausible latencies
                if step["config_id"] == "Config 1":
                    sec = 0.0030  # ~1.5 ns/op
                elif step["config_id"] == "Config 2":
                    sec = 0.00305 # ~1.525 ns/op (+1.6% Delta_kernel)
                elif step["config_id"] == "Config 3":
                    sec = 0.250   # ~125 ns/op
                else:  # Config 4 (chains C=4)
                    if speedup_override is not None:
                        sec = (0.250 / speedup_override) * 4  # adjust to force specific speedup
                    else:
                        sec = 0.070 * 4 # ~3.57x speedup

                ops = float(step["work"] * step["chains"])
                ns_op = (sec * 1e9) / ops
                nom = ops * 8.0
                f.write(
                    f"{step['mode']},{elems},{elems*8},{step['work']},"
                    f"{step['chains']},{rep},{sec:.9f},{ops:.1f},{ns_op:.7f},{nom:.1f},{chk}\n"
                )

    def make_synthetic_log(path: Path):
        with open(path, "w", encoding="utf-8") as f:
            f.write("=== EXP-20261016-03 SWEEP EXECUTION LOG ===\n")
            f.write("START_TIME_UTC: 2026-10-16T18:00:00Z\n")
            f.write("TOTAL_SCHEDULE_STEPS: 20\n\n")
            f.write("POST_EXEC_HASHES_VERIFIED: PASS\n")
            f.write("DISK_CSV_VALIDATION: PASS\n\n")
            f.write("=== SWEEP EXECUTION COMPLETED SUCCESSFULLY ===\n")
            f.write("END_TIME_UTC: 2026-10-16T18:05:00Z\n")
            f.write("TOTAL_ROWS_COMMITTED: 100\n")

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        valid_csv = tmp_path / "valid.csv"
        valid_log = tmp_path / "valid.log"
        make_synthetic_csv(valid_csv)
        make_synthetic_log(valid_log)

        # 1. Audit valid fixture
        res = audit_exp03_dataset(valid_csv, valid_log)
        assert res["h7"]["supported"] is True
        assert res["h9"]["supported"] is True
        print("  [PASS] Test 1: Valid 100-row synthetic fixture successfully audited (H7 and H9 pass)")

        # 2. Incomplete rows fixture (95 rows)
        inc_csv = tmp_path / "inc.csv"
        make_synthetic_csv(inc_csv, row_count=95)
        try:
            audit_exp03_dataset(inc_csv, valid_log)
            assert False, "Should have failed on row count"
        except AssertionError as e:
            assert "Row count mismatch" in str(e)
            print("  [PASS] Test 2: Incomplete row count correctly flagged")

        # 3. Checksum divergence fixture
        chk_csv = tmp_path / "bad_chk.csv"
        make_synthetic_csv(chk_csv, chk_override=888888)
        try:
            audit_exp03_dataset(chk_csv, valid_log)
            assert False, "Should have failed on checksum"
        except AssertionError as e:
            assert "Checksum mismatch" in str(e)
            print("  [PASS] Test 3: Checksum divergence correctly flagged")

        # 4. Bad header fixture
        hdr_csv = tmp_path / "bad_hdr.csv"
        make_synthetic_csv(hdr_csv, bad_header=True)
        try:
            audit_exp03_dataset(hdr_csv, valid_log)
            assert False, "Should have failed on header"
        except AssertionError as e:
            assert "Column mismatch" in str(e)
            print("  [PASS] Test 4: Column header mismatch correctly flagged")

        # 5. H9 speedup failure (Speedup = 2.5x <= 3.0x)
        h9_fail_csv = tmp_path / "h9_fail.csv"
        make_synthetic_csv(h9_fail_csv, speedup_override=2.5)
        res_h9 = audit_exp03_dataset(h9_fail_csv, valid_log)
        assert res_h9["h9"]["supported"] is False
        print("  [PASS] Test 5: H9 speedup compression (<= 3.00x) correctly detected and falsified")

        # 6. Incorrect elements value fixture (e.g. 2048 instead of 4096 on row 0)
        elem_csv = tmp_path / "bad_elem.csv"
        make_synthetic_csv(elem_csv, elements_override=2048)
        try:
            audit_exp03_dataset(elem_csv, valid_log)
            assert False, "Should have failed on elements mismatch"
        except AssertionError as e:
            assert "elements" in str(e)
            print("  [PASS] Test 6: Incorrect elements value (e.g. 2048 vs 4096) correctly flagged")

        # 7. Incorrect repeat index fixture (e.g. 3 instead of 0 on row 0)
        rep_csv = tmp_path / "bad_rep.csv"
        make_synthetic_csv(rep_csv, repeat_override=3)
        try:
            audit_exp03_dataset(rep_csv, valid_log)
            assert False, "Should have failed on repeat index mismatch"
        except AssertionError as e:
            assert "rep index mismatch" in str(e)
            print("  [PASS] Test 7: Incorrect repeat index (e.g. 3 vs 0) correctly flagged")

        # 8. Regression test: Accidental substitution of C=4 checksum (14274912) into Config 3 (64 MiB C=1)
        sub_c3_csv = tmp_path / "sub_c3.csv"
        make_synthetic_csv(sub_c3_csv, config_chk_override={"Config 3": 14274912})
        try:
            audit_exp03_dataset(sub_c3_csv, valid_log)
            assert False, "Should have failed on C=4 checksum substituted into Config 3"
        except AssertionError as e:
            assert "Checksum mismatch" in str(e)
            print("  [PASS] Test 8: Rejection of C=4 checksum (14274912) mistakenly supplied to Config 3 (64 MiB C=1)")

        # 9. Regression test: Accidental substitution of C=1 checksum (8253441) into Config 4 (64 MiB C=4)
        sub_c4_csv = tmp_path / "sub_c4.csv"
        make_synthetic_csv(sub_c4_csv, config_chk_override={"Config 4": 8253441})
        try:
            audit_exp03_dataset(sub_c4_csv, valid_log)
            assert False, "Should have failed on C=1 checksum substituted into Config 4"
        except AssertionError as e:
            assert "Checksum mismatch" in str(e)
            print("  [PASS] Test 9: Rejection of C=1 checksum (8253441) mistakenly supplied to Config 4 (64 MiB C=4)")

    print("ALL AUDIT SCRIPT SELF-TESTS PASSED.")


def main():
    parser = argparse.ArgumentParser(description="EXP-20261016-03 Data Audit & Statistical Analysis")
    parser.add_argument("--self-test", action="store_true", help="Run comprehensive in-memory unit tests on synthetic fixtures")
    parser.add_argument("--csv", type=Path, default=PRIMARY_CSV, help="Path to primary CSV (default: lab-notebook/raw/EXP-20261016-03-run2-primary.csv)")
    parser.add_argument("--log", type=Path, default=SWEEP_LOG, help="Path to sweep log (default: lab-notebook/raw/EXP-20261016-03-run2-sweep.log)")
    args = parser.parse_args()

    if args.self_test:
        run_self_tests()
        sys.exit(0)

    # Preflight Check: Source & Binary Hashes
    if SOURCE_PATH.exists():
        src_sha = sha256_file(SOURCE_PATH)
        print(f"Source SHA-256: {src_sha} (Expected: {EXPECTED_SRC_SHA})")
        assert src_sha == EXPECTED_SRC_SHA, "Source hash divergence detected!"
    if BINARY_PATH.exists():
        bin_sha = sha256_file(BINARY_PATH)
        print(f"Binary SHA-256: {bin_sha} (Expected: {EXPECTED_BIN_SHA})")
        assert bin_sha == EXPECTED_BIN_SHA, "Binary hash divergence detected!"

    audit_exp03_dataset(args.csv, args.log)


if __name__ == "__main__":
    main()
