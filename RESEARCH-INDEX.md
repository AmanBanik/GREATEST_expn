# CPU Memory Wall Research Index

A compact master navigation index linking protocols, raw evidence, analysis scripts, publication figures, known limitations, reproduction instructions, and current project status for the `memory-wall` research campaign.

---

## 1. Campaign Status & Experiment Registry

| Experiment ID | Focus / Research Question | Protocol | Raw Evidence | Analysis & Plots | Formal Record / Closure | Status |
|---|---|---|---|---|---|---|
| **EXP-20261016-01** | Dependent pointer-chasing latency sweep across 13 working-set sizes (16 KiB to 64 MiB) | [`EXP-20261016-01-protocol.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-01-protocol.md) | Primary: [`EXP-20261016-01-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-primary.csv)<br>Re-test: [`EXP-20261016-01-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-verification.csv)<br>Log: [`EXP-20261016-01-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-sweep.log) | [`scripts/audit_exp01.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/audit_exp01.py)<br>[`scripts/plot_exp01.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/plot_exp01.py)<br>[`results/plots/EXP-20261016-01-latency-linear.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-linear.png) | [`EXP-20261016-01-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-01-record.md)<br>[`AUDIT-EXP-20261016-01.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/AUDIT-EXP-20261016-01.md) | **Completed & Validated** |
| **EXP-20261016-02** | Memory-Level Parallelism (MLP) scaling across 1, 2, 4, 8, 16 concurrent chains in 32 KiB, 1 MiB, 64 MiB tiers | [`EXP-20261016-02-protocol.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-protocol.md) | Primary: [`EXP-20261016-02-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-primary.csv)<br>Re-test: [`EXP-20261016-02-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-verification.csv)<br>Log: [`EXP-20261016-02-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-sweep.log) | [`scripts/audit_exp02.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/audit_exp02.py)<br>[`scripts/plot_exp02.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/plot_exp02.py)<br>[`results/plots/EXP-20261016-02-mlp-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-speedup.png) | [`EXP-20261016-02-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-record.md)<br>[`EXP-20261016-02-closure.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-02-closure.md) | **Completed & Closed** |
| **EXP-20261016-03** | Interleaved randomized blocks: Kernel equivalence (`chase` vs. `chains C=1`), launch dispersion, and within-block MLP speedup ($C=1$ vs $C=4$) | [`EXP-20261016-03-proposal.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-03-proposal.md) | Run 2: [`EXP-20261016-03-run2-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-run2-primary.csv)<br>Run 2 Log: [`EXP-20261016-03-run2-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-run2-sweep.log)<br>Preserved Attempt 1: [`EXP-20261016-03-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-primary.csv) | [`scripts/audit_exp03.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/audit_exp03.py)<br>[`scripts/plot_exp03.py`](file:///home/amans/Devfield2/experiment/memory-wall/scripts/plot_exp03.py)<br>[`results/plots/EXP-20261016-03-within-block-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-03-within-block-speedup.png) | [`EXP-20261016-03-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/EXP-20261016-03-record.md) | **Completed & Validated (Run 2)** |

---

## 2. Key Verified Empirical Findings

1. **Hierarchy Latency Regimes (EXP-01):**
   - **Small Tier ($\le 32\text{ KiB}$):** Median amortized latency plateaus at **~1.24–1.47 ns/op** (~5–7 cycles at ~5 GHz), consistent with L1d residency.
   - **Intermediate Tier ($64\text{ KiB}$ to $2\text{ MiB}$):** Steps up to **~2.6–6.2 ns/op**, consistent with L2 residency.
   - **LLC Step ($4\text{ MiB}$ to $8\text{ MiB}$):** Rises to **~13.7–16.3 ns/op**, consistent with shared L3 cache.
   - **DRAM & Translation Plateau ($16\text{ MiB}$ to $64\text{ MiB}$):** Rises to **~41–100 ns/op** ($81\times$ dynamic range relative to L1d).
2. **Memory-Level Parallelism Concurrency Scaling (EXP-02):**
   - **Large Tier (64 MiB):** Amortized latency collapses from **125.70 ns/op** ($C=1$) down to **9.20 ns/op** ($C=16$), a **$13.66\times$ intra-tier speedup**.
   - **Runtime Inversion:** At $C=8$, executing $8\times$ as many operations ($16{,}000{,}000$ ops) completed in **less** wall-clock time than $C=1$ ($0.2009\text{ s}$ vs. $0.2514\text{ s}$).
   - **Superscalar Load Ports in Small Tier (32 KiB):** Sub-nanosecond amortized latency ($0.27\text{ ns/op}$) reflects multiple parallel loads executed per cycle across superscalar execution ports, not sub-nanosecond individual load latency.
   - **Verification Drift Discovery:** Continuous sequential sweeps exhibited $+40.22\%$ verification drift at 32 KiB and $+37.07\%$ at 64 MiB.
3. **Randomized Interleaved Validation (EXP-03 Run 2):**
   - **Kernel Equivalence (H7):** Amortized latency difference between 32 KiB `chase` ($0.9554$ ns/op) and 32 KiB `chains` $C=1$ ($0.9887$ ns/op) is **$+3.49\%$**, within the pre-registered $\pm 5.0\%$ descriptive heuristic band.
   - **Launch Dispersion & Drift Moderation (H8):** Separate process launches with $2.0\text{ s}$ procedural pauses and randomized block interleaving bounded 32 KiB drift to **$6.72\%–8.06\%$** (compared to $+40.22\%$ in EXP-02), while 64 MiB working-set timing variability persisted at **$\sim 23\%$** across launches.
   - **Within-Block Concurrency Speedup (H9):** Amortized operation speedup ($64\text{M } C=1$ vs $C=4$) strictly exceeded $3.00\times$ across all 5 independent blocks (**$4.41\times$**, **$3.42\times$**, **$4.35\times$**, **$4.20\times$**, **$4.26\times$**; overall median ratio **$4.21\times$**).

---

## 3. Core Artifact & Evidence Directory

- **C++ Benchmark Source:** [`src/memory_lab.cpp`](file:///home/amans/Devfield2/experiment/memory-wall/src/memory_lab.cpp) (`b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`)
- **Native Executable Baseline:** [`memory_lab`](file:///home/amans/Devfield2/experiment/memory-wall/memory_lab) (`9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0`)
- **Assembly Disassembly Dump:** [`results/memory_lab.s`](file:///home/amans/Devfield2/experiment/memory-wall/results/memory_lab.s) (`74dd7b0c7c8b046afffdfef9d6fcfcfbb068a16617b48bb150b6bb30493db592`)
- **Raw Measurements (`lab-notebook/raw/`):**
  - EXP-01: [`EXP-20261016-01-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-primary.csv) (65 rows) & [`EXP-20261016-01-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-01-verification.csv) (10 rows)
  - EXP-02: [`EXP-20261016-02-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-primary.csv) (75 rows) & [`EXP-20261016-02-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-verification.csv) (10 rows)
  - EXP-03 (Run 2 Complete): [`EXP-20261016-03-run2-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-run2-primary.csv) (100 rows) & [`EXP-20261016-03-run2-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-run2-sweep.log)
  - EXP-03 (Attempt 1 Preserved): [`EXP-20261016-03-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-primary.csv) (10 rows, Step 3 halt) & [`EXP-20261016-03-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-sweep.log)
- **Publication Figures (`results/plots/`):**
  - EXP-01: [`EXP-20261016-01-latency-linear.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-linear.png) & [`EXP-20261016-01-latency-loglog.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-01-latency-loglog.png)
  - EXP-02: [`EXP-20261016-02-mlp-latency.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-latency.png) & [`EXP-20261016-02-mlp-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-02-mlp-speedup.png)
  - EXP-03: [`EXP-20261016-03-32k-kernel-equivalence.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-03-32k-kernel-equivalence.png), [`EXP-20261016-03-64m-variability.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-03-64m-variability.png), [`EXP-20261016-03-within-block-speedup.png`](file:///home/amans/Devfield2/experiment/memory-wall/results/plots/EXP-20261016-03-within-block-speedup.png)
- **Hypothesis Register:** [`lab-notebook/experiments/HYPOTHESES.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/HYPOTHESES.md)
- **Experiment Index:** [`lab-notebook/experiments/INDEX.md`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/experiments/INDEX.md)

---

## 4. Known Methodological Limitations & Epistemological Boundaries

1. **PMU Hardware Counter Absence:** Running inside virtualized WSL2 prevents access to physical hardware performance counters (`perf`, PMU events for cache misses, line-fill buffer occupancy, and memory controller traffic). Claims regarding buffer occupancy and DRAM bus transactions are architectural interpretations, not directly measured hardware events.
2. **Virtualized Scheduling & 64 MiB Timing Variability:** WSL2 virtualizes 24 vCPUs without exposing the physical heterogeneous topology (8 P-cores + 8 E-cores on the Core i7-14650HX). Hypervisor thread preemption, P/E-core migrations, and host dynamic frequency scaling contribute to the observed $\sim 23\%$ timing variability in 64 MiB traversal.
3. **Exploratory Sample Sizes ($N=5$ per cell):** Current sweeps employ five repetitions per configuration launch. These provide descriptive bounds on sample medians, not formal inferential statistical significance ($p$-values) or parametric confidence intervals.
4. **Three Distinct Performance Concepts:**
   - **Amortized Time per Operation:** Elapsed wall-clock time divided by completed pointer operations.
   - **Total Elapsed Runtime:** Monotonic duration of benchmark kernel execution (`std::chrono::steady_clock`).
   - **Individual-Load Latency:** Hardware duration of an isolated memory access; **unmeasured** by this benchmark.

---

## 5. Reproduction Instructions (Audits & Figures)

### Prerequisites
- Python 3.10+
- Dependencies: `numpy>=1.26`, `matplotlib>=3.9`

### Re-Running Audits (Without Benchmarking)
```bash
python3 scripts/audit_exp01.py
python3 scripts/audit_exp02.py
python3 scripts/audit_exp03.py
```

### Re-Running Orchestrator and Audit Self-Tests
```bash
python3 scripts/run_exp03.py --self-test
python3 scripts/audit_exp03.py --self-test
```

### Regenerating Publication Visualizations
```bash
python3 scripts/plot_exp01.py
python3 scripts/plot_exp02.py
python3 scripts/plot_exp03.py
```

---

## 6. Operating Standards & Version Control

- **Canonical Public Overview:** [`README.md`](README.md)
- **Agent Setup & Instructions:** [`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md)
- **Authoritative Contract:** [`AGENT.md`](AGENT.md)
- **Field Guide Reference:** [`cpu_memory_experiments_field_guide.md`](.agent/references/cpu_memory_experiments_field_guide.md)
- **Git & GitHub Workflow:** [`.agent/GIT_WORKFLOW.md`](.agent/GIT_WORKFLOW.md)
- **Target GitHub Remote:** `https://github.com/AmanBanik/GREATEST_expn.git` (Private)
