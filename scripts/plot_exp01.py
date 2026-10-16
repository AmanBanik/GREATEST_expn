#!/usr/bin/env python3
"""
scripts/plot_exp01.py — Reproducible Plotting Script for EXP-20261016-01 (Revision 2.0)

Generates publication-quality figures from raw CSV evidence:
1. Semi-log plot (log2 x-axis, linear y-axis): Shows full latency scale and DRAM explosion.
2. Log-log plot (log2 x-axis, log10 y-axis): Resolves fine-grained hierarchy plateaus (L1, L2, L3, DRAM).

Key Methodological Clarifications:
- Cache reference lines are explicitly documented as nominal processor capacity references (from lscpu),
  not experimentally measured hardware boundaries.
- Per-step latency is clearly identified as elapsed monotonic wall-clock time (steady_clock) under WSL2.
- Measurements at large working sets (> 16 MiB) are presented as compound system effects
  (cache misses, virtual memory translation, main memory latency) without claiming direct measurement
  of hardware PMU counters, TLB misses, or DRAM bus cycles.
- Verification re-tests are visually segregated using distinct red diamond markers.
"""

import csv
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-01-primary.csv")
VERIFICATION_CSV = Path("lab-notebook/raw/EXP-20261016-01-verification.csv")
PLOTS_DIR = Path("results/plots")

def load_data(csv_path: Path):
    by_size = {}
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            bsz = int(r["working_set_bytes"])
            ns = float(r["ns_per_operation"])
            rep = int(r["repeat"])
            if bsz not in by_size:
                by_size[bsz] = {"bytes": bsz, "reps": [], "ns": []}
            by_size[bsz]["reps"].append(rep)
            by_size[bsz]["ns"].append(ns)

    sizes_bytes = sorted(by_size.keys())
    medians = []
    mins = []
    maxs = []
    q1s = []
    q3s = []
    all_x = []
    all_y = []

    for bsz in sizes_bytes:
        vals = by_size[bsz]["ns"]
        sorted_vals = sorted(vals)
        mins.append(sorted_vals[0])
        q1s.append(sorted_vals[1])
        medians.append(sorted_vals[2])
        q3s.append(sorted_vals[3])
        maxs.append(sorted_vals[4])
        for v in vals:
            all_x.append(bsz)
            all_y.append(v)

    return {
        "sizes_bytes": np.array(sizes_bytes),
        "medians": np.array(medians),
        "mins": np.array(mins),
        "maxs": np.array(maxs),
        "q1s": np.array(q1s),
        "q3s": np.array(q3s),
        "all_x": np.array(all_x),
        "all_y": np.array(all_y)
    }

def format_tick(bytes_val):
    if bytes_val < 1048576:
        return f"{int(bytes_val / 1024)} KiB"
    return f"{int(bytes_val / 1048576)} MiB"

def create_plot(log_y: bool, primary_data, verif_data, output_png: Path, output_svg: Path):
    fig, ax = plt.subplots(figsize=(11.5, 7.0), dpi=300)

    # Style configuration
    ax.set_xscale("log", base=2)
    if log_y:
        ax.set_yscale("log")
        title_suffix = " (Log-Log Scale: Hierarchy Plateaus)"
        y_label = "Elapsed Wall-Clock Time per Step (ns/op) [Log10 Scale]"
    else:
        title_suffix = " (Semi-Log Scale: Dynamic Range)"
        y_label = "Elapsed Wall-Clock Time per Step (ns/op) [Linear Scale]"

    sizes = primary_data["sizes_bytes"]
    meds = primary_data["medians"]
    q1s = primary_data["q1s"]
    q3s = primary_data["q3s"]

    # 1. Shaded IQR region for primary sweep
    ax.fill_between(sizes, q1s, q3s, color="#2563eb", alpha=0.18, label="Primary Sweep Dispersion (IQR: Q1–Q3)")

    # 2. Individual repetition scatter (raw data points)
    ax.scatter(primary_data["all_x"], primary_data["all_y"],
               color="#64748b", alpha=0.55, s=28, zorder=3, edgecolors="none",
               label="Raw Repetitions (5 per working set)")

    # 3. Primary sweep median curve
    ax.plot(sizes, meds, color="#1d4ed8", marker="o", markersize=6.5,
            linewidth=2.0, zorder=4, label="Primary Sweep Median ($N=5$)")

    # 4. Verification re-tests (visually distinct markers)
    verif_sizes = verif_data["sizes_bytes"]
    verif_meds = verif_data["medians"]
    verif_all_x = verif_data["all_x"]
    verif_all_y = verif_data["all_y"]

    ax.scatter(verif_all_x, verif_all_y, color="#dc2626", alpha=0.6, s=36,
               marker="x", zorder=5, label="Verification Raw Reps (16 KiB, 1 MiB)")

    ax.scatter(verif_sizes, verif_meds, color="#b91c1c", s=110,
               marker="D", edgecolor="#ffffff", linewidth=1.5, zorder=6,
               label="Verification Median ($N=5$)")

    # 5. Nominal architectural cache references (Explicitly identified as nominal topology references)
    cache_references = [
        (48 * 1024, "Nominal L1d Reference (48 KiB)", "#059669"),
        (2 * 1024 * 1024, "Nominal L2 Reference (2 MiB)", "#d97706"),
        (30 * 1024 * 1024, "Nominal L3 Reference (30 MiB)", "#7c3aed")
    ]

    for byte_val, lbl, col in cache_references:
        ax.axvline(x=byte_val, color=col, linestyle="--", linewidth=1.3, alpha=0.85, zorder=2,
                   label=lbl)

    # X-axis ticks and formatting
    ax.set_xticks(sizes)
    ax.set_xticklabels([format_tick(s) for s in sizes], fontsize=8.5, rotation=35, ha="right")
    ax.set_xlim(sizes[0] * 0.75, sizes[-1] * 1.35)

    # Grid and Labels
    ax.grid(True, which="major", linestyle=":", color="#cbd5e1", alpha=0.8)
    if log_y:
        ax.grid(True, which="minor", linestyle=":", color="#f1f5f9", alpha=0.5)

    ax.set_xlabel("Allocated Working-Set Size (Bytes = Elements × 8) [Log2 Scale]", fontsize=10.5, fontweight="semibold", labelpad=8)
    ax.set_ylabel(y_label, fontsize=10.5, fontweight="semibold", labelpad=8)
    ax.set_title(f"EXP-20261016-01: Dependent Pointer Chasing Latency vs. Working-Set Size{title_suffix}\n"
                 f"Intel Core i7-14650HX (WSL2), GCC 13.3.0 -O3 -march=native, WORK_COUNT=2,000,000",
                 fontsize=11.5, fontweight="bold", pad=12)

    # Explanatory note in figure footer
    footnote = ("Notes: Vertical dashed lines indicate nominal cache capacities reported by lscpu, not experimentally measured boundaries.\n"
                "Latencies reflect wall-clock steady_clock time per dependent traversal step under WSL2; hardware PMU counters are unmeasured.")
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.2, style="italic", color="#475569",
             bbox=dict(boxstyle="round,pad=0.3", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.9))

    ax.legend(loc="upper left", fontsize=8.5, framealpha=0.92, edgecolor="#cbd5e1", ncol=1)

    plt.subplots_adjust(bottom=0.18, top=0.90, left=0.10, right=0.96)
    fig.savefig(output_png, dpi=300)
    fig.savefig(output_svg)
    plt.close(fig)
    print(f"Saved: {output_png} and {output_svg}")

def main():
    PLOTS_DIR.mkdir(parents=True, exist_ok=True)
    primary_data = load_data(PRIMARY_CSV)
    verif_data = load_data(VERIFICATION_CSV)

    # Semi-log plot (Linear Y)
    create_plot(
        log_y=False,
        primary_data=primary_data,
        verif_data=verif_data,
        output_png=PLOTS_DIR / "EXP-20261016-01-latency-linear.png",
        output_svg=PLOTS_DIR / "EXP-20261016-01-latency-linear.svg"
    )

    # Log-Log plot (Log Y)
    create_plot(
        log_y=True,
        primary_data=primary_data,
        verif_data=verif_data,
        output_png=PLOTS_DIR / "EXP-20261016-01-latency-loglog.png",
        output_svg=PLOTS_DIR / "EXP-20261016-01-latency-loglog.svg"
    )

if __name__ == "__main__":
    main()
