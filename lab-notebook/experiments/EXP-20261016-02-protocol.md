# Experiment Protocol — EXP-20261016-02 (Revision 2.0)

**Experiment Title:** Investigating Memory-Level Parallelism (MLP) via Multi-Chain Pointer Traversal (`chains` mode)  
**Initial Pre-registration:** 2026-10-16T15:50:00Z (Rev 1.0)  
**Protocol Revision 2.0:** 2026-10-16T15:58:00Z  
**Status:** Pre-registered Protocol — Ready for Execution Approval
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
| **1.0** | 2026-10-16T15:50:00Z | Initial pre-registration protocol covering 15 primary configurations across 3 working sets and 5 chain counts ($C \in \{1, 2, 4, 8, 16\}$). |
| **2.0** | 2026-10-16T15:58:00Z | **Final Methodological Refinements:**<br>1. *Working-Set Tier Terminology:* Replaced categorical labels ("L1d-resident," "L2-resident," "DRAM-spanning") with descriptive tier labels: **small working-set tier (32 KiB)**, **intermediate working-set tier (1 MiB)**, and **large working-set tier (64 MiB)**. Reframed nominal cache capacities (48 KiB L1d, 2 MiB L2, 30 MiB L3 from `lscpu`) as architectural hypotheses rather than guaranteed physical residency.<br>2. *Detailed Timing Boundary & Kernel Cost Breakdown:* Verified and documented all costs inside vs. outside the timed interval directly from source code, specifically detailing the heap vector allocation/deallocation (`operator new[]`/`delete[]`), initialization, and inner-loop branching inside `chains_kernel`.<br>3. *Outcome Metrics Definition:* Predefined the primary outcome as median `ns/op` and secondary outcome as speedup relative to $C=1$ within the same working-set tier. Explicitly required reporting total elapsed time (`seconds`) and step time alongside amortized `ns/op` to avoid conflating amortized throughput gains with reduced wall-clock run time.<br>4. *Intra-Mode Comparison Rigor:* Explicitly barred treating $C=1$ in `chains` mode as directly interchangeable with `chase` mode due to differing register/loop/vector mechanics.<br>5. *Clean Divisibility & Traversal Formalization:* Verified exact divisibility for all configurations ($N \pmod C == 0$) and formalized segment construction, independent cycle seeding ($12345+c$), and non-overlapping traversal.<br>6. *Row Accounting Correction:* Corrected CSV row count description in Section 6 to strictly match the 75 primary + 10 verification = 85 total rows. |

---

## 1. Research Question & Pre-Registered Hypotheses

### Research Question
How does varying the number of independent concurrent pointer chains ($C \in \{1, 2, 4, 8, 16\}$) impact elapsed wall-clock execution time, derived amortized latency per operation (`ns_per_operation`), and relative speedup across three representative working-set capacity tiers:
1. **Small Working-Set Tier:** 32 KiB ($4,096$ elements)
2. **Intermediate Working-Set Tier:** 1 MiB ($131,072$ elements)
3. **Large Working-Set Tier:** 64 MiB ($8,388,608$ elements)?

### Pre-Registered Hypotheses
- **Hypothesis H4 (Small Working-Set Tier — 32 KiB: Limited MLP Benefit & Overhead Sensitivity):**
  At 32 KiB (nominally within the reported 48 KiB L1d capacity), single-load latency is already at the physical L1 hit floor (~1.2 ns/op). Because L1 hits complete in $\sim 5$ CPU cycles and the pipeline has ample load-port bandwidth for dependent work, issuing multiple chains will yield negligible latency reduction per operation. Instead, increasing chain count $C$ may slightly *increase* amortized `ns_per_operation` due to loop control instructions, pointer array indexing in memory, and register pressure inside `chains_kernel`.
- **Hypothesis H5 (Large Working-Set Tier — 64 MiB: Significant MLP Latency Hiding):**
  At 64 MiB (well beyond nominal on-chip cache capacities), single-chain pointer chasing incurs high latency (~100 ns/op) because each load stalls waiting for main memory and page translation. Multiple independent chains provide the out-of-order execution engine with an *opportunity* for Memory-Level Parallelism (MLP), enabling multiple concurrent outstanding cache misses to be serviced in parallel by Line Fill Buffers (LFBs) and DRAM channels/banks. Consequently, as $C$ increases from 1 to 2, 4, 8, and 16, amortized `ns_per_operation` will drop significantly (effective speedup relative to $C=1$), up to the concurrency saturation limit of the hardware memory subsystem.
- **Hypothesis H6 (Intermediate Working-Set Tier — 1 MiB: Moderate Concurrency Scaling):**
  At 1 MiB (nominally within the reported 2 MiB L2 capacity), baseline single-chain latency is $\sim 4.6$ ns/op. Multiple independent chains will exhibit moderate concurrency scaling, reducing amortized `ns_per_operation` up to the L1-to-L2 fill buffer limits, yielding a scaling curve intermediate between the small tier plateau and the large tier scaling.

### Methodological Guardrail
> [!IMPORTANT]
> **Opportunity for Parallelism vs. Proven Hardware Overlap:**
> Independent pointer chains provide the *opportunity* for memory-level parallelism. A reduction in wall-clock `ns_per_operation` demonstrates effective throughput improvement, but timing measurements alone do **not** directly measure or prove concurrent hardware bus transactions, DRAM bank concurrency, or Line Fill Buffer occupancy, as hardware PMU counters are unmeasured under WSL2.
> Furthermore, nominal cache capacities (48 KiB L1d, 2 MiB L2, 30 MiB L3) are architectural hypotheses derived from `lscpu`, not guarantees of physical residency.

---

## 2. Kernel Inspection & Timing Boundary Semantics

A direct audit of [`src/memory_lab.cpp`](file:///home/amans/Devfield2/experiment/memory-wall/src/memory_lab.cpp) establishes the exact implementation semantics of `chains_kernel` and distinguishes costs inside versus outside the timed interval:

```cpp
static u64 chains_kernel(const std::vector<std::size_t>& next,
                         std::size_t chain_count,
                         std::size_t steps_per_chain) {
    std::vector<std::size_t> p(chain_count);
    const std::size_t segment = next.size() / chain_count;
    for (std::size_t c = 0; c < chain_count; ++c)
        p[c] = c * segment;

    for (std::size_t step = 0; step < steps_per_chain; ++step)
        for (std::size_t c = 0; c < chain_count; ++c)
            p[c] = next[p[c]];

    u64 sum = 0;
    for (auto value : p) sum += static_cast<u64>(value);
    return sum;
}
```

### Complete Breakdown: Outside vs. Inside the Timed Interval

#### Costs Outside the Timed Interval (Setup Phase)
1. **Argument Parsing & Validation (Lines 101–113):**
   - Command-line arguments parsed: `mode`, `n`, `work`, `repeats`, `chains`, `seed`.
   - Divisibility check: `if (chains > n || n % chains != 0) throw ...`.
2. **Cycle Array Allocation (Line 136):**
   - `next.resize(n)` allocates $N \times \text{sizeof(size\_t)}$ bytes ($32\text{ KiB}$, $1\text{ MiB}$, or $64\text{ MiB}$) on the heap.
3. **Segment Permutation Construction (Lines 137–140):**
   - `const std::size_t segment = n / chains;`
   - For each chain $c \in [0, C-1]$, `make_cycle(next, c * segment, segment, seed + c)` builds an independent cycle over $[c \cdot S, (c+1) \cdot S - 1]$ using seed `12345 + c`.
4. **Untimed Warm-Up Execution (Line 151):**
   - `result_sink = kernel();` executes `chains_kernel(next, chains, work)` once prior to repetition 0. This faults in code and data pages and warms the allocator.
5. **CSV Header Output (Lines 153–155):** Printed once before the timed loop.

#### Costs Inside the Timed Interval (Lines 158–162)
Timing boundaries in `main`:
```cpp
const auto start = Clock::now();
const u64 checksum = kernel();
const double elapsed = std::chrono::duration<double>(Clock::now() - start).count();
result_sink = checksum;
```
Inside `kernel() -> chains_kernel(next, chains, work)`:
1. **Dynamic Heap Vector Allocation:**
   `std::vector<std::size_t> p(chain_count)` calls `operator new(chain_count * sizeof(size_t))` on the heap, value-initializing $C$ elements to 0.
   - *Epistemological Status:* The allocation/deallocation overhead (~20–50 ns total) is an **unmeasured estimate**, not an observed cost. At $W = 2,000,000$ steps ($2,000,000$ to $32,000,000$ total operations), its estimated impact is $< 0.00003$ ns/op, but it is formally documented as an intra-timing cost.
2. **Chain Pointer Initialization:**
   `for (std::size_t c = 0; c < chain_count; ++c) p[c] = c * segment;`
   Initializes the $C$ starting node indices inside the timed region.
3. **Traversal Loop Execution:**
   ```cpp
   for (std::size_t step = 0; step < steps_per_chain; ++step)
       for (std::size_t c = 0; c < chain_count; ++c)
           p[c] = next[p[c]];
   ```
   - Executes $W$ outer iterations. In each iteration, the inner loop advances all $C$ chains by 1 step.
   - For each chain, `p[c]` is loaded from vector heap memory, used as an index into `next`, and written back to `p[c]`.
   - The CPU executes loop increment, boundary comparison, and branch instructions for each chain on every step.
4. **Result Accumulation:**
   `for (auto value : p) sum += static_cast<u64>(value);`
   Sums the final node positions across all $C$ chains.
5. **Dynamic Heap Vector Deallocation:**
   Upon return from `chains_kernel`, vector `p` is destructed and its heap buffer is freed via `operator delete[]` inside the timed region.

#### Costs Outside the Timed Interval (Post-Run Accounting)
- Calculation of `operations = static_cast<double>(work) * chains`.
- Calculation of `ns_per_op = elapsed * 1e9 / operations`.
- Streaming CSV row output to `std::cout`.

### Intra-Mode Comparison Rigor: No Direct Equating with `chase` Mode
> [!WARNING]
> **Do Not Treat $C=1$ in `chains` Mode as Interchangeable with `chase` Mode:**
> In `chase_kernel`, pointer state is a single scalar variable held in a CPU register (`rdx`), compiling to a 2-instruction unrolled loop without heap allocation or inner loop branches. In `chains_kernel` with $C=1$, vector allocation occurs, `p[0]` is read/written to memory, and loop control executes for $c=0$.
> Therefore, $C=1$ in `chains` mode will exhibit slightly different absolute timing than `chase` mode. All MLP scaling analyses must be evaluated **strictly intra-mode relative to $C=1$ within `chains` mode**.

---

## 3. Predefined Outcomes & Metrics

To avoid conflating amortized throughput gains with reduced wall-clock run time, three distinct metrics will be evaluated:

### 1. Primary Outcome: Median Amortized Latency (`ns_per_operation`)
$$\text{ns\_per\_operation} = \frac{\text{seconds} \times 10^9}{\text{WORK\_COUNT} \times \text{CHAINS}}$$
Measures the effective elapsed time per individual pointer dereference serviced across the parallel chains. Summarized as the median across $N=5$ repetitions.

### 2. Secondary Outcome: Intra-Tier MLP Speedup ($S(C)$)
$$\text{Speedup}(C) = \frac{\text{Median ns/op}(C=1)}{\text{Median ns/op}(C)}$$
Evaluated strictly relative to the $C=1$ baseline within the same working-set tier.

### 3. Total Elapsed Time & Derived Step Time Reporting
- **Total Elapsed Wall-Clock Time (`seconds`):** The actual duration of the timed kernel invocation.
- **Derived Step Time (`step_time` in ns):**
  $$\text{step\_time}(C) = \frac{\text{seconds} \times 10^9}{\text{WORK\_COUNT}} = \text{ns\_per\_operation} \times C$$
  > [!IMPORTANT]
  > **Definition & Boundary:** `step_time` is strictly a **derived pace metric** representing the wall-clock time required to advance the outer loop by one step across all $C$ chains. **It is NOT an individual-load latency.** Individual load latency is amortized in `ns_per_operation`.
Because the total number of operations scales linearly with $C$ ($\text{operations} = 2,000,000 \times C$), an amortized throughput improvement (lower `ns/op`) does **not** necessarily imply a reduction in total elapsed wall-clock seconds. Reporting total seconds and derived step time makes this transparent.

---

## 4. Working-Set Partitioning & Clean Divisibility Verification

### Divisibility Verification
The source implementation enforces `if (chains > n || n % chains != 0) throw ...`.
For all three tiers, $N$ divides cleanly by every $C \in \{1, 2, 4, 8, 16\}$:

- **Small Tier ($N = 4,096$ elements, $32,768$ bytes = 32 KiB):**
  - $C=1: S = 4,096 / 1 = 4,096 \implies 4,096 \pmod 1 == 0$
  - $C=2: S = 4,096 / 2 = 2,048 \implies 4,096 \pmod 2 == 0$
  - $C=4: S = 4,096 / 4 = 1,024 \implies 4,096 \pmod 4 == 0$
  - $C=8: S = 4,096 / 8 = 512 \implies 4,096 \pmod 8 == 0$
  - $C=16: S = 4,096 / 16 = 256 \implies 4,096 \pmod{16} == 0$
- **Intermediate Tier ($N = 131,072$ elements, $1,048,576$ bytes = 1 MiB):**
  - $C=1: S = 131,072 / 1 = 131,072 \implies 131,072 \pmod 1 == 0$
  - $C=2: S = 131,072 / 2 = 65,536 \implies 131,072 \pmod 2 == 0$
  - $C=4: S = 131,072 / 4 = 32,768 \implies 131,072 \pmod 4 == 0$
  - $C=8: S = 131,072 / 8 = 16,384 \implies 131,072 \pmod 8 == 0$
  - $C=16: S = 131,072 / 16 = 8,192 \implies 131,072 \pmod{16} == 0$
- **Large Tier ($N = 8,388,608$ elements, $67,108,864$ bytes = 64 MiB):**
  - $C=1: S = 8,388,608 / 1 = 8,388,608 \implies 8,388,608 \pmod 1 == 0$
  - $C=2: S = 8,388,608 / 2 = 4,194,304 \implies 8,388,608 \pmod 2 == 0$
  - $C=4: S = 8,388,608 / 4 = 2,097,152 \implies 8,388,608 \pmod 4 == 0$
  - $C=8: S = 8,388,608 / 8 = 1,048,576 \implies 8,388,608 \pmod 8 == 0$
  - $C=16: S = 8,388,608 / 16 = 524,288 \implies 8,388,608 \pmod{16} == 0$

### Chain Initialization & Disjoint Traversal Mechanics
- Each chain $c \in [0, C-1]$ is assigned an exclusive array segment $[\text{begin}_c, \text{end}_c) = [c \cdot S, (c+1) \cdot S)$.
- `make_cycle` constructs a closed permutation cycle strictly within this range, seeded by $\text{seed}_c = 12345 + c$.
- Chain $c$ starts traversal at node $p[c] = c \cdot S$ (the base of its segment).
- Because $\text{next}[i] \in [c \cdot S, (c+1) \cdot S - 1]$ for all indices in the segment, chain $c$ **never traverses outside its segment**.
- The $C$ chains operate across completely disjoint memory ranges with zero shared nodes or pointer collisions.

---

## 5. Controlled Variables & Execution Parameters

- **Binary:** `./memory_lab` (SHA-256: `9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0`)
- **Source:** `src/memory_lab.cpp` (SHA-256: `b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`)
- **Mode:** `chains`
- **Fixed `WORK_COUNT`:** Uniformly `2,000,000` steps per chain across all configurations
- **Timed Repetitions:** `5` per configuration ($N=5$)
- **Base Seed:** `12345ULL` (deterministic random generator; segment $c$ uses `12345 + c`)
- **Warm-Up:** Single untimed warm-up execution (`result_sink = kernel();`) executed before repetition 0
- **Compiler Flags:** `-O3 -DNDEBUG -march=native -std=c++20 -Wall -Wextra`

---

## 6. Execution Order & Row Accounting

### Primary Sweep Order (Blocked by Tier, Ascending Chains)
Measurements are blocked by working-set capacity tier to isolate memory footprint effects, evaluating ascending chain counts ($C = 1, 2, 4, 8, 16$) within each block:
- **Block 1 (Small Tier — 32 KiB):** Steps 1–5 ($C = 1, 2, 4, 8, 16$) $\implies 25$ data rows
- **Block 2 (Intermediate Tier — 1 MiB):** Steps 6–10 ($C = 1, 2, 4, 8, 16$) $\implies 25$ data rows
- **Block 3 (Large Tier — 64 MiB):** Steps 11–15 ($C = 1, 2, 4, 8, 16$) $\implies 25$ data rows
- **Primary Sweep Total:** 15 commands $\times 5$ repetitions = **75 data rows**

### Post-Sweep Verification Re-test (2 Configurations)
Immediately following Block 3, two configurations will be re-executed with 5 repetitions each to quantify system drift and hysteresis:
- **Step 16 (Verification 1):** Small tier (32 KiB), $C = 1$ (`./memory_lab chains 4096 2000000 5 1`) $\implies 5$ data rows
- **Step 17 (Verification 2):** Large tier (64 MiB), $C = 4$ (`./memory_lab chains 8388608 2000000 5 4`) $\implies 5$ data rows
- **Verification Total:** 2 commands $\times 5$ repetitions = **10 data rows**

### Grand Total Expected Data Rows:
$$75 \text{ (Primary)} + 10 \text{ (Verification)} = \mathbf{85\text{ data rows}}$$

---

## 7. Output File Architecture & Data Segregation

In strict accordance with Rule 01:
- **Execution Log:** [`lab-notebook/raw/EXP-20261016-02-sweep.log`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-sweep.log) (Continuous stream of all stdout, stderr, timestamps, and exit codes)
- **Primary Sweep Raw CSV:** [`lab-notebook/raw/EXP-20261016-02-primary.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-primary.csv) (Strictly 75 primary data rows)
- **Verification Re-test Raw CSV:** [`lab-notebook/raw/EXP-20261016-02-verification.csv`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/EXP-20261016-02-verification.csv) (Strictly 10 verification data rows)
- **Pre-execution Non-Existence Check:** Before launching, verify that none of these three output paths already exist.

---

## 8. Statistical Aggregation & Validation Plan

1. **Quartile Convention:**
   All 5 repetitions for each configuration will be summarized using NumPy Type 7 / R default linear interpolation:
   - $\text{Median} = x_{(2)}$
   - $\text{Min} = x_{(0)}, \quad \text{Max} = x_{(4)}$
   - $Q_1 = x_{(1)}, \quad Q_3 = x_{(3)}$
   - $\text{Range} = x_{(4)} - x_{(0)} \quad (\text{ns/op})$
   - $\text{IQR} = x_{(3)} - x_{(1)} \quad (\text{ns/op})$
2. **Data Integrity Assertions:**
   - Exit status `0` for all 17 commands.
   - Exact row count match (75 primary + 10 verification = 85 total rows).
   - Checksum consistency across repetitions: In `chains` mode, `checksum = sum(p)` after $W$ steps. Checksums must be 100% identical across all 5 repetitions for each configuration.
   - Source and binary SHA-256 match pre-run values.

---

## 9. Limitations & Epistemological Guardrails

1. **Virtualized WSL2 Environment:** Timing is derived from `std::chrono::steady_clock` under guest Linux kernel `6.6.87.2-microsoft-standard-WSL2`. Hardware performance counters (`perf`, PMU events) are unavailable.
2. **No Hardware Concurrency Proof:** While multiple independent chains provide an opportunity for out-of-order execution to overlap requests, we do not claim direct measurement of physical bus transactions, memory controller queue depths, or Line Fill Buffer states.
3. **Core Allocation Unknowns:** Thread scheduling across physical P-cores (Golden Cove) vs. E-cores (Gracemont) cannot be determined from within WSL2.

---

> [!IMPORTANT]
> **Approval Gate:** This protocol is strictly pre-registered. No benchmark commands will be executed until the user explicitly reviews and approves this document.
