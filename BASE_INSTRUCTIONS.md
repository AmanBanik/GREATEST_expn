# Antigravity CPU Memory Lab Agent Pack — Fresh Start

This version is designed for a **clean, prospective start**. It contains no imported chat notes, old experiment outputs, or historical reconstruction workflow. It will establish a baseline and record work from the point the toolkit is installed.

See [`RESEARCH-INDEX.md`](RESEARCH-INDEX.md) for master campaign navigation, verified empirical findings, reproduction commands, and publication figure links. For the public research project overview, see [`README.md`](README.md).

## Install
1. Back up anything you care about. Do not delete the existing project source.
2. Copy `.agent/` and `lab-notebook/` into the root of the existing `memory-wall` project. Merge carefully if either directory already exists.
3. Open the project in Antigravity.
4. Ask it to read `.agent/rules/` and execute `.agent/workflows/fresh-start.md`.
5. Review the proposed baseline and approve each build or experiment before it runs.

## Important distinction
The pack can log commands and tool actions Antigravity actually executes and can save. It cannot automatically observe every command you type in a separate terminal unless that output is captured or the action is run through the agent. For full logging, ask Antigravity to execute each command or capture the command and its complete stdout/stderr into `lab-notebook/raw/`.

## Safety
The workflow is non-destructive by default. It must not delete results, reset Git, overwrite artifacts, install packages, or launch long-running experiments without explicit approval.


## Mandatory safeguards (updated)

- Read `AGENT.md` first; it is the top-level operating contract.
- The full `cpu_memory_experiments_field_guide.md` is bundled at `.agent/references/cpu_memory_experiments_field_guide.md`.
- Run `.agent/workflows/preflight-before-anything.md` before any build, benchmark, install, or modification. Initial checks are read-only.
- `.agent/scripts/preflight_readonly.sh` is an optional read-only environment helper. It does not run the benchmark and does not automatically save its output.
- The agent must inspect the actual C++ source before using or inventing any command-line options. No code edits or benchmark execution without user approval.
