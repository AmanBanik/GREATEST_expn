# Compiler-Generated Assembly Inspection Report

**Date/Time:** 2026-10-16T14:20:00Z  
**Compiler:** GCC 13.3.0 (`g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`)  
**Compile Flags:** `-O3 -DNDEBUG -march=native -std=c++20 -S -masm=intel`  
**Source File:** [`src/memory_lab.cpp`](file:///home/amans/Devfield2/experiment/memory-wall/src/memory_lab.cpp) (SHA-256: `b4a2b26240633d4546295f2c1b7996ea283aa49a5e4b9fc27fefc836b0bb9e2b`)  
**Assembly File:** [`results/memory_lab.s`](file:///home/amans/Devfield2/experiment/memory-wall/results/memory_lab.s) (SHA-256: `74dd7b0c7c8b046afffdfef9d6fcfcfbb068a16617b48bb150b6bb30493db592`, 3,623 lines, 75,399 bytes)  
**Binary Reference:** [`memory_lab`](file:///home/amans/Devfield2/experiment/memory-wall/memory_lab) (SHA-256: `9c71a0984e4001bac4a60b6bfcfbcce9e0cd1e760e9024dafc9a042c8cb390a0`)  
**Raw Evidence:** [`lab-notebook/raw/assembly-generation-20261016T141951Z.txt`](file:///home/amans/Devfield2/experiment/memory-wall/lab-notebook/raw/assembly-generation-20261016T141951Z.txt)

---

## 1. Summary of Compiler Optimization & Inlining

At `-O3 -DNDEBUG -march=native -std=c++20`:
1. `stream_kernel`, `chase_kernel`, and `random_kernel` are declared static and are completely **inlined** into `main` inside the repetition timing loop (around the calls to `std::chrono::_V2::steady_clock::now`).
2. `chains_kernel` is emitted as a distinct non-inlined function symbol (`_ZL13chains_kernelRKSt6vectorImSaImEEmm`, lines 28–235) and called via `call _ZL13chains_kernelRKSt6vectorImSaImEEmm` inside `main` (lines 2758 and 2920).

---

## 2. Kernel-by-Kernel Assembly Analysis

### A. Sequential Streaming (`stream`)
- **Assembly Location:** Lines 2950–2989 in `results/memory_lab.s`.
- **Inner Loop (`.L312`):**
  ```assembly
  .L312:
      vpaddq   ymm0, ymm0, YMMWORD PTR [rax]
      add      rax, 32
      cmp      rax, r12
      jne      .L312
  ```
- **Vector Reduction:** Lines 2965–2970 extract 128-bit halves from `ymm0` and accumulate across 64-bit lanes into scalar `rbx`. Remainder elements are processed in a scalar unrolled loop (`.L311`, lines 2974–2984).
- **Instruction-Level Findings (What the assembly establishes):**
  - **AVX2 SIMD Vectorization:** GCC vectorized the 64-bit integer addition using 256-bit AVX2 registers (`ymm0`), reading 4 64-bit words (32 bytes) per iteration.
  - **Strictly Contiguous Linear Access:** Memory addresses advance linearly by 32 bytes (`add rax, 32`).
  - **Zero Data-Dependent Addresses:** Address calculation (`rax + 32`) does not depend on memory contents. The processor can compute all upcoming load addresses unconditionally.
- **Hardware Caveats (What the assembly DOES NOT establish):**
  - Does NOT establish whether loads hit L1d, L2, L3, or DRAM. The `vpaddq` instruction opcode is identical whether data is in cache or in memory.
  - Does NOT prove hardware prefetching occurs, although the sequential linear stride is optimal for triggering the CPU's spatial/stream prefetchers.
  - Does NOT establish DRAM bus utilization or bandwidth limits.

---

### B. Dependent Pointer Chasing (`chase`)
- **Assembly Location:** Lines 2288–2295 in `results/memory_lab.s`.
- **Timed Inner Loop (`.L323`):**
  ```assembly
  .L323:
      add      rax, 1
      mov      rbx, QWORD PTR [rdx+rbx*8]
      cmp      r15, rax
      jne      .L323
  ```
- **Instruction-Level Findings (What the assembly establishes):**
  - **True Serial Dependency Chain:** In `mov rbx, QWORD PTR [rdx+rbx*8]`, the loaded value `rbx` becomes the index for the next load in the next iteration.
  - **Strictly Zero Memory-Level Parallelism (MLP):** The CPU cannot compute the target address of load $i+1$ until load $i$ has completed and returned its data.
  - **No SIMD Vectorization or Compiler Transformation:** The compiler cannot unroll or vectorize this loop because each load address is data-dependent on the prior load.
  - **Minimal Instruction Overhead:** Exactly 4 instructions per iteration (`add`, `mov`, `cmp`, `jne`).
- **Hardware Caveats (What the assembly DOES NOT establish):**
  - Does NOT establish whether loads hit L1d, L2, L3, or DRAM. If the cycle fits entirely within L1d (e.g., 32 KiB), all loads in `.L323` hit L1d at ~4–5 CPU cycles. If the working set is 64 MiB, loads will miss L3 and traverse the memory controller.
  - Does NOT measure access latency in nanoseconds. Only wall-clock timing or PMU counters (where available) can quantify latency.

---

### C. Multi-Chain Interleaved Traversal (`chains`)
- **Assembly Location:** Function `_ZL13chains_kernelRKSt6vectorImSaImEEmm`, lines 28–235 in `results/memory_lab.s`.
- **Timed Traversal Loop (`.L13` / `.L14`):**
  ```assembly
  .L13:
      mov      rax, r13
  .L14:
      mov      rdx, QWORD PTR [rax]
      add      rax, 8
      mov      rdx, QWORD PTR [rsi+rdx*8]
      mov      QWORD PTR -8[rax], rdx
      cmp      rcx, rax
      jne      .L14
      add      rdi, 1
      cmp      r14, rdi
      jne      .L13
  ```
- **Instruction-Level Findings (What the assembly establishes):**
  - **Interleaved Independent Pointer Dereferences:** Outer loop `.L13` counts steps (`rdi` up to `r14` = `work`). Inner loop `.L14` steps through the chain state pointer array `p` (length `chain_count`). For each chain, it reads `p[c]`, loads `next[p[c]]`, and stores back to `p[c]`.
  - **Independence Across Chains:** Within a step, chain $c+1$ does not depend on chain $c$. Their load addresses are independent.
  - **Memory-Level Parallelism (MLP) Opportunity:** The out-of-order execution engine can inspect subsequent iterations of `.L14` and issue loads for multiple chains concurrently, up to hardware load queue and MSHR limits.
  - **Internal Allocation Detail:** `vector<size_t> p(chain_count)` is allocated (`operator new`, line 60) and deallocated (`operator delete`, line 219) inside `chains_kernel` on each execution. For large step counts (e.g. 2,000,000 steps), this overhead is negligible, but it is technically within the timed region of `kernel()`.
- **Hardware Caveats (What the assembly DOES NOT establish):**
  - Does NOT guarantee that the hardware executes all chains in parallel. Hardware queuing, cache miss buffers, and TLB capacity determine actual concurrent in-flight requests.
  - Does NOT prove DRAM saturation or measure memory-controller contention.

---

## 3. Comparison Matrix: Instruction Evidence vs. Hardware Claims

| Kernel | Instruction Evidence (Observed in Assembly) | What Assembly Proves | What Assembly Cannot Prove (Requires Measurement) |
|---|---|---|---|
| **`stream`** | AVX2 256-bit SIMD (`vpaddq ymm0, ymm0, [rax]`), linear +32 byte stride. | Contiguous sequential load pattern; independent address calculations; absence of dependencies between loads. | Whether data hits L1, L2, L3, or DRAM; effective DRAM bandwidth; prefetcher hit rates. |
| **`chase`** | Single scalar loop (`mov rbx, [rdx+rbx*8]`), strict self-dependency. | Serial execution constraint; zero instruction-level memory parallelism; addresses cannot be known in advance. | Latency in nanoseconds; whether accesses hit cache or RAM; cycle-by-cycle pipeline stalls. |
| **`chains`** | Interleaved loops over `chain_count` pointers; independent dereferences across chains. | Independent memory access streams within each step; architectural opportunity for concurrent in-flight loads. | Actual degree of hardware concurrency; cache miss buffer occupancy; DRAM channel utilization. |

---

## 4. Verification Check

All instruction patterns in `results/memory_lab.s` strictly confirm the design and theoretical model documented in the field guide:
- `stream` enables SIMD throughput and prefetching.
- `chase` enforces serial dependent latency.
- `chains` provides independent chains for latency hiding.
