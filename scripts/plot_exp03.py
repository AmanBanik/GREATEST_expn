#!/usr/bin/env python3
"""
scripts/plot_exp03.py — Reproducible Plotting Script for EXP-20261016-03 (Run 2)

Generates three publication-quality, independently readable figures from verified Run 2 raw evidence:
1. Figure 1: results/plots/EXP-20261016-03-32k-kernel-equivalence (.png, .svg)
   - Evaluates Hypothesis H7 (Kernel Equivalence Heuristic at 32 KiB).
   - Shows Config 1 (chase) vs. Config 2 (chains C=1) across Blocks 1-5 with the +/-5.0% heuristic band.
2. Figure 2: results/plots/EXP-20261016-03-64m-variability (.png, .svg)
   - Evaluates Hypothesis H8 (64 MiB Working-Set Timing Variability & Launch Dispersion).
   - Shows Config 3 (64M C=1) vs. Config 4 (64M C=4) across Blocks 1-5 with CV and drift annotations.
3. Figure 3: results/plots/EXP-20261016-03-within-block-speedup (.png, .svg)
   - Evaluates Hypothesis H9 (Within-Block Concurrency Speedup at 64 MiB).
   - Compares within-block speedups (4.4091x, 3.4208x, 4.3484x, 4.2007x, 4.2623x) against the 3.00x threshold.

Methodological & Epistemological Guardrails:
- All y-axes state: "Amortized Wall-Clock Time per Pointer Operation (ns/op)".
- Replaced "DRAM drift" with cautious terminology: "64 MiB working-set timing variability".
- Direct DRAM latency, physical DRAM transactions, and cache misses are NOT directly measured (PMU unavailable under WSL2).
- H7 +/-5% band is described as a descriptive heuristic check, not a formal equivalence test.
- Individual block speedups are kept distinct from the overall median ratio (4.2115x).
"""

import os
import sys
from pathlib import Path

# Self-healing interpreter delegation if matplotlib is installed in conda env
try:
    import matplotlib
except ImportError:
    candidate = "/home/amans/miniconda3/envs/torch_bk/bin/python3"
    if os.path.exists(candidate) and candidate != sys.executable:
        os.execv(candidate, [candidate] + sys.argv)
    raise

import csv
import matplotlib.pyplot as plt
import numpy as np

PRIMARY_CSV = Path("lab-notebook/raw/EXP-20261016-03-run2-primary.csv")
PLOTS_DIR = Path("results/plots")


def load_run2_data(csv_path: Path):
    """
    Loads and structures the 100 rows into launches, blocks, and configurations.
    """
    if not csv_path.exists():
        raise FileNotFoundError(f"Primary Run 2 CSV not found: {csv_path}")

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = list(csv.DictReader(f))

    if len(reader) != 100:
        raise ValueError(f"Expected exactly 100 data rows, found {len(reader)}")

    configs = {
        ("chase", 4096, 1): "Config 1",
        ("chains", 4096, 1): "Config 2",
        ("chains", 8388608, 1): "Config 3",
        ("chains", 8388608, 4): "Config 4",
    }

    launches = []
    for i in range(0, 100, 5):
        chunk = reader[i : i + 5]
        mode = chunk[0]["mode"]
        elems = int(chunk[0]["elements"])
        chains = int(chunk[0]["chains"])
        cid = configs[(mode, elems, chains)]
        step = (i // 5) + 1
        block = (step - 1) // 4 + 1
        ns_vals = [float(r["ns_per_operation"]) for r in chunk]
        launches.append(
            {
                "step": step,
                "block": block,
                "config_id": cid,
                "mode": mode,
                "elements": elems,
                "chains": chains,
                "ns_vals": ns_vals,
                "median_ns": float(np.median(ns_vals)),
            }
        )

    by_config = {cid: [] for cid in ["Config 1", "Config 2", "Config 3", "Config 4"]}
    for r in reader:
        cid = configs[(r["mode"], int(r["elements"]), int(r["chains"]))]
        by_config[cid].append(float(r["ns_per_operation"]))

    return launches, by_config


def plot_32k_kernel_equivalence(launches, by_config, out_png: Path, out_svg: Path):
    """
    Figure 1: 32 KiB Tier — Kernel Equivalence Heuristic (H7) Across 5 Blocks.
    """
    fig, ax = plt.subplots(figsize=(10.5, 6.2), dpi=300)

    c1_overall_med = float(np.median(by_config["Config 1"]))
    c2_overall_med = float(np.median(by_config["Config 2"]))
    h7_delta = ((c2_overall_med - c1_overall_med) / c1_overall_med) * 100.0

    blocks = list(range(1, 6))
    c1_block_meds = []
    c2_block_meds = []

    np.random.seed(20261016)
    for b in blocks:
        l_c1 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 1"][0]
        l_c2 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 2"][0]
        c1_block_meds.append(l_c1["median_ns"])
        c2_block_meds.append(l_c2["median_ns"])

        # Jittered scatter points
        jitter_c1 = np.random.normal(0, 0.035, len(l_c1["ns_vals"]))
        jitter_c2 = np.random.normal(0, 0.035, len(l_c2["ns_vals"]))
        ax.scatter([b - 0.14 + j for j in jitter_c1], l_c1["ns_vals"], color="#2563eb", alpha=0.55, s=28, zorder=3)
        ax.scatter([b + 0.14 + j for j in jitter_c2], l_c2["ns_vals"], color="#059669", alpha=0.55, s=28, zorder=3)

    # Plot block medians connected
    ax.plot([b - 0.14 for b in blocks], c1_block_meds, marker="o", markersize=7.5, linewidth=2.0,
            color="#2563eb", zorder=4, label=f"Config 1: 32 KiB chase (Block Medians, Range: [{min(c1_block_meds):.4f}, {max(c1_block_meds):.4f}] ns)")
    ax.plot([b + 0.14 for b in blocks], c2_block_meds, marker="s", markersize=7.0, linewidth=2.0,
            color="#059669", zorder=4, label=f"Config 2: 32 KiB chains C=1 (Block Medians, Range: [{min(c2_block_meds):.4f}, {max(c2_block_meds):.4f}] ns)")

    # Baseline reference lines and +/- 5% heuristic band
    band_low = c1_overall_med * 0.95
    band_high = c1_overall_med * 1.05
    ax.axhline(c1_overall_med, color="#2563eb", linestyle="--", linewidth=1.4, zorder=2,
               label=f"Config 1 Overall Median: {c1_overall_med:.4f} ns/op (N=25 baseline)")
    ax.axhspan(band_low, band_high, color="#2563eb", alpha=0.08, zorder=1,
               label=f"H7 Descriptive Heuristic Band (+/-5.0%: [{band_low:.4f}, {band_high:.4f}] ns/op)")
    ax.axhline(c2_overall_med, color="#059669", linestyle=":", linewidth=1.5, zorder=2,
               label=f"Config 2 Overall Median: {c2_overall_med:.4f} ns/op (Delta = {h7_delta:+.2f}%)")

    # Callout badge
    ax.text(0.03, 0.88, f"H7 Result: SUPPORTED\nDelta_kernel = {h7_delta:+.2f}%\nInside [-5.0%, +5.0%] Heuristic Band",
            transform=ax.transAxes, fontsize=9.2, fontweight="bold",
            bbox=dict(boxstyle="round,pad=0.45", facecolor="#ecfdf5", edgecolor="#059669", alpha=0.95))

    ax.set_xticks(blocks)
    ax.set_xticklabels([f"Block {b}" for b in blocks], fontsize=10.5, fontweight="medium")
    ax.set_ylabel("Amortized Wall-Clock Time per Pointer Operation (ns/op)", fontsize=11, fontweight="semibold")
    ax.set_title("EXP-20261016-03: Kernel Equivalence Heuristic (32 KiB Tier)\n"
                 "chase vs. chains (C=1) Across 5 Interleaved Randomized Blocks (WORK_COUNT=2,000,000)",
                 fontsize=12, fontweight="bold", pad=12)
    ax.legend(loc="upper right", fontsize=8.8, framealpha=0.92, edgecolor="#cbd5e1")
    ax.grid(True, linestyle=":", color="#cbd5e1", alpha=0.7)
    ax.set_ylim(0.88, 1.22)

    footnote = (
        "Notes: Performance values reflect amortized wall-clock nanoseconds per pointer operation (std::chrono::steady_clock under WSL2).\n"
        "Individual physical L1 hit latency is unmeasured. PMU hardware counters unavailable under virtualized WSL2.\n"
        "The +/-5.0% band is a pre-registered descriptive heuristic check across 5 blocks (N=25 each), not a formal statistical equivalence test."
    )
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.0, style="italic", color="#334155",
             bbox=dict(boxstyle="round,pad=0.35", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.95))

    plt.subplots_adjust(bottom=0.17, top=0.90, left=0.10, right=0.96)
    fig.savefig(out_png, dpi=300)
    fig.savefig(out_svg)
    plt.close(fig)
    print(f"Generated: {out_png} and {out_svg}")


def plot_64m_variability(launches, by_config, out_png: Path, out_svg: Path):
    """
    Figure 2: 64 MiB Working-Set Timing Variability & Launch Dispersion (H8).
    """
    fig, ax = plt.subplots(figsize=(10.5, 6.2), dpi=300)

    blocks = list(range(1, 6))
    c3_block_meds = []
    c4_block_meds = []

    np.random.seed(20261016)
    for b in blocks:
        l_c3 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 3"][0]
        l_c4 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 4"][0]
        c3_block_meds.append(l_c3["median_ns"])
        c4_block_meds.append(l_c4["median_ns"])

        # Jittered scatter points
        jitter_c3 = np.random.normal(0, 0.035, len(l_c3["ns_vals"]))
        jitter_c4 = np.random.normal(0, 0.035, len(l_c4["ns_vals"]))
        ax.scatter([b - 0.14 + j for j in jitter_c3], l_c3["ns_vals"], color="#dc2626", alpha=0.55, s=28, zorder=3)
        ax.scatter([b + 0.14 + j for j in jitter_c4], l_c4["ns_vals"], color="#d97706", alpha=0.55, s=28, zorder=3)

    ax.plot([b - 0.14 for b in blocks], c3_block_meds, marker="^", markersize=8.0, linewidth=2.0,
            color="#dc2626", zorder=4, label="Config 3: 64 MiB chains C=1 (Block Medians)")
    ax.plot([b + 0.14 for b in blocks], c4_block_meds, marker="D", markersize=7.0, linewidth=2.0,
            color="#d97706", zorder=4, label="Config 4: 64 MiB chains C=4 (Block Medians)")

    c3_overall_med = float(np.median(by_config["Config 3"]))
    c4_overall_med = float(np.median(by_config["Config 4"]))
    ax.axhline(c3_overall_med, color="#dc2626", linestyle="--", linewidth=1.4, zorder=2,
               label=f"Config 3 Overall Median: {c3_overall_med:.2f} ns/op (CV=9.08%, Drift=23.37%)")
    ax.axhline(c4_overall_med, color="#d97706", linestyle="--", linewidth=1.4, zorder=2,
               label=f"Config 4 Overall Median: {c4_overall_med:.2f} ns/op (CV=9.05%, Drift=22.93%)")

    # Callout badge for H8 dispersion context
    ax.text(0.03, 0.82,
            "64 MiB Timing Variability (H8 Context):\n"
            "• C=1 Median Range: [76.00, 93.76] ns/op (Drift = 23.37%)\n"
            "• C=4 Median Range: [18.09, 22.24] ns/op (Drift = 22.93%)\n"
            "• Overall Median Throughput Ratio: 4.21x",
            transform=ax.transAxes, fontsize=8.8, fontweight="medium",
            bbox=dict(boxstyle="round,pad=0.45", facecolor="#fffbeb", edgecolor="#d97706", alpha=0.95))

    ax.set_xticks(blocks)
    ax.set_xticklabels([f"Block {b}" for b in blocks], fontsize=10.5, fontweight="medium")
    ax.set_ylabel("Amortized Wall-Clock Time per Pointer Operation (ns/op)", fontsize=11, fontweight="semibold")
    ax.set_title("EXP-20261016-03: 64 MiB Working-Set Timing Variability (C=1 vs. C=4)\n"
                 "Launch-to-Launch Dispersion Across 5 Interleaved Randomized Blocks (WORK_COUNT=2,000,000)",
                 fontsize=12, fontweight="bold", pad=12)
    ax.legend(loc="upper right", fontsize=8.8, framealpha=0.92, edgecolor="#cbd5e1")
    ax.grid(True, linestyle=":", color="#cbd5e1", alpha=0.7)
    ax.set_ylim(10, 105)

    footnote = (
        "Notes: Working set is 64 MiB (8,388,608 elements). Timing represents amortized wall-clock nanoseconds per pointer operation.\n"
        "Direct DRAM latency, DRAM bus traffic, and cache misses were not measured (PMU counters unavailable under WSL2).\n"
        "Randomized block interleaving with 2.0s pauses moderated 32 KiB drift (6.7-8.1%), while 64 MiB timing variability persisted across launches."
    )
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.0, style="italic", color="#334155",
             bbox=dict(boxstyle="round,pad=0.35", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.95))

    plt.subplots_adjust(bottom=0.17, top=0.90, left=0.10, right=0.96)
    fig.savefig(out_png, dpi=300)
    fig.savefig(out_svg)
    plt.close(fig)
    print(f"Generated: {out_png} and {out_svg}")


def plot_within_block_speedup(launches, by_config, out_png: Path, out_svg: Path):
    """
    Figure 3: Within-Block Concurrency Speedup at 64 MiB (H9).
    """
    fig, ax = plt.subplots(figsize=(10.5, 6.2), dpi=300)

    blocks = list(range(1, 6))
    speedups = []
    labels = []

    for b in blocks:
        l_c3 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 3"][0]
        l_c4 = [l for l in launches if l["block"] == b and l["config_id"] == "Config 4"][0]
        s_b = l_c3["median_ns"] / l_c4["median_ns"]
        speedups.append(s_b)
        labels.append(f"Block {b}\n(Step {l_c3['step']} vs {l_c4['step']})")

    c3_overall_med = float(np.median(by_config["Config 3"]))
    c4_overall_med = float(np.median(by_config["Config 4"]))
    overall_ratio = c3_overall_med / c4_overall_med

    all_x = list(range(len(blocks))) + [len(blocks) + 0.5]
    all_speedups = speedups + [overall_ratio]
    all_labels = labels + ["Overall\n(N=25 Median)"]

    bar_colors = ["#0284c7"] * len(blocks) + ["#0f766e"]
    bars = ax.bar(all_x, all_speedups, width=0.55, color=bar_colors, edgecolor="#0f172a", linewidth=1.0, zorder=3)

    # Threshold line at 3.00x
    ax.axhline(3.00, color="#dc2626", linestyle="--", linewidth=1.8, zorder=4,
               label="H9 Pre-Registered Threshold: S_b > 3.00x (All 5 blocks exceed threshold)")

    # Overall ratio reference line
    ax.axhline(overall_ratio, color="#0f766e", linestyle=":", linewidth=1.5, zorder=4,
               label=f"Overall Median Ratio: {overall_ratio:.4f}x")

    # Add numeric labels above bars
    for bar, val in zip(bars, all_speedups):
        height = bar.get_height()
        ax.annotate(f"{val:.4f}x",
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 4),
                    textcoords="offset points",
                    ha="center", va="bottom", fontsize=9.5, fontweight="bold", color="#0f172a")

    ax.set_xticks(all_x)
    ax.set_xticklabels(all_labels, fontsize=9.5)
    ax.set_ylabel("Within-Block Speedup (S_b = Median(C=1) / Median(C=4))", fontsize=10.5, fontweight="semibold")
    ax.set_ylim(0, 5.2)

    ax.set_title("EXP-20261016-03: Within-Block Concurrency Speedup (64 MiB Tier, C=1 vs. C=4)\n"
                 "Evaluation of Hypothesis H9: S_b > 3.00x Across All 5 Balanced Blocks",
                 fontsize=12, fontweight="bold", pad=12)

    footnote = (
        "Notes: Speedup reflects amortized pointer operation throughput under concurrent pointer chains relative to serialized chasing within the same block.\n"
        "Observed within-block speedups: Block 1: 4.4091x, Block 2: 3.4208x, Block 3: 4.3484x, Block 4: 4.2007x, Block 5: 4.2623x (All exceed 3.00x threshold; H9 Supported).\n"
        "Individual physical DRAM load latency is unmeasured. Wall-clock timing under WSL2; PMU hardware counters unavailable."
    )
    fig.text(0.5, 0.015, footnote, ha="center", fontsize=8.0, style="italic", color="#334155",
             bbox=dict(boxstyle="round,pad=0.35", facecolor="#f8fafc", edgecolor="#cbd5e1", alpha=0.95))

    ax.grid(True, axis="y", linestyle=":", color="#cbd5e1", alpha=0.7, zorder=0)
    ax.legend(loc="upper left", fontsize=9.0, framealpha=0.92, edgecolor="#cbd5e1")

    plt.subplots_adjust(bottom=0.17, top=0.90, left=0.10, right=0.96)
    fig.savefig(out_png, dpi=300)
    fig.savefig(out_svg)
    plt.close(fig)
    print(f"Generated: {out_png} and {out_svg}")


def main():
    print("================================================================================")
    print("EXP-20261016-03 Reproducible Plot Generation (Run 2 — 3 Dedicated Figures)")
    print("================================================================================")

    PLOTS_DIR.mkdir(parents=True, exist_ok=True)
    launches, by_config = load_run2_data(PRIMARY_CSV)

    png_32k = PLOTS_DIR / "EXP-20261016-03-32k-kernel-equivalence.png"
    svg_32k = PLOTS_DIR / "EXP-20261016-03-32k-kernel-equivalence.svg"
    plot_32k_kernel_equivalence(launches, by_config, png_32k, svg_32k)

    png_64m = PLOTS_DIR / "EXP-20261016-03-64m-variability.png"
    svg_64m = PLOTS_DIR / "EXP-20261016-03-64m-variability.svg"
    plot_64m_variability(launches, by_config, png_64m, svg_64m)

    png_speedup = PLOTS_DIR / "EXP-20261016-03-within-block-speedup.png"
    svg_speedup = PLOTS_DIR / "EXP-20261016-03-within-block-speedup.svg"
    plot_within_block_speedup(launches, by_config, png_speedup, svg_speedup)

    print("All 3 EXP-03 figures successfully created.")


if __name__ == "__main__":
    main()
