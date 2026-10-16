# Mandatory Preflight — Run Before Any Build, Benchmark, Install, or Modification

## Rule
This workflow is mandatory at the beginning of a new campaign and before every materially different operation. Initial preflight is read-only. Do not compile or run `memory_lab` during initial preflight.

## Stage A — Read instructions and specification
1. Read root `AGENT.md`.
2. Read every file in `.agent/rules/`.
3. Read the complete `.agent/references/cpu_memory_experiments_field_guide.md`.
4. Read the relevant workflow before using it.
5. Inspect `src/memory_lab.cpp` directly. Determine the real CLI, modes, argument parsing, output columns, setup/warmup/timing boundaries, and whether output paths are hard-coded or supplied by arguments. Cite exact source locations in the session log. Do not infer them from memory or old chat.

## Stage B — Read-only workspace inventory
Capture working directory, directory tree, Git status (if Git exists), file sizes and timestamps, and hashes of relevant source/spec files. Do not print secrets or dump unrelated environment variables. Do not move, delete, or overwrite anything. Distinguish existing artifacts from fresh campaign records.

## Stage C — Read-only environment checks
Use the smallest available read-only commands to record:
- date/time and timezone;
- `uname -a`, `/etc/os-release`, whether WSL is detected;
- CPU/topology (`lscpu`, `/proc/cpuinfo` where available);
- memory summary (`free -h` where available);
- compiler and version (`g++ --version`), build tools (`cmake --version`, `make --version`) only if installed;
- benchmark executable metadata if it exists, without running it;
- `perf` executable and exposed event sources, without assuming hardware counters work;
- source/build configuration and Git revision/status if available.

Do not install missing tools. Record “not installed”, “not exposed”, or “unknown” instead. Avoid privileged commands unless approved.

## Stage D — Capture and report
For each check, record exact command, purpose, timestamp/timezone, working directory, stdout, stderr, and exit status. Preserve raw output in a unique file under `lab-notebook/raw/`; never reuse a filename. If the logging mechanism cannot capture an exit code or stderr, state that limitation rather than fabricate it.

Create/update the environment baseline and session log without overwriting previous records. If a target file already exists, create a new uniquely named file or ask before changing it.

## Stage E — Human approval gate
Present a concise report with confirmed facts, unknowns, any conflicting evidence, and one proposed next step. Stop. Do not build, run benchmark modes, generate assembly, install packages, change system settings, or clean the repository until the user explicitly approves the named operation.

## Per-operation mini-preflight
Before any later build or benchmark, repeat the relevant checks: source/CLI validation, command review, fixed vs changed variables, output destination/overwrite check, expected runtime, logging destination, and user approval when the operation changes files or consumes significant resources.
