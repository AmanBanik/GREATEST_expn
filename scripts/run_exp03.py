#!/usr/bin/env python3
"""
scripts/run_exp03.py — Execution Orchestrator for EXP-20261016-03

Executes the pre-registered balanced block design protocol:
- 4 focal configurations: 32 KiB chase, 32 KiB chains(C=1), 64 MiB chains(C=1), 64 MiB chains(C=4)
- 5 balanced blocks (4 launches per block = 20 total process launches)
- Fixed deterministic schedule (Section 6 of proposal, seed 20261016)
- 5 timed repetitions per process launch = 100 planned data rows
- 2.0-second procedural quiescent pause between launches
- Expected regression checksum validation (32 KiB: 1923, 64 MiB: 14274912)
- Strict fail-closed error handling: halts on non-zero exit status, wrong row count,
  unexpected header, config mismatch, or checksum divergence. No silent retries.
"""

import argparse
import csv
import datetime
import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Dict, List

# --- Paths & Hashes ---
PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-03-primary.csv")
SWEEP_LOG = Path("lab-notebook/raw/EXP-20261016-03-sweep.log")
BINARY_PATH = Path("./memory_lab").resolve()
SOURCE_PATH = Path("src/memory_lab.cpp").resolve()

EXPECTED_SRC_SHA = "b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b"
EXPECTED_BIN_SHA = "9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0"

CANONICAL_HEADER = (
    "mode,elements,working_set_bytes,work_count,chains,repeat,"
    "seconds,operations,ns_per_operation,nominal_bytes,checksum\n"
)
EXPECTED_COLUMNS = CANONICAL_HEADER.strip().split(",")

# --- Fixed 20-Step Predefined Schedule (Section 6 of EXP-20261016-03-proposal.md) ---
# Deterministic pseudorandom sequence generated under seed 20261016.
# Consumed verbatim — never dynamically regenerated at runtime.
SCHEDULE: List[Dict[str, Any]] = [
    # Block 1
    {"global_step": 1,  "block": 1, "block_step": 1, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 2,  "block": 1, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 3,  "block": 1, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 14274912},
    {"global_step": 4,  "block": 1, "block_step": 4, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},

    # Block 2
    {"global_step": 5,  "block": 2, "block_step": 1, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 6,  "block": 2, "block_step": 2, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 7,  "block": 2, "block_step": 3, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 8,  "block": 2, "block_step": 4, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 14274912},

    # Block 3
    {"global_step": 9,  "block": 3, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 10, "block": 3, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 11, "block": 3, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 14274912},
    {"global_step": 12, "block": 3, "block_step": 4, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},

    # Block 4
    {"global_step": 13, "block": 4, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 14, "block": 4, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 15, "block": 4, "block_step": 3, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 16, "block": 4, "block_step": 4, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 14274912},

    # Block 5
    {"global_step": 17, "block": 5, "block_step": 1, "config_id": "Config 2", "tier": "32 KiB", "mode": "chains", "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
    {"global_step": 18, "block": 5, "block_step": 2, "config_id": "Config 4", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 4, "expected_checksum": 14274912},
    {"global_step": 19, "block": 5, "block_step": 3, "config_id": "Config 3", "tier": "64 MiB", "mode": "chains", "elements": 8388608, "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 14274912},
    {"global_step": 20, "block": 5, "block_step": 4, "config_id": "Config 1", "tier": "32 KiB", "mode": "chase",  "elements": 4096,    "work": 2000000, "repeats": 5, "chains": 1, "expected_checksum": 1923},
]


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def build_command(cfg: Dict[str, Any], bin_path: Path) -> List[str]:
    cmd = [
        str(bin_path),
        cfg["mode"],
        str(cfg["elements"]),
        str(cfg["work"]),
        str(cfg["repeats"]),
    ]
    if cfg["mode"] == "chains":
        cmd.append(str(cfg["chains"]))
    return cmd


def validate_launch_output(
    step_info: Dict[str, Any],
    stdout: str,
    stderr: str,
    returncode: int
) -> List[str]:
    """
    Validates process output strictly:
    - Zero return code.
    - Emitted header matches CANONICAL_HEADER.
    - Exactly 5 data rows.
    - Field-by-field verification (11 columns, mode, elements, chains, work, checksum).
    Returns list of validated data row strings, or raises ValueError.
    """
    if returncode != 0:
        raise ValueError(f"Process failed with non-zero exit code {returncode}. Stderr: {stderr.strip()}")

    lines = [line.strip() for line in stdout.strip().splitlines() if line.strip()]
    if not lines:
        raise ValueError("Process stdout was completely empty.")

    header_line = lines[0]
    if header_line != CANONICAL_HEADER.strip():
        raise ValueError(
            f"Emitted CSV header mismatch!\nExpected: {CANONICAL_HEADER.strip()}\nReceived: {header_line}"
        )

    data_rows = lines[1:]
    if len(data_rows) != step_info["repeats"]:
        raise ValueError(
            f"Expected exactly {step_info['repeats']} data rows, received {len(data_rows)}."
        )

    expected_mode = step_info["mode"]
    expected_elements = step_info["elements"]
    expected_bytes = expected_elements * 8
    expected_work = step_info["work"]
    expected_chains = step_info["chains"]
    expected_checksum = step_info["expected_checksum"]

    for rep_idx, row_str in enumerate(data_rows):
        fields = row_str.split(",")
        if len(fields) != len(EXPECTED_COLUMNS):
            raise ValueError(
                f"Row {rep_idx} column count mismatch: expected {len(EXPECTED_COLUMNS)}, got {len(fields)}."
            )

        row_mode = fields[0]
        row_elements = int(fields[1])
        row_bytes = int(fields[2])
        row_work = int(fields[3])
        row_chains = int(fields[4])
        row_rep = int(fields[5])
        row_sec = float(fields[6])
        row_ops = float(fields[7])
        row_ns_op = float(fields[8])
        row_nominal = float(fields[9])
        row_checksum = int(fields[10])

        if row_mode != expected_mode:
            raise ValueError(f"Row {rep_idx} mode mismatch: expected {expected_mode}, got {row_mode}.")
        if row_elements != expected_elements:
            raise ValueError(f"Row {rep_idx} elements mismatch: expected {expected_elements}, got {row_elements}.")
        if row_bytes != expected_bytes:
            raise ValueError(f"Row {rep_idx} working_set_bytes mismatch: expected {expected_bytes}, got {row_bytes}.")
        if row_work != expected_work:
            raise ValueError(f"Row {rep_idx} work_count mismatch: expected {expected_work}, got {row_work}.")
        if row_chains != expected_chains:
            raise ValueError(f"Row {rep_idx} chains mismatch: expected {expected_chains}, got {row_chains}.")
        if row_rep != rep_idx:
            raise ValueError(f"Row {rep_idx} repeat index mismatch: expected {rep_idx}, got {row_rep}.")
        if row_sec <= 0.0:
            raise ValueError(f"Row {rep_idx} non-positive elapsed seconds: {row_sec}.")

        expected_ops = float(expected_work * expected_chains)
        if row_ops != expected_ops:
            raise ValueError(f"Row {rep_idx} operations mismatch: expected {expected_ops}, got {row_ops}.")

        expected_ns_op = (row_sec * 1e9) / expected_ops
        if abs(row_ns_op - expected_ns_op) > 1e-4:
            raise ValueError(f"Row {rep_idx} ns_per_operation mismatch: derived {expected_ns_op}, recorded {row_ns_op}.")

        if row_nominal != expected_ops * 8.0:
            raise ValueError(f"Row {rep_idx} nominal_bytes mismatch.")

        # Expected regression checksum validation
        if row_checksum != expected_checksum:
            raise ValueError(
                f"Row {rep_idx} checksum mismatch! Expected regression value: {expected_checksum}, observed: {row_checksum}. "
                "Halting immediately without retrying or replacing observation."
            )

    return data_rows


def validate_final_csv_on_disk(csv_path: Path, schedule: List[Dict[str, Any]]) -> int:
    """
    Reopens the final primary CSV from disk and strictly validates it using csv.reader:
    - Exactly one canonical 11-column header.
    - Exactly 100 data rows.
    - Exactly 11 columns per row.
    - Correct schedule mapping, configuration fields, repetition indices, and expected checksums.
    - Correct configuration counts across all 5 blocks (each of the 4 configs appears exactly once per block).
    Returns number of verified data rows (100) or raises ValueError.
    """
    if not csv_path.exists():
        raise FileNotFoundError(f"Primary CSV does not exist on disk: {csv_path}")

    with open(csv_path, "r", encoding="utf-8", newline="") as f:
        reader = list(csv.reader(f))

    if not reader:
        raise ValueError(f"Primary CSV on disk is empty: {csv_path}")

    header = reader[0]
    if header != EXPECTED_COLUMNS:
        raise ValueError(
            f"Primary CSV disk header mismatch!\nExpected: {EXPECTED_COLUMNS}\nReceived: {header}"
        )

    data_rows = reader[1:]
    if len(data_rows) != 100:
        raise ValueError(
            f"Primary CSV disk row count mismatch: expected exactly 100 data rows, found {len(data_rows)}."
        )

    # Track configuration appearances per block
    block_counts: Dict[int, Dict[str, int]] = {b: {} for b in range(1, 6)}

    for i, row in enumerate(data_rows):
        if len(row) != len(EXPECTED_COLUMNS):
            raise ValueError(
                f"Disk row {i} column count mismatch: expected {len(EXPECTED_COLUMNS)}, got {len(row)}."
            )

        step_idx = (i // 5) + 1  # 1..20
        rep_idx = i % 5          # 0..4
        expected_step = schedule[step_idx - 1]

        row_mode = row[0]
        row_elements = int(row[1])
        row_bytes = int(row[2])
        row_work = int(row[3])
        row_chains = int(row[4])
        row_rep = int(row[5])
        row_sec = float(row[6])
        row_ops = float(row[7])
        row_ns_op = float(row[8])
        row_nominal = float(row[9])
        row_checksum = int(row[10])

        if row_mode != expected_step["mode"]:
            raise ValueError(f"Disk row {i} mode mismatch: expected {expected_step['mode']}, got {row_mode}.")
        if row_elements != expected_step["elements"]:
            raise ValueError(f"Disk row {i} elements mismatch: expected {expected_step['elements']}, got {row_elements}.")
        if row_bytes != expected_step["elements"] * 8:
            raise ValueError(f"Disk row {i} working_set_bytes mismatch: expected {expected_step['elements'] * 8}, got {row_bytes}.")
        if row_work != expected_step["work"]:
            raise ValueError(f"Disk row {i} work mismatch: expected {expected_step['work']}, got {row_work}.")
        if row_chains != expected_step["chains"]:
            raise ValueError(f"Disk row {i} chains mismatch: expected {expected_step['chains']}, got {row_chains}.")
        if row_rep != rep_idx:
            raise ValueError(f"Disk row {i} repeat index mismatch: expected {rep_idx}, got {row_rep}.")
        if row_sec <= 0.0:
            raise ValueError(f"Disk row {i} non-positive elapsed seconds: {row_sec}.")

        expected_ops = float(expected_step["work"] * expected_step["chains"])
        if row_ops != expected_ops:
            raise ValueError(f"Disk row {i} operations mismatch: expected {expected_ops}, got {row_ops}.")

        expected_ns_op = (row_sec * 1e9) / expected_ops
        if abs(row_ns_op - expected_ns_op) > 1e-4:
            raise ValueError(f"Disk row {i} ns_per_operation mismatch: derived {expected_ns_op}, recorded {row_ns_op}.")

        if row_nominal != expected_ops * 8.0:
            raise ValueError(f"Disk row {i} nominal_bytes mismatch.")

        if row_checksum != expected_step["expected_checksum"]:
            raise ValueError(
                f"Disk row {i} checksum mismatch: expected {expected_step['expected_checksum']}, got {row_checksum}."
            )

        b = expected_step["block"]
        cid = expected_step["config_id"]
        if rep_idx == 0:
            block_counts[b][cid] = block_counts[b].get(cid, 0) + 1

    # Validate configuration counts across all five blocks
    for b in range(1, 6):
        if len(block_counts[b]) != 4:
            raise ValueError(f"Disk validation error: Block {b} does not contain all 4 configurations ({block_counts[b]}).")
        for cid, count in block_counts[b].items():
            if count != 1:
                raise ValueError(f"Disk validation error: Block {b} configuration {cid} count is {count} != 1.")

    return len(data_rows)


def execute_schedule(
    schedule: List[Dict[str, Any]],
    bin_path: Path,
    csv_path: Path,
    log_path: Path,
    pause_sec: float = 2.0,
    src_path: Path = SOURCE_PATH,
    runner_func=None
) -> None:
    """
    Executes the predefined 20-step schedule strictly in order.
    Fails closed on any error, preserving logs and outputs.
    Re-verifies source/binary hashes and disk CSV after completion before writing completion marker.
    """
    if runner_func is None:
        runner_func = subprocess.run

    # 1. Ensure output files do not already exist
    if csv_path.exists():
        raise FileExistsError(f"Target CSV already exists: {csv_path}. Refusing to overwrite.")
    if log_path.exists():
        raise FileExistsError(f"Target sweep log already exists: {log_path}. Refusing to overwrite.")

    csv_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # 2. Initialize primary CSV with single canonical header
    with open(csv_path, "w", encoding="utf-8") as f:
        f.write(CANONICAL_HEADER)

    log_lines = []
    start_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    log_lines.append("=== EXP-20261016-03 SWEEP EXECUTION LOG ===\n")
    log_lines.append(f"START_TIME_UTC: {start_utc}\n")
    log_lines.append(f"TOTAL_SCHEDULE_STEPS: {len(schedule)}\n\n")

    total_data_rows = 0

    try:
        for idx, step_info in enumerate(schedule, 1):
            g_step = step_info["global_step"]
            block = step_info["block"]
            b_step = step_info["block_step"]
            cfg_id = step_info["config_id"]
            tier = step_info["tier"]
            mode = step_info["mode"]
            chains = step_info["chains"]

            cmd = build_command(step_info, bin_path)
            cmd_str = " ".join(cmd)
            step_ts = datetime.datetime.now(datetime.timezone.utc).isoformat()

            desc = f"[Step {g_step}/20: Block {block}, Step {b_step} — {cfg_id} ({tier}, {mode}, C={chains})]"
            print(f"[{g_step:02d}/20] Running: {cmd_str} {desc}")

            log_lines.append(f"{desc}\n")
            log_lines.append(f"Command: {cmd_str}\n")
            log_lines.append(f"Timestamp: {step_ts}\n")

            res = runner_func(cmd, capture_output=True, text=True)

            log_lines.append("STDOUT:\n")
            log_lines.append(res.stdout)
            if not res.stdout.endswith("\n"):
                log_lines.append("\n")

            if res.stderr:
                log_lines.append("STDERR:\n")
                log_lines.append(res.stderr)
                if not res.stderr.endswith("\n"):
                    log_lines.append("\n")

            log_lines.append(f"EXIT_STATUS: {res.returncode}\n\n")

            # Validate output and extract data rows
            data_rows = validate_launch_output(step_info, res.stdout, res.stderr, res.returncode)

            # Append validated data rows to CSV
            with open(csv_path, "a", encoding="utf-8") as f:
                for r in data_rows:
                    f.write(r + "\n")
                    total_data_rows += 1

            # Flush log incrementally
            with open(log_path, "w", encoding="utf-8") as f:
                f.writelines(log_lines)

            # Procedural pause between process launches
            if idx < len(schedule) and pause_sec > 0:
                time.sleep(pause_sec)

    except Exception as e:
        print(f"\nFATAL EXECUTION ERROR at Step {idx}: {e}", file=sys.stderr)
        log_lines.append(f"\nFATAL_ERROR at Step {idx}: {e}\n")
        with open(log_path, "w", encoding="utf-8") as f:
            f.writelines(log_lines)
        raise

    # Post-Execution Check 1: Recompute Source and Binary Hashes
    final_src_sha = sha256_file(src_path)
    final_bin_sha = sha256_file(bin_path)

    log_lines.append("=== POST-EXECUTION INTEGRITY VERIFICATION ===\n")
    log_lines.append(f"POST_EXEC_SRC_SHA: {final_src_sha}\n")
    log_lines.append(f"POST_EXEC_BIN_SHA: {final_bin_sha}\n")

    if final_src_sha != EXPECTED_SRC_SHA:
        err_msg = f"Post-execution source hash mismatch!\nExpected: {EXPECTED_SRC_SHA}\nObserved: {final_src_sha}"
        print(f"\nFATAL POST-EXECUTION ERROR: {err_msg}", file=sys.stderr)
        log_lines.append(f"FATAL_ERROR: {err_msg}\n")
        with open(log_path, "w", encoding="utf-8") as f:
            f.writelines(log_lines)
        raise ValueError(err_msg)

    if final_bin_sha != EXPECTED_BIN_SHA:
        err_msg = f"Post-execution binary hash mismatch!\nExpected: {EXPECTED_BIN_SHA}\nObserved: {final_bin_sha}"
        print(f"\nFATAL POST-EXECUTION ERROR: {err_msg}", file=sys.stderr)
        log_lines.append(f"FATAL_ERROR: {err_msg}\n")
        with open(log_path, "w", encoding="utf-8") as f:
            f.writelines(log_lines)
        raise ValueError(err_msg)

    log_lines.append("POST_EXEC_HASHES_VERIFIED: PASS\n")

    # Post-Execution Check 2: Reopen and Validate Primary CSV from Disk
    try:
        verified_rows = validate_final_csv_on_disk(csv_path, schedule)
        log_lines.append(f"DISK_CSV_VALIDATED_ROWS: {verified_rows}\n")
        log_lines.append("DISK_CSV_VALIDATION: PASS\n\n")
    except Exception as e:
        print(f"\nFATAL POST-EXECUTION CSV VALIDATION ERROR: {e}", file=sys.stderr)
        log_lines.append(f"FATAL_ERROR in disk CSV validation: {e}\n")
        with open(log_path, "w", encoding="utf-8") as f:
            f.writelines(log_lines)
        raise

    # Write completion marker ONLY after both post-checks pass
    end_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    log_lines.append("=== SWEEP EXECUTION COMPLETED SUCCESSFULLY ===\n")
    log_lines.append(f"END_TIME_UTC: {end_utc}\n")
    log_lines.append(f"TOTAL_ROWS_COMMITTED: {total_data_rows}\n")
    with open(log_path, "w", encoding="utf-8") as f:
        f.writelines(log_lines)

    print(f"\nExecution successfully completed. {total_data_rows} rows recorded and verified on disk in {csv_path}.")


def run_self_tests() -> None:
    """
    Comprehensive in-memory self-test suite covering:
    - Schedule integrity and deterministic balance.
    - Preflight hash checks.
    - Fail-closed behavior on existing output files.
    - Mocked 20-step execution with header stripping and row mapping.
    - Non-zero exit status detection.
    - Checksum mismatch detection.
    - Malformed / incomplete rows detection.
    - Header mismatch detection.
    """
    import io
    import tempfile

    print("Running EXP-03 Runner Self-Tests (mocked execution)...")

    # 1. Schedule integrity
    assert len(SCHEDULE) == 20, f"Expected 20 steps, got {len(SCHEDULE)}"
    block_counts: Dict[int, Dict[str, int]] = {b: {} for b in range(1, 6)}
    for s in SCHEDULE:
        b = s["block"]
        cid = s["config_id"]
        block_counts[b][cid] = block_counts[b].get(cid, 0) + 1

    for b in range(1, 6):
        assert len(block_counts[b]) == 4, f"Block {b} does not contain 4 distinct configs"
        for cid, count in block_counts[b].items():
            assert count == 1, f"Block {b} config {cid} count is {count} != 1"
    print("  [PASS] Test 1: Schedule integrity and block balance")

    # 2. Mock stdout generator
    def make_mock_stdout(
        step_info: Dict[str, Any],
        checksum_override=None,
        rows_count=5,
        header_override=None,
        elements_override=None,
        repeat_override=None,
    ):
        hdr = header_override if header_override is not None else CANONICAL_HEADER.strip()
        lines = [hdr]
        chk = checksum_override if checksum_override is not None else step_info["expected_checksum"]
        work = step_info["work"]
        chains = step_info["chains"]
        ops = float(work * chains)
        elems = elements_override if elements_override is not None else step_info["elements"]
        ws_bytes = elems * 8
        for r in range(rows_count):
            rep_val = repeat_override if repeat_override is not None else r
            sec = 0.003 if step_info["tier"] == "32 KiB" else 0.050
            ns_op = (sec * 1e9) / ops
            nominal = ops * 8.0
            lines.append(
                f"{step_info['mode']},{elems},{ws_bytes},"
                f"{work},{chains},{rep_val},{sec:.9f},{ops:.1f},{ns_op:.7f},{nominal:.1f},{chk}"
            )
        return "\n".join(lines) + "\n"

    # Mock completed process
    class MockProcess:
        def __init__(self, stdout="", stderr="", returncode=0):
            self.stdout = stdout
            self.stderr = stderr
            self.returncode = returncode

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        test_csv = tmp_path / "test_primary.csv"
        test_log = tmp_path / "test_sweep.log"

        # 3. Successful 20-step mock execution
        def mock_runner_ok(cmd, capture_output=True, text=True):
            # Find matching step
            for s in SCHEDULE:
                if s["mode"] in cmd and str(s["elements"]) in cmd and str(s["chains"]) in cmd:
                    return MockProcess(stdout=make_mock_stdout(s), returncode=0)
            return MockProcess(stdout=make_mock_stdout(SCHEDULE[0]), returncode=0)

        execute_schedule(SCHEDULE, Path("./memory_lab"), test_csv, test_log, pause_sec=0.0, runner_func=mock_runner_ok)
        assert test_csv.exists()
        assert test_log.exists()

        with open(test_csv) as f:
            csv_lines = f.readlines()
        assert len(csv_lines) == 101, f"Expected 101 lines (1 header + 100 rows), got {len(csv_lines)}"
        assert csv_lines[0] == CANONICAL_HEADER

        with open(test_log) as f:
            log_content = f.read()
        assert "=== SWEEP EXECUTION COMPLETED SUCCESSFULLY ===" in log_content
        assert "POST_EXEC_HASHES_VERIFIED: PASS" in log_content
        assert "DISK_CSV_VALIDATION: PASS" in log_content
        print("  [PASS] Test 2: Mock 20-step execution produces verified disk CSV and completion log")

        # 4. Fail-closed on existing files
        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), test_csv, test_log, pause_sec=0.0, runner_func=mock_runner_ok)
            assert False, "Should have raised FileExistsError"
        except FileExistsError:
            print("  [PASS] Test 3: Fail-closed on existing output files (refuses overwrite)")

        # 5. Non-zero exit status handling
        bad_csv = tmp_path / "bad_primary.csv"
        bad_log = tmp_path / "bad_sweep.log"
        def mock_runner_fail(cmd, capture_output=True, text=True):
            return MockProcess(stdout="", stderr="SIGSEGV segmentation fault", returncode=139)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), bad_csv, bad_log, pause_sec=0.0, runner_func=mock_runner_fail)
            assert False, "Should have raised ValueError on non-zero exit"
        except ValueError as e:
            assert "139" in str(e)
            assert bad_log.exists()
            print("  [PASS] Test 4: Immediate halt and log preservation on non-zero exit status")

        # 6. Checksum divergence handling
        chk_csv = tmp_path / "chk_primary.csv"
        chk_log = tmp_path / "chk_sweep.log"
        def mock_runner_bad_chk(cmd, capture_output=True, text=True):
            step = SCHEDULE[0]
            return MockProcess(stdout=make_mock_stdout(step, checksum_override=999999), returncode=0)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), chk_csv, chk_log, pause_sec=0.0, runner_func=mock_runner_bad_chk)
            assert False, "Should have raised ValueError on checksum mismatch"
        except ValueError as e:
            assert "checksum mismatch" in str(e)
            print("  [PASS] Test 5: Immediate halt on regression checksum mismatch (no retry)")

        # 7. Incomplete rows handling (4 rows instead of 5)
        inc_csv = tmp_path / "inc_primary.csv"
        inc_log = tmp_path / "inc_sweep.log"
        def mock_runner_inc(cmd, capture_output=True, text=True):
            step = SCHEDULE[0]
            return MockProcess(stdout=make_mock_stdout(step, rows_count=4), returncode=0)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), inc_csv, inc_log, pause_sec=0.0, runner_func=mock_runner_inc)
            assert False, "Should have raised ValueError on incomplete rows"
        except ValueError as e:
            assert "Expected exactly 5 data rows" in str(e)
            print("  [PASS] Test 6: Immediate halt on incomplete row count")

        # 8. Malformed header handling
        hdr_csv = tmp_path / "hdr_primary.csv"
        hdr_log = tmp_path / "hdr_sweep.log"
        def mock_runner_bad_hdr(cmd, capture_output=True, text=True):
            step = SCHEDULE[0]
            return MockProcess(stdout=make_mock_stdout(step, header_override="bad,header,format"), returncode=0)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), hdr_csv, hdr_log, pause_sec=0.0, runner_func=mock_runner_bad_hdr)
            assert False, "Should have raised ValueError on bad header"
        except ValueError as e:
            assert "header mismatch" in str(e)
            print("  [PASS] Test 7: Immediate halt on malformed or unexpected CSV header")

        # 9. Incorrect elements value detection (e.g. 2048 instead of 4096)
        elem_csv = tmp_path / "elem_primary.csv"
        elem_log = tmp_path / "elem_sweep.log"
        def mock_runner_bad_elem(cmd, capture_output=True, text=True):
            step = SCHEDULE[0]
            return MockProcess(stdout=make_mock_stdout(step, elements_override=2048), returncode=0)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), elem_csv, elem_log, pause_sec=0.0, runner_func=mock_runner_bad_elem)
            assert False, "Should have raised ValueError on elements mismatch"
        except ValueError as e:
            assert "elements mismatch" in str(e)
            print("  [PASS] Test 8: Immediate halt on incorrect elements value (e.g. 2048 vs 4096)")

        # 10. Incorrect repeat index detection (e.g. 3 instead of 0)
        rep_csv = tmp_path / "rep_primary.csv"
        rep_log = tmp_path / "rep_sweep.log"
        def mock_runner_bad_rep(cmd, capture_output=True, text=True):
            step = SCHEDULE[0]
            return MockProcess(stdout=make_mock_stdout(step, repeat_override=3), returncode=0)

        try:
            execute_schedule(SCHEDULE, Path("./memory_lab"), rep_csv, rep_log, pause_sec=0.0, runner_func=mock_runner_bad_rep)
            assert False, "Should have raised ValueError on repeat index mismatch"
        except ValueError as e:
            assert "repeat index mismatch" in str(e)
            print("  [PASS] Test 9: Immediate halt on incorrect repeat index (e.g. 3 vs 0)")

        # 11. Post-execution hash divergence detection
        bad_bin = tmp_path / "mutated_binary"
        bad_bin.write_bytes(b"corrupted_binary_bytes")
        bad_hash_csv = tmp_path / "bad_hash_primary.csv"
        bad_hash_log = tmp_path / "bad_hash_sweep.log"

        try:
            execute_schedule(SCHEDULE, bad_bin, bad_hash_csv, bad_hash_log, pause_sec=0.0, runner_func=mock_runner_ok)
            assert False, "Should have raised ValueError on post-execution binary hash mismatch"
        except ValueError as e:
            assert "Post-execution binary hash mismatch" in str(e)
            with open(bad_hash_log) as f:
                bad_hash_content = f.read()
            assert "SWEEP EXECUTION COMPLETED SUCCESSFULLY" not in bad_hash_content
            assert "FATAL_ERROR" in bad_hash_content
            print("  [PASS] Test 10: Post-execution hash divergence detected; completion marker prevented")

        # 12. Direct validate_final_csv_on_disk tests
        valid_rows = validate_final_csv_on_disk(test_csv, SCHEDULE)
        assert valid_rows == 100
        print("  [PASS] Test 11: validate_final_csv_on_disk confirms valid 100-row file")

        # Corrupt one row on disk to test disk validator rejection
        corrupt_disk_csv = tmp_path / "corrupt_disk.csv"
        with open(test_csv) as f:
            lines = f.readlines()
        # Corrupt elements in row 1
        row1_parts = lines[1].strip().split(",")
        row1_parts[1] = "9999"
        lines[1] = ",".join(row1_parts) + "\n"
        with open(corrupt_disk_csv, "w") as f:
            f.writelines(lines)

        try:
            validate_final_csv_on_disk(corrupt_disk_csv, SCHEDULE)
            assert False, "Should have failed on corrupted elements in disk CSV"
        except ValueError as e:
            assert "elements mismatch" in str(e)
            print("  [PASS] Test 12: validate_final_csv_on_disk rejects corrupted element values on disk")

    print("ALL RUNNER SELF-TESTS PASSED.")


def main():
    parser = argparse.ArgumentParser(description="EXP-20261016-03 Execution Orchestrator")
    parser.add_argument("--self-test", action="store_true", help="Run comprehensive in-memory unit tests")
    parser.add_argument("--dry-run", action="store_true", help="Perform preflight checks and print schedule without executing")
    args = parser.parse_args()

    if args.self_test:
        run_self_tests()
        sys.exit(0)

    print("=" * 80)
    print("EXP-20261016-03 Execution Orchestrator")
    print("=" * 80)

    # Preflight Check 1: Source & Binary SHA-256
    if not SOURCE_PATH.exists():
        print(f"FATAL: Source file missing: {SOURCE_PATH}", file=sys.stderr)
        sys.exit(1)
    if not BINARY_PATH.exists():
        print(f"FATAL: Binary missing: {BINARY_PATH}", file=sys.stderr)
        sys.exit(1)

    src_sha = sha256_file(SOURCE_PATH)
    bin_sha = sha256_file(BINARY_PATH)

    print(f"Source SHA-256: {src_sha}")
    if src_sha != EXPECTED_SRC_SHA:
        print(f"FATAL: Source SHA-256 mismatch!\nExpected: {EXPECTED_SRC_SHA}\nActual:   {src_sha}", file=sys.stderr)
        sys.exit(1)

    print(f"Binary SHA-256: {bin_sha}")
    if bin_sha != EXPECTED_BIN_SHA:
        print(f"FATAL: Binary SHA-256 mismatch!\nExpected: {EXPECTED_BIN_SHA}\nActual:   {bin_sha}", file=sys.stderr)
        sys.exit(1)

    # Preflight Check 2: Absence of Target Evidence Files
    if PRIMARY_CSV.exists():
        print(f"FATAL: Primary CSV already exists: {PRIMARY_CSV}. Refusing to overwrite prior evidence.", file=sys.stderr)
        sys.exit(1)
    if SWEEP_LOG.exists():
        print(f"FATAL: Sweep log already exists: {SWEEP_LOG}. Refusing to overwrite prior evidence.", file=sys.stderr)
        sys.exit(1)

    print("Preflight checks passed: Source and binary integrity verified. Target paths absent.")

    if args.dry_run:
        print("\nDRY RUN: Displaying fixed 20-step execution schedule:")
        for s in SCHEDULE:
            cmd = build_command(s, BINARY_PATH)
            print(f"  Step {s['global_step']:02d} [Block {s['block']}, Step {s['block_step']}] — {s['config_id']}: {' '.join(cmd)}")
        print("\nDry run completed successfully. No benchmarks executed.")
        sys.exit(0)

    # Strict authorization reminder
    print("\nWARNING: Live benchmark execution requires explicit user authorization.")
    print("Execute only when authorization has been granted under pre-registered protocol.")
    execute_schedule(SCHEDULE, BINARY_PATH, PRIMARY_CSV, SWEEP_LOG, pause_sec=2.0)


if __name__ == "__main__":
    main()
