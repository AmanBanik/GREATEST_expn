# AGENT.md — CPU Memory Lab: Authoritative Operating Contract

This file is the top-level project instruction. Read it before any action, then read `.agent/rules/`, `.agent/GIT_WORKFLOW.md`, and the relevant workflow. The full experimental specification is `.agent/references/cpu_memory_experiments_field_guide.md`; master navigation is at `RESEARCH-INDEX.md`; preserve all caveats and terminology.

## Non-negotiable order of operations
1. **Preflight before action.** First inspect project tree, current working directory, OS/kernel/WSL context, source files, build artifacts, Git status, available tools, and existing notebook state. Use read-only commands only. Capture outputs and exit statuses.
2. **Report before changing anything.** Summarize findings, unknowns, risks, and proposed next action. Do not install packages, compile, execute the benchmark, change system settings, delete/move files, overwrite outputs, or run long commands until the user approves the specific action.
3. **Follow the source of truth.** Read the full field guide and inspect the actual `src/memory_lab.cpp` before suggesting code or commands. Never invent source functions, CLI arguments, file paths, output columns, or expected results. If a detail is not supported by the source or captured output, label it unknown and ask or inspect.
4. **No unsolicited code changes.** Do not create, rewrite, optimize, or replace benchmark code unless the user explicitly asks and approves a concrete plan. Prefer the existing code and exact CLI it actually implements.
5. **Pre-check every experiment.** Before each build/run, verify command against source and field guide; record purpose, hypothesis, independent/dependent variables, controls, expected duration, target paths, and overwrite risk. Ask for approval before executing.
6. **Reproducible logging.** Record timestamp with timezone, exact command, working directory, environment/build identity, stdout, stderr, exit code, artifact paths and hashes where relevant. Preserve raw output unchanged. Every run gets a unique ID; never silently overwrite logs.
7. **Separate evidence classes.** Label statements as observed, calculated, interpretation, hypothesis, or unknown. Never invent measurements or claim a cache level/DRAM traffic solely from timing.
8. **Protect the workspace.** Never use destructive commands (`rm`, `git clean/reset`, overwriting redirection, package installation, permission changes) without explicit approval. Do not run a command whose effects you cannot explain.
9. **One step at a time.** Explain the next command in plain language before asking the user to run it. Avoid dumping a large command sequence when one check will do.
10. **Writing comes later.** Do not draft the Medium article until the user explicitly asks. Preserve first-person storytelling as a later evidence-led goal, not as a reason to exaggerate findings.

## Required initial response
When the project opens, do not immediately build or benchmark. Read the field guide, read `.agent/rules/`, inspect the workspace read-only, and run the preflight workflow. Then report: (a) confirmed environment, (b) files found, (c) exact source-supported CLI/interface, (d) available/unavailable profiling capabilities, (e) risks/unknowns, (f) the single safest next action. Wait for approval.
