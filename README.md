# CPU Memory Wall & Memory-Level Parallelism Research Lab

A reproducible systems-performance research repository investigating pointer chasing, cache hierarchy latency regimes, and memory-level parallelism (MLP) on modern x86-64 hardware.

> **Accompanying Article:** [*The Hard Part Wasn't Making It Faster. It Was Trusting the Numbers.*](https://medium.com/@amanbaniksr75/the-hard-part-wasnt-making-it-faster-it-was-trusting-the-numbers-a3644dc59639)

---

## 1. Research Overview & Core Questions

Modern processors rely on deep, multi-tiered cache hierarchies to bridge the growing performance gap between high-speed execution cores and high-capacity dynamic RAM—the classic **Memory Wall**. When traversing pointer-linked data structures, execution throughput is constrained by memory latency:

$$\text{Pointer Chasing (Serialized):} \quad p_{i+1} = \text{memory}[p_i]$$

Because each target address cannot be computed until the preceding load completes, out-of-order execution engines cannot speculatively issue subsequent dependent loads. The core stalls while waiting for data to travel across the memory hierarchy.

### The Central Question
**What changes when a CPU can execute multiple independent pointer chains concurrently?**
$$\text{Multi-Chain Traversal (Concurrent):} \quad p^{(c)}_{i+1} = \text{memory}[p^{(c)}_i] \quad \text{for } c \in \{1, \dots, C\}$$

By structuring traversals into $C$ mutually independent, disjoint cycles, the processor can expose **Memory-Level Parallelism (MLP)**. If the memory subsystem and Line Fill Buffers (LFBs) can service multiple cache misses simultaneously, the amortized wall-clock time per pointer operation should decrease under concurrency.

This repository records three controlled experiments designed to measure this effect, verify timing stability, and audit the reproducibility of memory microbenchmarks under virtualized execution environments.

---

## 2. Experimental Summary

| Experiment | Focus & Methodology | Primary Working Sets | Concurrency ($C$) | Key Empirical Finding |
|---|---|---|:---:|---|
| **[EXP-01](lab-notebook/experiments/EXP-20261016-01-record.md)** | **Working-Set Sweep:** Dependent single-chain traversal across 13 memory tiers | 16 KiB to 64 MiB | $C=1$ | Measured amortized latency exhibits distinct step plateaus corresponding to L1d (~1.2 ns), L2 (~2.6–6.2 ns), L3 (~14–16 ns), and main memory (>100 ns). |
| **[EXP-02](lab-notebook/experiments/EXP-20261016-02-record.md)** | **Independent-Chain Sweep:** Scaling concurrent chains from 1 to 16 | 32 KiB, 1 MiB, 64 MiB | $1, 2, 4, 8, 16$ | At 64 MiB, amortized latency drops from **125.70 ns/op** ($C=1$) to **9.20 ns/op** ($C=16$), an apparent **$13.66\times$ speedup**. However, continuous sweeps revealed $+37\text{–}40\%$ sequential verification drift. |
| **[EXP-03](lab-notebook/experiments/EXP-20261016-03-record.md)** | **Interleaved Balanced Retest:** 5 randomized blocks, 20 separate process launches, 2.0s pauses | 32 KiB, 64 MiB | $1, 4$ | Evaluated kernel equivalence (H7: $+3.49\%$), moderated L1 drift (H8: 6.7–8.1%), and verified **within-block speedups of $3.42\times\text{–}4.41\times$** ($4.21\times$ overall ratio) for $C=4$ vs $C=1$ at 64 MiB. |

---

## 3. Principal Results & Methodological Guardrails

### 3.1 Measured Concurrency Speedups
- **EXP-02 Scaling (64 MiB Working Set):**  
  - $C=1$ Median: **125.7006 ns/op**  
  - $C=16$ Median: **9.2006 ns/op**  
  - Speedup Ratio: **$13.6622\times$** ($\approx 13.7\times$)  
  - *Critical Qualification:* **EXP-03 did not retest $C=16$.** The $13.66\times$ figure is an exploratory measurement from continuous sequential sweeps in EXP-02; it was not re-evaluated in the final balanced verification experiment.
- **EXP-03 Run 2 Verification (64 MiB Working Set):**  
  - $C=1$ Overall Median ($N=25$): **80.9060 ns/op** (block medians: 76.00 to 93.76 ns/op)  
  - $C=4$ Overall Median ($N=25$): **19.2108 ns/op** (block medians: 18.09 to 22.24 ns/op)  
  - Overall Median Ratio: **$4.2115\times$** ($\approx 4.21\times$)  
  - **Within-Block Speedups ($S_b = \text{Med}(C=1)_b / \text{Med}(C=4)_b$):**  
    - Block 1: **4.4091×**
    - Block 2: **3.4208×**
    - Block 3: **4.3484×**
    - Block 4: **4.2007×**
    - Block 5: **4.2623×**  
    *(All five independent blocks strictly exceed the pre-registered $3.00\times$ threshold.)*
- **32 KiB Kernel Equivalence Check (H7):**  
  At 32 KiB, `chains` ($C=1$) median latency ($0.9887\text{ ns/op}$) differed from single-pointer `chase` ($0.9554\text{ ns/op}$) by **$+3.49\%$**, within the pre-registered $\pm 5.0\%$ descriptive heuristic band.

### 3.2 Epistemological Guardrails & Interpretive Boundaries
1. **Amortized Wall-Clock Time vs. Physical Load Latency:**  
   Reported performance values represent *amortized wall-clock nanoseconds per pointer operation* (total elapsed time divided by operations executed). A $4.21\times$ throughput speedup does **not** imply that individual physical DRAM read operations completed $4.21\times$ faster.
2. **Architectural Mechanism vs. Direct Hardware Measurement:**  
   The observed speedups are consistent with memory-level parallelism (multiple outstanding memory requests serviced concurrently by CPU line fill buffers and DRAM channels). However, hardware counters were unmeasured; CPU internal queue occupancy was not directly observed.
3. **Non-Mergeable Baselines Across Protocols:**  
   Single-chain 64 MiB medians differed across experiments ($100.32\text{ ns/op}$ in EXP-01, $125.70\text{ ns/op}$ in EXP-02, $80.91\text{ ns/op}$ in EXP-03). These variations reflect differences in process lifecycles, sequential sweep drift, warm-up state, and host dynamic frequency scaling. They must **never be pooled into a single statistical distribution**.

---

## 4. Test Environment & Benchmark Implementation

### 4.1 Hardware & Software Platform
- **Processor:** Intel Core i7-14650HX (16 physical cores: 8 Performance cores + 8 Efficient cores; 24 logical vCPUs exposed to guest).
- **Reported Cache Topology (`lscpu`):** L1d: 48 KiB/core, L2: 2 MiB/core, L3: 30 MiB shared. *(Treated as nominal topology descriptions, not physical residency guarantees).*
- **Host OS:** Windows 11 running Microsoft WSL2.
- **Guest Environment:** Ubuntu 24.04.4 LTS (`Linux 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC`).
- **Compiler:** GCC 13.3.0 (`-O3 -DNDEBUG -march=native -std=c++20 -Wall -Wextra`).
- **Timing Primitive:** `std::chrono::steady_clock` (monotonic wall-clock timer).

### 4.2 Benchmark Source & Accounting
The benchmark implementation is in [`src/memory_lab.cpp`](src/memory_lab.cpp):
- **Cycle Generation:** Each pointer cycle is generated via `std::mt19937_64` and `std::shuffle` seeded deterministically. For multi-chain mode, memory is partitioned into $C$ disjoint, equal-length segments.
- **Operation Accounting:**
  - `chase`: `work_count` operations ($2,000,000$).
  - `chains`: `work_count * chains` operations ($2,000,000 \times C$).
  - Amortized latency = $\frac{\text{elapsed seconds} \times 10^9}{\text{operations}}$.
- **Checksum Invariance:** Every execution computes and validates a cumulative checksum across pointer endpoints, guaranteeing identical traversal paths across all repetitions.

---

## 5. Reproducibility & Independent Verification

You can reproduce all data validations, statistical calculations, and publication figures directly from the verified raw evidence without executing benchmarks.

### Prerequisites
- Python 3.10+
- `numpy >= 1.26`
- `matplotlib >= 3.9`

### Re-Running Automated Audits
```bash
# Validate EXP-01 raw measurements and schema
python3 scripts/audit_exp01.py

# Validate EXP-02 raw measurements and drift calculations
python3 scripts/audit_exp02.py

# Validate EXP-03 Run 2 (100 rows, 5 blocks, H7-H9 evaluations)
python3 scripts/audit_exp03.py
```

### Running Orchestrator & Audit Self-Tests
```bash
# Runner harness self-test (14/14 tests)
python3 scripts/run_exp03.py --self-test

# Audit script self-test (9/9 regression fixtures)
python3 scripts/audit_exp03.py --self-test
```

### Regenerating Publication Visualizations
```bash
python3 scripts/plot_exp01.py
python3 scripts/plot_exp02.py
python3 scripts/plot_exp03.py
```
Generated figures are output to [`results/plots/`](results/plots/):
- [`EXP-20261016-01-latency-linear.png`](results/plots/EXP-20261016-01-latency-linear.png) & [`.svg`](results/plots/EXP-20261016-01-latency-linear.svg): Working-set sweep (16 KiB to 64 MiB).
- [`EXP-20261016-02-mlp-speedup.png`](results/plots/EXP-20261016-02-mlp-speedup.png) & [`.svg`](results/plots/EXP-20261016-02-mlp-speedup.svg): Multi-chain scaling across 1..16 chains.
- [`EXP-20261016-03-32k-kernel-equivalence.png`](results/plots/EXP-20261016-03-32k-kernel-equivalence.png) & [`.svg`](results/plots/EXP-20261016-03-32k-kernel-equivalence.svg): 32 KiB H7 equivalence check.
- [`EXP-20261016-03-64m-variability.png`](results/plots/EXP-20261016-03-64m-variability.png) & [`.svg`](results/plots/EXP-20261016-03-64m-variability.svg): 64 MiB H8 launch-to-launch dispersion.
- [`EXP-20261016-03-within-block-speedup.png`](results/plots/EXP-20261016-03-within-block-speedup.png) & [`.svg`](results/plots/EXP-20261016-03-within-block-speedup.svg): Within-block speedup bars vs. 3.00x threshold.

---

## 6. Known Methodological Limitations

1. **Hardware Performance Counters Unavailable:**  
   Under virtualized WSL2, physical CPU PMU access was not exposed (`perf stat` reported `<not supported>`). Direct hardware events for cache misses (`L1-dcache-load-misses`, `LLC-load-misses`), Line Fill Buffer occupancy, and DRAM bus transactions could not be collected.
2. **Virtualized Host Scheduling & Timing Variance:**  
   The hybrid host architecture (8 P-cores + 8 E-cores) and hypervisor thread scheduling introduce unobservable timing variance. Interleaving separate process launches with 2.0s pauses moderated 32 KiB drift (bounded at 6.7–8.1%), but 64 MiB traversal times exhibited $\sim 23\%$ launch-to-launch variation.
3. **Small Sample Sizes per Cell ($N=5$):**  
   Each launch recorded five timed repetitions. These establish descriptive medians and inter-quartile ranges, not formal parametric confidence intervals.
4. **Generalization Limits:**  
   These results characterize pointer chasing on this specific processor, memory configuration (DDR5-5600), compiler, and virtualized OS. They demonstrate the presence and robustness of concurrency speedups under host jitter, but do not represent universal constants for all workloads or architectures.

---

## 7. Prior Art & Attribution

Pointer chasing with multiple independent chains to explore memory-level parallelism is an established technique in systems performance literature:
- **Algorithmica HPC:** Comprehensive analysis of memory-level parallelism, miss-status holding registers (MSHRs), and pointer chains ([en.algorithmica.org/hpc/cpu-cache/mlp](https://en.algorithmica.org/hpc/cpu-cache/mlp/)).
- **Daniel Lemire's `testingmlp`:** Benchmarking memory-level parallelism with independent pointer walks ([github.com/lemire/testingmlp](https://github.com/lemire/testingmlp)).
- **Tim Besard's `pChase`:** Microbenchmark for pointer-chasing latency and memory hierarchy exploration ([github.com/maleadt/pChase](https://github.com/maleadt/pChase)).

This project does not claim novelty for the pointer-chasing technique. Its primary engineering focus is on benchmark integrity: detecting uncalibrated sequential timing drift, preserving failed attempts, implementing a balanced interleaved retest, and establishing defensible bounds on what the data actually proves.

---

## 8. Repository Structure & Navigation

```text
memory-wall/
├── README.md               # Canonical public research overview (this file)
├── LICENSE                 # MIT License
├── BASE_INSTRUCTIONS.md    # Preserved Antigravity Agent Pack Fresh Start setup guide
├── RESEARCH-INDEX.md       # Comprehensive master catalog of experimental evidence
├── AGENT.md                # Authoritative operating contract for AI agents
├── src/
│   └── memory_lab.cpp      # Standalone C++20 benchmark implementation
├── scripts/
│   ├── run_exp03.py        # Balanced block orchestrator with fail-closed safety
│   ├── audit_exp01.py      # Automated audit validator for EXP-01
│   ├── audit_exp02.py      # Automated audit validator for EXP-02
│   ├── audit_exp03.py      # Automated audit validator for EXP-03
│   ├── plot_exp01.py       # Matplotlib visualization script for EXP-01
│   ├── plot_exp02.py       # Matplotlib visualization script for EXP-02
│   └── plot_exp03.py       # Matplotlib visualization script for EXP-03
├── results/
│   ├── memory_lab.s        # Verified assembly disassembly dump
│   └── plots/              # Verified PNG and SVG publication figures
├── lab-notebook/
│   ├── experiments/        # Formal experiment proposals, protocols, and records
│   ├── raw/                # Immutable primary CSV measurements and sweep logs
│   └── environment/        # System configuration and hardware baselines
└── .agent/                 # Antigravity operating rules, workflows, and references
```

For detailed agent setup and toolkit instructions, see [`BASE_INSTRUCTIONS.md`](BASE_INSTRUCTIONS.md).  
For the master evidence directory, see [`RESEARCH-INDEX.md`](RESEARCH-INDEX.md).

---

## 9. License

This research codebase and toolkit are distributed under the [MIT License](LICENSE).
