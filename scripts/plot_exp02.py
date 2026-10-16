#!/usr/bin/env python3
"""
scripts/plot_exp02.py — Reproducible Plotting Script for EXP-20261016-02

Generates publication-quality visualizations for the MLP multi-chain experiment:
1. Latency Scaling Plot: Amortized ns/op vs. Chain Count (C=1, 2, 4, 8, 16) across the 3 tiers.
2. Speedup Scaling Plot: Intra-tier Speedup vs. Chain Count (S(C) = Median(C=1) / Median(C)).

Methodological Guardrails:
- Points represent median ns/op across N=5 repetitions, with IQR error bars.
- Tiers labeled descriptively: Small Tier (32 KiB), Intermediate Tier (1 MiB), Large Tier (64 MiB).
- Footnote clarifies: Monotonic steady_clock wall-clock time under WSL2; independent chains provide an opportunity
  for memory-level parallelism; physical bus concurrency and PMU counters are unmeasured.
- Verification re-tests included as visually distinct markers.
"""

import csv
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-02-primary.csv")
VERIFICATION_CSV = Path("lab-notebook/raw/EXP-20261016-02-verification.csv")
PLOTS_DIR = Path("results/plots")

TIER_NAMES = {
    32768: "Small Tier (32 KiB)",
    1048576: "Intermediate Tier (1 MiB)",
    67108864: "Large Tier (64 MiB)"
}

TIER_COLORS = {
    32768: "#059669",      # Green
    1048576: "#d97706",    # Amber
    67108864: "#dc2626"    # Red
}

def load_data(csv_path: Path):
    data = {}
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            bsz = int(r["working_set_bytes"])
            c = int(r["chains"])
            ns = float(r["ns_per_operation"])
            secs = float(r["seconds"])
            key = (bsz, c)
            if key not in data:
                data[key] = {"bytes": bsz, "chains": c, "ns": [], "secs": []}
            data[key]["ns"].append(ns)
            data[key]["secs"].append(secs)

    stats = {}
    for key, d in data.items():
        bsz, c = key
        ns_sorted = sorted(d["ns"])
        q1 = ns_sorted[1]
        med = ns_sorted[2]
        q3 = ns_sorted[3]
        stats[key] = {
            "bytes": bsz,
            "chains": c,
            "median_ns": med,
            "min_ns": ns_sorted[0],
            "max_ns": ns_sorted[4],
            "q1_ns": q1,
            "q3_ns": q3,
            "all_ns": d["ns"],
            "all_secs": d["secs"]
        }
    return stats

def plot_latency(primary_stats, verif_stats, out_png: Path, out_svg: Path):
    fig, ax = plt.subplots(figsize=(10.5, 6.5), dpi=300)
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")

    chains_list = [1, 2, 4, 8, 16]

    for bsz in [32768, 1048576, 67108864]:
        lbl = TIER_NAMES[bsz]
        col = TIER_COLORS[bsz]
        meds = [primary_stats[(bsz, c)]["median_ns"] for c in chains_list]
        q1s = [primary_stats[(bsz, c)]["q1_ns"] for c in chains_list]
        q3s = [primary_stats[(bsz, c)]["q3_ns"] for c in chains_list]

        # Plot median curve
        ax.plot(chains_list, meds, marker="o", markersize=6.5, linewidth=2.0, color=col, label=f"{lbl} Median ($N=5$)")
        # Shaded IQR
        ax.fill_between(chains_list, q1s, q3s, color=col, alpha=0.18)

        # Plot raw individual points
        for c in chains_list:
            all_pts = primary_stats[(bsz, c)]["all_ns"]
            ax.scatter([c] * len(all_pts), all_pts, color=col, alpha=0.45, s=20, edgecolors="none")

    # Verification re-tests
    # 32 KiB, C=1
    v_32k = verif_stats[(32768, 1)]
    ax.scatter([1], [v_32k["median_ns"]], marker="D", s=90, color="#059669", edgecolor="#ffffff", linewidth=1.5,
               zorder=5, label="Small Tier (32 KiB, C=1) Verification Re-test")
    # 64 MiB, C=4
    v_64m = verif_stats[(67108864, 4)]
    ax.scatter([4], [v_64m["median_ns"]], marker="D", s=90, color="#dc2626", edgecolor="#ffffff", linewidth=1.5,
               zorder=5, label="Large Tier (64 MiB, C=4) Verification Re-test")

    ax.set_xticks(chains_list)
    ax.set_xticklabels([f"C={c}" for c in chains_list], fontsize=10)
    ax.set_xlabel("Concurrent Independent Pointer Chains ($C$) [Log2 Scale]", fontsize=11, fontweight="semibold", labelpad=8)
    ax.set_ylabel("Amortized Elapsed Time per Operation (ns/op) [Log10 Scale]", fontsize=11, fontweight="semibold", labelpad=8)
    ax.set_title("EXP-20261016-02: Memory-Level Parallelism (MLP) Latency Scaling\n"
                 "Intel Core i7-14650HX (WSL2), GCC 13.3.0 -O3 -march=native, WORK_COUNT=2,000,000/chain",
                 fontsize=12, fontweight="bold", pad=12)

    footnote = ("Notes: Y-axis is amortized time per operation (elapsed wall-clock seconds / total operations), NOT individual-load latency.\n"
                "Individual-load latency is not directly measured. Points represent median ns/op across N=5 repetitions (IQR bands).\n"
                "Monotonic steady_clock under WSL2; independent chains provide opportunity for MLP; PMU counters are unmeasured.")
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.2, style="italic", color="#475569",
             bbox=dict(boxstyle="round,pad=0.3", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.9))

    ax.grid(True, which="major", linestyle=":", color="#cbd5e1", alpha=0.8)
    ax.grid(True, which="minor", linestyle=":", color="#f1f5f9", alpha=0.5)
    ax.legend(loc="upper right", fontsize=9.2, framealpha=0.92, edgecolor="#cbd5e1")

    plt.subplots_adjust(bottom=0.18, top=0.90, left=0.10, right=0.96)
    fig.savefig(out_png, dpi=300)
    fig.savefig(out_svg)
    plt.close(fig)
    print(f"Saved: {out_png} and {out_svg}")

def plot_speedup(primary_stats, verif_stats, out_png: Path, out_svg: Path):
    fig, ax = plt.subplots(figsize=(10.5, 6.5), dpi=300)
    ax.set_xscale("log", base=2)

    chains_list = [1, 2, 4, 8, 16]

    # Ideal linear speedup reference line
    ax.plot(chains_list, chains_list, linestyle="--", color="#94a3b8", linewidth=1.5, label="Ideal Linear Concurrency ($S=C$)")

    for bsz in [32768, 1048576, 67108864]:
        lbl = TIER_NAMES[bsz]
        col = TIER_COLORS[bsz]
        base_med = primary_stats[(bsz, 1)]["median_ns"]
        speedups = [base_med / primary_stats[(bsz, c)]["median_ns"] for c in chains_list]

        ax.plot(chains_list, speedups, marker="o", markersize=7.0, linewidth=2.2, color=col,
                label=f"{lbl} Speedup vs. C=1")

    # Verification speedup point for Small Tier (32 KiB C=1)
    base_32k = primary_stats[(32768, 1)]["median_ns"]
    v_speedup_32k = base_32k / verif_stats[(32768, 1)]["median_ns"]
    ax.scatter([1], [v_speedup_32k], marker="D", s=90, color="#059669", edgecolor="#ffffff", linewidth=1.5,
               zorder=5, label=f"Small Tier Verification (C=1, Speedup={v_speedup_32k:.2f}x)")

    # Verification speedup point for Large Tier (64 MiB C=4)
    base_64m = primary_stats[(67108864, 1)]["median_ns"]
    v_speedup_64m = base_64m / verif_stats[(67108864, 4)]["median_ns"]
    ax.scatter([4], [v_speedup_64m], marker="D", s=90, color="#dc2626", edgecolor="#ffffff", linewidth=1.5,
               zorder=5, label=f"Large Tier Verification (C=4, Speedup={v_speedup_64m:.2f}x)")

    ax.set_xticks(chains_list)
    ax.set_xticklabels([f"C={c}" for c in chains_list], fontsize=10)
    ax.set_yticks(range(0, 18, 2))
    ax.set_xlabel("Concurrent Independent Pointer Chains ($C$) [Log2 Scale]", fontsize=11, fontweight="semibold", labelpad=8)
    ax.set_ylabel("Intra-Tier Amortized Speedup Relative to C=1 ($S(C)$)", fontsize=11, fontweight="semibold", labelpad=8)
    ax.set_title("EXP-20261016-02: Intra-Tier MLP Speedup Relative to C=1\n"
                 "Speedup = Median ns/op(C=1) / Median ns/op(C) within each working-set tier",
                 fontsize=12, fontweight="bold", pad=12)

    footnote = ("Notes: Speedup reflects amortized operation throughput relative to C=1 within each tier, NOT reduced individual-load latency.\n"
                "Individual-load latency is unmeasured. Verification markers: Large Tier C=4 (3.56x) and Small Tier C=1 (0.71x) vs primary C=1.\n"
                "Timing reflects opportunity for memory-level parallelism; physical bus concurrency and PMU events are unmeasured.")
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.2, style="italic", color="#475569",
             bbox=dict(boxstyle="round,pad=0.3", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.9))

    ax.grid(True, which="major", linestyle=":", color="#cbd5e1", alpha=0.8)
    ax.legend(loc="upper left", fontsize=9.2, framealpha=0.92, edgecolor="#cbd5e1")

    plt.subplots_adjust(bottom=0.18, top=0.90, left=0.10, right=0.96)
    fig.savefig(out_png, dpi=300)
    fig.savefig(out_svg)
    plt.close(fig)
    print(f"Saved: {out_png} and {out_svg}")

def main():
    PLOTS_DIR.mkdir(parents=True, exist_ok=True)
    primary_stats = load_data(PRIMARY_CSV)
    verif_stats = load_data(VERIFICATION_CSV)

    plot_latency(
        primary_stats, verif_stats,
        PLOTS_DIR / "EXP-20261016-02-mlp-latency.png",
        PLOTS_DIR / "EXP-20261016-02-mlp-latency.svg"
    )

    plot_speedup(
        primary_stats, verif_stats,
        PLOTS_DIR / "EXP-20261016-02-mlp-speedup.png",
        PLOTS_DIR / "EXP-20261016-02-mlp-speedup.svg"
    )

if __name__ == "__main__":
    main()
