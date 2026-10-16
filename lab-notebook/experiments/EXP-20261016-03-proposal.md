# Experiment Proposal & Draft Protocol — EXP-20261016-03

> [!WARNING]
> **STATUS: DRAFT — NOT APPROVED FOR EXECUTION**  
> This protocol is a pre-execution design proposal submitted for review and approval. No benchmarks will be executed, no source code will be modified, and no binaries will be recompiled until explicit user authorization is granted.

---

## 1. Research Question & Methodological Motivation

### Background
In `EXP-20261016-02`, multi-chain pointer traversal demonstrated substantial memory-level parallelism (MLP) at 64 MiB ($13.66\times$ amortized speedup at $C=16$). However, post-sweep verification re-tests showed non-trivial measurement drift relative to the primary sweep baseline:
- **Small Tier (32 KiB, $C=1$):** $+40.22\%$ ($1.4975\text{ ns/op}$ primary vs. $2.0998\text{ ns/op}$ verification).
- **Large Tier (64 MiB, $C=4$):** $+37.07\%$ ($25.7739\text{ ns/op}$ primary vs. $35.3271\text{ ns/op}$ verification).

Because all primary and verification runs produced bit-for-bit identical checksums (`1923` and `14274912`), the executed pointer graph traversal paths were identical. The observed variance reflects non-deterministic system-level runtime latency (such as hypervisor thread scheduling, core migration across Performance-cores and Efficient-cores, or CPU frequency scaling). 

Furthermore, `EXP-20261016-02` evaluated multi-chain scaling exclusively within `chains` mode, leaving untested whether the `chains_kernel` implementation (which includes heap vector allocation and nested loop indexing) introduces measurable timing overhead compared to the dedicated serialized pointer-chasing kernel (`chase_kernel`) evaluated in `EXP-20261016-01`.

### Research Questions
1. **Kernel Equivalence (Heuristic Check):** At the small working-set tier (32 KiB), does `chains` mode with $C=1$ (`chains_kernel`) exhibit practical timing equivalence ($\pm 5.0\%$) with dedicated single-chain `chase` mode (`chase_kernel`)?
2. **Measurement Stability Under Balanced Interleaving:** When tested across multiple independent process launches arranged in a predefined balanced block design, what is the empirical between-block dispersion (median spread, range, and coefficient of variation) for baseline configurations?
3. **MLP Robustness Under Drift:** Does the $C=4$ MLP latency reduction at 64 MiB remain consistently greater than $3.0\times$ relative to $C=1$ *within every individual execution block*, regardless of external runtime drift?

---

## 2. Why This Experiment is the Best Next Step

1. **Addresses the Most Consequential Methodological Uncertainty:**
   Before proceeding to new algorithmic sweeps (e.g. streaming strides, prefetching thresholds, or random layouts), we must understand whether measurement drift can be bounded by a balanced block design and establish a rigorous baseline for run-to-run repeatability.
2. **Validates Kernel Baseline Interchangeability:**
   It empirically tests whether `chains(C=1)` can be compared to `chase` without modifying source code or recompiling the binary.
3. **Zero Risk to Codebase Integrity:**
   Requires **no source modifications** and runs entirely on the existing verified executable `memory_lab` (SHA-256: `9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0`).

---

## 3. What Results Would Change the Interpretation of EXP-20261016-02?

- **If H7 Fails ($|\Delta_{\text{kernel}}| > 5.0\%$):** If `chains C=1` is noticeably slower than `chase` at 32 KiB, the $C=1$ baseline in `EXP-20261016-02` includes non-negligible inner-loop / vector initialization overhead. This would mean that intra-tier speedups in EXP-02 partially reflect amortizing loop instruction overhead alongside hardware concurrency.
- **If H8 Demonstrates Narrow Between-Block Spread ($< 10\%$):** If the between-block median spread is narrow compared to the $+37–40\%$ verification drift from EXP-02, this provides descriptive evidence that temporal ordering in a long continuous sweep contributed to earlier drift, establishing interleaved block designs as the mandatory protocol standard.
- **If H9 Fails ($S_B < 3.0\times$ in any block):** If external system jitter compresses the within-block speedup below $3.0\times$, it proves that host background interference can substantially distort measured memory-level parallelism.

---

## 4. Pre-Registered Hypotheses (Draft H7, H8, H9)

| ID | Hypothesis Summary | Measurable Prediction | Falsification / Guardrail Conditions |
|---|---|---|---|
| **H7** | **Kernel Equivalence (Descriptive Heuristic)** | At 32 KiB, the percentage difference between overall median amortized latency of `chains C=1` and `chase` will fall within a $\pm 5.0\%$ practical equivalence band: $$-5.0\% \le \Delta_{\text{kernel}} \le +5.0\%$$ where: $$\Delta_{\text{kernel}} = \frac{\text{Median}(\text{chains } C=1) - \text{Median}(\text{chase})}{\text{Median}(\text{chase})} \times 100\%$$ | $|\Delta_{\text{kernel}}| > 5.0\%$ indicates that kernel loop structure differences materially affect the baseline. *Guardrail:* This is a descriptive heuristic check; five blocks do NOT establish formal statistical equivalence or inferential proof of zero overhead. |
| **H8** | **Measurement Stability & Dispersion** | For each configuration, between-block median spread ($\max_B - \min_B$) and coefficient of variation ($\text{CV}_B$) across the 5 independent blocks will be calculated and reported. We descriptively evaluate whether inter-block drift is narrower than the $37–40\%$ jump seen between primary and verification runs in EXP-02. | *Guardrail:* EXP-02 and EXP-03 have different designs (ascending sweep vs. balanced blocks). Comparing their variability is an informative descriptive comparison, NOT a controlled causal test proving that run order caused the earlier drift. |
| **H9** | **Within-Block MLP Speedup Robustness** | In **every individual block** $B \in \{1, 2, 3, 4, 5\}$, the within-block speedup: $$S_B = \frac{\text{Median}(64\text{ MiB, chains } C=1)_B}{\text{Median}(64\text{ MiB, chains } C=4)_B}$$ will strictly exceed $3.0\times$ ($S_B > 3.00\times$). | Any individual block where $S_B \le 3.00\times$ falsifies H9 and demonstrates that host performance shifts can compress apparent MLP speedup. |

---

## 5. Experimental Design & Parameters

### Focal Configurations (4 Configurations)
1. **Config 1 (`32K_chase`):** Small Tier (32 KiB / 4,096 elements), `chase` mode, `WORK_COUNT = 2,000,000` (Command: `./memory_lab chase 4096 2000000 5`)
2. **Config 2 (`32K_chains_c1`):** Small Tier (32 KiB / 4,096 elements), `chains` mode, $C=1$, `WORK_COUNT = 2,000,000` (Command: `./memory_lab chains 4096 2000000 5 1`)
3. **Config 3 (`64M_chains_c1`):** Large Tier (64 MiB / 8,388,608 elements), `chains` mode, $C=1$, `WORK_COUNT = 2,000,000` (Command: `./memory_lab chains 8388608 2000000 5 1`)
4. **Config 4 (`64M_chains_c4`):** Large Tier (64 MiB / 8,388,608 elements), `chains` mode, $C=4$, `WORK_COUNT = 2,000,000` (Command: `./memory_lab chains 8388608 2000000 5 4`)

### Block Structure & Process Accounting
- **Number of Blocks:** 5 blocks ($B \in \{1, 2, 3, 4, 5\}$).
- **Process Launches per Block:** 4 independent OS process invocations (one per focal configuration).
- **Total Process Launches:** 4 configurations $\times$ 5 blocks = **20 independent process launches**.
- **Timed Repetitions per Process:** 5 repetitions (`repeats = 5`).
- **Total Planned Data Rows:** 20 process launches $\times$ 5 repetitions = **100 data rows**.
- **Base Seed:** Fixed at `12345ULL` across all configurations for deterministic cycle generation.

---

## 6. Predefined Reproducible Execution Schedule

Configurations within each block are randomized using a fixed pseudorandom seed (`20261016`). The complete execution sequence is predefined below and will be executed strictly without dynamic reordering:

| Global Step | Block | Block Step | Configuration | Working Set | Mode & Chains | Command Line String |
|---|---|---|---|---|---|---|
| **1** | Block 1 | Step 1 | **Config 1** | 32 KiB | `chase` | `./memory_lab chase 4096 2000000 5` |
| **2** | Block 1 | Step 2 | **Config 4** | 64 MiB | `chains`, $C=4$ | `./memory_lab chains 8388608 2000000 5 4` |
| **3** | Block 1 | Step 3 | **Config 3** | 64 MiB | `chains`, $C=1$ | `./memory_lab chains 8388608 2000000 5 1` |
| **4** | Block 1 | Step 4 | **Config 2** | 32 KiB | `chains`, $C=1$ | `./memory_lab chains 4096 2000000 5 1` |
| **5** | Block 2 | Step 1 | **Config 4** | 64 MiB | `chains`, $C=4$ | `./memory_lab chains 8388608 2000000 5 4` |
| **6** | Block 2 | Step 2 | **Config 1** | 32 KiB | `chase` | `./memory_lab chase 4096 2000000 5` |
| **7** | Block 2 | Step 3 | **Config 2** | 32 KiB | `chains`, $C=1$ | `./memory_lab chains 4096 2000000 5 1` |
| **8** | Block 2 | Step 4 | **Config 3** | 64 MiB | `chains`, $C=1$ | `./memory_lab chains 8388608 2000000 5 1` |
| **9** | Block 3 | Step 1 | **Config 2** | 32 KiB | `chains`, $C=1$ | `./memory_lab chains 4096 2000000 5 1` |
| **10** | Block 3 | Step 2 | **Config 4** | 64 MiB | `chains`, $C=4$ | `./memory_lab chains 8388608 2000000 5 4` |
| **11** | Block 3 | Step 3 | **Config 3** | 64 MiB | `chains`, $C=1$ | `./memory_lab chains 8388608 2000000 5 1` |
| **12** | Block 3 | Step 4 | **Config 1** | 32 KiB | `chase` | `./memory_lab chase 4096 2000000 5` |
| **13** | Block 4 | Step 1 | **Config 2** | 32 KiB | `chains`, $C=1$ | `./memory_lab chains 4096 2000000 5 1` |
| **14** | Block 4 | Step 2 | **Config 4** | 64 MiB | `chains`, $C=4$ | `./memory_lab chains 8388608 2000000 5 4` |
| **15** | Block 4 | Step 3 | **Config 1** | 32 KiB | `chase` | `./memory_lab chase 4096 2000000 5` |
| **16** | Block 4 | Step 4 | **Config 3** | 64 MiB | `chains`, $C=1$ | `./memory_lab chains 8388608 2000000 5 1` |
| **17** | Block 5 | Step 1 | **Config 2** | 32 KiB | `chains`, $C=1$ | `./memory_lab chains 4096 2000000 5 1` |
| **18** | Block 5 | Step 2 | **Config 4** | 64 MiB | `chains`, $C=4$ | `./memory_lab chains 8388608 2000000 5 4` |
| **19** | Block 5 | Step 3 | **Config 3** | 64 MiB | `chains`, $C=1$ | `./memory_lab chains 8388608 2000000 5 1` |
| **20** | Block 5 | Step 4 | **Config 1** | 32 KiB | `chase` | `./memory_lab chase 4096 2000000 5` |

### Procedural Pause Control
- A uniform **2.0-second quiescent sleep** will be executed between consecutive process launches.
- *Methodological Qualification:* This pause is a procedural spacing control to permit clean OS process termination and buffer flushing; it is **NOT** assumed or described as evidence that temperature, CPU frequency, or hypervisor thread scheduling has stabilized.

### Schedule Properties & Temporal Confounding Qualification
- **Block Balance vs. Position Balance:** Each of the 4 configurations appears exactly once per block across all 5 blocks. However, within-block execution position is determined by the PRNG seed (`20261016`) and is not evenly balanced across positions (e.g., Config 2 occupies Step 1 in blocks 3, 4, and 5; Config 4 occupies Step 2 in blocks 1, 3, 4, and 5).
- **Reduction, Not Elimination, of Confounding:** Interleaving configurations across 5 blocks substantially reduces the monotonic ordering bias present in the continuous ascending sweeps of EXP-01 and EXP-02; it does not eliminate all temporal confounding.
- **Descriptive Status of H8:** H8 is an observational summary of between-block dispersion. Because EXP-02 and EXP-03 have structurally different experimental designs, comparing their variability cannot establish that process launch order caused the verification drift observed in EXP-02.

### Process Independence Qualification
- Launching separate processes guarantees independent virtual address spaces, heap allocations, and Linux process descriptor contexts.
- However, independent guest processes **do not guarantee independent physical execution conditions**, nor do they eliminate WSL2 hypervisor scheduling slices, host background load, or dynamic frequency scaling.

---

## 7. Metric Definitions & Statistical Analysis Plan

### Performance Metrics
1. **Recorded Wall-Clock Time (`seconds`):** Raw duration of kernel execution measured via `std::chrono::steady_clock`.
2. **Total Operations (`operations`):** $\text{WORK\_COUNT} \times C$ pointer hops.
3. **Amortized Time per Operation (`ns_per_operation`):** $(\text{seconds} \times 10^9) / \text{operations}$.
   - *Guardrail:* Reported as amortized wall-clock time per pointer operation; never described as individual physical memory load latency.
4. **Per-Block Summary Statistics:**
   - For each combination of configuration and block $B$, the 5 repetitions are summarized under NumPy Type 7 linear interpolation: $\text{Min}, Q_1, \text{Median}, Q_3, \text{Max}, \text{Range}, \text{IQR}$.
5. **Between-Block Dispersion Metrics:**
   - **Spread:** $\text{Spread}_B = \max_{B}(\text{Median}_B) - \min_{B}(\text{Median}_B) \quad (\text{ns/op})$
   - **Range:** $[\min_{B}(\text{Median}_B), \max_{B}(\text{Median}_B)] \quad (\text{ns/op})$
   - **Coefficient of Variation:** $\text{CV}_B = \frac{\sigma(\text{Medians}_B)}{\mu(\text{Medians}_B)} \times 100\%$
   - **Max Percentage Drift:** $\frac{\max_{B}(\text{Median}_B) - \min_{B}(\text{Median}_B)}{\min_{B}(\text{Median}_B)} \times 100\%$
6. **Kernel Equivalence Percentage Difference ($\Delta_{\text{kernel}}$):**
   $$\Delta_{\text{kernel}} = \frac{\text{Overall Median}(32\text{ KiB, chains } C=1) - \text{Overall Median}(32\text{ KiB, chase})}{\text{Overall Median}(32\text{ KiB, chase})} \times 100\%$$
   Denominator is strictly the overall median of `chase` across all 25 repetitions.
7. **Within-Block Speedup ($S_B$):**
   $$S_B = \frac{\text{Median}(64\text{ MiB, chains } C=1)_B}{\text{Median}(64\text{ MiB, chains } C=4)_B}$$
   Evaluated strictly using the paired medians within the same execution block $B$.

---

## 8. Epistemological Boundary

### What Can Be Concluded from Wall-Clock Timings Alone
- Quantitative verification of whether `chains C=1` matches `chase` within $\pm 5.0\%$ practical equivalence at 32 KiB.
- Descriptive characterization of between-block spread and run-to-run dispersion across independent process invocations.
- Verification of whether $C=4$ MLP speedup remains $> 3.0\times$ within every individual block under varying system conditions.

### What CANNOT Be Concluded (Requires PMU Counters / Host Instrumentation)
- We cannot attribute differences to physical Performance-core vs. Efficient-core scheduling.
- We cannot measure instantaneous core clock frequencies or thermal throttling.
- We cannot claim measured counts of Line Fill Buffer occupancy, cache misses, or memory bus transactions.

---

## 9. Execution, Integrity & Failure Handling Safeguards

1. **Preflight File Separation & Absence Check:**
   - Raw output CSV: [`lab-notebook/raw/EXP-20261016-03-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-primary.csv)
   - Sweep execution log: [`lab-notebook/raw/EXP-20261016-03-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-sweep.log)
   - Preflight check confirms both files are currently absent.
2. **Planned vs. Completed Row Accounting:**
   - Exactly 100 data rows are planned (20 launches $\times$ 5 repetitions).
   - If a process launch fails (non-zero exit code or timeout), the event, command, exit code, and error stream will be logged in `sweep.log`.
   - **No silent retries or row replacement:** Failed launches will be disclosed as incomplete blocks; observations will never be fabricated, imputed, or discarded.
3. **Preservation of Existing Artifacts:**
   - `src/memory_lab.cpp` SHA-256: `b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`
   - `memory_lab` binary SHA-256: `9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0`
   - Existing CSVs, logs, and experiment records for EXP-01 and EXP-02 remain untouched.
4. **Deterministic Checksum Regression Expectations:**
   - 32 KiB `chase`: `1923`
   - 32 KiB `chains C=1`: `1923`
   - 64 MiB `chains C=1`: `14274912`
   - 64 MiB `chains C=4`: `14274912`
   - *Epistemological Qualification:* These values are **expected regression-check values observed in prior benchmark runs**, not mathematical proof of algorithm correctness.
   - *Failure Safeguard:* Any checksum divergence indicates an unexpected pointer graph traversal state. A mismatch must stop the run immediately, preserve the failing command's complete stdout/stderr and exit status in `sweep.log`, and must **NOT** trigger an automatic retry or silent replacement of the observation.
5. **Raw CSV Collection, Header Handling, and Schedule Mapping:**
   - **Binary Output Behavior:** Each invocation of `memory_lab` emits a 1-line CSV header (`mode,elements,working_set_bytes,work_count,chains,repeat,seconds,operations,ns_per_operation,nominal_bytes,checksum`) followed by 5 data rows (one per repetition, `rep=0` through `rep=4`).
   - **Runner Header Handling:** The orchestrator writes a single canonical CSV header once when creating [`lab-notebook/raw/EXP-20261016-03-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-primary.csv). For each process launch, the runner strips the per-process emitted header from stdout, validates that exactly 5 data rows were produced, and appends those 5 data rows to `primary.csv`. This avoids repeated header lines while preserving the binary's native 11-column CSV schema.
   - **Complete Provenance in Sweep Log:** The raw, unstripped stdout (including the per-launch header) and stderr, along with command string, timestamp, and exit status, are preserved in full in [`lab-notebook/raw/EXP-20261016-03-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-03-sweep.log). Malformed output is never silently repaired.
   - **Row-to-Schedule Mapping:** Exactly 100 data rows are produced across the 20 launches (5 timed observations per launch). Each 1-indexed data row $i \in [1, 100]$ in `primary.csv` maps unambiguously to the fixed 20-step schedule:
     - Schedule Step index: $S = \lfloor(i - 1) / 5\rfloor + 1 \in [1, 20]$
     - Repetition index: $R = (i - 1) \pmod 5 \in [0, 4]$
     - Block, Block Step, Working Set, Mode, and Chains are looked up directly from Step $S$ of the Section 6 schedule table.
   - **Integrity Assertion:** If any launch returns a non-zero exit code or emits anything other than exactly 5 data rows, execution halts immediately; no observations will be fabricated, imputed, or silently replaced.

---

## 10. Stop Condition

Execution will **NOT** begin until this draft protocol is reviewed, revised as necessary, and explicitly authorized by the user.
