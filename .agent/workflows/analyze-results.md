# Analyze Results and Prepare Charts

1. Identify the raw files and confirm they are unmodified.
2. Parse with a script that is itself saved in the repository. Record the script path and version/commit.
3. Validate columns, row count, units, checksums, operation counts, and missing values.
4. Summarize per experiment and per working-set size: sample count, median, min/max, and a spread metric (IQR or standard deviation; state which).
5. Preserve raw measurements; create derived files under `results/derived/` and plots under `results/plots/`.
6. Label axes with units, identify the metric, and state what each point summarizes. Do not use a smooth curve to imply precision not supported by data.
7. Do not label a region as a specific cache or DRAM boundary based on timing alone. Use cautious language such as “a change in observed timing around this working-set range.”
8. Explain limitations: WSL2 scheduling/virtualization, missing hardware counters if still unavailable, compiler behavior, cache/TLB effects, prefetching, and background load where relevant.
9. Add an analysis note linking every chart to the exact raw input files and analysis script.
