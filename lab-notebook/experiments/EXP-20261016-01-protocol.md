# Experiment Protocol — EXP-20261016-01 (Revision 3.0)

**Experiment Title:** Working-Set Size Latency Sweep using Dependent Pointer Chasing (`chase` mode)  
**Initial Pre-registration:** 2026-10-16T14:30:23Z (Rev 1.0)  
**Revision 2.0:** 2026-10-16T14:37:25Z  
**Final Protocol Revision 3.0:** 2026-10-16T14:45:46Z  
**Status:** Pre-registered Protocol (Final Revision — Awaiting Approval to Execute)  
**Governing Documents:**
- [`AGENT.md`](file:///home/amans/Devfield2/experiment/memory-wall/AGENT.md)
- [`.agent/rules/01-evidence-and-logging.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/rules/01-evidence-and-logging.md)
- [`.agent/rules/02-safe-tool-use.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/rules/02-safe-tool-use.md)
- [`.agent/workflows/run-experiment.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/workflows/run-experiment.md)
- [`.agent/templates/experiment-record.md`](file:///home/amans/Devfield2/experiment/memory-wall/.agent/templates/experiment-record.md)

---

## Revision History & Audit Notes

| Revision | Timestamp | Summary of Changes |
|---|---|---|
| **1.0** | 2026-10-16T14:30:23Z | Initial draft protocol with 13 working-set sizes and uniform `WORK_COUNT = 2,000,000`. |
| **2.0** | 2026-10-16T14:37:25Z | Addressed traversal coverage, warm-up boundaries, test ordering, repetition non-independence, cache provenance, and corrected source line references (192-line file). |
| **3.0** | 2026-10-16T14:45:46Z | **Final methodological refinements:**<br>1. *Cycle Prefix Wording:* Clarified that traversal is a deterministic prefix of a pseudorandomly generated cycle; identified virtual page/cache-line coverage estimates strictly as probabilistic expectations, not measured facts.<br>2. *Page Coverage vs. TLB Misses:* Decoupled virtual page touching from TLB miss occurrence; emphasized that page touching does not directly measure TLB miss penalties.<br>3. *Row Accounting & Output Segregation:* Formally reconciled data row count: 65 primary sweep rows ($13 \times 5$) + 10 post-sweep verification rows ($2 \times 5$) = 75 total expected data rows. Segregated primary and verification outputs into dedicated CSV files.<br>4. *Explicit IQR Convention:* Documented exact NumPy Type 7 / R default linear interpolation formula for $N=5$ observations ($Q_1 = x_{(1)}$, $Q_3 = x_{(3)}$, $\text{IQR} = x_{(3)} - x_{(1)}$).<br>5. *Evidence Integrity:* Re-confirmed source/binary SHA-256 hashes and pre-verified non-existence of destination log/CSV files. |

---

## 1. Research Question and Refined Hypotheses

### Research Question
How does the elapsed wall-clock time per dependent pointer traversal change as the allocated working set increases from small sizes (16 KiB) up to 64 MiB?

### Refined Pre-Registered Hypotheses
1. **Hypothesis H1 (Low-Latency Plateau at Small Working Sets):**
   When working-set sizes are small (16 KiB and 32 KiB, well within the 48 KiB L1d reported by `lscpu`), the memory access latency per dependent step will remain minimal and relatively flat (~1–4 ns/step), reflecting high hit rates in primary on-core cache storage.
2. **Hypothesis H2 (Multi-Stage Latency Regimes):**
   As working-set size increases across several orders of magnitude (from 16 KiB to 64 MiB), elapsed time per operation will increase, exhibiting one or more upward inflection regions or regimes. These transitions are consistent with the working set exceeding the effective capacities of successive levels of the cache hierarchy (L1d, L2, L3).
   - *Guardrail:* The transition is not assumed to align with exact nominal cache boundaries. A smooth or gradual increase does **not** disprove cache effects, as associativity conflicts, set-indexing hash behavior, and partial cache residency can blur transition boundaries.
3. **Hypothesis H3 (Large-Scale Footprint and Address Translation Influences):**
   At larger working sets (e.g. 16 MiB to 64 MiB), the pointer chain traverses an array spanning thousands of distinct 4 KiB virtual pages. In this regime, the latency per dependent operation may reflect compound overheads, including memory hierarchy traversal and potential address translation overheads (such as TLB miss penalties and page-table walks).
   - *Guardrail:* Touching a virtual page does **not** directly measure or prove a TLB miss. Timing measurements alone cannot isolate or quantify the proportion of latency attributable to TLB misses versus cache misses.
4. **Falsification Criteria:**
   - If time per operation remains completely flat across 16 KiB to 64 MiB, H2 is falsified (indicating either compiler optimization/vectorization circumventing the pointer dependency or instrumentation failure).
   - If time per operation drops significantly at large working-set sizes without an architectural explanation, the hypothesis of hierarchical memory constraint is unsupported.

---

## 2. Source Code Timing, Traversal & Accounting Semantics

A direct audit of [`src/memory_lab.cpp`](file:///home/amans/Devfield2/experiment/memory-wall/src/memory_lab.cpp) (192 lines, SHA-256: `b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`) establishes the exact kernel semantics:

### A. Cycle Construction & Starting-State
- **Allocation & Shuffle (Lines 116–140):**
  ```cpp
  if (mode == "chase") {
      next.resize(n);
      make_cycle(next, 0, n, seed);
  }
  ```
  `make_cycle` constructs a single random Hamiltonian cycle of length $n$ containing all indices $0 \dots n-1$ via `std::iota` and `std::shuffle` with `std::mt19937_64(seed)`.
- **Kernel Starting-State (Lines 59–65):**
  ```cpp
  static u64 chase_kernel(const std::vector<std::size_t>& next,
                          std::size_t accesses) {
      std::size_t p = 0;
      for (std::size_t i = 0; i < accesses; ++i)
          p = next[p];
      return static_cast<u64>(p);
  }
  ```
  `chase_kernel` **always starts at `p = 0`**.
  Because `seed = 12345` is fixed and deterministic, the sequence of node addresses visited from `p = 0` is strictly identical across every invocation and repetition for a given size $n$.

### B. Traversal Coverage: Working-Set Size vs. Traversal Steps
On this x86-64 platform, `sizeof(std::size_t) == 8` bytes.
`ELEMENTS` ($n$) defines the allocated array size: $\text{working\_set\_bytes} = n \times 8$.
`WORK_COUNT` is fixed at $2,000,000$ steps for all sizes.

The relationship between allocated elements $n$ and traversal steps ($2,000,000$) falls into two distinct operational regimes:

1. **Cycle Recycling Regime ($n < 2,000,000$ steps):**
   - **Sizes 16 KiB to 8 MiB** ($n = 2,048$ to $n = 1,048,576$ elements).
   - Traversal steps exceed cycle length. The single cycle is traversed multiple times:
     - 16 KiB ($n = 2,048$): $2,000,000 / 2,048 \approx 976.6$ full traversals.
     - 1 MiB ($n = 131,072$): $2,000,000 / 131,072 \approx 15.3$ full traversals.
     - 8 MiB ($n = 1,048,576$): $2,000,000 / 1,048,576 \approx 1.91$ traversals.
   - *Implication:* Every element in the allocated working set is visited at least once (and smaller sets hundreds of times). The measured time reflects repeated, steady-state traversal over the entire allocated dataset.

2. **Sub-Cycle Traversal Regime ($n > 2,000,000$ steps):**
   - **Sizes 32 MiB and 64 MiB** ($n = 4,194,304$ and $n = 8,388,608$ elements).
   - Traversal steps are *fewer* than the number of allocated elements:
     - 32 MiB ($n = 4,194,304$): $2,000,000 / 4,194,304 \approx 47.7\%$ of the cycle is traversed.
     - 64 MiB ($n = 8,388,608$): $2,000,000 / 8,388,608 \approx 23.8\%$ of the cycle is traversed.
   - *Precise Characterization:* The traversal executes a **deterministic prefix of $2,000,000$ steps** along a pseudorandomly generated permutation cycle starting from `p = 0`.
   - *Probabilistic Footprint Expectation (Not Measured Hardware Coverage):* Under the theoretical assumption of uniform random permutations, visiting $2,000,000$ distinct nodes across $16,384$ virtual 4 KiB pages (512 nodes/page) is probabilistically expected to access nearly all virtual pages (expected average $\sim 122$ accesses per page). However, this is an analytical expectation based on random sampling models, **not directly measured page-table or hardware cache-line trace data**.

### C. Distinguishing Virtual Page Touching from TLB Misses
- **Touching a Virtual Page:** Occurs whenever the CPU calculates an effective address whose upper bits correspond to that 4 KiB virtual page frame.
- **Incurring a TLB Miss:** Occurs only when the virtual-to-physical translation for that page is absent from the L1 Data TLB (DTLB) and L2 unified TLB (STLB) at the exact moment the translation is looked up.
- **Methodological Rule:** Even if a traversal pattern touches thousands of distinct virtual pages over $2,000,000$ steps, the actual occurrence of TLB misses depends dynamically on TLB capacity, associativity, replacement state, and temporal re-access intervals. **Virtual page touching does not measure, prove, or equate to TLB misses.**

### D. Warm-Up Semantics and Limitations
- **Code Location:** Line 151 of `src/memory_lab.cpp` executes:
  ```cpp
  result_sink = kernel();
  ```
- **What Warm-Up Does:**
  It executes `chase_kernel(next, 2000000)` starting from `p = 0`.
  - For $n \le 1,048,576$ (16 KiB to 8 MiB), warm-up traverses the entire array, pre-faulting pages and establishing cache residency.
  - For 32 MiB and 64 MiB, warm-up traverses *only the first 2,000,000 steps* along the cycle from `p = 0`.
- **What Warm-Up DOES NOT Do:**
  Warm-up does **not** touch the remaining nodes ($2,194,304$ nodes in 32 MiB; $6,388,608$ nodes in 64 MiB).
- **Key Repeatability Guarantee:**
  Because timed repetitions 0, 1, 2, 3, 4 also start at `p = 0` and execute $2,000,000$ steps, they traverse the **exact same deterministic sequence of 2,000,000 nodes** as the warm-up run. Therefore, page faults for this active sequence are completed during warm-up, and repetitions measure steady-state repeated-use traversal of that active subgraph.

### E. Timed Boundary & Accounting Correctness
- **Timed Region (Lines 158–162):**
  ```cpp
  const auto start = Clock::now();
  const u64 checksum = kernel();
  const double elapsed = std::chrono::duration<double>(Clock::now() - start).count();
  result_sink = checksum;
  ```
  Only the traversal kernel is timed. Allocation, cycle generation, and warm-up are strictly outside the timer.
- **Operations Accounting (Line 173):**
  `operations = static_cast<double>(work);` ($2,000,000$ operations).
  `nominal_bytes = operations * sizeof(std::size_t);` ($16,000,000$ bytes).
- **Checksum Integrity:** `result_sink` is declared `static volatile u64 result_sink = 0;` (line 14), preventing dead-code elimination. The final pointer index returned by `chase_kernel` is deterministic and verified across all repetitions.

---

## 3. Environment & Cache Specifications Provenance

### A. Observations from Environment Check (`lscpu` inside WSL2)
From [`preflight-readonly-20261016T132839Z.txt`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/preflight-readonly-20261016T132839Z.txt):
- OS: Ubuntu 24.04.4 LTS on WSL2 (Kernel `6.6.87.2-microsoft-standard-WSL2`).
- CPU string: `Intel(R) Core(TM) i7-14650HX`.
- Reported by `lscpu`:
  - L1d cache: 576 KiB total (12 instances @ 48 KiB/instance).
  - L1i cache: 384 KiB total (12 instances @ 32 KiB/instance).
  - L2 cache: 24 MiB total (12 instances @ 2 MiB/instance).
  - L3 cache: 30 MiB total (1 shared instance).

### B. Provenance & Verification Status (Physical vs. Virtual)
- **Verified Fact:** The values above are the exact cache capacities reported to the Linux kernel by the Microsoft WSL2 hypervisor.
- **Unverified Hardware Nuance:**
  - Physical Intel Core i7-14650HX is a hybrid architecture: 8 Performance-cores (P-cores with 48 KiB L1d, 2 MiB L2 each) and 8 Efficient-cores (E-cores with 32 KiB L1d each, sharing 4 MiB L2 per cluster).
  - The hypervisor abstracts this topology into 12 symmetric virtual cores with uniform 48 KiB L1d and 2 MiB L2.
  - From inside WSL2, we **cannot verify** whether the thread running `./memory_lab` executes on a physical P-core, an E-core, or migrations between them scheduled by Windows.
  - Therefore, nominal cache boundaries (48 KiB, 2 MiB, 30 MiB) must be treated as **reference models**, not guaranteed physical boundaries for any individual run.

---

## 4. Execution Protocol & Reconciled Row Accounting

### A. Execution Sequence (Primary Sweep + Verification Re-test)

| Phase | Step # | Configuration | Elements ($n$) | Target Size | Work Count | Repetitions | Expected Rows |
|---|---|---|---|---|---|---|---|
| **Primary** | 1 | `chase 2048 2000000 5` | 2,048 | 16 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 2 | `chase 4096 2000000 5` | 4,096 | 32 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 3 | `chase 8192 2000000 5` | 8,192 | 64 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 4 | `chase 16384 2000000 5` | 16,384 | 128 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 5 | `chase 32768 2000000 5` | 32,768 | 256 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 6 | `chase 65536 2000000 5` | 65,536 | 512 KiB | 2,000,000 | 5 | 5 |
| **Primary** | 7 | `chase 131072 2000000 5` | 131,072 | 1 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 8 | `chase 262144 2000000 5` | 262,144 | 2 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 9 | `chase 524288 2000000 5` | 524,288 | 4 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 10 | `chase 1048576 2000000 5` | 1,048,576 | 8 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 11 | `chase 2097152 2000000 5` | 2,097,152 | 16 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 12 | `chase 4194304 2000000 5` | 4,194,304 | 32 MiB | 2,000,000 | 5 | 5 |
| **Primary** | 13 | `chase 8388608 2000000 5` | 8,388,608 | 64 MiB | 2,000,000 | 5 | 5 |
| **Primary Subtotal** | — | **13 Sizes** | — | — | — | — | **65 rows** |
| **Verification** | 14 | `chase 2048 2000000 5` | 2,048 | 16 KiB (Re-test) | 2,000,000 | 5 | 5 |
| **Verification** | 15 | `chase 131072 2000000 5` | 131,072 | 1 MiB (Re-test) | 2,000,000 | 5 | 5 |
| **Verification Subtotal** | — | **2 Re-tests** | — | — | — | — | **10 rows** |
| **Total Experiment** | — | **15 Invocations** | — | — | — | — | **75 rows** |

### B. Output Segregation & File Hygiene
To prevent ambiguity between primary sweep measurements and post-sweep verification measurements, results will be captured in distinct, dedicated files:
1. **Primary Sweep CSV:** `lab-notebook/raw/EXP-20261016-01-primary.csv` (contains exactly 65 data rows from Steps 1–13).
2. **Verification CSV:** `lab-notebook/raw/EXP-20261016-01-verification.csv` (contains exactly 10 data rows from Steps 14–15).
3. **Combined Log:** `lab-notebook/raw/EXP-20261016-01-sweep.log` (captures complete terminal stdout/stderr for all 15 invocations).
4. **Pre-Run Overwrite Guard:** The execution harness will assert that none of these destination files exist prior to launch.

---

## 5. Repetition Interpretation & Explicit Statistical Definitions

### A. Nature of Repetitions
The 5 repetitions within each `./memory_lab` execution run sequentially in the same process loop:
- They are **not** fully independent experiments: they share heap allocation, virtual memory mappings, CPU thread affinity, and cache state from the prior repetition.
- They measure **within-process measurement stability**, not independent trial variance across system reboots or separate process instances.

### B. Explicit Quartile & Dispersion Convention for $N = 5$ Observations
For $N = 5$ observations sorted in ascending order:
$$x_{(0)} \le x_{(1)} \le x_{(2)} \le x_{(3)} \le x_{(4)}$$
We adopt the **NumPy default / R Type 7 linear interpolation convention**, which evaluates directly to integer indices for $N=5$:
- **Median ($Q_2$):** $x_{(2)}$ (the 3rd observation).
- **Lower Quartile ($Q_1$):** $x_{(1)}$ (index $p = 0.25 \times (5 - 1) = 1.0$).
- **Upper Quartile ($Q_3$):** $x_{(3)}$ (index $p = 0.75 \times (5 - 1) = 3.0$).
- **Interquartile Range (IQR):**
  $$\text{IQR} = Q_3 - Q_1 = x_{(3)} - x_{(1)}$$
- **Total Range:**
  $$\text{Range} = x_{(4)} - x_{(0)}$$

This exact convention will be applied uniformly across all 13 primary sizes and the 2 verification configurations.

### C. Data Retention Policy
In accordance with Rule 01, **all 75 raw repetition data rows will be retained and presented**. No anomalous rows will be discarded, censored, or tuned away. If spread is elevated, plausible confounders (e.g. context switching) will be documented.

---

## 6. Limitations & Claims Guardrails

1. **No Hardware PMU Counters:** WSL2 in this environment exposes zero CPU PMU counters (`perf` unavailable, exit status 2). We cannot measure hardware cache-miss events or memory bus cycles directly.
2. **Timing Is Not Proven Topology:** A change in slope near 48 KiB, 2 MiB, or 30 MiB is consistent with cache boundaries, but timing alone does not prove hardware cache hit/miss locations.
3. **No DRAM Traffic Claim:** We do not claim that working sets exceeding 30 MiB (e.g. 64 MiB) exclusively reach DRAM, nor do we describe nominal source bytes as measured DRAM bus traffic.

---

## 7. Final Readiness Checklist

- [x] Traversal coverage characterized as a deterministic prefix of a pseudorandom cycle.
- [x] Page touching explicitly decoupled from TLB miss occurrence.
- [x] Reconciled data row count: 65 primary + 10 verification = 75 total expected rows.
- [x] Segregated output paths defined (`EXP-20261016-01-primary.csv` and `EXP-20261016-01-verification.csv`).
- [x] Explicit NumPy Type 7 / R default quartile convention ($x_{(3)} - x_{(1)}$) documented.
- [x] Pre-checked that no output files exist to avoid overwrite.
- [x] Source SHA-256 (`b4a2b262...`) and binary SHA-256 (`9c71a098...`) verified.
- [ ] User review and explicit approval to execute the sweep.
