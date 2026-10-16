# The CPU Isn't Slow. It's Waiting for Memory.
## Experimental field guide for a Medium article

**Environment:** Windows host + WSL2 (Linux), C++ first  
**Target hardware:** Intel Core i7-14650HX, DDR5-5600 system memory (verify actual configuration)  
**Purpose:** Run a small, reproducible investigation into memory-access patterns, latency hiding, and the limits of memory-level parallelism.

> This is an experiment plan, not a promise about the results. Record what happens, including confusing or negative results. Do not write the conclusion before measuring.

---

## 0. Research question and guardrails

### Main question

How do access pattern, working-set size, and independent memory operations affect the performance observed by a program on one modern CPU?

### Questions the experiments can answer

1. How does throughput change when a workload's working set grows?
2. How different are sequential streaming and dependent pointer chasing?
3. Can multiple independent pointer chains improve aggregate throughput?
4. When do additional independent chains stop helping?
5. Can measured behaviour be explained by cache residency, prefetching, memory-level parallelism, bandwidth, or other limits?

### What this investigation cannot automatically prove

- A cache miss is not necessarily a DRAM access.
- A slow program is not automatically “waiting for RAM.”
- A working-set transition does not identify a cache boundary by itself.
- WSL2 results are not identical to bare-metal Linux results. Virtualization, host scheduling, power management, and available performance counters can affect measurements.
- DDR5-5600 is a transfer-rate rating, not a promise of a particular load-to-use latency.
- Results from one laptop do not generalize to all CPUs.

### Experimental discipline

- Run on AC power and use the same Windows power mode for a session.
- Close heavy background workloads; note any exceptions.
- Keep the WSL distribution and benchmark files on the Linux filesystem (for example, `~/memory-wall`), not `/mnt/c`, to avoid filesystem overhead affecting builds and file I/O.
- Do not run benchmarks while the laptop is thermally saturated from another workload.
- Use optimized builds for performance measurements.
- Run each case multiple times; report medians and spread, not only the best result.
- Change one variable at a time.
- Record compiler version, flags, kernel, WSL version, CPU details, RAM configuration if known, and date.
- Do not compare results from different environments without clearly labelling them.

---

# 1. WSL2 environment setup

Commands below assume Ubuntu or a Debian-based WSL distribution.

## 1.1 Check the environment

In PowerShell:

```powershell
wsl --status
wsl --version
wsl -l -v
```

Inside WSL:

```bash
uname -a
cat /etc/os-release
lscpu
free -h
grep -m1 "model name" /proc/cpuinfo
nproc
```

Keep these outputs in the experiment log. WSL may expose a virtualized view of some hardware details.

From Windows PowerShell, you can also inspect host details:

```powershell
Get-CimInstance Win32_Processor |
  Select-Object Name, NumberOfCores, NumberOfLogicalProcessors

Get-CimInstance Win32_PhysicalMemory |
  Select-Object Manufacturer, Capacity, Speed, ConfiguredClockSpeed
```

Windows reporting and memory configuration vary by system. Record the results rather than assuming the advertised speed is the currently configured speed.

## 1.2 Install tools

```bash
sudo apt update
sudo apt install -y build-essential cmake git time python3 python3-pip \
  linux-tools-common linux-tools-generic
```

On some WSL kernels, a version-specific `linux-tools-$(uname -r)` package may not exist. That is okay; continue with the core experiments and check `perf` separately.

Verify:

```bash
g++ --version
cmake --version
python3 --version
perf --version
```

If `perf` reports that hardware counters are unavailable or permission is denied, do not treat this as a blocker. The main experiments can use wall-clock timing. Counter access depends on the kernel, WSL configuration, permissions, and host support. Do not assume that changing `perf_event_paranoid` will make unsupported counters available.

## 1.3 Create the workspace

```bash
mkdir -p ~/memory-wall/{src,results,notes}
cd ~/memory-wall
```

Save the C++ program in `src/memory_lab.cpp`.

---

# 2. Build the benchmark harness

This single program supports four experiments:

- `stream`: sequential traversal over a working set.
- `random`: randomized independent accesses.
- `chase`: one dependent pointer chain.
- `chains`: multiple independent dependent chains.

It emits CSV rows to standard output. Each case performs a warm-up, then several timed repetitions. Use the output to make plots later.

## 2.1 Code: `src/memory_lab.cpp`

```cpp
#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

using Clock = std::chrono::steady_clock;
using u64 = std::uint64_t;
static volatile u64 result_sink = 0;

static std::size_t parse_positive(const char* s) {
    std::size_t used = 0;
    const std::string value(s);
    const auto parsed = std::stoull(value, &used);
    if (used != value.size() || parsed == 0)
        throw std::runtime_error("Expected a positive integer: " + value);
    return static_cast<std::size_t>(parsed);
}

static std::vector<u64> make_data(std::size_t n) {
    std::vector<u64> data(n);
    for (std::size_t i = 0; i < n; ++i)
        data[i] = static_cast<u64>(i) * 0x9e3779b97f4a7c15ULL + 1;
    return data;
}

static void make_cycle(std::vector<std::size_t>& next,
                       std::size_t begin, std::size_t length, u64 seed) {
    std::vector<std::size_t> order(length);
    std::iota(order.begin(), order.end(), begin);
    std::mt19937_64 rng(seed);
    std::shuffle(order.begin(), order.end(), rng);
    for (std::size_t i = 0; i < length; ++i)
        next[order[i]] = order[(i + 1) % length];
}

static u64 stream_kernel(const std::vector<u64>& data, std::size_t passes) {
    u64 sum = 0;
    for (std::size_t p = 0; p < passes; ++p)
        for (std::size_t i = 0; i < data.size(); ++i)
            sum += data[i];
    return sum;
}

static u64 random_kernel(const std::vector<u64>& data,
                         const std::vector<std::size_t>& order,
                         std::size_t accesses) {
    u64 sum = 0;
    for (std::size_t i = 0; i < accesses; ++i)
        sum += data[order[i % order.size()]];
    return sum;
}

static u64 chase_kernel(const std::vector<std::size_t>& next,
                        std::size_t accesses) {
    std::size_t p = 0;
    for (std::size_t i = 0; i < accesses; ++i)
        p = next[p];
    return static_cast<u64>(p);
}

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

int main(int argc, char** argv) {
    try {
        if (argc < 5) {
            std::cerr << "Usage: " << argv[0]
                      << " MODE ELEMENTS WORK_COUNT REPEATS [CHAINS] [SEED]"
                      << std::endl
                      << "MODE: stream | random | chase | chains" << std::endl
                      << "ELEMENTS: uint64_t elements / pointer nodes" << std::endl
                      << "WORK_COUNT: stream passes; otherwise accesses or steps per chain"
                      << std::endl
                      << "REPEATS: timed repetitions" << std::endl
                      << "CHAINS: chains mode only; default 1" << std::endl
                      << "SEED: optional deterministic seed; default 12345"
                      << std::endl;
            return 2;
        }

        const std::string mode = argv[1];
        const std::size_t n = parse_positive(argv[2]);
        const std::size_t work = parse_positive(argv[3]);
        const std::size_t repeats = parse_positive(argv[4]);
        const std::size_t chains = (argc >= 6) ? parse_positive(argv[5]) : 1;
        const u64 seed = (argc >= 7)
            ? static_cast<u64>(parse_positive(argv[6])) : 12345ULL;

        if (n > static_cast<std::size_t>(-1) / sizeof(u64))
            throw std::runtime_error("Working-set byte count would overflow");
        if (mode == "chains" && (chains > n || n % chains != 0))
            throw std::runtime_error(
                "For chains mode, CHAINS must divide ELEMENTS and be <= ELEMENTS");

        // Setup is outside the timed region.
        std::vector<u64> data;
        std::vector<std::size_t> order;
        std::vector<std::size_t> next;

        if (mode == "stream" || mode == "random")
            data = make_data(n);

        if (mode == "random") {
            order.resize(n);
            std::iota(order.begin(), order.end(), 0);
            std::mt19937_64 rng(seed);
            std::shuffle(order.begin(), order.end(), rng);
        }

        if (mode == "chase") {
            next.resize(n);
            make_cycle(next, 0, n, seed);
        }

        if (mode == "chains") {
            next.resize(n);
            const std::size_t segment = n / chains;
            for (std::size_t c = 0; c < chains; ++c)
                make_cycle(next, c * segment, segment, seed + c);
        }

        auto kernel = [&]() -> u64 {
            if (mode == "stream") return stream_kernel(data, work);
            if (mode == "random") return random_kernel(data, order, work);
            if (mode == "chase") return chase_kernel(next, work);
            if (mode == "chains") return chains_kernel(next, chains, work);
            throw std::runtime_error("Unknown mode: " + mode);
        };

        // Warm-up makes this a repeated-use measurement, not a cold-start test.
        result_sink = kernel();

        std::cout << "mode,elements,working_set_bytes,work_count,chains,repeat,"
                     "seconds,operations,ns_per_operation,nominal_bytes,checksum"
                  << std::endl;

        for (std::size_t rep = 0; rep < repeats; ++rep) {
            const auto start = Clock::now();
            const u64 checksum = kernel();
            const double elapsed =
                std::chrono::duration<double>(Clock::now() - start).count();
            result_sink = checksum;

            double operations = 0.0;
            double nominal_bytes = 0.0;
            if (mode == "stream") {
                operations = static_cast<double>(n) * work;
                nominal_bytes = operations * sizeof(u64);
            } else if (mode == "random") {
                operations = static_cast<double>(work);
                nominal_bytes = operations * sizeof(u64);
            } else if (mode == "chase") {
                operations = static_cast<double>(work);
                nominal_bytes = operations * sizeof(std::size_t);
            } else {
                operations = static_cast<double>(work) * chains;
                nominal_bytes = operations * sizeof(std::size_t);
            }

            const double ns_per_op =
                elapsed * 1e9 / std::max(operations, 1.0);
            std::cout << mode << ',' << n << ',' << n * sizeof(u64) << ','
                      << work << ',' << ((mode == "chains") ? chains : 1)
                      << ',' << rep << ',' << std::setprecision(10) << elapsed
                      << ',' << operations << ',' << ns_per_op << ','
                      << nominal_bytes << ',' << checksum << std::endl;
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}
```

### Benchmark design notes

- Allocation, initialization, and index/cycle construction occur before the timed region.
- The `random` mode cycles through a pre-shuffled index order; its index table is created outside timing.
- The `chase` mode follows one shuffled dependent cycle.
- The `chains` mode gives each chain a separate segment and cycle, then interleaves dependent loads. This is a simplified way to test independent chains, not a guarantee of optimal instruction scheduling.
- A warm-up is performed before the timed repetitions. Results therefore represent repeated-use behaviour, not a cold-start measurement.
- The reported nominal bytes count source-level load traffic, not measured DRAM traffic. Cache hits, line fills, writebacks, and prefetching mean actual memory traffic can differ.
- This is a research harness, not a fully peer-reviewed benchmark suite. Inspect assembly and validate surprising results before making claims.
## 2.2 Compile

```bash
cd ~/memory-wall
g++ -O3 -DNDEBUG -march=native -std=c++20 -Wall -Wextra \
  src/memory_lab.cpp -o memory_lab
```

`-march=native` tunes code for the CPU features visible to the compiler in WSL. For comparisons across machines, use a documented portable target instead. Do not mix binaries built with different flags in one comparison.

Quick smoke test:

```bash
./memory_lab chase 32768 2000000 5
./memory_lab chains 32768 2000000 5 4
```

These commands test that the program runs; they are not yet publication-quality measurements.

---

# 3. Validate the harness before trusting it

The provided harness keeps allocation, initialization, and shuffle/cycle construction outside the timed region. It is still necessary to verify that the compiled code performs the intended work.

## 3.1 Compile and run smoke tests

```bash
cd ~/memory-wall
g++ -O3 -DNDEBUG -march=native -std=c++20 -Wall -Wextra \
  src/memory_lab.cpp -o memory_lab

./memory_lab stream 1048576 20 5
./memory_lab random 1048576 10000000 5
./memory_lab chase 1048576 10000000 5
./memory_lab chains 1048576 1000000 5 4
```

These are functional checks, not final measurements. `ELEMENTS` means 64-bit elements for `stream`/`random`, and pointer/index nodes for `chase`/`chains`.

For `chains`, `ELEMENTS` must be divisible by the number of chains. The code gives each chain a separate cycle in its own segment.

## 3.2 Inspect compiler output

```bash
g++ -O3 -DNDEBUG -march=native -std=c++20 \
  -S -masm=intel src/memory_lab.cpp -o results/memory_lab.s

objdump -d -C ./memory_lab | less
```

Questions to ask:

- Does the compiler vectorize the sequential loop?
- Does each pointer-chase load still depend on the preceding load?
- Are there unexpected function calls in the timed kernel?
- Does the generated code differ between builds or compiler versions?

The checksum makes the result observable, but it does not guarantee that the compiled kernel has exactly the structure intended.

## 3.3 Choose work counts

Aim for each timed repetition to last long enough that timer overhead is negligible. Start with the sample counts, inspect elapsed time, then increase or decrease `WORK_COUNT` to get stable measurements without excessively long runs.

The `stream` mode's work count is the number of passes. For other modes it is the number of accesses, or steps per chain. For `chains`, total dependent loads equal `WORK_COUNT × CHAINS`.

## 3.4 Be careful interpreting bytes

The CSV field `nominal_bytes` is a count based on source-level operations. It is not a hardware measurement of DRAM traffic. For a bandwidth claim, report it as nominal/effective throughput and explain the assumption. If reliable memory-controller counters are unavailable in WSL2, do not describe this as directly measured DRAM bandwidth.
# 4. Experiment 1: Working-set size sweep

## Question

How does performance change as the working set grows from small to larger than the CPU's cache hierarchy?

## Method

Once the harness is refactored so setup is outside the timed region, run the same kernel at a range of working-set sizes.

Example target sizes:

```text
16 KiB, 32 KiB, 64 KiB, 128 KiB, 256 KiB,
512 KiB, 1 MiB, 2 MiB, 4 MiB, 8 MiB,
16 MiB, 32 MiB, 64 MiB, 128 MiB
```

Use element counts derived from the size, for `uint64_t` elements:

```text
elements = working_set_bytes / 8
```

Do not assume these sizes correspond exactly to particular cache boundaries. Use your machine's documented cache capacities and measured evidence to interpret them.

## Measurements

- Median nanoseconds per operation.
- Throughput, where meaningful.
- Variation between repetitions.
- Optional cache-miss and cycle counters if available.

## Possible findings to look for

- A relatively stable region for small working sets.
- One or more performance changes as the working set grows.
- A gradual decline rather than a sharp boundary.
- No clear transition, perhaps because the chosen kernel or access pattern masks it.

## Interpretation guardrail

A transition near a known cache capacity is a clue, not proof. Associativity, prefetching, TLB behavior, other active processes, and cache sharing can all influence the curve.

## Plot

Plot working-set size on a logarithmic x-axis against median time per operation or throughput. Annotate documented cache capacities, but label them as reference points, not proven transition locations.

---

# 5. Experiment 2: Sequential streaming versus dependent pointer chasing

## Question

Why can a CPU move data at high throughput in one workload but show much higher time per access in another?

## Method A: Sequential streaming

Traverse a preallocated array repeatedly. The measured kernel must exclude allocation and initialization.

Calculate effective read throughput:

```text
bytes_read = element_count × sizeof(element) × number_of_passes
throughput = bytes_read / elapsed_seconds
```

Be precise about what is counted. This is nominal bytes read by the kernel, not necessarily exact DRAM traffic; caches and hardware behavior can change actual memory traffic.

## Method B: Dependent pointer chasing

Create a single cycle of shuffled indexes before timing. Start from one index and follow the next pointer repeatedly.

Each next address depends on the previous result, restricting memory-level parallelism.

Use enough nodes that the working set is larger than the cache level you want to investigate. Compare several sizes.

Calculate:

```text
ns_per_dependent_step = elapsed_seconds × 1e9 / steps
```

This is an average dependent-step cost for that workload, not a universal RAM latency number.

## Possible findings to look for

- Streaming may achieve high throughput because of prefetching, cache-line utilization, and overlapping requests.
- Dependent pointer chasing may have much lower throughput because the next address cannot be known early.
- Small pointer-chase working sets may be served largely by cache and behave differently from large ones.
- The gap may vary with working-set size and implementation details.

## Plot

Use two related plots rather than forcing unlike metrics onto one axis:

1. Streaming throughput versus working-set size.
2. Dependent-chain nanoseconds per step versus working-set size.

This experiment is likely to provide the clearest visual explanation of why bandwidth and latency are different properties.

---

# 6. Experiment 3: Independent chains and latency hiding

## Question

Can the CPU make better progress when multiple independent memory chains are available?

## Method

Implement multiple independent pointer chains. For a controlled version, each chain should have a separate starting point and should traverse its own cycle over a defined region. Keep total memory footprint and total dependent loads accounted for when comparing cases.

Sweep the number of chains:

```text
1, 2, 4, 8, 16
```

Adjust the values to fit the workload and available resources. Do not assume the best count in advance.

For each count:

- Use the same total working-set size where possible.
- Keep total loads comparable.
- Time only the traversal.
- Report aggregate loads per second and average time per load.
- Repeat measurements.

A subtlety: average time per load across interleaved chains is not the same as single-chain load-to-use latency. The goal here is aggregate throughput and the effect of independent work.

## Possible findings to look for

- Aggregate throughput may increase as more independent chains allow more overlap.
- Gains may flatten when another resource becomes limiting.
- The best chain count may depend on working-set size.
- Too many chains may increase overhead or cache/TLB pressure.
- No improvement may mean the kernel, compiler, or environment is not exposing the intended parallelism.

## Plot

Plot independent chain count against aggregate loads per second. Add a second plot of median time per load, clearly labelled as an aggregate metric.

## Interpretation guardrail

A plateau does not uniquely identify a hardware limit. Use assembly inspection and, where available, performance counters to support any explanation.

---

# 7. Experiment 4: Random access as a separate investigation

## Question

How does unpredictable independent access behave compared with sequential access and dependent access?

## Method

Use a prebuilt shuffled index array and preallocated data. Do not generate random numbers or shuffle indexes inside the timed region.

Be clear that random indexed loads can be independent, unlike a single dependent pointer chain. The processor may overlap several independent loads, and the hardware may still exploit some locality.

Run multiple working-set sizes and fixed random seeds for reproducibility. If you test different seeds, record them.

## Possible findings to look for

- Random access may be less friendly to prefetching than sequential access.
- It may still outperform a dependent chain if multiple loads can overlap.
- Performance may deteriorate when the working set exceeds effective cache capacity.
- TLB effects may appear for large or sparsely accessed working sets.

Do not assume every random workload is slower. The result depends on access count, locality, data structure, cache residency, and memory-level parallelism.

---

# 8. Optional Experiment 5: A software change that improves locality

Only attempt this after the earlier experiments produce stable, interpretable results.

## Question

Can changing the memory-access order improve performance without changing the mathematical result?

A classic example is matrix traversal or matrix multiplication. Compare an access pattern with poor locality against one that reuses cache-resident blocks.

For matrix multiplication, compare:

- A simple baseline.
- A blocked/tiled implementation.

Ensure both implementations compute the same result, use the same numeric type, and are compiled with documented flags. Verify correctness before comparing timing.

## Possible findings to look for

- Tiling may improve cache reuse and reduce unnecessary data movement.
- The benefit may depend on matrix size and tile size.
- Compiler vectorization and instruction scheduling may affect results.
- A larger tile is not always better.

This experiment extends the investigation from observing a memory effect to testing a software technique that responds to it.

---

# 9. Optional hardware counters with `perf`

First check whether the environment permits access:

```bash
perf stat -e cycles,instructions,cache-references,cache-misses \
  ./memory_lab chase 1048576 10000000 5
```

The example is only a smoke test for counter availability. Because the current prototype includes setup in timed regions for some modes, do not use it to make final claims.

If generic events are supported, use them to gather supporting evidence. If they are unavailable under WSL2, record that limitation and proceed with timing-based measurements. Do not silently switch to Windows measurements and mix them with WSL results.

Counter names and semantics vary by kernel and CPU. Generic cache events may not correspond to a simple count of DRAM accesses. Use Intel documentation and the `perf` documentation to understand the events exposed by your system.

---

# 10. Rust comparison: optional, not part of the first baseline

Do not introduce Rust until the C++ experiments are repeatable.

If you later compare Rust and C++:

- Implement equivalent algorithms.
- Match working-set sizes and data layout.
- Use optimized release builds.
- Keep setup outside timed regions in both implementations.
- Inspect generated assembly.
- Compare repeated measurements and their spread.
- Avoid claiming one language is faster based on one run.

The comparison should investigate implementation and compiler output, not turn the article into a simplistic language contest.

---

# 11. Results collection and analysis

For every run, preserve raw CSV output and record metadata in `notes/run-log.md`.

Suggested run log:

```markdown
## Run: YYYY-MM-DD HH:MM

- Git commit:
- WSL distro:
- Kernel:
- Compiler:
- Compiler flags:
- CPU reported inside WSL:
- Host power mode:
- Working-set size:
- Access pattern:
- Number of chains:
- Repetitions:
- Background activity:
- Perf counters available:
- Observations:
- Questions raised:
```

## Minimum analysis checklist

- [ ] Use a corrected benchmark where setup is outside the timed region.
- [ ] Keep raw data unchanged.
- [ ] Report median and a measure of spread.
- [ ] Use the same compiler flags across comparable cases.
- [ ] Verify checksums/correctness.
- [ ] Inspect representative assembly.
- [ ] Label throughput and latency separately.
- [ ] Record the WSL2 environment and its limitations.
- [ ] Do not omit results that contradict the hypothesis.
- [ ] Repeat surprising findings before interpreting them.

A small Python script can read the CSV with pandas and produce plots, but don't plot prototype results as final evidence.

---

# 12. Troubleshooting

## Results vary wildly

- Close background workloads.
- Increase the work per timed repetition.
- Run multiple trials and report spread.
- Check whether the laptop is thermally or power constrained.
- Avoid running multiple benchmark instances simultaneously.

## Every working-set size looks similar

Possible reasons include:
- The access pattern is being optimized or prefetched.
- The working set is not crossing the expected hierarchy.
- The timing kernel includes unrelated overhead.
- The data set or measurement duration is too small.
- WSL2 or host conditions add noise.

Check assembly and improve the harness before drawing conclusions.

## `perf` does not work

This can happen because of WSL kernel support, permissions, or unavailable hardware events. Continue with timing measurements and state the limitation explicitly. Do not claim counter-based evidence you did not obtain.

## The compiler removes or transforms the workload

Inspect assembly, use observable results/checksums, and make sure the benchmark's result depends on the loads you intend to measure. Avoid adding `volatile` to every data access as a blanket fix; it can change the workload and prevent normal optimizations.

## The laptop gets hot or clocks change

Use consistent power conditions, allow the machine to cool between long runs, and record the conditions. Do not treat thermal or power-management differences as memory-hierarchy effects.

---

# 13. Article structure: let results decide the narrative

Working title:

**I Tried to Make My CPU Wait for Memory. Here's What I Found.**

Possible narrative sequence:

1. **The contradiction:** A fast laptop can still run memory-sensitive workloads poorly.
2. **First observation:** Working-set size and access pattern change performance.
3. **Second question:** Why do sequential and dependent accesses behave differently?
4. **Third question:** Can independent memory operations hide some latency?
5. **The limit:** Where do gains flatten, and what evidence supports the explanation?
6. **Optional application:** Can a locality-aware software implementation improve performance?
7. **Conclusion:** What the experiments show, what they do not show, and what remains uncertain.

Do not promise that every experiment will produce a dramatic result. A flat curve or inconclusive counter set is still useful if the measurement is valid and the limitation is explained.

---

# 14. Reference material to consult

Use primary documentation for implementation and interpretation:

- Intel product specifications for the Core i7-14650HX and its documented cache/memory characteristics.
- Intel optimization manuals for cache behavior, memory access, and performance analysis.
- Linux `perf` documentation for counter access and event interpretation.
- GCC documentation for optimization options and target-specific compilation.
- WSL documentation for kernel and performance-tool limitations.

Treat hardware specifications as context, not as evidence that a particular benchmark has reached a specific cache or DRAM limit.

---

## Final principle

The objective is not to prove that “the CPU is waiting for memory.”

The objective is to measure how access patterns and available parallelism change observed performance, then use the strongest evidence available to explain the result.

**Run the experiment first. Write the claim second.**
