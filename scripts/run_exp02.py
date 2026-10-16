#!/usr/bin/env python3
"""
scripts/run_exp02.py — Execution Orchestrator for EXP-20261016-02

Executes the approved Revision 2.0 protocol:
- 15 Primary configurations (32 KiB, 1 MiB, 64 MiB x chains 1, 2, 4, 8, 16)
- 2 Verification re-tests (32 KiB C=1, 64 MiB C=4)
- Captures complete stdout/stderr to sweep.log
- Segregates raw CSV rows to primary.csv (75 rows) and verification.csv (10 rows)
- Verifies exit codes, row counts, and source/binary hashes
"""

import datetime
import hashlib
import os
import subprocess
import sys
from pathlib import Path

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-02-primary.csv")
VERIFICATION_CSV = Path("lab-notebook/raw/EXP-20261016-02-verification.csv")
SWEEP_LOG = Path("lab-notebook/raw/EXP-20261016-02-sweep.log")
BINARY_PATH = Path("./memory_lab").resolve()
SOURCE_PATH = Path("src/memory_lab.cpp").resolve()

EXPECTED_SRC_SHA = "b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b"
EXPECTED_BIN_SHA = "9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0"

CONFIGURATIONS = [
    # Block 1: Small tier (32 KiB = 4096 elements)
    {"tier": "Small (32 KiB)", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 1},
    {"tier": "Small (32 KiB)", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 2},
    {"tier": "Small (32 KiB)", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 4},
    {"tier": "Small (32 KiB)", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 8},
    {"tier": "Small (32 KiB)", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 16},

    # Block 2: Intermediate tier (1 MiB = 131072 elements)
    {"tier": "Intermediate (1 MiB)", "elements": 131072, "work": 2000000, "repeats": 5, "chains": 1},
    {"tier": "Intermediate (1 MiB)", "elements": 131072, "work": 2000000, "repeats": 5, "chains": 2},
    {"tier": "Intermediate (1 MiB)", "elements": 131072, "work": 2000000, "repeats": 5, "chains": 4},
    {"tier": "Intermediate (1 MiB)", "elements": 131072, "work": 2000000, "repeats": 5, "chains": 8},
    {"tier": "Intermediate (1 MiB)", "elements": 131072, "work": 2000000, "repeats": 5, "chains": 16},

    # Block 3: Large tier (64 MiB = 8388608 elements)
    {"tier": "Large (64 MiB)", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1},
    {"tier": "Large (64 MiB)", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 2},
    {"tier": "Large (64 MiB)", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4},
    {"tier": "Large (64 MiB)", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 8},
    {"tier": "Large (64 MiB)", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 16},
]

VERIFICATION_CONFIGS = [
    {"tier": "Small (32 KiB) Re-test", "elements": 4096, "work": 2000000, "repeats": 5, "chains": 1},
    {"tier": "Large (64 MiB) Re-test", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4},
]

def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def main():
    print("=== EXP-20261016-02 EXECUTION INITIATION ===")

    # 1. Output non-existence pre-check
    for path in [PRIMARY_CSV, VERIFICATION_CSV, SWEEP_LOG]:
        if path.exists():
            print(f"ERROR: Destination file already exists: {path}. Aborting.")
            sys.exit(1)

    # 2. Source and binary integrity pre-check
    src_sha = sha256_file(SOURCE_PATH)
    bin_sha = sha256_file(BINARY_PATH)
    print(f"Pre-run Source SHA-256: {src_sha}")
    print(f"Pre-run Binary SHA-256: {bin_sha}")
    if src_sha != EXPECTED_SRC_SHA:
        print(f"ERROR: Source hash mismatch! Expected {EXPECTED_SRC_SHA}, got {src_sha}")
        sys.exit(1)
    if bin_sha != EXPECTED_BIN_SHA:
        print(f"ERROR: Binary hash mismatch! Expected {EXPECTED_BIN_SHA}, got {bin_sha}")
        sys.exit(1)

    PRIMARY_CSV.parent.mkdir(parents=True, exist_ok=True)

    header = "mode,elements,working_set_bytes,work_count,chains,repeat,seconds,operations,ns_per_operation,nominal_bytes,checksum\n"
    with open(PRIMARY_CSV, "w", encoding="utf-8") as f:
        f.write(header)
    with open(VERIFICATION_CSV, "w", encoding="utf-8") as f:
        f.write(header)

    start_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    log_lines = []
    log_lines.append("=== EXP-20261016-02 EXECUTION START ===\n")
    log_lines.append(f"START_TIME_UTC: {start_utc}\n")
    log_lines.append("--- PRE-EXECUTION CHECKS ---\n")
    log_lines.append(f"Source SHA-256: {src_sha}\n")
    log_lines.append(f"Binary SHA-256: {bin_sha}\n\n")

    # Capture system memory snapshot
    try:
        mem_info = subprocess.check_output(["free", "-h"], text=True)
        log_lines.append("Free memory snapshot:\n" + mem_info + "\n")
    except Exception as e:
        log_lines.append(f"free -h failed: {e}\n")

    total_primary_rows = 0
    total_verif_rows = 0

    # 3. Primary Sweep (15 steps)
    log_lines.append("--- PRIMARY SWEEP (15 CONFIGURATIONS x 5 REPEATS) ---\n\n")
    for step_idx, cfg in enumerate(CONFIGURATIONS, 1):
        cmd = [
            str(BINARY_PATH),
            "chains",
            str(cfg["elements"]),
            str(cfg["work"]),
            str(cfg["repeats"]),
            str(cfg["chains"])
        ]
        cmd_str = " ".join(cmd)
        step_ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
        print(f"[{step_idx}/15] Running: {cmd_str} ({cfg['tier']}, C={cfg['chains']})")
        log_lines.append(f"[Step {step_idx}/15: {cfg['tier']}, C={cfg['chains']}]\n")
        log_lines.append(f"Command: {cmd_str}\n")
        log_lines.append(f"Timestamp: {step_ts}\n")

        res = subprocess.run(cmd, capture_output=True, text=True)
        log_lines.append(res.stdout)
        if res.stderr:
            log_lines.append("STDERR:\n" + res.stderr)
        log_lines.append(f"EXIT_STATUS={res.returncode}\n\n")

        if res.returncode != 0:
            print(f"ERROR: Step {step_idx} failed with exit code {res.returncode}!")
            with open(SWEEP_LOG, "w", encoding="utf-8") as f:
                f.writelines(log_lines)
            sys.exit(1)

        # Parse output rows
        lines = [line.strip() for line in res.stdout.strip().splitlines() if line.strip()]
        data_rows = lines[1:]  # skip header
        if len(data_rows) != 5:
            print(f"ERROR: Expected 5 data rows, got {len(data_rows)}!")
            with open(SWEEP_LOG, "w", encoding="utf-8") as f:
                f.writelines(log_lines)
            sys.exit(1)

        with open(PRIMARY_CSV, "a", encoding="utf-8") as f:
            for r in data_rows:
                f.write(r + "\n")
                total_primary_rows += 1

    # 4. Post-Sweep Verification (2 steps)
    log_lines.append("--- POST-SWEEP VERIFICATION (2 CONFIGURATIONS x 5 REPEATS) ---\n\n")
    for step_idx, cfg in enumerate(VERIFICATION_CONFIGS, 16):
        cmd = [
            str(BINARY_PATH),
            "chains",
            str(cfg["elements"]),
            str(cfg["work"]),
            str(cfg["repeats"]),
            str(cfg["chains"])
        ]
        cmd_str = " ".join(cmd)
        step_ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
        print(f"[{step_idx}/17] Running Verification: {cmd_str} ({cfg['tier']})")
        log_lines.append(f"[Step {step_idx}/17: {cfg['tier']}]\n")
        log_lines.append(f"Command: {cmd_str}\n")
        log_lines.append(f"Timestamp: {step_ts}\n")

        res = subprocess.run(cmd, capture_output=True, text=True)
        log_lines.append(res.stdout)
        if res.stderr:
            log_lines.append("STDERR:\n" + res.stderr)
        log_lines.append(f"EXIT_STATUS={res.returncode}\n\n")

        if res.returncode != 0:
            print(f"ERROR: Step {step_idx} failed with exit code {res.returncode}!")
            with open(SWEEP_LOG, "w", encoding="utf-8") as f:
                f.writelines(log_lines)
            sys.exit(1)

        lines = [line.strip() for line in res.stdout.strip().splitlines() if line.strip()]
        data_rows = lines[1:]
        if len(data_rows) != 5:
            print(f"ERROR: Expected 5 data rows, got {len(data_rows)}!")
            with open(SWEEP_LOG, "w", encoding="utf-8") as f:
                f.writelines(log_lines)
            sys.exit(1)

        with open(VERIFICATION_CSV, "a", encoding="utf-8") as f:
            for r in data_rows:
                f.write(r + "\n")
                total_verif_rows += 1

    # 5. Post-execution checks
    end_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    log_lines.append("--- POST-EXECUTION VALIDATION ---\n")
    log_lines.append(f"COMPLETION_TIME_UTC: {end_utc}\n")
    log_lines.append(f"Primary data rows count:      {total_primary_rows} (expected: 75)\n")
    log_lines.append(f"Verification data rows count: {total_verif_rows} (expected: 10)\n")
    log_lines.append(f"Total data rows count:        {total_primary_rows + total_verif_rows} (expected: 85)\n")

    post_src_sha = sha256_file(SOURCE_PATH)
    post_bin_sha = sha256_file(BINARY_PATH)
    log_lines.append(f"Post-run Source SHA-256: {post_src_sha}\n")
    log_lines.append(f"Post-run Binary SHA-256: {post_bin_sha}\n")

    assert post_src_sha == EXPECTED_SRC_SHA, "Source hash changed!"
    assert post_bin_sha == EXPECTED_BIN_SHA, "Binary hash changed!"
    assert total_primary_rows == 75, f"Primary rows {total_primary_rows} != 75"
    assert total_verif_rows == 10, f"Verification rows {total_verif_rows} != 10"

    log_lines.append("ALL VALIDATIONS PASSED.\n")
    with open(SWEEP_LOG, "w", encoding="utf-8") as f:
        f.writelines(log_lines)

    print("=== EXP-20261016-02 EXECUTION COMPLETED SUCCESSFULLY ===")
    print(f"Primary CSV:      {PRIMARY_CSV} ({total_primary_rows} rows)")
    print(f"Verification CSV: {VERIFICATION_CSV} ({total_verif_rows} rows)")
    print(f"Sweep Log:        {SWEEP_LOG}")

if __name__ == "__main__":
    main()
