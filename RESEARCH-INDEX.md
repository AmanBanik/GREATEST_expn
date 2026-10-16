# CPU Memory Wall Research Index

A compact master navigation index linking protocols, raw evidence, analysis scripts, publication figures, known limitations, and current project status for the `memory-wall` research campaign.

---

## 1. Campaign Status & Experiment Registry

| Experiment ID | Focus / Research Question | Protocol | Raw Evidence | Analysis & Plots | Formal Record / Closure | Status |
|---|---|---|---|---|---|---|
| **EXP-20261016-01** | Dependent pointer-chasing latency sweep across 13 working-set sizes (16 KiB to 64 MiB) | [`EXP-20261016-01-protocol.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-01-protocol.md) | [`EXP-20261016-01-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-primary.csv)<br>[`EXP-20261016-01-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-sweep.log) | [`scripts/plot_exp01.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/plot_exp01.py)<br>[`results/plots/EXP-20261016-01-latency-linear.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-linear.png) | [`EXP-20261016-01-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-01-record.md)<br>[`AUDIT-EXP-20261016-01.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/AUDIT-EXP-20261016-01.md) | **Completed & Validated** |
| **EXP-20261016-02** | Memory-Level Parallelism (MLP) scaling across 1, 2, 4, 8, 16 concurrent chains in 32 KiB, 1 MiB, 64 MiB tiers | [`EXP-20261016-02-protocol.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-protocol.md) | [`EXP-20261016-02-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-primary.csv)<br>[`EXP-20261016-02-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-sweep.log) | [`scripts/plot_exp02.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/plot_exp02.py)<br>[`results/plots/EXP-20261016-02-mlp-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-speedup.png) | [`EXP-20261016-02-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-record.md)<br>[`EXP-20261016-02-closure.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-closure.md) | **Completed & Closed** |
| **EXP-20261016-03** | Run-order invariance, process-launch variance, and kernel equivalence (`chase` vs. `chains C=1`) under 5 balanced blocks | [`EXP-20261016-03-proposal.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-03-proposal.md) | Planned: `lab-notebook/raw/EXP-20261016-03-primary.csv` | Planned: `scripts/audit_exp03.py` | Planned: `lab-notebook/experiments/EXP-20261016-03-record.md` | **Draft Proposal (Not Approved)** |

---

## 2. Key Verified Findings

1. **Hierarchy Latency Regimes (EXP-01):**
   - **Small Tier ($\le 32\text{ KiB}$):** Median latency plateaus at **~1.24–1.47 ns/op** (~5–7 cycles at ~5 GHz), consistent with L1d residency.
   - **Intermediate Tier ($64\text{ KiB}$ to $2\text{ MiB}$):** Steps up to **~2.6–6.2 ns/op**, consistent with L2 residency.
   - **LLC Step ($4\text{ MiB}$ to $8\text{ MiB}$):** Rises to **~13.7–16.3 ns/op**, consistent with shared L3 cache.
   - **DRAM & Translation Plateau ($16\text{ MiB}$ to $64\text{ MiB}$):** Steeps up to **~41–100 ns/op** ($81\times$ dynamic range relative to L1d).
2. **Memory-Level Parallelism Latency Hiding (EXP-02):**
   - **Large Tier (64 MiB):** Amortized latency collapses from **125.70 ns/op** ($C=1$) down to **9.20 ns/op** ($C=16$), a **$13.66\times$ intra-tier speedup**.
   - **Runtime Inversion:** At $C=8$, executing $8\times$ as many operations ($16{,}000{,}000$ ops) completed in **less** wall-clock time than $C=1$ ($0.2009\text{ s}$ vs. $0.2514\text{ s}$).
   - **Superscalar Load Ports in Small Tier (32 KiB):** Sub-nanosecond amortized latency ($0.27\text{ ns/op}$) reflects multiple parallel loads executed per cycle across superscalar execution ports, not sub-nanosecond individual load latency.
3. **Verification Hysteresis / Drift:**
   - EXP-02 post-sweep verification re-tests showed $+40.22\%$ drift at 32 KiB ($C=1$) and $+37.07\%$ drift at 64 MiB ($C=4$).

---

## 3. Core Artifact & Evidence Paths

- **C++ Benchmark Source:** [`src/memory_lab.cpp`](file:///home/amans/Devfield2/experiment/memory-wall/src/memory_lab.cpp) (`b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`)
- **Assembly Inspection:** [`results/memory_lab.s`](file:///home/amans/Devfield2/experiment/memory-wall/results/memory_lab.s) | Audit: [`ASSEMBLY-INSPECTION-20261016T142000Z.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/ASSEMBLY-INSPECTION-20261016T142000Z.md)
- **Primary Sweep Data:**
  - EXP-01: [`lab-notebook/raw/EXP-20261016-01-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-primary.csv) (65 rows)
  - EXP-02: [`lab-notebook/raw/EXP-20261016-02-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-primary.csv) (75 rows)
- **Verification Re-test Data:**
  - EXP-01: [`lab-notebook/raw/EXP-20261016-01-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-verification.csv) (10 rows)
  - EXP-02: [`lab-notebook/raw/EXP-20261016-02-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-verification.csv) (10 rows)
- **Publication Figures:**
  - Latency Linear: [`results/plots/EXP-20261016-01-latency-linear.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-linear.png)
  - Latency Log-Log: [`results/plots/EXP-20261016-01-latency-loglog.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-loglog.png)
  - MLP Latency Scaling: [`results/plots/EXP-20261016-02-mlp-latency.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-latency.png)
  - MLP Speedup Scaling: [`results/plots/EXP-20261016-02-mlp-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-speedup.png)
- **Hypothesis Register:** [`lab-notebook/experiments/HYPOTHESES.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/HYPOTHESES.md)
- **Session Chronicle:** [`lab-notebook/sessions/SESSION-20261016T132839Z.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/sessions/SESSION-20261016T132839Z.md)

---

## 4. Known Methodological Limitations & Epistemological Boundaries

1. **PMU Hardware Counter Absence:** Running inside WSL2 prevents access to Linux `perf` and physical hardware counters. Claims regarding Line Fill Buffer occupancy, cache miss counts, and DRAM bus transaction concurrency are architectural interpretations, not directly measured counter events.
2. **Virtualized Scheduling & Unresolved Drift:** WSL2 virtualizes 24 vCPUs without exposing the underlying physical heterogeneous topology (8 P-cores + 8 E-cores on the Core i7-14650HX). Hypervisor thread preemption, P/E-core migrations, and host dynamic frequency scaling remain unobservable. The exact cause of the $+37–40\%$ verification drift remains unresolved.
3. **Exploratory Sample Sizes ($N=5$):** All current sweeps employ five repetitions per configuration. These provide descriptive bounds on sample medians, not formal inferential statistical significance ($p$-values) or parametric confidence intervals.
4. **Three Performance Concepts:**
   - **Amortized Time per Operation:** Elapsed time divided by total operations.
   - **Total Elapsed Runtime:** Monotonic duration of benchmark execution.
   - **Individual-Load Latency:** Hardware duration of a single memory access; **unmeasured** by this benchmark.

---

## 5. Operating Standards & Version Control

- **Authoritative Contract:** [`AGENT.md`](file:///home/amans/Devfield2/experiment/memory-wall/AGENT.md)
- **Field Guide Reference:** [`cpu_memory_experiments_field_guide.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/references/cpu_memory_experiments_field_guide.md)
- **Git & GitHub Workflow:** [`.agent/GIT_WORKFLOW.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/GIT_WORKFLOW.md)
- **Target GitHub Remote:** `https://github.com/AmanBanik/GREATEST_expn.git`
